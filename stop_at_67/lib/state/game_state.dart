import 'dart:async';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../engine/types.dart';
import '../engine/constants.dart';
import '../engine/scoring.dart';
import '../engine/progression.dart';
import '../engine/timer_engine.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import '../services/ads_service.dart';
import '../services/leaderboard_service.dart';
import 'auth_state.dart';

enum AppScreen {
  menu,
  modeSelect,
  countdown,
  playing,
  results,
  settings,
  leaderboard,
  profile,
  shop,
  auth,
}

class GameState extends ChangeNotifier {
  final StorageService _storage;
  final SoundService _sound;
  final AdsService _ads;

  // ── Navigation ─────────────────────────────────────────────
  AppScreen _screen = AppScreen.menu;
  AppScreen get screen => _screen;

  // ── Game session ────────────────────────────────────────────
  GameMode? _currentMode;
  GameMode? get currentMode => _currentMode;

  TimerState _timerState = TimerState.initial();
  TimerState get timerState => _timerState;

  ScoreResult? _lastResult;
  ScoreResult? get lastResult => _lastResult;

  int _countdownValue = 3;
  int get countdownValue => _countdownValue;

  bool _isBlindMode = false;
  bool get isBlindMode => _isBlindMode;

  // ── Player data ─────────────────────────────────────────────
  PlayerStats _stats = const PlayerStats(
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
  PlayerStats get stats => _stats;

  List<String> _achievements = [];
  List<String> get achievements => _achievements;

  PlayerLoadout _loadout = const PlayerLoadout();
  PlayerLoadout get loadout => _loadout;

  int _coins = 0;
  int get coins => _coins;

  List<String> _ownedCosmetics = [
    'timer_skin_default',
    'bg_default',
    'sound_default',
    'celebration_default',
  ];
  List<String> get ownedCosmetics => _ownedCosmetics;

  // ── Daily rewards ───────────────────────────────────────────
  DailyRewardState _dailyRewards = DailyRewardState.initial();
  DailyRewardState get dailyRewards => _dailyRewards;

  // ── Session stats ───────────────────────────────────────────
  SessionStats _sessionStats = SessionStats.initial();
  SessionStats get sessionStats => _sessionStats;

  // ── Surge mode ──────────────────────────────────────────────
  int _surgeGamesInSession = 0;
  int _surgeFailStreak = 0;
  bool _surgePendingReset = false;

  double get surgeSpeedMultiplier => _computeSurgeMultiplier();
  int get surgeFailStreak => _surgeFailStreak;
  bool get surgePendingReset => _surgePendingReset;

  // ── Double Tap mode ─────────────────────────────────────────
  // Phase: 0=not active, 1=running (waiting for mid-tap), 2=mid-done (waiting for stop)
  static const int _doubleTapMidpointMs = 3350;
  static const int _doubleTapDeviationDivisor = 2; // average mid-tap + stop deviation
  int _doubleTapPhase = 0;
  int _doubleTapMidMs = 0; // virtual elapsed ms recorded at mid-tap
  int get doubleTapPhase => _doubleTapPhase;

  // ── Moving Target mode ──────────────────────────────────────
  int _movingTargetRound = 0; // 0-indexed round counter
  int get movingTargetCurrentMs {
    final mode = _currentMode;
    if (mode == null || !mode.movingTarget) return 6700;
    return mode.targetMs + _movingTargetRound * mode.movingTargetStep;
  }

  // ── Calibration mode ────────────────────────────────────────
  List<ScoreResult> _calibrationResults = [];
  List<ScoreResult> get calibrationResults => List.unmodifiable(_calibrationResults);

  // ── Pressure mode ────────────────────────────────────────────
  static const int _pressureInitialToleranceMs = 50;
  static const int _pressureToleranceStepMs = 10;
  static const int _pressureMinToleranceMs = 10;
  static const int _pressurePointsPerRound = 200;
  int _pressureTolerance = _pressureInitialToleranceMs;
  int _pressureRoundsSucceeded = 0;
  bool _pressureLastRoundSuccess = false;
  int get pressureTolerance => _pressureTolerance;
  int get pressureRoundsSucceeded => _pressureRoundsSucceeded;
  bool get pressureLastRoundSuccess => _pressureLastRoundSuccess;

  // ── Internal ────────────────────────────────────────────────
  final StreakManager _streakManager = StreakManager();
  final AchievementChecker _achievementChecker = AchievementChecker();
  PrecisionTimer? _precisionTimer;
  bool _initialized = false;
  int _gamesAtLastAd = 0; // tracks totalGames when last interstitial was shown

  final AuthState _authState;
  final LeaderboardService _leaderboard;

  GameState({
    required StorageService storage,
    required SoundService sound,
    required AdsService ads,
    required AuthState authState,
    required LeaderboardService leaderboard,
  })  : _storage = storage,
        _sound = sound,
        _ads = ads,
        _authState = authState,
        _leaderboard = leaderboard;

  // ═══════════════════════════════════════════════════════════
  // INIT
  // ═══════════════════════════════════════════════════════════

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _stats = await _storage.loadStats();
    _achievements = await _storage.loadAchievements();
    _coins = await _storage.loadCoins();
    _loadout = await _storage.loadLoadout();
    _ownedCosmetics = await _storage.loadOwnedCosmetics();
    _dailyRewards = await _storage.loadDailyRewards();

    final streakData = await _storage.loadStreak();
    _streakManager.loadState(
      streakData.currentStreak,
      streakData.bestStreak,
    );

    _checkDailyReward();
    _sessionStats = SessionStats.initial();

    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════

  void setScreen(AppScreen screen) {
    _screen = screen;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  // GAME FLOW
  // ═══════════════════════════════════════════════════════════

  void selectMode(String modeId) {
    final mode = kGameModes[modeId];
    if (mode == null) return;
    _currentMode = mode;
    // Reset any per-run state for the newly selected mode
    _movingTargetRound = 0;
    _calibrationResults = [];
    _pressureTolerance = _pressureInitialToleranceMs;
    _pressureRoundsSucceeded = 0;
    _pressureLastRoundSuccess = false;
    _doubleTapPhase = 0;
    _doubleTapMidMs = 0;
    _screen = AppScreen.modeSelect;
    notifyListeners();
  }

  Future<void> startCountdown() async {
    // Show interstitial every 5 games before starting the next round
    final gamesSinceLastAd = _stats.totalGames - _gamesAtLastAd;
    if (gamesSinceLastAd > 0 && gamesSinceLastAd % 5 == 0) {
      _gamesAtLastAd = _stats.totalGames;
      await _ads.showInterstitial();
    }

    _screen = AppScreen.countdown;
    _countdownValue = 3;
    _isBlindMode = false;
    _timerState = TimerState.initial();
    notifyListeners();
  }

  void tickCountdown() {
    if (_countdownValue > 1) {
      _countdownValue--;
      notifyListeners();
    } else {
      _screen = AppScreen.playing;
      notifyListeners();
      _startPrecisionTimer();
    }
  }

  void _startPrecisionTimer() {
    _precisionTimer?.dispose();
    final mode = _currentMode;
    if (mode == null) return;

    WakelockPlus.enable().catchError((_) {});

    // Double Tap: start waiting for the mid-tap
    if (mode.doubleTap) {
      _doubleTapPhase = 1;
      _doubleTapMidMs = 0;
    }

    _precisionTimer = PrecisionTimer(onTick: _onTimerTick);
    if (mode.countdownFrom != null) {
      _precisionTimer!.setCountdown(true, mode.countdownFrom!);
    }
    if (mode.id == 'surge') {
      _precisionTimer!.setSpeedMultiplier(_computeSurgeMultiplier());
    }
    _precisionTimer!.start();
  }

  double _computeSurgeMultiplier() =>
      (1.0 + _surgeGamesInSession * 0.067).clamp(1.0, 3.0);

  void _onTimerTick(TimerState state) {
    _timerState = state;
    final mode = _currentMode;
    if (mode != null &&
        mode.blindAfterMs != null &&
        state.elapsedMs >= mode.blindAfterMs!) {
      _isBlindMode = true;
    }
    notifyListeners();
  }

  /// Called from the playing screen when the user taps at the midpoint
  /// during Double Tap mode. Records the mid-tap time and advances phase.
  void doubleTapMid() {
    final timer = _precisionTimer;
    if (timer == null || _doubleTapPhase != 1) return;
    // getStoppedValue(0) returns _virtualElapsed without stopping the timer
    _doubleTapMidMs = timer.getStoppedValue(0);
    _doubleTapPhase = 2;
    Haptics.vibrate(HapticsType.medium).catchError((_) {});
    notifyListeners();
  }

  // Called from playing screen when user taps
  Future<void> stopGame() async {
    final timer = _precisionTimer;
    if (timer == null) return;

    final elapsedMs = timer.stop();
    final mode = _currentMode;
    if (mode == null) return;

    WakelockPlus.disable().catchError((_) {});

    final stoppedAtMs = timer.getStoppedValue(elapsedMs);

    // ── Determine effective target & deviation ───────────────
    final int effectiveTargetMs;
    final int effectiveDeviation;

    if (mode.doubleTap) {
      // Combined deviation: average of mid-tap error and stop error
      final midDev = (_doubleTapMidMs - _doubleTapMidpointMs).abs();
      final stopDev = (stoppedAtMs - mode.targetMs).abs();
      effectiveDeviation = (midDev + stopDev) ~/ _doubleTapDeviationDivisor;
      effectiveTargetMs = mode.targetMs;
      _doubleTapPhase = 0;
    } else if (mode.movingTarget) {
      effectiveTargetMs = movingTargetCurrentMs;
      effectiveDeviation = (stoppedAtMs - effectiveTargetMs).abs();
    } else {
      effectiveTargetMs = mode.targetMs;
      effectiveDeviation = (stoppedAtMs - effectiveTargetMs).abs();
    }

    // Process streak
    final streakResult = _streakManager.processAttempt(effectiveDeviation);
    final bestScore = _stats.bestScores[mode.id] ?? 0;

    // ── Calculate score ──────────────────────────────────────
    ScoreResult result;

    if (mode.doubleTap) {
      // Build score directly from combined deviation
      final rawScore = (kScoringConfig.maxScore - effectiveDeviation)
          .clamp(0, kScoringConfig.maxScore);
      final streakMult = calculateStreakMultiplier(streakResult.streakForScoring);
      final finalScore = (rawScore * streakMult).round();
      result = ScoreResult(
        stoppedAtMs: stoppedAtMs,
        targetMs: effectiveTargetMs,
        deviationMs: effectiveDeviation,
        rawScore: rawScore,
        streakMultiplier: streakMult,
        finalScore: finalScore,
        rating: getRating(effectiveDeviation),
        xpEarned: (finalScore / kScoringConfig.xpDivisor).round(),
        isNewBest: finalScore > bestScore,
      );
    } else if (mode.isPressure) {
      // Normal scoring for the individual round
      result = calculateScore(stoppedAtMs, mode, streakResult.streakForScoring, bestScore);
      // Update pressure state
      final hitTolerance = effectiveDeviation <= _pressureTolerance;
      _pressureLastRoundSuccess = hitTolerance;
      if (hitTolerance) {
        _pressureRoundsSucceeded++;
        _pressureTolerance = (_pressureTolerance - _pressureToleranceStepMs)
                .clamp(_pressureMinToleranceMs, _pressureInitialToleranceMs);
      } else {
        // Game over: override final score with rounds-survived score
        final pressureScore =
            (_pressureRoundsSucceeded * _pressurePointsPerRound)
                .clamp(0, kScoringConfig.maxScore);
        result = ScoreResult(
          stoppedAtMs: stoppedAtMs,
          targetMs: effectiveTargetMs,
          deviationMs: effectiveDeviation,
          rawScore: pressureScore,
          streakMultiplier: 1.0,
          finalScore: pressureScore,
          rating: getRating(effectiveDeviation),
          xpEarned: (pressureScore / kScoringConfig.xpDivisor).round(),
          isNewBest: pressureScore > bestScore,
        );
      }
    } else {
      result = calculateScore(
        stoppedAtMs,
        mode,
        streakResult.streakForScoring,
        bestScore,
        overrideTargetMs: mode.movingTarget ? effectiveTargetMs : null,
      );
    }

    // ── Calibration: accumulate attempts ─────────────────────
    if (mode.isCalibration) {
      _calibrationResults = [..._calibrationResults, result];
    }

    // ── Check achievements ───────────────────────────────────
    final newAchievements = _achievementChecker.checkAfterGame(
      result,
      _stats,
      mode.id,
      streakResult.newStreak,
    );

    // ── Update stats ─────────────────────────────────────────
    // For calibration, only persist stats after the final attempt.
    // For pressure success rounds, persist each round normally.
    final bool persistStats = !mode.isCalibration ||
        _calibrationResults.length >= mode.calibrationRounds;

    // Use averaged result for calibration final persistence
    ScoreResult resultToSave = result;
    if (mode.isCalibration && _calibrationResults.length >= mode.calibrationRounds) {
      final avgDev = _calibrationResults
              .map((r) => r.deviationMs)
              .reduce((a, b) => a + b) ~/
          _calibrationResults.length;
      final avgScore = _calibrationResults
              .map((r) => r.finalScore)
              .reduce((a, b) => a + b) ~/
          _calibrationResults.length;
      resultToSave = ScoreResult(
        stoppedAtMs: result.stoppedAtMs,
        targetMs: result.targetMs,
        deviationMs: avgDev,
        rawScore: avgScore,
        streakMultiplier: 1.0,
        finalScore: avgScore,
        rating: getRating(avgDev),
        xpEarned: (avgScore / kScoringConfig.xpDivisor).round(),
        isNewBest: avgScore > bestScore,
      );
    }

    final newStats = persistStats
        ? updateStats(_stats, resultToSave, mode.id, streakResult.newStreak)
        : _stats;

    // Coins (1 per 10 points); skip for calibration interim rounds
    final coinsEarned = persistStats ? resultToSave.finalScore ~/ 10 : 0;
    final newCoins = _coins + coinsEarned;

    // Surge: update game counter and fail streak
    if (mode.id == 'surge') {
      _surgeGamesInSession++;
      if (result.finalScore < 700) {
        _surgeFailStreak++;
      } else {
        _surgeFailStreak = 0;
      }
      if (_surgeFailStreak >= 3) {
        _surgePendingReset = true;
      }
    }

    // Moving Target: advance round
    if (mode.movingTarget) {
      _movingTargetRound++;
    }

    // Session
    final newSession = SessionStats(
      gamesPlayed: _sessionStats.gamesPlayed + 1,
      bestScore: resultToSave.finalScore > _sessionStats.bestScore
          ? resultToSave.finalScore
          : _sessionStats.bestScore,
      coinsEarned: _sessionStats.coinsEarned + coinsEarned,
      sessionStart: _sessionStats.sessionStart,
      surgeGamesPlayed: mode.id == 'surge'
          ? _surgeGamesInSession
          : _sessionStats.surgeGamesPlayed,
    );

    // Persist
    if (persistStats) {
      await Future.wait([
        _storage.saveStats(newStats),
        _storage.saveCoins(newCoins),
        _storage.saveAchievements([
          ..._achievements,
          ...newAchievements.map((a) => a.id),
        ]),
        _storage.saveStreak(
          streakResult.newStreak,
          _streakManager.getBestStreak(),
        ),
      ]);
    }

    // Apply state
    _lastResult = mode.isCalibration &&
            _calibrationResults.length >= mode.calibrationRounds
        ? resultToSave
        : result;
    if (persistStats) {
      _stats = newStats;
      _coins = newCoins;
      _achievements = [
        ..._achievements,
        ...newAchievements.map((a) => a.id),
      ];
    }
    _sessionStats = newSession;
    _timerState = _timerState.copyWith(isRunning: false);
    _screen = AppScreen.results;
    notifyListeners();

    // Sound feedback
    _playResultFeedback(resultToSave);

    // Submit to online leaderboard if signed in and new personal best
    if (resultToSave.isNewBest && _authState.isSignedIn) {
      final uid = _authState.user!.uid;
      _leaderboard.submitScore(
        uid: uid,
        modeId: mode.id,
        score: resultToSave.finalScore,
        displayName: _authState.userName,
      );
    }
  }

  void _playResultFeedback(ScoreResult result) {
    final deviation = result.deviationMs;
    if (deviation == 0) {
      Haptics.vibrate(HapticsType.success).catchError((_) {});
      _sound.play('perfect');
    } else if (deviation <= 50) {
      Haptics.vibrate(HapticsType.medium).catchError((_) {});
      _sound.play('excellent');
    } else if (deviation <= 250) {
      Haptics.vibrate(HapticsType.light).catchError((_) {});
      _sound.play('good');
    } else {
      Haptics.vibrate(HapticsType.error).catchError((_) {});
      _sound.play('miss');
    }
  }

  Future<void> playAgain() async {
    final mode = _currentMode;
    if (mode == null) return;

    // Determine if we are continuing a calibration run (not yet complete)
    final bool calibrationContinue = mode.isCalibration &&
        _calibrationResults.isNotEmpty &&
        _calibrationResults.length < mode.calibrationRounds;

    // Determine if we are continuing a pressure run (last round was a success)
    final bool pressureContinue = mode.isPressure && _pressureLastRoundSuccess;

    // Reset completed calibration run so next "Play Again" starts fresh
    if (mode.isCalibration && !calibrationContinue) {
      _calibrationResults = [];
    }

    // Reset pressure state when starting a new run (failure = game over)
    if (mode.isPressure && !pressureContinue) {
      _pressureTolerance = _pressureInitialToleranceMs;
      _pressureRoundsSucceeded = 0;
      _pressureLastRoundSuccess = false;
    }

    _lastResult = null;
    _surgePendingReset = false;
    _screen = AppScreen.countdown;
    notifyListeners();

    // Show interstitial every 5 games the user actively chooses to play again
    final gamesSinceLastAd = _stats.totalGames - _gamesAtLastAd;
    if (gamesSinceLastAd > 0 && gamesSinceLastAd % 5 == 0) {
      _gamesAtLastAd = _stats.totalGames;
      await _ads.showInterstitial();
    }
  }

  void returnToMenu() {
    _precisionTimer?.dispose();
    _precisionTimer = null;
    _currentMode = null;
    _lastResult = null;
    _isBlindMode = false;
    _timerState = TimerState.initial();
    _surgeGamesInSession = 0;
    _surgeFailStreak = 0;
    _surgePendingReset = false;
    // Reset new-mode state
    _doubleTapPhase = 0;
    _doubleTapMidMs = 0;
    _movingTargetRound = 0;
    _calibrationResults = [];
    _pressureTolerance = _pressureInitialToleranceMs;
    _pressureRoundsSucceeded = 0;
    _pressureLastRoundSuccess = false;
    _screen = AppScreen.menu;
    WakelockPlus.disable().catchError((_) {});
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  // SURGE ACTIONS
  // ═══════════════════════════════════════════════════════════

  void surgeAcceptReset() {
    _surgeGamesInSession = 0;
    _surgeFailStreak = 0;
    _surgePendingReset = false;
    notifyListeners();
  }

  Future<void> surgeWatchAdRetry() async {
    bool rewarded = false;
    final success = await _ads.showRewarded((_) { rewarded = true; });
    if (success && rewarded) {
      _surgeFailStreak = 0;
      _surgePendingReset = false;
      // Undo the last failed game's speed increment so the player
      // resumes at the speed they had before that failed round.
      if (_surgeGamesInSession > 0) _surgeGamesInSession--;
      // Reset the interstitial counter so the next ad is 5 games away
      _gamesAtLastAd = _stats.totalGames;
    } else {
      surgeAcceptReset();
    }
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  // DAILY REWARD
  // ═══════════════════════════════════════════════════════════

  void _checkDailyReward() {
    final today = _dateString(DateTime.now());
    if (_dailyRewards.lastClaimDate == null ||
        _dailyRewards.lastClaimDate != today) {
      _dailyRewards = DailyRewardState(
        lastClaimDate: _dailyRewards.lastClaimDate,
        loginStreak: _dailyRewards.loginStreak,
        canClaim: true,
      );
    }
  }

  Future<({int coins, int streak})?> claimDailyReward() async {
    if (!_dailyRewards.canClaim) return null;

    final today = _dateString(DateTime.now());
    final yesterday = _dateString(DateTime.now().subtract(const Duration(days: 1)));
    final isConsecutive = _dailyRewards.lastClaimDate == yesterday;
    final newStreak = isConsecutive ? _dailyRewards.loginStreak + 1 : 1;
    final rewardCoins = (50 + (newStreak - 1) * 10).clamp(0, 200);

    _dailyRewards = DailyRewardState(
      lastClaimDate: today,
      loginStreak: newStreak,
      canClaim: false,
    );
    _coins += rewardCoins;

    await Future.wait([
      _storage.saveDailyRewards(_dailyRewards),
      _storage.saveCoins(_coins),
    ]);

    notifyListeners();
    return (coins: rewardCoins, streak: newStreak);
  }

  void resetDailyReward() {
    _dailyRewards = const DailyRewardState(
      lastClaimDate: null,
      loginStreak: 0,
      canClaim: true,
    );
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  // COSMETICS / PROGRESSION
  // ═══════════════════════════════════════════════════════════

  void addCoins(int amount) {
    _coins += amount;
    _storage.saveCoins(_coins);
    notifyListeners();
  }

  bool purchaseCosmetic(String cosmeticId, int price) {
    if (_coins >= price && !_ownedCosmetics.contains(cosmeticId)) {
      _coins -= price;
      _ownedCosmetics = [..._ownedCosmetics, cosmeticId];
      _storage.saveCoins(_coins);
      _storage.saveOwnedCosmetics(_ownedCosmetics);
      notifyListeners();
      return true;
    }
    return false;
  }

  void equipCosmetic(String type, String cosmeticId) {
    if (!_ownedCosmetics.contains(cosmeticId)) return;
    _loadout = switch (type) {
      'timerSkin' => _loadout.copyWith(timerSkin: cosmeticId),
      'background' => _loadout.copyWith(background: cosmeticId),
      'soundPack' => _loadout.copyWith(soundPack: cosmeticId),
      'celebration' => _loadout.copyWith(celebration: cosmeticId),
      _ => _loadout,
    };
    _storage.saveLoadout(_loadout);
    notifyListeners();
  }

  void setSoundEnabled(bool enabled) {
    _sound.setEnabled(enabled);
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════

  static String _dateString(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  int get currentStreakValue => _streakManager.getCurrentStreak();
  int get bestStreakValue => _streakManager.getBestStreak();
  double get streakMultiplier => _streakManager.getMultiplier();

  @override
  void dispose() {
    _precisionTimer?.dispose();
    super.dispose();
  }
}
