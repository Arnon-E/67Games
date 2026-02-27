import 'constants.dart';
import 'types.dart';

// ============================================================
// MODE UNLOCK
// ============================================================

bool isModeUnlocked(String modeId, PlayerStats stats) {
  final mode = kGameModes[modeId];
  if (mode == null) return false;
  if (mode.unlockCondition == null) return true;
  return checkUnlockCondition(mode.unlockCondition!, stats);
}

bool checkUnlockCondition(UnlockCondition condition, PlayerStats stats) {
  switch (condition.type) {
    case 'score':
      if (condition.modeId == null) return false;
      return (stats.bestScores[condition.modeId!] ?? 0) >= condition.value;
    case 'games_played':
      return stats.totalGames >= condition.value;
    default:
      return false;
  }
}

List<({GameMode mode, double progress, String requirement})> getLockedModes(PlayerStats stats) {
  return kGameModes.values
      .where((mode) => !isModeUnlocked(mode.id, stats))
      .map((mode) {
        final condition = mode.unlockCondition!;
        double progress = 0;
        String requirement = '';

        switch (condition.type) {
          case 'score':
            final currentScore = stats.bestScores[condition.modeId ?? ''] ?? 0;
            progress = (currentScore / condition.value * 100).clamp(0, 100);
            final modeName = kGameModes[condition.modeId]?.name ?? 'Unknown';
            requirement = 'Score ${condition.value}+ in $modeName';
            break;
          case 'games_played':
            progress = (stats.totalGames / condition.value * 100).clamp(0, 100);
            requirement = 'Play ${condition.value} games';
            break;
        }

        return (mode: mode, progress: progress, requirement: requirement);
      })
      .toList();
}

// ============================================================
// ACHIEVEMENT CHECKER
// ============================================================

class AchievementChecker {
  final Set<String> _unlockedAchievements;

  AchievementChecker([List<String> unlockedIds = const []]) : _unlockedAchievements = Set.from(unlockedIds);

  List<Achievement> checkAfterGame(
    ScoreResult result,
    PlayerStats stats,
    String modeId,
    int currentStreak,
  ) {
    final newlyUnlocked = <Achievement>[];

    for (final achievement in kAchievements) {
      if (_unlockedAchievements.contains(achievement.id)) continue;
      if (_checkCondition(achievement, result, stats, modeId, currentStreak)) {
        _unlockedAchievements.add(achievement.id);
        newlyUnlocked.add(Achievement(
          id: achievement.id,
          name: achievement.name,
          description: achievement.description,
          icon: achievement.icon,
          rarity: achievement.rarity,
          condition: achievement.condition,
          unlockedAt: DateTime.now().millisecondsSinceEpoch,
        ));
      }
    }

    return newlyUnlocked;
  }

  bool _checkCondition(Achievement a, ScoreResult result, PlayerStats stats, String modeId, int streak) {
    if (a.condition.modeId != null && a.condition.modeId != modeId) return false;

    switch (a.condition.type) {
      case 'single_game':
        return _checkSingleGame(a.condition, result);
      case 'cumulative':
        return _checkCumulative(a.condition, stats);
      case 'streak':
        return _checkStreak(a.condition, streak);
      default:
        return false;
    }
  }

  bool _checkSingleGame(AchievementCondition c, ScoreResult result) {
    switch (c.metric) {
      case 'deviation':
        return result.deviationMs <= c.value;
      case 'score':
        return result.finalScore >= c.value;
      default:
        return false;
    }
  }

  bool _checkCumulative(AchievementCondition c, PlayerStats stats) {
    switch (c.metric) {
      case 'games_played':
        return stats.totalGames >= c.value;
      default:
        return false;
    }
  }

  bool _checkStreak(AchievementCondition c, int streak) {
    switch (c.metric) {
      case 'within_100ms':
        return streak >= c.value;
      default:
        return false;
    }
  }

  bool isUnlocked(String id) => _unlockedAchievements.contains(id);

  List<String> exportState() => _unlockedAchievements.toList();
}

// ============================================================
// STATS HELPERS
// ============================================================

PlayerStats createDefaultStats() => const PlayerStats(
  totalGames: 0,
  totalScore: 0,
  bestScores: {},
  perfectCount: 0,
  currentStreak: 0,
  bestStreak: 0,
  averageDeviation: 0,
  totalXp: 0,
  level: 1,
);

PlayerStats updateStats(
  PlayerStats stats,
  ScoreResult result,
  String modeId,
  int newStreak,
) {
  final newTotalGames = stats.totalGames + 1;
  final newTotalScore = stats.totalScore + result.finalScore;

  final newBestScores = Map<String, int>.from(stats.bestScores);
  if ((newBestScores[modeId] ?? 0) < result.finalScore) {
    newBestScores[modeId] = result.finalScore;
  }

  final newPerfectCount = stats.perfectCount + (result.deviationMs == 0 ? 1 : 0);
  final newAverageDeviation =
      ((stats.averageDeviation * stats.totalGames + result.deviationMs) / newTotalGames).round();
  final newBestStreak = newStreak > stats.bestStreak ? newStreak : stats.bestStreak;
  final newTotalXp = stats.totalXp + result.xpEarned;
  final newLevel = levelFromXp(newTotalXp).level;

  return stats.copyWith(
    totalGames: newTotalGames,
    totalScore: newTotalScore,
    bestScores: newBestScores,
    perfectCount: newPerfectCount,
    currentStreak: newStreak,
    bestStreak: newBestStreak,
    averageDeviation: newAverageDeviation,
    totalXp: newTotalXp,
    level: newLevel,
  );
}
