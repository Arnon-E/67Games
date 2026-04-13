import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../engine/types.dart';

/// Service for managing 1v1 matchmaking and match lifecycle via Firestore.
///
/// Match lifecycle:
/// 1. Player joins queue → creates a doc in `matchmaking_queue/{uid}`
/// 2. If an existing queue entry from another user exists, a match is created
///    in `matches/{matchId}` with both players, and both queue entries removed.
/// 3. Both clients listen to `matches/{matchId}` for state changes.
/// 4. Match goes through: waiting → countdown → playing → finished.
/// 5. Each player submits their result; when both are in, match is complete.
class MatchmakingService {
  static const _matchStaleDuration = Duration(minutes: 2);
  static const _activeAttachMaxAge = Duration(seconds: 30);
  static const _heartbeatTimeout = Duration(seconds: 30);

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  StreamSubscription<DocumentSnapshot>? _matchSub;
  StreamSubscription<QuerySnapshot>? _queueSub;

  // ── Queue ───────────────────────────────────────────────────

  /// Join the matchmaking queue. If another player is already waiting,
  /// creates a match immediately. Returns the match ID (or null if queued).
  Future<String?> joinQueue({
    required String uid,
    required String displayName,
    required String modeId,
    required int targetMs,
    String? wrestlerSkin,
    String? preferOpponentUid,
    bool acceptSpeedUp = false,
    int rematchRound = 1,
  }) async {
    final queueRef = _db.collection('matchmaking_queue');

    // Use a transaction to atomically claim an opponent from the queue.
    // This prevents two players from matching with the same opponent.
    final matchId = await _db.runTransaction<String?>((tx) async {
      // Find a waiting opponent.
      // Use limit(2) + client-side self-filter instead of isNotEqualTo to
      // avoid requiring a composite Firestore index on (modeId, uid).
      // Queue entries use the player's uid as document ID, so filtering by
      // doc ID is equivalent and works with single-field indexes only.
      QueryDocumentSnapshot? opponentDoc;

      if (preferOpponentUid != null) {
        // Rematch: try the specific preferred opponent first.
        final preferred = await queueRef
            .where('modeId', isEqualTo: modeId)
            .where('uid', isEqualTo: preferOpponentUid)
            .limit(1)
            .get();
        if (preferred.docs.isNotEmpty) {
          opponentDoc = preferred.docs.first;
        }
      }

      if (opponentDoc == null) {
        // General match: fetch up to 2 entries and skip self by document ID.
        final snap = await queueRef
            .where('modeId', isEqualTo: modeId)
            .limit(2)
            .get();
        final others = snap.docs.where((d) => d.id != uid).toList();
        opponentDoc = others.isEmpty ? null : others.first;
      }

      if (opponentDoc != null) {
        // Re-read the opponent doc inside the transaction to guard against
        // concurrent claims.
        final opponentSnap = await tx.get(opponentDoc.reference);
        if (!opponentSnap.exists) return null; // already claimed

        final opponentData = opponentSnap.data()! as Map<String, dynamic>;
        final matchRef = _db.collection('matches').doc();

        final opponentAcceptSpeedUp = opponentData['acceptSpeedUp'] == true;
        final opponentRematchRound =
            (opponentData['rematchRound'] as num?)?.toInt() ?? 1;
        final speedUpRequested = acceptSpeedUp || opponentAcceptSpeedUp;
        final speedUpAgreed = acceptSpeedUp && opponentAcceptSpeedUp;
        final agreedRematchRound = rematchRound < opponentRematchRound
            ? rematchRound
            : opponentRematchRound;
        final speedMultiplier = speedUpAgreed
            ? ((1.0 + (agreedRematchRound - 1) * 0.2).clamp(1.0, 3.0))
                .toDouble()
            : 1.0;

        tx.set(matchRef, {
          'modeId': modeId,
          'targetMs': targetMs,
          'speedMultiplier': speedMultiplier,
          'speedUpRequested': speedUpRequested,
          'speedUpAgreed': speedUpAgreed,
          'status': MatchStatus.countdown.name,
          'playerUids': [opponentData['uid'], uid],
          'player1': {
            'uid': opponentData['uid'],
            'displayName': opponentData['displayName'],
            'acceptSpeedUp': opponentAcceptSpeedUp,
            if (opponentData['wrestlerSkin'] != null)
              'wrestlerSkin': opponentData['wrestlerSkin'],
          },
          'player2': {
            'uid': uid,
            'displayName': displayName,
            'acceptSpeedUp': acceptSpeedUp,
            if (wrestlerSkin != null) 'wrestlerSkin': wrestlerSkin,
          },
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Remove both queue entries
        tx.delete(opponentDoc.reference);
        tx.delete(queueRef.doc(uid));

        return matchRef.id;
      }

      return null; // no opponent found
    });

    if (matchId != null) return matchId;

    // No opponent found — add to queue
    await queueRef.doc(uid).set({
      'uid': uid,
      'displayName': displayName,
      'modeId': modeId,
      'targetMs': targetMs,
      'acceptSpeedUp': acceptSpeedUp,
      'rematchRound': rematchRound,
      if (wrestlerSkin != null) 'wrestlerSkin': wrestlerSkin,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return null; // queued, waiting for opponent
  }

  /// Leave the matchmaking queue (cancel search).
  Future<void> leaveQueue(String uid) async {
    await _db.collection('matchmaking_queue').doc(uid).delete();
    _queueSub?.cancel();
    _queueSub = null;
  }

  /// Listen for when another player picks us from the queue and creates a match.
  /// The callback fires with the match ID once found.
  void listenForMatch({
    required String uid,
    required String modeId,
    required void Function(String matchId) onMatchFound,
  }) {
    _queueSub?.cancel();

    // Only react to matches created recently to avoid picking up old finished/cancelled
    // matches from previous sessions, which would cancel the timeout and prevent the
    // real new match from ever being detected.
    final cutoff = DateTime.now().subtract(_matchStaleDuration);

    // Listen only to matches that include this user — O(1) reads via arrayContains index.
    _queueSub = _db
        .collection('matches')
        .where('playerUids', arrayContains: uid)
        .snapshots()
        .listen((snapshot) {
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String?;
        // Only react to active matches (handles the race where the match is already
        // `playing` by the time the first snapshot arrives).
        if (status != MatchStatus.countdown.name &&
            status != MatchStatus.playing.name) {
          continue;
        }
        // Ignore old abandoned "active" matches from previous sessions.
        // These docs may still be countdown/playing when a player force-kills the app.
        if (_isAbandonedActiveMatch(data)) {
          continue;
        }
        // Ignore matches created before we started searching (old abandoned matches).
        // A null createdAt means the server timestamp hasn't been written yet —
        // that only happens on a brand-new doc, so allow it through.
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        if (createdAt != null && createdAt.isBefore(cutoff)) {
          continue;
        }
        _queueSub?.cancel();
        _queueSub = null;
        onMatchFound(doc.id);
        return;
      }
    });
  }

  bool _isAbandonedActiveMatch(Map<String, dynamic> data) {
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    if (createdAt == null) return false;
    final now = DateTime.now();

    // Fresh matches should always be considered valid attach candidates.
    if (now.difference(createdAt) <= _activeAttachMaxAge) {
      return false;
    }

    final p1Heartbeat = (data['player1Heartbeat'] as dynamic)?.toDate() as DateTime?;
    final p2Heartbeat = (data['player2Heartbeat'] as dynamic)?.toDate() as DateTime?;

    // If no one has heartbeated for a while, this is almost certainly an orphaned doc.
    if (p1Heartbeat == null && p2Heartbeat == null) {
      return true;
    }

    final p1Stale =
        p1Heartbeat == null || now.difference(p1Heartbeat) > _heartbeatTimeout;
    final p2Stale =
        p2Heartbeat == null || now.difference(p2Heartbeat) > _heartbeatTimeout;
    return p1Stale && p2Stale;
  }

  // ── Match lifecycle ────────────────────────────────────────

  /// Listen to real-time updates on a match document.
  Stream<MatchData?> watchMatch(String matchId) {
    return _db.collection('matches').doc(matchId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return MatchData.fromJson(snap.id, snap.data()!);
    });
  }

  /// Transition the match to `playing` status.
  /// Called after the shared countdown completes on the first player to finish.
  Future<void> startMatch(String matchId) async {
    await _db.collection('matches').doc(matchId).update({
      'status': MatchStatus.playing.name,
    });
  }

  /// Write a heartbeat timestamp for this player so the opponent can detect disconnects.
  Future<void> sendHeartbeat({
    required String matchId,
    required bool isPlayer1,
  }) async {
    try {
      final field = isPlayer1 ? 'player1Heartbeat' : 'player2Heartbeat';
      await _db.collection('matches').doc(matchId).update({
        field: FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  /// Submit this player's result to the match.
  /// When both players have submitted, mark the match as finished.
  Future<void> submitResult({
    required String matchId,
    required String uid,
    required int stoppedAtMs,
    required int deviationMs,
    required int score,
  }) async {
    final matchRef = _db.collection('matches').doc(matchId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(matchRef);
      if (!snap.exists) return;

      final data = snap.data()!;
      final p1 = data['player1'] as Map<String, dynamic>;
      final p2 = data['player2'] as Map<String, dynamic>?;

      if (p1['uid'] == uid) {
        tx.update(matchRef, {
          'player1.stoppedAtMs': stoppedAtMs,
          'player1.deviationMs': deviationMs,
          'player1.score': score,
        });
      } else if (p2 != null && p2['uid'] == uid) {
        tx.update(matchRef, {
          'player2.stoppedAtMs': stoppedAtMs,
          'player2.deviationMs': deviationMs,
          'player2.score': score,
        });
      }

      // Check if both players have submitted
      final p1Score = p1['uid'] == uid ? score : (p1['score'] as num?)?.toInt();
      final p2Score = p2 != null
          ? (p2['uid'] == uid ? score : (p2['score'] as num?)?.toInt())
          : null;

      if (p1Score != null && p2Score != null) {
        tx.update(matchRef, {'status': MatchStatus.finished.name});
      }
    });
  }

  /// Cancel a match (e.g., player disconnected before game started).
  Future<void> cancelMatch(String matchId) async {
    try {
      await _db.collection('matches').doc(matchId).update({
        'status': MatchStatus.cancelled.name,
      });
    } catch (_) {
      // Match may already be deleted or cancelled
    }
  }

  /// Delete a finished/cancelled match document from Firestore.
  /// Called by both players when they return to menu — idempotent,
  /// so concurrent deletes are safe.
  Future<void> deleteMatch(String matchId) async {
    try {
      await _db.collection('matches').doc(matchId).delete();
    } catch (_) {}
  }

  /// Reset an existing match document for the next fight round.
  /// Clears player results and sets status back to `countdown` with
  /// the new speed multiplier. Both clients are already watching this
  /// document, so they transition automatically — no queue needed.
  Future<void> resetMatchForNextRound(
      String matchId, double speedMultiplier) async {
    await _db.collection('matches').doc(matchId).update({
      'status': MatchStatus.countdown.name,
      'speedMultiplier': speedMultiplier,
      'speedUpAgreed': speedMultiplier > 1.0,
      'speedUpRequested': speedMultiplier > 1.0,
      'player1.stoppedAtMs': null,
      'player1.deviationMs': null,
      'player1.score': null,
      'player2.stoppedAtMs': null,
      'player2.deviationMs': null,
      'player2.score': null,
    });
  }

  // ── Fight invites ──────────────────────────────────────────────

  static const _inviteCodeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const _inviteCodeLength = 6;
  static const _inviteTtl = Duration(minutes: 10);

  String _generateInviteCode() {
    final rng = Random.secure();
    return List.generate(
      _inviteCodeLength,
      (_) => _inviteCodeChars[rng.nextInt(_inviteCodeChars.length)],
    ).join();
  }

  /// Create a private fight-invite lobby. Returns the 6-char code.
  Future<String> createFightInvite({
    required String hostUid,
    required String hostName,
    String? wrestlerSkin,
  }) async {
    final code = _generateInviteCode();
    final expiresAt = DateTime.now().add(_inviteTtl);
    await _db.collection('fight_invites').doc(code).set({
      'code': code,
      'hostUid': hostUid,
      'hostName': hostName,
      if (wrestlerSkin != null) 'hostWrestlerSkin': wrestlerSkin,
      'status': 'waiting',
      'guestUid': null,
      'guestName': null,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
    });
    return code;
  }

  /// Stream real-time updates on a fight-invite document.
  Stream<Map<String, dynamic>?> watchFightInvite(String code) {
    return _db
        .collection('fight_invites')
        .doc(code)
        .snapshots()
        .map((snap) => snap.exists ? (snap.data() as Map<String, dynamic>) : null);
  }

  /// Accept a fight invite as the guest. Returns the host UID on success,
  /// or null if the invite is invalid/expired/already taken.
  Future<String?> joinFightInvite({
    required String code,
    required String guestUid,
    required String guestName,
    String? wrestlerSkin,
  }) async {
    final ref = _db.collection('fight_invites').doc(code.toUpperCase());
    String? hostUid;

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;

      final data = snap.data()!;
      if (data['status'] != 'waiting') return;

      final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
      if (expiresAt != null && DateTime.now().isAfter(expiresAt)) return;

      final existingGuest = data['guestUid'];
      if (existingGuest != null && existingGuest != guestUid) return; // already taken

      hostUid = data['hostUid'] as String;
      tx.update(ref, {
        'status': 'accepted',
        'guestUid': guestUid,
        'guestName': guestName,
        if (wrestlerSkin != null) 'guestWrestlerSkin': wrestlerSkin,
      });
    });

    return hostUid;
  }

  /// Delete a fight-invite document (called by host on cancel or both on match start).
  Future<void> deleteFightInvite(String code) async {
    try {
      await _db.collection('fight_invites').doc(code).delete();
    } catch (_) {}
  }

  // ── Clean up listeners ─────────────────────────────────────────

  /// Clean up listeners.
  void dispose() {
    _matchSub?.cancel();
    _queueSub?.cancel();
  }
}
