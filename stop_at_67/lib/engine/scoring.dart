import 'constants.dart';
import 'types.dart';

// ============================================================
// CALCULATE SCORE
// ============================================================

ScoreResult calculateScore(
  int stoppedAtMs,
  GameMode mode,
  int currentStreak,
  int bestScore,
) {
  final targetMs = mode.targetMs;
  final deviationMs = (stoppedAtMs - targetMs).abs();
  final rawScore = (kScoringConfig.maxScore - deviationMs).clamp(0, kScoringConfig.maxScore);
  final streakMultiplier = calculateStreakMultiplier(currentStreak);
  final finalScore = (rawScore * streakMultiplier).round();
  final rating = getRating(deviationMs);
  final xpEarned = (finalScore / kScoringConfig.xpDivisor).round();
  final isNewBest = finalScore > bestScore;

  return ScoreResult(
    stoppedAtMs: stoppedAtMs,
    targetMs: targetMs,
    deviationMs: deviationMs,
    rawScore: rawScore,
    streakMultiplier: streakMultiplier,
    finalScore: finalScore,
    rating: rating,
    xpEarned: xpEarned,
    isNewBest: isNewBest,
  );
}

ScoreRating getRating(int deviationMs) {
  for (final tier in kRatingTiers) {
    if (deviationMs <= tier.maxDeviation) return tier.rating;
  }
  return kRatingTiers.last.rating;
}

double calculateStreakMultiplier(int streak) {
  final multiplier = 1.0 + (streak * kStreakConfig.multiplierStep);
  return multiplier.clamp(1.0, kStreakConfig.maxMultiplier);
}

// ============================================================
// STREAK MANAGER
// ============================================================

class StreakManager {
  int _currentStreak = 0;
  int _bestStreak = 0;

  ({int streakForScoring, int newStreak, bool streakBroken, bool newBestStreak}) processAttempt(
    int deviationMs,
  ) {
    final streakForScoring = _currentStreak;
    bool streakBroken = false;
    bool newBestStreak = false;

    if (deviationMs <= kStreakConfig.maintainThreshold) {
      _currentStreak++;
      if (_currentStreak > _bestStreak) {
        _bestStreak = _currentStreak;
        newBestStreak = true;
      }
    } else if (deviationMs > kStreakConfig.breakThreshold) {
      streakBroken = _currentStreak > 0;
      _currentStreak = 0;
    }
    // Between maintain and break: freeze streak

    return (
      streakForScoring: streakForScoring,
      newStreak: _currentStreak,
      streakBroken: streakBroken,
      newBestStreak: newBestStreak,
    );
  }

  int getCurrentStreak() => _currentStreak;
  int getBestStreak() => _bestStreak;
  double getMultiplier() => calculateStreakMultiplier(_currentStreak);

  void reset() => _currentStreak = 0;

  void loadState(int currentStreak, int bestStreak) {
    _currentStreak = currentStreak;
    _bestStreak = bestStreak;
  }

  ({int currentStreak, int bestStreak}) exportState() =>
      (currentStreak: _currentStreak, bestStreak: _bestStreak);
}

// ============================================================
// FORMAT HELPERS
// ============================================================

String formatDeviation(int deviationMs) {
  if (deviationMs == 0) return '±0.000s';
  final seconds = deviationMs ~/ 1000;
  final millis = deviationMs % 1000;
  if (seconds > 0) {
    return '±$seconds.${millis.toString().padLeft(3, '0')}s';
  }
  return '±0.${millis.toString().padLeft(3, '0')}s';
}

String formatScore(int score) => score.toString();
