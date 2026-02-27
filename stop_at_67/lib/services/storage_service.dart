import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../engine/types.dart';

class StorageService {
  static const _statsKey = 'stop_at_67_stats';
  static const _achievementsKey = 'stop_at_67_achievements';
  static const _coinsKey = 'stop_at_67_coins';
  static const _loadoutKey = 'stop_at_67_loadout';
  static const _dailyRewardsKey = 'stop_at_67_daily_rewards';
  static const _languageKey = 'stop_at_67_language';
  static const _ownedCosmeticsKey = 'stop_at_67_owned_cosmetics';
  static const _streakKey = 'stop_at_67_streak';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<PlayerStats> loadStats() async {
    final prefs = await _prefs;
    final json = prefs.getString(_statsKey);
    if (json == null) return _defaultStats();
    try {
      return PlayerStats.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return _defaultStats();
    }
  }

  Future<void> saveStats(PlayerStats stats) async {
    final prefs = await _prefs;
    await prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }

  Future<List<String>> loadAchievements() async {
    final prefs = await _prefs;
    return prefs.getStringList(_achievementsKey) ?? [];
  }

  Future<void> saveAchievements(List<String> ids) async {
    final prefs = await _prefs;
    await prefs.setStringList(_achievementsKey, ids);
  }

  Future<int> loadCoins() async {
    final prefs = await _prefs;
    return prefs.getInt(_coinsKey) ?? 0;
  }

  Future<void> saveCoins(int coins) async {
    final prefs = await _prefs;
    await prefs.setInt(_coinsKey, coins);
  }

  Future<PlayerLoadout> loadLoadout() async {
    final prefs = await _prefs;
    final json = prefs.getString(_loadoutKey);
    if (json == null) return const PlayerLoadout();
    try {
      return PlayerLoadout.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return const PlayerLoadout();
    }
  }

  Future<void> saveLoadout(PlayerLoadout loadout) async {
    final prefs = await _prefs;
    await prefs.setString(_loadoutKey, jsonEncode(loadout.toJson()));
  }

  Future<DailyRewardState> loadDailyRewards() async {
    final prefs = await _prefs;
    final json = prefs.getString(_dailyRewardsKey);
    if (json == null) return DailyRewardState.initial();
    try {
      return DailyRewardState.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return DailyRewardState.initial();
    }
  }

  Future<void> saveDailyRewards(DailyRewardState state) async {
    final prefs = await _prefs;
    await prefs.setString(_dailyRewardsKey, jsonEncode(state.toJson()));
  }

  Future<String> loadLanguage() async {
    final prefs = await _prefs;
    return prefs.getString(_languageKey) ?? 'en';
  }

  Future<void> saveLanguage(String code) async {
    final prefs = await _prefs;
    await prefs.setString(_languageKey, code);
  }

  Future<List<String>> loadOwnedCosmetics() async {
    final prefs = await _prefs;
    return prefs.getStringList(_ownedCosmeticsKey) ??
        ['timer_skin_default', 'bg_default', 'sound_default', 'celebration_default'];
  }

  Future<void> saveOwnedCosmetics(List<String> ids) async {
    final prefs = await _prefs;
    await prefs.setStringList(_ownedCosmeticsKey, ids);
  }

  Future<({int currentStreak, int bestStreak})> loadStreak() async {
    final prefs = await _prefs;
    final json = prefs.getString(_streakKey);
    if (json == null) return (currentStreak: 0, bestStreak: 0);
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return (
        currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
        bestStreak: (map['bestStreak'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return (currentStreak: 0, bestStreak: 0);
    }
  }

  Future<void> saveStreak(int currentStreak, int bestStreak) async {
    final prefs = await _prefs;
    await prefs.setString(
      _streakKey,
      jsonEncode({'currentStreak': currentStreak, 'bestStreak': bestStreak}),
    );
  }

  PlayerStats _defaultStats() => const PlayerStats(
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
}
