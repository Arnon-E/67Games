import 'package:flutter/material.dart';

// ============================================================
// GAME MODE
// ============================================================

class UnlockCondition {
  final String type; // 'score' | 'games_played' | 'achievement'
  final String? modeId;
  final int value;
  final String? achievementId;
  const UnlockCondition({required this.type, this.modeId, required this.value, this.achievementId});
}

class GameMode {
  final String id;
  final String name;
  final int targetMs;
  final String displayTarget;
  final String description;
  final bool countdown;
  final int? countdownFrom;
  final int? blindAfterMs;
  final UnlockCondition? unlockCondition;
  const GameMode({
    required this.id,
    required this.name,
    required this.targetMs,
    required this.displayTarget,
    required this.description,
    this.countdown = false,
    this.countdownFrom,
    this.blindAfterMs,
    this.unlockCondition,
  });
}

// ============================================================
// SCORE RATING
// ============================================================

class ScoreRating {
  final String tier;
  final String label;
  final Color color;
  final String emoji;
  final String description;
  const ScoreRating({
    required this.tier,
    required this.label,
    required this.color,
    required this.emoji,
    required this.description,
  });
}

// ============================================================
// SCORE RESULT
// ============================================================

class ScoreResult {
  final int stoppedAtMs;
  final int targetMs;
  final int deviationMs;
  final int rawScore;
  final double streakMultiplier;
  final int finalScore;
  final ScoreRating rating;
  final int xpEarned;
  final bool isNewBest;
  const ScoreResult({
    required this.stoppedAtMs,
    required this.targetMs,
    required this.deviationMs,
    required this.rawScore,
    required this.streakMultiplier,
    required this.finalScore,
    required this.rating,
    required this.xpEarned,
    required this.isNewBest,
  });
}

// ============================================================
// PLAYER STATS
// ============================================================

class PlayerStats {
  final int totalGames;
  final int totalScore;
  final Map<String, int> bestScores;
  final int perfectCount;
  final int currentStreak;
  final int bestStreak;
  final int averageDeviation;
  final int totalXp;
  final int level;

  const PlayerStats({
    required this.totalGames,
    required this.totalScore,
    required this.bestScores,
    required this.perfectCount,
    required this.currentStreak,
    required this.bestStreak,
    required this.averageDeviation,
    required this.totalXp,
    required this.level,
  });

  PlayerStats copyWith({
    int? totalGames,
    int? totalScore,
    Map<String, int>? bestScores,
    int? perfectCount,
    int? currentStreak,
    int? bestStreak,
    int? averageDeviation,
    int? totalXp,
    int? level,
  }) {
    return PlayerStats(
      totalGames: totalGames ?? this.totalGames,
      totalScore: totalScore ?? this.totalScore,
      bestScores: bestScores ?? this.bestScores,
      perfectCount: perfectCount ?? this.perfectCount,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      averageDeviation: averageDeviation ?? this.averageDeviation,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalGames': totalGames,
    'totalScore': totalScore,
    'bestScores': bestScores,
    'perfectCount': perfectCount,
    'currentStreak': currentStreak,
    'bestStreak': bestStreak,
    'averageDeviation': averageDeviation,
    'totalXp': totalXp,
    'level': level,
  };

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
    totalGames: (json['totalGames'] as num?)?.toInt() ?? 0,
    totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
    bestScores: (json['bestScores'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ) ??
        {},
    perfectCount: (json['perfectCount'] as num?)?.toInt() ?? 0,
    currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
    bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
    averageDeviation: (json['averageDeviation'] as num?)?.toInt() ?? 0,
    totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
    level: (json['level'] as num?)?.toInt() ?? 1,
  );
}

// ============================================================
// ACHIEVEMENT
// ============================================================

class AchievementCondition {
  final String type; // 'single_game' | 'cumulative' | 'streak' | 'special'
  final String metric;
  final int value;
  final String? modeId;
  const AchievementCondition({required this.type, required this.metric, required this.value, this.modeId});
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String rarity;
  final AchievementCondition condition;
  final int? unlockedAt;
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.condition,
    this.unlockedAt,
  });
}

// ============================================================
// TIMER STATE
// ============================================================

class TimerState {
  final bool isRunning;
  final int elapsedMs;
  final String displayTime;
  final double speedMultiplier;

  const TimerState({
    required this.isRunning,
    required this.elapsedMs,
    required this.displayTime,
    this.speedMultiplier = 1.0,
  });

  factory TimerState.initial() => const TimerState(isRunning: false, elapsedMs: 0, displayTime: '0.000');

  TimerState copyWith({bool? isRunning, int? elapsedMs, String? displayTime, double? speedMultiplier}) => TimerState(
    isRunning: isRunning ?? this.isRunning,
    elapsedMs: elapsedMs ?? this.elapsedMs,
    displayTime: displayTime ?? this.displayTime,
    speedMultiplier: speedMultiplier ?? this.speedMultiplier,
  );
}

// ============================================================
// PLAYER LOADOUT
// ============================================================

class PlayerLoadout {
  final String timerSkin;
  final String background;
  final String soundPack;
  final String celebration;

  const PlayerLoadout({
    this.timerSkin = 'timer_skin_default',
    this.background = 'bg_default',
    this.soundPack = 'sound_default',
    this.celebration = 'celebration_default',
  });

  Map<String, dynamic> toJson() => {
    'timerSkin': timerSkin,
    'background': background,
    'soundPack': soundPack,
    'celebration': celebration,
  };

  factory PlayerLoadout.fromJson(Map<String, dynamic> json) => PlayerLoadout(
    timerSkin: json['timerSkin'] as String? ?? 'timer_skin_default',
    background: json['background'] as String? ?? 'bg_default',
    soundPack: json['soundPack'] as String? ?? 'sound_default',
    celebration: json['celebration'] as String? ?? 'celebration_default',
  );

  PlayerLoadout copyWith({String? timerSkin, String? background, String? soundPack, String? celebration}) =>
      PlayerLoadout(
        timerSkin: timerSkin ?? this.timerSkin,
        background: background ?? this.background,
        soundPack: soundPack ?? this.soundPack,
        celebration: celebration ?? this.celebration,
      );
}

// ============================================================
// DAILY REWARD STATE
// ============================================================

class DailyRewardState {
  final String? lastClaimDate;
  final int loginStreak;
  final bool canClaim;

  const DailyRewardState({this.lastClaimDate, this.loginStreak = 0, this.canClaim = false});

  factory DailyRewardState.initial() => const DailyRewardState();

  Map<String, dynamic> toJson() => {
    'lastClaimDate': lastClaimDate,
    'loginStreak': loginStreak,
    'canClaim': canClaim,
  };

  factory DailyRewardState.fromJson(Map<String, dynamic> json) => DailyRewardState(
    lastClaimDate: json['lastClaimDate'] as String?,
    loginStreak: (json['loginStreak'] as num?)?.toInt() ?? 0,
    canClaim: json['canClaim'] as bool? ?? false,
  );

  DailyRewardState copyWith({String? lastClaimDate, int? loginStreak, bool? canClaim}) => DailyRewardState(
    lastClaimDate: lastClaimDate ?? this.lastClaimDate,
    loginStreak: loginStreak ?? this.loginStreak,
    canClaim: canClaim ?? this.canClaim,
  );
}

// ============================================================
// LEADERBOARD ENTRY
// ============================================================

class LeaderboardEntry {
  final String uid;
  final String displayName;
  final int score;
  final int rank;
  const LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.score,
    required this.rank,
  });
}

// ============================================================
// SESSION STATS
// ============================================================

class SessionStats {
  final int gamesPlayed;
  final int bestScore;
  final int coinsEarned;
  final int sessionStart;
  final int surgeGamesPlayed;

  const SessionStats({
    this.gamesPlayed = 0,
    this.bestScore = 0,
    this.coinsEarned = 0,
    required this.sessionStart,
    this.surgeGamesPlayed = 0,
  });

  factory SessionStats.initial() => SessionStats(sessionStart: DateTime.now().millisecondsSinceEpoch);

  SessionStats copyWith({int? gamesPlayed, int? bestScore, int? coinsEarned, int? surgeGamesPlayed}) => SessionStats(
    gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    bestScore: bestScore ?? this.bestScore,
    coinsEarned: coinsEarned ?? this.coinsEarned,
    sessionStart: sessionStart,
    surgeGamesPlayed: surgeGamesPlayed ?? this.surgeGamesPlayed,
  );
}
