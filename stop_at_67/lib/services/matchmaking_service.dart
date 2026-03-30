import 'dart:async';
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
  }) async {
    final queueRef = _db.collection('matchmaking_queue');

    // Use a transaction to atomically claim an opponent from the queue.
    // This prevents two players from matching with the same opponent.
    final matchId = await _db.runTransaction<String?>((tx) async {
      // Look for an existing waiting player in the same mode
      final waiting = await queueRef
          .where('modeId', isEqualTo: modeId)
          .where('uid', isNotEqualTo: uid)
          .limit(1)
          .get();

      if (waiting.docs.isNotEmpty) {
        final opponentDoc = waiting.docs.first;
        // Re-read the opponent doc inside the transaction to guard against
        // concurrent claims.
        final opponentSnap = await tx.get(opponentDoc.reference);
        if (!opponentSnap.exists) return null; // already claimed

        final opponentData = opponentSnap.data()!;
        final matchRef = _db.collection('matches').doc();

        tx.set(matchRef, {
          'modeId': modeId,
          'targetMs': targetMs,
          'status': MatchStatus.countdown.name,
          'player1': {
            'uid': opponentData['uid'],
            'displayName': opponentData['displayName'],
          },
          'player2': {
            'uid': uid,
            'displayName': displayName,
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

    // Listen to matches where this user is player1 or player2 and status is countdown
    _queueSub = _db
        .collection('matches')
        .where('status', isEqualTo: MatchStatus.countdown.name)
        .snapshots()
        .listen((snapshot) {
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final p1Uid = (data['player1'] as Map?)?['uid'] as String?;
        final p2Uid = (data['player2'] as Map?)?['uid'] as String?;
        if (p1Uid == uid || p2Uid == uid) {
          _queueSub?.cancel();
          _queueSub = null;
          onMatchFound(doc.id);
          return;
        }
      }
    });
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

  /// Clean up listeners.
  void dispose() {
    _matchSub?.cancel();
    _queueSub?.cancel();
  }
}
