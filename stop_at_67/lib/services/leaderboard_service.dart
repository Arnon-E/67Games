import 'package:cloud_firestore/cloud_firestore.dart';
import '../engine/types.dart';
import '../engine/constants.dart';

class LeaderboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── In-memory cache ──────────────────────────────────────────
  // Key: cache key string (modeId or 'tournament:{weekId}')
  // Value: (entries, fetchedAt)
  static const Duration _cacheTtl = Duration(minutes: 5);
  final Map<String, ({List<LeaderboardEntry> entries, DateTime fetchedAt})> _cache = {};

  List<LeaderboardEntry>? _getCached(String key) {
    final hit = _cache[key];
    if (hit == null) return null;
    if (DateTime.now().difference(hit.fetchedAt) > _cacheTtl) {
      _cache.remove(key);
      return null;
    }
    return hit.entries;
  }

  /// Deduplicates entries by uid, keeping the highest score per user.
  List<LeaderboardEntry> _deduplicate(List<LeaderboardEntry> entries) {
    final seen = <String, LeaderboardEntry>{};
    for (final e in entries) {
      if (!seen.containsKey(e.uid) || e.score > seen[e.uid]!.score) {
        seen[e.uid] = e;
      }
    }
    final deduped = seen.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return deduped
        .asMap()
        .entries
        .map((e) => LeaderboardEntry(
              uid: e.value.uid,
              displayName: e.value.displayName,
              score: e.value.score,
              rank: e.key + 1,
            ))
        .toList();
  }

  void _setCache(String key, List<LeaderboardEntry> entries) {
    _cache[key] = (entries: entries, fetchedAt: DateTime.now());
  }

  /// Force-invalidate a cache entry (called after a new personal best is written).
  void invalidate(String cacheKey) => _cache.remove(cacheKey);

  // ── Top-10 aggregated document helpers ───────────────────────

  /// Reads the pre-aggregated top-10 document (1 Firestore read).
  /// Returns null if the document doesn't exist yet.
  Future<List<LeaderboardEntry>?> _readTop10Doc(DocumentReference ref) async {
    try {
      final snap = await ref.get();
      if (!snap.exists) return null;
      final data = snap.data() as Map<String, dynamic>?;
      final list = data?['entries'] as List<dynamic>?;
      if (list == null || list.isEmpty) return null;
      return list.asMap().entries.map((e) {
        final m = e.value as Map<String, dynamic>;
        return LeaderboardEntry(
          uid: m['uid'] as String? ?? '',
          displayName: m['displayName'] as String? ?? 'Player',
          score: (m['score'] as num?)?.toInt() ?? 0,
          rank: e.key + 1,
        );
      }).toList();
    } catch (_) {
      return null;
    }
  }

  /// Rewrites the top-10 document from the current scores collection.
  /// Called inside the same transaction as submitScore so it stays consistent.
  void _updateTop10InTx(
    Transaction tx,
    DocumentReference top10Ref,
    List<Map<String, dynamic>> currentTop10,
    Map<String, dynamic> newEntry,
  ) {
    // Merge new entry into the list, keep top 10 by score
    final merged = [...currentTop10];
    final existingIdx = merged.indexWhere((e) => e['uid'] == newEntry['uid']);
    if (existingIdx >= 0) {
      merged[existingIdx] = newEntry;
    } else {
      merged.add(newEntry);
    }
    merged.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    final top10 = merged.take(10).toList();
    tx.set(top10Ref, {'entries': top10, 'updatedAt': FieldValue.serverTimestamp()});
  }

  // ── Leaderboard ──────────────────────────────────────────────

  /// Submit a score for the current user. Only updates if the new score
  /// is strictly greater than the existing one.
  /// Also maintains the aggregated top-10 document.
  Future<void> submitScore({
    required String uid,
    required String modeId,
    required int score,
    required String displayName,
  }) async {
    final scoresRef = _db.collection('leaderboard').doc(modeId).collection('scores').doc(uid);
    final top10Ref = _db.collection('leaderboard').doc(modeId).collection('meta').doc('top10');

    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(scoresRef);
        final top10Snap = await tx.get(top10Ref);

        final existingScore = (snap.data()?['score'] as num? ?? 0).toInt();
        if (snap.exists && existingScore >= score) return; // no improvement

        final newEntry = {
          'uid': uid,
          'displayName': displayName,
          'score': score,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        tx.set(scoresRef, newEntry);

        // Rebuild top-10
        final currentList = top10Snap.exists
            ? ((top10Snap.data()?['entries'] as List<dynamic>?) ?? [])
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList()
            : <Map<String, dynamic>>[];

        _updateTop10InTx(tx, top10Ref, currentList, {
          'uid': uid,
          'displayName': displayName,
          'score': score,
        });
      });

      // Invalidate cache so the next read reflects the new score
      invalidate(modeId);
    } catch (e, st) {
      // ignore: avoid_print
      print('[LB] submitScore ERROR: $e\n$st');
    }
  }

  /// Fetch top scores for a mode.
  /// 1. Returns cache if < 5 minutes old (0 reads).
  /// 2. Reads the aggregated top-10 doc (1 read).
  /// 3. Falls back to full query only if meta doc missing (cold start).
  Future<List<LeaderboardEntry>> getTopScores(String modeId) async {
    // 1. Cache hit
    final cached = _getCached(modeId);
    if (cached != null) return cached;

    try {
      // 2. Aggregated top-10 (1 read)
      final top10Ref = _db.collection('leaderboard').doc(modeId).collection('meta').doc('top10');
      final top10 = await _readTop10Doc(top10Ref);
      if (top10 != null && top10.isNotEmpty) {
        final deduped = _deduplicate(top10);
        _setCache(modeId, deduped);
        return deduped;
      }

      // 3. Cold-start fallback: full query (up to 100 reads), also seeds the top-10 doc
      final snap = await _db
          .collection('leaderboard')
          .doc(modeId)
          .collection('scores')
          .orderBy('score', descending: true)
          .limit(100)
          .get();

      final entries = snap.docs.asMap().entries.map((e) {
        final data = e.value.data();
        return LeaderboardEntry(
          uid: data['uid'] as String? ?? e.value.id,
          displayName: data['displayName'] as String? ?? 'Player',
          score: (data['score'] as num?)?.toInt() ?? 0,
          rank: e.key + 1,
        );
      }).toList();

      // Seed the top-10 doc so future reads are cheap
      if (entries.isNotEmpty) {
        final top10Data = entries.take(10).map((e) => {
          'uid': e.uid,
          'displayName': e.displayName,
          'score': e.score,
        }).toList();
        _db
            .collection('leaderboard')
            .doc(modeId)
            .collection('meta')
            .doc('top10')
            .set({'entries': top10Data, 'updatedAt': FieldValue.serverTimestamp()});
      }

      _setCache(modeId, entries);
      return entries;
    } catch (_) {
      return [];
    }
  }

  // ── Weekly Tournament ────────────────────────────────────────

  /// Submit a score to the current week's tournament.
  /// Also maintains the aggregated top-10 document for this week.
  Future<void> submitTournamentScore({
    required String uid,
    required String displayName,
    required int score,
  }) async {
    final weekId = weekIdForDate(DateTime.now());
    final scoresRef = _db.collection('tournaments').doc(weekId).collection('scores').doc(uid);
    final top10Ref = _db.collection('tournaments').doc(weekId).collection('meta').doc('top10');
    final cacheKey = 'tournament:$weekId';

    await _db.runTransaction((tx) async {
      final snap = await tx.get(scoresRef);
      final top10Snap = await tx.get(top10Ref);

      final existingScore = (snap.data()?['score'] as num? ?? 0).toInt();
      if (snap.exists && existingScore >= score) return;

      final newEntry = {
        'uid': uid,
        'displayName': displayName,
        'score': score,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      tx.set(scoresRef, newEntry);

      final currentList = top10Snap.exists
          ? ((top10Snap.data()?['entries'] as List<dynamic>?) ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList()
          : <Map<String, dynamic>>[];

      _updateTop10InTx(tx, top10Ref, currentList, {
        'uid': uid,
        'displayName': displayName,
        'score': score,
      });
    });

    invalidate(cacheKey);
  }

  /// Fetch this week's tournament top scores.
  /// Same 3-tier strategy: cache → top-10 doc → full query fallback.
  Future<List<LeaderboardEntry>> getTournamentTopScores() async {
    final weekId = weekIdForDate(DateTime.now());
    final cacheKey = 'tournament:$weekId';

    // 1. Cache hit
    final cached = _getCached(cacheKey);
    if (cached != null) return cached;

    try {
      // 2. Aggregated top-10 (1 read)
      final top10Ref = _db.collection('tournaments').doc(weekId).collection('meta').doc('top10');
      final top10 = await _readTop10Doc(top10Ref);
      if (top10 != null && top10.isNotEmpty) {
        final deduped = _deduplicate(top10);
        _setCache(cacheKey, deduped);
        return deduped;
      }

      // 3. Cold-start fallback
      final snap = await _db
          .collection('tournaments')
          .doc(weekId)
          .collection('scores')
          .orderBy('score', descending: true)
          .limit(100)
          .get();

      final entries = snap.docs.asMap().entries.map((e) {
        final data = e.value.data();
        return LeaderboardEntry(
          uid: data['uid'] as String? ?? e.value.id,
          displayName: data['displayName'] as String? ?? 'Player',
          score: (data['score'] as num?)?.toInt() ?? 0,
          rank: e.key + 1,
        );
      }).toList();

      if (entries.isNotEmpty) {
        final top10Data = entries.take(10).map((e) => {
          'uid': e.uid,
          'displayName': e.displayName,
          'score': e.score,
        }).toList();
        _db
            .collection('tournaments')
            .doc(weekId)
            .collection('meta')
            .doc('top10')
            .set({'entries': top10Data, 'updatedAt': FieldValue.serverTimestamp()});
      }

      _setCache(cacheKey, entries);
      return entries;
    } catch (_) {
      return [];
    }
  }
}
