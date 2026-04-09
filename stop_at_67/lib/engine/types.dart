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

  // Double Tap mode: user taps at midpoint then again to stop
  final bool doubleTap;

  // Moving Target mode: target shifts each round
  final bool movingTarget;
  final int movingTargetStep; // ms increase per round (default 200)

  // Calibration mode: N attempts, score averaged
  final bool isCalibration;
  final int calibrationRounds; // default 5

  // Pressure mode: tolerance tightens with each success
  final bool isPressure;

  // Fortune mode: costs coins to play; wheel picks mode + multiplier
  final int costCoins;

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
    this.doubleTap = false,
    this.movingTarget = false,
    this.movingTargetStep = 200,
    this.isCalibration = false,
    this.calibrationRounds = 5,
    this.isPressure = false,
    this.costCoins = 0,
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
  final Map<String, int> modeGamesPlayed;

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
    this.modeGamesPlayed = const {},
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
    Map<String, int>? modeGamesPlayed,
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
      modeGamesPlayed: modeGamesPlayed ?? this.modeGamesPlayed,
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
    'modeGamesPlayed': modeGamesPlayed,
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
    modeGamesPlayed: (json['modeGamesPlayed'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ) ??
        {},
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

  factory TimerState.initial() => const TimerState(isRunning: false, elapsedMs: 0, displayTime: '0.0000');

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
// WEEKLY MISSIONS
// ============================================================

/// Defines a mission that resets each week.
class WeeklyMissionDef {
  final String id;
  final String label;
  final String description;
  final int target;
  final String type; // 'games' | 'perfects' | 'modes' | 'score' | 'streak'
  final int rewardCoins;

  const WeeklyMissionDef({
    required this.id,
    required this.label,
    required this.description,
    required this.target,
    required this.type,
    required this.rewardCoins,
  });
}

/// Tracks per-player progress on a single mission this week.
class WeeklyMissionProgress {
  final String missionId;
  final int progress;
  final bool claimed;

  const WeeklyMissionProgress({
    required this.missionId,
    this.progress = 0,
    this.claimed = false,
  });

  WeeklyMissionProgress copyWith({int? progress, bool? claimed}) =>
      WeeklyMissionProgress(
        missionId: missionId,
        progress: progress ?? this.progress,
        claimed: claimed ?? this.claimed,
      );

  Map<String, dynamic> toJson() => {
    'missionId': missionId,
    'progress': progress,
    'claimed': claimed,
  };

  factory WeeklyMissionProgress.fromJson(Map<String, dynamic> json) =>
      WeeklyMissionProgress(
        missionId: json['missionId'] as String,
        progress: (json['progress'] as num?)?.toInt() ?? 0,
        claimed: json['claimed'] as bool? ?? false,
      );
}

class WeeklyMissionsState {
  final String weekId; // e.g. '2026-W11'
  final List<WeeklyMissionProgress> missions;
  /// Distinct mode IDs played this week (for the 'modes' mission).
  final List<String> playedModeIds;

  const WeeklyMissionsState({
    required this.weekId,
    required this.missions,
    this.playedModeIds = const [],
  });

  factory WeeklyMissionsState.initial(String weekId, List<WeeklyMissionDef> defs) =>
      WeeklyMissionsState(
        weekId: weekId,
        missions: defs.map((d) => WeeklyMissionProgress(missionId: d.id)).toList(),
        playedModeIds: const [],
      );

  WeeklyMissionsState copyWith({
    List<WeeklyMissionProgress>? missions,
    List<String>? playedModeIds,
  }) =>
      WeeklyMissionsState(
        weekId: weekId,
        missions: missions ?? this.missions,
        playedModeIds: playedModeIds ?? this.playedModeIds,
      );

  Map<String, dynamic> toJson() => {
    'weekId': weekId,
    'missions': missions.map((m) => m.toJson()).toList(),
    'playedModeIds': playedModeIds,
  };

  factory WeeklyMissionsState.fromJson(Map<String, dynamic> json) =>
      WeeklyMissionsState(
        weekId: json['weekId'] as String,
        missions: (json['missions'] as List<dynamic>)
            .map((m) => WeeklyMissionProgress.fromJson(m as Map<String, dynamic>))
            .toList(),
        playedModeIds: (json['playedModeIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
            [],
      );
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

// ============================================================
// MULTIPLAYER MATCH
// ============================================================

/// Status of a 1v1 match document in Firestore.
enum MatchStatus { waiting, countdown, playing, finished, cancelled }

/// A player within a match.
class MatchPlayer {
  final String uid;
  final String displayName;
  final int? stoppedAtMs;
  final int? deviationMs;
  final int? score;

  const MatchPlayer({
    required this.uid,
    required this.displayName,
    this.stoppedAtMs,
    this.deviationMs,
    this.score,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'displayName': displayName,
    if (stoppedAtMs != null) 'stoppedAtMs': stoppedAtMs,
    if (deviationMs != null) 'deviationMs': deviationMs,
    if (score != null) 'score': score,
  };

  factory MatchPlayer.fromJson(Map<String, dynamic> json) => MatchPlayer(
    uid: json['uid'] as String? ?? '',
    displayName: json['displayName'] as String? ?? 'Player',
    stoppedAtMs: (json['stoppedAtMs'] as num?)?.toInt(),
    deviationMs: (json['deviationMs'] as num?)?.toInt(),
    score: (json['score'] as num?)?.toInt(),
  );
}

/// Represents a live 1v1 match stored in Firestore.
class MatchData {
  final String matchId;
  final String modeId;
  final int targetMs;
  final double speedMultiplier;
  final bool speedUpRequested;
  final bool speedUpAgreed;
  final MatchStatus status;
  final MatchPlayer player1;
  final MatchPlayer? player2;
  final DateTime createdAt;
  final DateTime? player1Heartbeat;
  final DateTime? player2Heartbeat;

  const MatchData({
    required this.matchId,
    required this.modeId,
    required this.targetMs,
    this.speedMultiplier = 1.0,
    this.speedUpRequested = false,
    this.speedUpAgreed = false,
    required this.status,
    required this.player1,
    this.player2,
    required this.createdAt,
    this.player1Heartbeat,
    this.player2Heartbeat,
  });

  /// Whether both players have submitted their results.
  bool get isComplete =>
      player1.score != null && player2 != null && player2!.score != null;

  /// The UID of the winner, or null for a tie / incomplete match.
  String? get winnerUid {
    if (!isComplete) return null;
    if (player1.score! > player2!.score!) return player1.uid;
    if (player2!.score! > player1.score!) return player2!.uid;
    return null; // tie
  }

  factory MatchData.fromJson(String id, Map<String, dynamic> json) => MatchData(
    matchId: id,
    modeId: json['modeId'] as String? ?? 'classic',
    targetMs: (json['targetMs'] as num?)?.toInt() ?? 6700,
    speedMultiplier: (json['speedMultiplier'] as num?)?.toDouble() ?? 1.0,
    speedUpRequested: json['speedUpRequested'] as bool? ?? false,
    speedUpAgreed: json['speedUpAgreed'] as bool? ?? false,
    status: MatchStatus.values.firstWhere(
      (s) => s.name == (json['status'] as String? ?? 'waiting'),
      orElse: () => MatchStatus.waiting,
    ),
    player1: MatchPlayer.fromJson(
      (json['player1'] as Map<String, dynamic>?) ?? {},
    ),
    player2: json['player2'] != null
        ? MatchPlayer.fromJson(json['player2'] as Map<String, dynamic>)
        : null,
    createdAt: json['createdAt'] != null
        ? (json['createdAt'] as dynamic).toDate()
        : DateTime.now(),
    player1Heartbeat: (json['player1Heartbeat'] as dynamic)?.toDate(),
    player2Heartbeat: (json['player2Heartbeat'] as dynamic)?.toDate(),
  );
}
