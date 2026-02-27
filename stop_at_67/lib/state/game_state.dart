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

  // ── Internal ────────────────────────────────────────────────
  final StreakManager _streakManager = StreakManager();
  final AchievementChecker _achievementChecker = AchievementChecker();
  PrecisionTimer? _precisionTimer;
  bool _initialized = false;

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
    _screen = AppScreen.modeSelect;
    notifyListeners();
  }

  void startCountdown() {
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

    _precisionTimer = PrecisionTimer(onTick: _onTimerTick);
    if (mode.countdownFrom != null) {
      _precisionTimer!.setCountdown(true, mode.countdownFrom!);
    }
    _precisionTimer!.start();
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

  // Called from playing screen when user taps
  Future<void> stopGame() async {
    final timer = _precisionTimer;
    if (timer == null) return;

    final elapsedMs = timer.stop();
    final mode = _currentMode;
    if (mode == null) return;

    WakelockPlus.disable().catchError((_) {});

    final stoppedAtMs = timer.getStoppedValue(elapsedMs);
    final deviation = (stoppedAtMs - mode.targetMs).abs();

    // Process streak
    final streakResult = _streakManager.processAttempt(deviation);
    final bestScore = _stats.bestScores[mode.id] ?? 0;

    // Calculate score
    final result = calculateScore(
      stoppedAtMs,
      mode,
      streakResult.streakForScoring,
      bestScore,
    );

    // Check achievements
    final newAchievements = _achievementChecker.checkAfterGame(
      result,
      _stats,
      mode.id,
      streakResult.newStreak,
    );

    // Update stats
    final newStats = updateStats(_stats, result, mode.id, streakResult.newStreak);

    // Coins (1 per 10 points)
    final coinsEarned = result.finalScore ~/ 10;
    final newCoins = _coins + coinsEarned;

    // Session
    final newSession = SessionStats(
      gamesPlayed: _sessionStats.gamesPlayed + 1,
      bestScore: result.finalScore > _sessionStats.bestScore
          ? result.finalScore
          : _sessionStats.bestScore,
      coinsEarned: _sessionStats.coinsEarned + coinsEarned,
      sessionStart: _sessionStats.sessionStart,
    );

    // Persist
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

    // Apply state
    _lastResult = result;
    _stats = newStats;
    _coins = newCoins;
    _achievements = [..._achievements, ...newAchievements.map((a) => a.id)];
    _sessionStats = newSession;
    _timerState = _timerState.copyWith(isRunning: false);
    _screen = AppScreen.results;
    notifyListeners();

    // Sound feedback
    _playResultFeedback(result);

    // Submit to online leaderboard if signed in and new personal best
    if (result.isNewBest && _authState.isSignedIn) {
      final uid = _authState.user!.uid;
      _leaderboard.submitScore(
        uid: uid,
        modeId: mode.id,
        score: result.finalScore,
        displayName: _authState.userName,
      );
    }

    // Ad after every 5 lifetime games (persisted across sessions)
    if (AdsService.shouldShowAd(newStats.totalGames)) {
      await _ads.showInterstitial();
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

  void playAgain() {
    if (_currentMode == null) return;
    _lastResult = null;
    _isBlindMode = false;
    _countdownValue = 3;
    _timerState = TimerState.initial();
    _screen = AppScreen.countdown;
    notifyListeners();
  }

  void returnToMenu() {
    _precisionTimer?.dispose();
    _precisionTimer = null;
    _currentMode = null;
    _lastResult = null;
    _isBlindMode = false;
    _timerState = TimerState.initial();
    _screen = AppScreen.menu;
    WakelockPlus.disable().catchError((_) {});
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
