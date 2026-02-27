import 'package:cloud_firestore/cloud_firestore.dart';
import '../engine/types.dart';

class LeaderboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Submit a score for the current user. Only updates if the new score
  /// is strictly greater than the existing one.
  Future<void> submitScore({
    required String uid,
    required String modeId,
    required int score,
    required String displayName,
  }) async {
    final ref = _db.collection('leaderboard').doc(modeId).collection('scores').doc(uid);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists || (snap.data()?['score'] as num? ?? 0) < score) {
        tx.set(ref, {
          'uid': uid,
          'displayName': displayName,
          'score': score,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /// Fetch top scores for a mode, sorted descending. Assigns rank 1-N.
  Future<List<LeaderboardEntry>> getTopScores(String modeId, {int limit = 100}) async {
    try {
      final snap = await _db
          .collection('leaderboard')
          .doc(modeId)
          .collection('scores')
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      return snap.docs.asMap().entries.map((entry) {
        final data = entry.value.data();
        return LeaderboardEntry(
          uid: data['uid'] as String? ?? entry.value.id,
          displayName: data['displayName'] as String? ?? 'Player',
          score: (data['score'] as num?)?.toInt() ?? 0,
          rank: entry.key + 1,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
