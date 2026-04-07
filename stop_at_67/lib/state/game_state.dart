import 'dart:async';
import 'dart:math';
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
import '../services/matchmaking_service.dart';
import 'auth_state.dart';

enum AppScreen {
  menu,
  modeSelect,
  fortuneWheel,
  countdown,
  playing,
  results,
  settings,
  leaderboard,
  profile,
  shop,
  auth,
  matchmaking,
  matchLobby,
  matchPlaying,
  matchResults,
}

class GameState extends ChangeNotifier {
  final StorageService _storage;
  final SoundService _sound;
  final AdsService _ads;

  // ── Navigation ─────────────────────────────────────────────
  AppScreen _screen = AppScreen.menu;
  AppScreen get screen => _screen;
  AppScreen _authReturnScreen = AppScreen.menu;
  AppScreen get authReturnScreen => _authReturnScreen;

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
  /// Cumulative score across all rounds in the current Accelerate session.
  int _surgeCumulativeScore = 0;
  /// Number of lives remaining (starts at 3, excellent+ adds 1, anything else subtracts 1).
  int _surgeLives = 3;

  double get surgeSpeedMultiplier => _computeSurgeMultiplier();
  int get surgeFailStreak => _surgeFailStreak;
  bool get surgePendingReset => _surgePendingReset;
  int get surgeCumulativeScore => _surgeCumulativeScore;
  int get surgeLives => _surgeLives;

  // ── Hot streak (excellent+ in a row boosts final score) ──────
  int _hotStreak = 0;
  int get hotStreak => _hotStreak;

  // ── Session score ────────────────────────────────────────────
  int _sessionScore = 0;
  String? _sessionModeId; // which mode the session belongs to
  int get sessionScore => _sessionScore;

  // ── Fortune mode ─────────────────────────────────────────────
  double _fortuneMultiplier = 1.0;
  double get fortuneMultiplier => _fortuneMultiplier;

  // ── Double Tap mode ─────────────────────────────────────────
  // Phase: 0=not active, 1=running (waiting for mid-tap), 2=mid-done (waiting for stop)
  static const int _doubleTapMidpointMs = 3350;
  static const int _doubleTapDeviationDivisor = 2; // average mid-tap + stop deviation
  /// Maximum deviation from the midpoint that still lets the game continue.
  static const int _doubleTapMidToleranceMs = 500;
  int _doubleTapPhase = 0;
  int _doubleTapMidMs = 0; // virtual elapsed ms recorded at mid-tap
  int get doubleTapPhase => _doubleTapPhase;

  // ── Moving Target mode ──────────────────────────────────────
  static const int _movingTargetMinMs = 5000;
  static const int _movingTargetMaxMs = 9000;
  static const int _movingTargetStepMs = 100;
  int _movingTargetCurrentTarget = 6500; // random target for the current round
  final Random _rng = Random();
  int get movingTargetCurrentMs => _movingTargetCurrentTarget;

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
  /// Consecutive failed attempts at the current pressure level (resets on success).
  int _pressureFailAttempts = 0;
  /// True when the player has used their free retry and an ad retry is being offered.
  bool _pressurePendingAdRetry = false;
  /// True after all retries are exhausted — shows the final game-over result screen.
  bool _pressureGameOver = false;
  int get pressureTolerance => _pressureTolerance;
  int get pressureRoundsSucceeded => _pressureRoundsSucceeded;
  bool get pressureLastRoundSuccess => _pressureLastRoundSuccess;
  int get pressureFailAttempts => _pressureFailAttempts;
  bool get pressurePendingAdRetry => _pressurePendingAdRetry;
  bool get pressureGameOver => _pressureGameOver;

  // ── Weekly missions ─────────────────────────────────────────
  WeeklyMissionsState _weeklyMissions = const WeeklyMissionsState(
    weekId: '',
    missions: [],
  );
  WeeklyMissionsState get weeklyMissions => _weeklyMissions;

  // ── Internal ────────────────────────────────────────────────
  final StreakManager _streakManager = StreakManager();
  final AchievementChecker _achievementChecker = AchievementChecker();
  PrecisionTimer? _precisionTimer;
  bool _initialized = false;
  int _gamesAtLastAd = 0; // tracks totalGames when last interstitial was shown

  final AuthState _authState;
  final LeaderboardService _leaderboard;
  final MatchmakingService _matchmaking;

  // ── Multiplayer 1v1 ─────────────────────────────────────────
  MatchData? _currentMatch;
  MatchData? get currentMatch => _currentMatch;
  StreamSubscription<MatchData?>? _matchStreamSub;
  bool _matchSearching = false;
  bool get matchSearching => _matchSearching;
  bool _matchPlayerStopped = false;
  bool get matchPlayerStopped => _matchPlayerStopped;
  Timer? _matchmakingTimeout;
  bool _matchTimedOut = false;
  bool get matchTimedOut => _matchTimedOut;
  /// True when the current match is against a local bot (no Firestore writes).
  bool _isBotMatch = false;
  bool get isBotMatch => _isBotMatch;
  /// Opponent UID to rematch with (set after a real match, cleared on menu return).
  String? _rematchOpponentUid;
  /// Round number within the current rematch streak (1 = first game, 2 = second, etc.)
  int _rematchRound = 1;
  int get rematchRound => _rematchRound;
  /// Speed multiplier applied to the match timer — increases each rematch round.
  double _matchSpeedMultiplier = 1.0;
  double get matchSpeedMultiplier => _matchSpeedMultiplier;
  int _matchSeriesWins = 0;
  int get matchSeriesWins => _matchSeriesWins;
  int _matchSeriesLosses = 0;
  int get matchSeriesLosses => _matchSeriesLosses;
  int _matchSeriesTies = 0;
  int get matchSeriesTies => _matchSeriesTies;

  GameState({
    required StorageService storage,
    required SoundService sound,
    required AdsService ads,
    required AuthState authState,
    required LeaderboardService leaderboard,
    required MatchmakingService matchmaking,
  })  : _storage = storage,
        _sound = sound,
        _ads = ads,
        _authState = authState,
        _leaderboard = leaderboard,
        _matchmaking = matchmaking;

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
    _sound.setEnabled(await _storage.loadSoundEnabled());
    _ownedCosmetics = await _storage.loadOwnedCosmetics();
    _dailyRewards = await _storage.loadDailyRewards();

    final streakData = await _storage.loadStreak();
    _streakManager.loadState(
      streakData.currentStreak,
      streakData.bestStreak,
    );

    _checkDailyReward();
    _weeklyMissions = await _loadOrInitWeeklyMissions();
    _sessionStats = SessionStats.initial();

    notifyListeners();
  }

  Future<WeeklyMissionsState> _loadOrInitWeeklyMissions() async {
    final currentWeek = weekIdForDate(DateTime.now());
    final saved = await _storage.loadWeeklyMissions();
    if (saved != null && saved.weekId == currentWeek) return saved;
    // New week — start fresh
    return WeeklyMissionsState.initial(currentWeek, kWeeklyMissions);
  }

  // ═══════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════

  void setScreen(AppScreen screen) {
    if (screen == AppScreen.auth) _authReturnScreen = AppScreen.menu;
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
    _movingTargetCurrentTarget = mode.movingTarget ? _randomMovingTarget() : 6500;
    _calibrationResults = [];
    _pressureTolerance = _pressureInitialToleranceMs;
    _pressureRoundsSucceeded = 0;
    _pressureLastRoundSuccess = false;
    _pressureFailAttempts = 0;
    _pressurePendingAdRetry = false;
    _pressureGameOver = false;
    _doubleTapPhase = 0;
    _doubleTapMidMs = 0;
    // Reset Accelerate session state when selecting a new mode
    if (modeId == 'surge') {
      _surgeLives = 3;
      _surgeCumulativeScore = 0;
      _surgeGamesInSession = 0;
    }
    // Reset session score when switching to a different mode
    if (modeId != _sessionModeId) {
      _sessionScore = 0;
      _sessionModeId = modeId;
    }
    _screen = AppScreen.modeSelect;
    notifyListeners();
  }

  /// Navigates to the Fortune wheel screen. Does NOT deduct coins yet.
  bool startFortuneSpin() {
    if (_coins < kFortuneCost) return false;
    _fortuneMultiplier = 1.0;
    _screen = AppScreen.fortuneWheel;
    notifyListeners();
    return true;
  }

  /// Deducts the spin cost when the user actually taps SPIN on the wheel.
  /// Returns false if they can no longer afford it.
  bool chargeForSpin() {
    if (_coins < kFortuneCost) return false;
    _coins -= kFortuneCost;
    _storage.saveCoins(_coins);
    notifyListeners();
    return true;
  }

  /// Deducts an arbitrary coin amount. Returns false if insufficient funds.
  bool chargeCoins(int amount) {
    if (_coins < amount) return false;
    _coins -= amount;
    _storage.saveCoins(_coins);
    notifyListeners();
    return true;
  }

  /// Called from FortuneWheelScreen once the wheel lands.
  /// Selects the given mode, stores the multiplier, and starts the countdown.
  void applyFortuneResult(String modeId, double multiplier) {
    _fortuneMultiplier = multiplier;
    selectMode(modeId); // resets _surgeGamesInSession to 0 for surge
    if (modeId == 'surge' && multiplier > 1.0) {
      // Pre-offset surge speed so the timer starts at the fortune multiplier level.
      // Formula inverse of _computeSurgeMultiplier: games = (mult - 1.0) / 0.067
      _surgeGamesInSession = ((multiplier - 1.0) / 0.067).round();
    }
    startCountdown();
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

    // Moving Target: pick a new random target for this round
    if (mode.movingTarget) {
      _movingTargetCurrentTarget = _randomMovingTarget();
    }

    _precisionTimer = PrecisionTimer(onTick: _onTimerTick);
    if (mode.countdownFrom != null) {
      _precisionTimer!.setCountdown(true, mode.countdownFrom!);
    }
    if (mode.id == 'surge') {
      _precisionTimer!.setSpeedMultiplier(_computeSurgeMultiplier());
    } else if (_matchSpeedMultiplier > 1.0) {
      _precisionTimer!.setSpeedMultiplier(_matchSpeedMultiplier);
    }
    _precisionTimer!.start();
  }

  double _computeSurgeMultiplier() =>
      (1.0 + _surgeGamesInSession * 0.067).clamp(1.0, 3.0);

  /// Returns a random moving-target value within [_movingTargetMinMs, _movingTargetMaxMs],
  /// rounded to the nearest [_movingTargetStepMs], and different from the current target.
  int _randomMovingTarget() {
    const numSteps =
        (_movingTargetMaxMs - _movingTargetMinMs) ~/ _movingTargetStepMs;
    int target;
    do {
      target = _movingTargetMinMs + _rng.nextInt(numSteps + 1) * _movingTargetStepMs;
    } while (target == _movingTargetCurrentTarget && numSteps > 0);
    return target;
  }

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
  ///
  /// Returns `true` if the tap was close enough to the midpoint target
  /// (game continues to the second tap), or `false` if the deviation exceeds
  /// [_doubleTapMidToleranceMs] and the game should end immediately.
  bool doubleTapMid() {
    final timer = _precisionTimer;
    if (timer == null || _doubleTapPhase != 1) return false;
    // getStoppedValue(0) returns _virtualElapsed without stopping the timer
    _doubleTapMidMs = timer.getStoppedValue(0);
    final midDev = (_doubleTapMidMs - _doubleTapMidpointMs).abs();
    if (midDev > _doubleTapMidToleranceMs) {
      // Too far from the midpoint — game will end; phase stays at 1 so that
      // stopGame() can still compute the combined-deviation score correctly.
      return false;
    }
    _doubleTapPhase = 2;
    Haptics.vibrate(HapticsType.medium).catchError((_) {});
    notifyListeners();
    return true;
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
      // Build score directly from combined deviation (exponential curve)
      final rawScore = calculateRawScore(effectiveDeviation);
      final streakMult = calculateStreakMultiplier(streakResult.streakForScoring);
      final finalScore = rawScore;
      result = ScoreResult(
        stoppedAtMs: stoppedAtMs,
        targetMs: effectiveTargetMs,
        deviationMs: effectiveDeviation,
        rawScore: rawScore,
        streakMultiplier: streakMult,
        finalScore: finalScore,
        rating: getRating(effectiveDeviation),
        xpEarned: finalScore ~/ kScoringConfig.xpDivisor,
        isNewBest: finalScore > bestScore,
      );
    } else if (mode.isPressure) {
      // Normal scoring for the individual round
      result = calculateScore(stoppedAtMs, mode, streakResult.streakForScoring, bestScore);
      // Update pressure state
      final hitTolerance = effectiveDeviation <= _pressureTolerance;
      _pressureLastRoundSuccess = hitTolerance;
      if (hitTolerance) {
        // Success: advance level, reset fail counter
        _pressureRoundsSucceeded++;
        _pressureFailAttempts = 0;
        _pressurePendingAdRetry = false;
        _pressureTolerance = (_pressureTolerance - _pressureToleranceStepMs)
                .clamp(_pressureMinToleranceMs, _pressureInitialToleranceMs);
      } else {
        // Failure: track consecutive fail attempts at this level
        _pressureFailAttempts++;
        if (_pressureFailAttempts >= 2 && !_pressurePendingAdRetry) {
          // Second natural failure: offer the ad retry
          _pressurePendingAdRetry = true;
        } else if (_pressureFailAttempts >= 3) {
          // All retries exhausted (ad retry attempt also failed): final game over
          _pressureGameOver = true;
          _pressurePendingAdRetry = false;
        }
        // Score is based on rounds already survived (not incremented on failure)
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
          xpEarned: pressureScore ~/ kScoringConfig.xpDivisor,
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

    // ── Apply Surge speed multiplier to score ────────────────
    if (mode.id == 'surge') {
      final speedMult = _computeSurgeMultiplier();
      if (speedMult > 1.0) {
        final boosted = (result.finalScore * speedMult).round();
        result = ScoreResult(
          stoppedAtMs: result.stoppedAtMs,
          targetMs: result.targetMs,
          deviationMs: result.deviationMs,
          rawScore: result.rawScore,
          streakMultiplier: result.streakMultiplier,
          finalScore: boosted,
          rating: result.rating,
          xpEarned: boosted ~/ kScoringConfig.xpDivisor,
          isNewBest: boosted > bestScore,
        );
      }
    }

    // ── Apply Fortune multiplier ──────────────────────────────
    if (_fortuneMultiplier > 1.0) {
      final boosted = (result.finalScore * _fortuneMultiplier).round();
      result = ScoreResult(
        stoppedAtMs: result.stoppedAtMs,
        targetMs: result.targetMs,
        deviationMs: result.deviationMs,
        rawScore: result.rawScore,
        streakMultiplier: result.streakMultiplier,
        finalScore: boosted,
        rating: result.rating,
        xpEarned: boosted ~/ kScoringConfig.xpDivisor,
        isNewBest: boosted > bestScore,
      );
    }

    // ── Hot streak bonus (excellent+ in a row) ───────────────
    final tier = result.rating.tier;
    final isExcellentOrAbove =
        tier == 'perfect' || tier == 'incredible' || tier == 'excellent';
    if (isExcellentOrAbove) {
      _hotStreak++;
      if (_hotStreak > 1) {
        final hotBonus = 1.0 + (_hotStreak - 1) * 0.1; // +10% per extra consecutive excellent+
        final boosted = (result.finalScore * hotBonus).round();
        result = ScoreResult(
          stoppedAtMs: result.stoppedAtMs,
          targetMs: result.targetMs,
          deviationMs: result.deviationMs,
          rawScore: result.rawScore,
          streakMultiplier: result.streakMultiplier,
          finalScore: boosted,
          rating: result.rating,
          xpEarned: boosted ~/ kScoringConfig.xpDivisor,
          isNewBest: boosted > bestScore,
        );
      }
    } else {
      _hotStreak = 0;
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
    // For calibration: only persist after the final attempt.
    // For surge: only persist at game-over (when _surgePendingReset triggers).
    // For pressure: only persist at game-over (when _pressureGameOver triggers).
    final bool persistStats = switch (true) {
      _ when mode.isCalibration =>
        _calibrationResults.length >= mode.calibrationRounds,
      _ when mode.id == 'surge' => _surgePendingReset,
      _ when mode.isPressure => _pressureGameOver,
      _ => true,
    };

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
        xpEarned: avgScore ~/ kScoringConfig.xpDivisor,
        isNewBest: avgScore > bestScore,
      );
    }

    var newStats = persistStats
        ? updateStats(_stats, resultToSave, mode.id, streakResult.newStreak)
        : _stats;

    // Coins (1 per 10 points); skip for calibration interim rounds
    final coinsEarned = persistStats ? resultToSave.finalScore ~/ 10 : 0;
    final newCoins = _coins + coinsEarned;

    // Surge / Accelerate: update lives, speed level, and cumulative score
    if (mode.id == 'surge') {
      // Accumulate the round score into the session total
      _surgeCumulativeScore += result.finalScore;

      final tier = result.rating.tier;
      final isExcellentOrBetter =
          tier == 'perfect' || tier == 'incredible' || tier == 'excellent';

      if (isExcellentOrBetter) {
        // Excellent+: gain a life (lives effectively capped at 999) and advance speed
        _surgeLives++;
        _surgeGamesInSession++;
        _surgeFailStreak = 0;
      } else {
        // Anything below excellent: lose a life
        _surgeLives = (_surgeLives - 1).clamp(0, 999);
        _surgeFailStreak++;
      }
      if (_surgeLives <= 0) {
        _surgePendingReset = true;
      }
    }

    // Moving Target: next target is randomized on _startPrecisionTimer; nothing to track here.

    // ── Session score ────────────────────────────────────────────
    // Only update session score for non-pressure, non-calibration, non-surge normal rounds
    if (!mode.isPressure && !mode.isCalibration && mode.id != 'surge') {
      final tier = result.rating.tier;
      if (tier == 'great' || tier == 'excellent' || tier == 'incredible' || tier == 'perfect') {
        _sessionScore += result.finalScore;
      } else if (tier == 'miss') {
        _sessionScore = (_sessionScore - 200).clamp(0, 999999);
      }
      // good / ok: no change

      // If the session total now beats the stored best, patch newStats so it
      // gets persisted and submitted to the leaderboard.
      if (persistStats && _sessionScore > (newStats.bestScores[mode.id] ?? 0)) {
        final patchedBest = Map<String, int>.from(newStats.bestScores)..[mode.id] = _sessionScore;
        newStats = newStats.copyWith(bestScores: patchedBest);
      }
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

    // ── Update weekly missions ────────────────────────────────
    if (persistStats) {
      _weeklyMissions = _advanceMissions(
        _weeklyMissions,
        result: resultToSave,
        modeId: mode.id,
        newStreak: streakResult.newStreak,
      );
    }

    // Apply state and transition to results immediately (storage persists in background)
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

    // Persist asynchronously — fire and forget so the UI isn't blocked
    if (persistStats) {
      Future.wait([
        _storage.saveStats(_stats),
        _storage.saveCoins(_coins),
        _storage.saveAchievements(_achievements),
        _storage.saveStreak(
          streakResult.newStreak,
          _streakManager.getBestStreak(),
        ),
        _storage.saveWeeklyMissions(_weeklyMissions),
      ]).catchError((_) => <void>[]);
    }

    // Submit to online leaderboard if signed in.
    // For normal modes: submit the session cumulative score when it beats the stored best.
    // For surge/pressure/calibration: submit the single-round score as before.
    if (_authState.isSignedIn) {
      final uid = _authState.user!.uid;
      final bool isSessionMode = !mode.isPressure && !mode.isCalibration && mode.id != 'surge';
      final int scoreToSubmit = isSessionMode ? _sessionScore : resultToSave.finalScore;
      final bool isNewBest = scoreToSubmit > bestScore;

      if (isNewBest) {
        _leaderboard.submitScore(
          uid: uid,
          modeId: mode.id,
          score: scoreToSubmit,
          displayName: _authState.userName,
        );
        _leaderboard.submitTournamentScore(
          uid: uid,
          displayName: _authState.userName,
          score: scoreToSubmit,
        );
      }
    }
  }

  void _playResultFeedback(ScoreResult result) {
    // Surge game-over overrides any positive sound — it's a fail state
    if (_surgePendingReset) {
      Haptics.vibrate(HapticsType.error).catchError((_) {});
      _sound.play('miss');
      return;
    }
    final mode = _currentMode;
    // Pressure failure (any round, including game-over): play failure sound
    if (mode != null && mode.isPressure && !_pressureLastRoundSuccess) {
      Haptics.vibrate(HapticsType.error).catchError((_) {});
      _sound.play('miss');
      return;
    }
    if (mode != null && mode.id == 'surge') {
      final tier = result.rating.tier;
      final isExcellentOrBetter =
          tier == 'perfect' || tier == 'incredible' || tier == 'excellent';
      if (!isExcellentOrBetter) {
        Haptics.vibrate(HapticsType.error).catchError((_) {});
        _sound.play('miss');
        return;
      }
    }
    final tier = result.rating.tier;
    switch (tier) {
      case 'perfect':
        Haptics.vibrate(HapticsType.success).catchError((_) {});
        _sound.play('perfect');
      case 'incredible':
      case 'excellent':
        Haptics.vibrate(HapticsType.medium).catchError((_) {});
        _sound.play('excellent');
      case 'great':
        Haptics.vibrate(HapticsType.medium).catchError((_) {});
        _sound.play('great');
      case 'good':
        Haptics.vibrate(HapticsType.light).catchError((_) {});
        _sound.play('good');
      case 'ok':
        Haptics.vibrate(HapticsType.light).catchError((_) {});
        _sound.play('ok');
      default: // miss
        Haptics.vibrate(HapticsType.error).catchError((_) {});
        _sound.play('miss');
    }
  }

  Future<void> playAgain() async {
    final mode = _currentMode;
    if (mode == null) return;

    // Fortune boost is single-use: after one round, return to mode select.
    // Surge and Pressure are exempt — they run until the user manually exits.
    if (_fortuneMultiplier > 1.0 && !mode.isPressure && mode.id != 'surge') {
      _fortuneMultiplier = 1.0;
      _lastResult = null;
      _currentMode = null;
      _screen = AppScreen.modeSelect;
      notifyListeners();
      return;
    }

    // Determine if we are continuing a calibration run (not yet complete)
    final bool calibrationContinue = mode.isCalibration &&
        _calibrationResults.isNotEmpty &&
        _calibrationResults.length < mode.calibrationRounds;

    // Reset completed calibration run so next "Play Again" starts fresh
    if (mode.isCalibration && !calibrationContinue) {
      _calibrationResults = [];
    }

    // Reset pressure state when starting a brand-new run after final game over
    if (mode.isPressure && _pressureGameOver) {
      _pressureTolerance = _pressureInitialToleranceMs;
      _pressureRoundsSucceeded = 0;
      _pressureLastRoundSuccess = false;
      _pressureFailAttempts = 0;
      _pressurePendingAdRetry = false;
      _pressureGameOver = false;
    }

    _lastResult = null;
    _surgePendingReset = false;
    _hotStreak = 0;
    await _sound.cleanup();
    await startCountdown();
  }

  Future<void> returnToMenu() async {
    await _sound.cleanup();
    _precisionTimer?.dispose();
    _precisionTimer = null;
    _currentMode = null;
    _lastResult = null;
    _isBlindMode = false;
    _timerState = TimerState.initial();
    // Preserve _surgeGamesInSession so the player resumes at the same speed
    // level when they return to Accelerate from the lobby.
    _surgeFailStreak = 0;
    _surgePendingReset = false;
    // Reset new-mode state
    _doubleTapPhase = 0;
    _doubleTapMidMs = 0;
    _calibrationResults = [];
    _pressureTolerance = _pressureInitialToleranceMs;
    _pressureRoundsSucceeded = 0;
    _pressureLastRoundSuccess = false;
    _pressureFailAttempts = 0;
    _pressurePendingAdRetry = false;
    _pressureGameOver = false;
    _sessionScore = 0;
    _sessionModeId = null;
    _fortuneMultiplier = 1.0;
    _hotStreak = 0;
    _screen = AppScreen.modeSelect;
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
    _surgeLives = 3;
    _surgeCumulativeScore = 0;
    notifyListeners();
  }

  Future<void> surgeWatchAdRetry() async {
    bool rewarded = false;
    final success = await _ads.showRewarded((_) { rewarded = true; });
    if (success && rewarded) {
      // Ad rewards exactly 1 life — speed and cumulative score are preserved
      _surgeLives = 1;
      _surgeFailStreak = 0;
      _surgePendingReset = false;
      // Reset the interstitial counter so the next ad is 5 games away
      _gamesAtLastAd = _stats.totalGames;
    } else {
      surgeAcceptReset();
    }
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  // PRESSURE ACTIONS
  // ═══════════════════════════════════════════════════════════

  /// Retry the current pressure level for free (after the first failure).
  Future<void> pressureFreeRetry() async {
    _pressureLastRoundSuccess = false;
    _lastResult = null;
    _surgePendingReset = false;
    await startCountdown();
  }

  /// Show a rewarded ad. If the ad is rewarded, grant one extra attempt at the
  /// current pressure level. Otherwise treat as a full game-over.
  Future<void> pressureWatchAdRetry() async {
    bool rewarded = false;
    final success = await _ads.showRewarded((_) { rewarded = true; });
    if (success && rewarded) {
      _pressurePendingAdRetry = false;
      // Keep _pressureFailAttempts at 2 so that a subsequent fail increments to 3
      // and triggers _pressureGameOver in stopGame().
      _gamesAtLastAd = _stats.totalGames;
      _lastResult = null;
      await startCountdown();
    } else {
      // Ad not shown or not rewarded — mark as final game over
      _pressureAcceptGameOver();
    }
  }

  /// Dismiss the pressure retry options and accept the game-over outcome.
  void pressureAcceptGameOver() {
    _pressureTolerance = _pressureInitialToleranceMs;
    _pressureRoundsSucceeded = 0;
    _pressureLastRoundSuccess = false;
    _pressureFailAttempts = 0;
    _pressurePendingAdRetry = false;
    _pressureGameOver = true;
    notifyListeners();
  }

  void _pressureAcceptGameOver() => pressureAcceptGameOver();

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

  void unequipCosmetic(String type) {
    _loadout = switch (type) {
      'timerSkin' => _loadout.copyWith(timerSkin: 'timer_skin_default'),
      'background' => _loadout.copyWith(background: 'bg_default'),
      'soundPack' => _loadout.copyWith(soundPack: 'sound_default'),
      'celebration' => _loadout.copyWith(celebration: 'celebration_default'),
      _ => _loadout,
    };
    _storage.saveLoadout(_loadout);
    notifyListeners();
  }

  bool get isSoundEnabled => _sound.isEnabled;

  void setSoundEnabled(bool enabled) {
    _sound.setEnabled(enabled);
    _storage.saveSoundEnabled(enabled);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  // WEEKLY MISSIONS
  // ═══════════════════════════════════════════════════════════

  /// Advance mission progress based on the game just played.
  WeeklyMissionsState _advanceMissions(
    WeeklyMissionsState state, {
    required ScoreResult result,
    required String modeId,
    required int newStreak,
  }) {
    final updatedMissions = state.missions.map((mp) {
      if (mp.claimed) return mp;
      final def = kWeeklyMissions.firstWhere(
        (d) => d.id == mp.missionId,
        orElse: () => const WeeklyMissionDef(
          id: '', label: '', description: '', target: 0, type: '', rewardCoins: 0,
        ),
      );
      if (def.id.isEmpty || def.type == 'modes') return mp;

      if (def.type == 'games') {
        return mp.copyWith(progress: (mp.progress + 1).clamp(0, def.target));
      } else if (def.type == 'perfects') {
        if (result.deviationMs == 0) {
          return mp.copyWith(progress: (mp.progress + 1).clamp(0, def.target));
        }
      } else if (def.type == 'score') {
        if (result.finalScore >= def.target && mp.progress < def.target) {
          return mp.copyWith(progress: def.target);
        }
      } else if (def.type == 'streak') {
        if (newStreak > mp.progress) {
          return mp.copyWith(progress: newStreak.clamp(0, def.target));
        }
      }
      return mp;
    }).toList();

    // Handle the 'modes' mission using the persisted playedModeIds list
    final newPlayedModeIds = List<String>.from(state.playedModeIds);
    if (!newPlayedModeIds.contains(modeId)) {
      newPlayedModeIds.add(modeId);
    }
    final modesMissionIdx = updatedMissions.indexWhere(
      (m) => m.missionId == 'modes_3',
    );
    if (modesMissionIdx != -1) {
      final mp = updatedMissions[modesMissionIdx];
      if (!mp.claimed) {
        final count = newPlayedModeIds.length.clamp(0, 3);
        if (count > mp.progress) {
          updatedMissions[modesMissionIdx] = mp.copyWith(progress: count);
        }
      }
    }

    return state.copyWith(missions: updatedMissions, playedModeIds: newPlayedModeIds);
  }

  /// Claim the coin reward for a completed mission.
  Future<bool> claimMissionReward(String missionId) async {
    final missionIdx = _weeklyMissions.missions.indexWhere(
      (m) => m.missionId == missionId && !m.claimed,
    );
    if (missionIdx == -1) return false;

    final def = kWeeklyMissions.firstWhere(
      (d) => d.id == missionId,
      orElse: () => const WeeklyMissionDef(
        id: '', label: '', description: '', target: 0, type: '', rewardCoins: 0,
      ),
    );
    if (def.id.isEmpty) return false;

    final mp = _weeklyMissions.missions[missionIdx];
    if (mp.progress < def.target) return false;

    final updatedMissions = List<WeeklyMissionProgress>.from(_weeklyMissions.missions);
    updatedMissions[missionIdx] = mp.copyWith(claimed: true);
    _weeklyMissions = _weeklyMissions.copyWith(missions: updatedMissions);
    _coins += def.rewardCoins;

    await Future.wait([
      _storage.saveWeeklyMissions(_weeklyMissions),
      _storage.saveCoins(_coins),
    ]);

    notifyListeners();
    return true;
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════

  static String _dateString(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  int get currentStreakValue => _streakManager.getCurrentStreak();
  int get bestStreakValue => _streakManager.getBestStreak();
  double get streakMultiplier => _streakManager.getMultiplier();

  // ═══════════════════════════════════════════════════════════
  // MULTIPLAYER 1v1
  // ═══════════════════════════════════════════════════════════

  /// Start searching for a 1v1 opponent. Navigates to the matchmaking screen.
  Future<void> startMatchmaking({bool acceptSpeedUp = false}) async {
    if (!_authState.isSignedIn) {
      _authReturnScreen = AppScreen.matchmaking;
      _screen = AppScreen.auth;
      notifyListeners();
      return;
    }
    await _sound.cleanup();

    // Fresh matchmaking resets rematch state; coming from results keeps it
    final isRematch = _rematchOpponentUid != null;
    if (!isRematch) {
      _rematchRound = 1;
      _matchSpeedMultiplier = 1.0;
      _resetMatchSeriesRecord();
    }
    final preferOpponent = _rematchOpponentUid;
    final queuedRematchRound = _rematchRound;
    final allowSpeedUp = isRematch && acceptSpeedUp;
    _rematchOpponentUid = null;

    _matchSearching = true;
    _currentMatch = null;
    _matchPlayerStopped = false;
    _matchTimedOut = false;
    _isBotMatch = false;
    _screen = AppScreen.matchmaking;
    notifyListeners();

    final uid = _authState.user!.uid;
    const modeId = 'classic';
    const targetMs = 6700;

    // Start a 7-second timeout — if no opponent found, try once more then show bot option
    _matchmakingTimeout?.cancel();
    _matchmakingTimeout = Timer(const Duration(seconds: 7), () async {
      if (!_matchSearching || _screen != AppScreen.matchmaking) return;
      // Try to match with any waiting player one last time
      try {
        final lateMatchId = await _matchmaking.joinQueue(
          uid: uid,
          displayName: _authState.userName,
          modeId: modeId,
          targetMs: targetMs,
          preferOpponentUid: preferOpponent,
          acceptSpeedUp: allowSpeedUp,
          rematchRound: queuedRematchRound,
        );
        if (lateMatchId != null && _matchSearching && _screen == AppScreen.matchmaking) {
          _subscribeToMatch(lateMatchId);
          return;
        }
      } catch (_) {}
      // No opponent found — show bot option
      if (_matchSearching && _screen == AppScreen.matchmaking) {
        _matchTimedOut = true;
        notifyListeners();
      }
    });

    final matchId = await _matchmaking.joinQueue(
      uid: uid,
      displayName: _authState.userName,
      modeId: modeId,
      targetMs: targetMs,
      preferOpponentUid: preferOpponent,
      acceptSpeedUp: allowSpeedUp,
      rematchRound: queuedRematchRound,
    );

    if (matchId != null) {
      // Matched immediately — listen to the match doc
      _matchmakingTimeout?.cancel();
      _subscribeToMatch(matchId);
    } else {
      // Queued — listen for when an opponent creates the match
      _matchmaking.listenForMatch(
        uid: uid,
        modeId: modeId,
        onMatchFound: (id) {
          _matchmakingTimeout?.cancel();
          _subscribeToMatch(id);
        },
      );
    }
  }

  void _subscribeToMatch(String matchId) {
    _matchStreamSub?.cancel();
    _matchStreamSub = _matchmaking.watchMatch(matchId).listen((match) {
      if (match == null) return;
      _currentMatch = match;
      _matchSpeedMultiplier = match.speedMultiplier;
      _matchSearching = false;

      if (match.status == MatchStatus.countdown &&
          _screen == AppScreen.matchmaking) {
        _screen = AppScreen.matchLobby;
        notifyListeners();
      } else if (match.status == MatchStatus.playing &&
          (_screen == AppScreen.matchLobby ||
              _screen == AppScreen.matchmaking)) {
        // Countdown finished — also handles first snapshot arriving as playing
        _currentMode = kGameModes[match.modeId] ?? kGameModes['classic']!;
        _screen = AppScreen.matchPlaying;
        _timerState = TimerState.initial();
        _matchPlayerStopped = false;
        notifyListeners();
        _startPrecisionTimer();
      } else if (match.status == MatchStatus.finished) {
        // Remember opponent for rematch and bump speed for next round
        final myUid = _authState.user?.uid;
        _rematchOpponentUid = myUid == match.player1.uid
            ? match.player2?.uid
            : match.player1.uid;
        _rematchRound++;
        _matchSpeedMultiplier = 1.0;
        // Play winner/loser sound
        final myPlayer = myUid == match.player1.uid ? match.player1 : match.player2;
        final oppPlayer = myUid == match.player1.uid ? match.player2 : match.player1;
        final myScore = myPlayer?.score ?? 0;
        final oppScore = oppPlayer?.score ?? 0;
        _updateMatchSeriesRecord(myScore: myScore, oppScore: oppScore);
        if (myScore == oppScore) {
          _sound.play('great');
        } else {
          _sound.play(myScore > oppScore ? 'winner' : 'loser');
        }
        _screen = AppScreen.matchResults;
        notifyListeners();
      } else if (match.status == MatchStatus.cancelled) {
        _cancelMultiplayer();
      } else {
        notifyListeners();
      }
    });
  }

  /// Cancel matchmaking or leave a match.
  Future<void> _cancelMultiplayer() async {
    _matchmakingTimeout?.cancel();
    _matchStreamSub?.cancel();
    _matchStreamSub = null;
    _matchSearching = false;
    _matchTimedOut = false;
    _isBotMatch = false;
    _currentMatch = null;
    _matchPlayerStopped = false;
    _resetMatchSeriesRecord();
    _precisionTimer?.dispose();
    _precisionTimer = null;
    _timerState = TimerState.initial();
    _screen = AppScreen.menu;
    WakelockPlus.disable().catchError((_) {});
    notifyListeners();
  }

  Future<void> cancelMatchmaking() async {
    _matchmakingTimeout?.cancel();
    if (_authState.isSignedIn) {
      try {
        await _matchmaking.leaveQueue(_authState.user!.uid);
      } catch (_) {}
    }
    final match = _currentMatch;
    if (match != null &&
        match.status != MatchStatus.finished &&
        match.status != MatchStatus.cancelled) {
      await _matchmaking.cancelMatch(match.matchId);
    }
    await _cancelMultiplayer();
  }

  /// Start a local bot match — zero Firestore writes.
  /// The bot's result is generated locally after the player stops.
  Future<void> playAgainstBot() async {
    if (!_authState.isSignedIn) return;

    // Leave the real queue first (may fail if never queued due to Firestore rules — ignore)
    _matchmakingTimeout?.cancel();
    try {
      await _matchmaking.leaveQueue(_authState.user!.uid);
    } catch (_) {}

    _isBotMatch = true;
    _matchSearching = false;
    _matchTimedOut = false;
    _resetMatchSeriesRecord();

    final uid = _authState.user!.uid;
    const targetMs = 6700;

    // Build a purely local MatchData (never touches Firestore)
    _currentMatch = MatchData(
      matchId: 'bot_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}',
      modeId: 'classic',
      targetMs: targetMs,
      speedMultiplier: 1.0,
      status: MatchStatus.countdown,
      player1: MatchPlayer(uid: uid, displayName: _authState.userName),
      player2: const MatchPlayer(uid: 'bot', displayName: '🤖 Bot'),
      createdAt: DateTime.now(),
    );

    _screen = AppScreen.matchLobby;
    notifyListeners();
  }

  /// Rematch directly against a bot — skips queue entirely (used from match results).
  /// If [increaseSpeed] is false, keeps the current speed multiplier.
  Future<void> rematchBot({bool increaseSpeed = false}) async {
    if (!_authState.isSignedIn) return;
    await _sound.cleanup();
    _matchmakingTimeout?.cancel();
    _matchStreamSub?.cancel();
    _matchStreamSub = null;
    _isBotMatch = true;
    _matchSearching = false;
    _matchTimedOut = false;
    _matchPlayerStopped = false;
    if (increaseSpeed) {
      _rematchRound++;
      _matchSpeedMultiplier =
          (1.0 + (_rematchRound - 1) * 0.2).clamp(1.0, 3.0);
    }

    final uid = _authState.user!.uid;
    _currentMatch = MatchData(
      matchId: 'bot_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}',
      modeId: 'classic',
      targetMs: 6700,
      speedMultiplier: _matchSpeedMultiplier,
      status: MatchStatus.countdown,
      player1: MatchPlayer(uid: uid, displayName: _authState.userName),
      player2: const MatchPlayer(uid: 'bot', displayName: '🤖 Bot'),
      createdAt: DateTime.now(),
    );
    _screen = AppScreen.matchLobby;
    notifyListeners();
  }

  /// Called from matchLobby when countdown finishes — handles bot transition.
  Future<void> matchCountdownComplete() async {
    final match = _currentMatch;
    if (match == null) return;

    if (_isBotMatch) {
      // Local bot match — skip Firestore, just transition screens
      _currentMatch = MatchData(
        matchId: match.matchId,
        modeId: match.modeId,
        targetMs: match.targetMs,
        speedMultiplier: match.speedMultiplier,
        status: MatchStatus.playing,
        player1: match.player1,
        player2: match.player2,
        createdAt: match.createdAt,
      );
      _currentMode = kGameModes[match.modeId] ?? kGameModes['classic']!;
      _screen = AppScreen.matchPlaying;
      _timerState = TimerState.initial();
      _matchPlayerStopped = false;
      notifyListeners();
      _startPrecisionTimer();
    } else {
      await _matchmaking.startMatch(match.matchId);
    }
  }

  /// Stop the timer and submit this player's result.
  Future<void> stopMatchGame() async {
    final timer = _precisionTimer;
    if (timer == null || _matchPlayerStopped) return;
    _matchPlayerStopped = true;

    final elapsedMs = timer.stop();
    final stoppedAtMs = timer.getStoppedValue(elapsedMs);
    final match = _currentMatch;
    if (match == null) return;

    WakelockPlus.disable().catchError((_) {});

    final deviationMs = (stoppedAtMs - match.targetMs).abs();
    final rawScore = calculateRawScore(deviationMs);

    _timerState = _timerState.copyWith(isRunning: false);
    notifyListeners();

    if (_isBotMatch) {
      // Generate bot result locally — no Firestore writes
      _completeBotMatch(
        playerStoppedAtMs: stoppedAtMs,
        playerDeviationMs: deviationMs,
        playerScore: rawScore,
      );
    } else {
      await _matchmaking.submitResult(
        matchId: match.matchId,
        uid: _authState.user!.uid,
        stoppedAtMs: stoppedAtMs,
        deviationMs: deviationMs,
        score: rawScore,
      );
    }
  }

  /// Instantly resolve a bot match. The bot's deviation is random 50–400ms.
  void _completeBotMatch({
    required int playerStoppedAtMs,
    required int playerDeviationMs,
    required int playerScore,
  }) {
    final match = _currentMatch;
    if (match == null) return;

    final rng = Random();
    final botDeviationMs = 20 + rng.nextInt(131); // 20..150ms — bot always stops within ±150ms
    final botScore = calculateRawScore(botDeviationMs);
    final botStoppedAtMs = match.targetMs + (rng.nextBool() ? botDeviationMs : -botDeviationMs);

    final uid = _authState.user!.uid;
    final isPlayer1 = match.player1.uid == uid;

    _currentMatch = MatchData(
      matchId: match.matchId,
      modeId: match.modeId,
      targetMs: match.targetMs,
      speedMultiplier: match.speedMultiplier,
      status: MatchStatus.finished,
      player1: isPlayer1
          ? MatchPlayer(
              uid: uid,
              displayName: match.player1.displayName,
              stoppedAtMs: playerStoppedAtMs,
              deviationMs: playerDeviationMs,
              score: playerScore,
            )
          : MatchPlayer(
              uid: 'bot',
              displayName: '🤖 Bot',
              stoppedAtMs: botStoppedAtMs,
              deviationMs: botDeviationMs,
              score: botScore,
            ),
      player2: isPlayer1
          ? MatchPlayer(
              uid: 'bot',
              displayName: '🤖 Bot',
              stoppedAtMs: botStoppedAtMs,
              deviationMs: botDeviationMs,
              score: botScore,
            )
          : MatchPlayer(
              uid: uid,
              displayName: match.player2?.displayName ?? _authState.userName,
              stoppedAtMs: playerStoppedAtMs,
              deviationMs: playerDeviationMs,
              score: playerScore,
            ),
      createdAt: match.createdAt,
    );

    final didWin = playerScore > botScore;
    final isTie = playerScore == botScore;
    _updateMatchSeriesRecord(myScore: playerScore, oppScore: botScore);
    _sound.play(isTie ? 'great' : (didWin ? 'winner' : 'loser'));

    _screen = AppScreen.matchResults;
    notifyListeners();
  }

  /// Return to menu from match results.
  Future<void> matchReturnToMenu() async {
    await _sound.cleanup();
    _matchmakingTimeout?.cancel();
    _matchStreamSub?.cancel();
    _matchStreamSub = null;
    _currentMatch = null;
    _matchPlayerStopped = false;
    _isBotMatch = false;
    _matchTimedOut = false;
    _rematchOpponentUid = null;
    _rematchRound = 1;
    _matchSpeedMultiplier = 1.0;
    _resetMatchSeriesRecord();
    _precisionTimer?.dispose();
    _precisionTimer = null;
    _timerState = TimerState.initial();
    _screen = AppScreen.menu;
    notifyListeners();
  }

  @override
  void dispose() {
    _precisionTimer?.dispose();
    _matchmakingTimeout?.cancel();
    _matchStreamSub?.cancel();
    _matchmaking.dispose();
    super.dispose();
  }

  void _resetMatchSeriesRecord() {
    _matchSeriesWins = 0;
    _matchSeriesLosses = 0;
    _matchSeriesTies = 0;
  }

  void _updateMatchSeriesRecord({
    required int myScore,
    required int oppScore,
  }) {
    if (myScore > oppScore) {
      _matchSeriesWins++;
    } else if (myScore < oppScore) {
      _matchSeriesLosses++;
    } else {
      _matchSeriesTies++;
    }
  }
}
