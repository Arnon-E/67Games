import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/game_state.dart';
import '../engine/constants.dart';
import '../engine/scoring.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/screen_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final stats = gs.stats;
    final levelInfo = levelFromXp(stats.totalXp);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(title: 'Profile', onBack: () => gs.setScreen(AppScreen.menu)),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // Avatar + level
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                  colors: [Color(0xFFFF6B35), Color(0xFFFF9B65)]),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0xFFFF6B35).withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    spreadRadius: 4)
                              ],
                            ),
                            child: const Icon(Icons.person, color: Colors.white, size: 40),
                          ),
                          const SizedBox(height: 12),
                          Text('Level ${levelInfo.level}',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w200, color: Colors.white)),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 200,
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: levelInfo.nextLevelXp > 0
                                        ? levelInfo.currentXp / levelInfo.nextLevelXp
                                        : 1.0,
                                    backgroundColor: Colors.white12,
                                    valueColor:
                                        const AlwaysStoppedAnimation(Color(0xFFFF6B35)),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('${levelInfo.currentXp} / ${levelInfo.nextLevelXp} XP',
                                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _label('Statistics'),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                      children: [
                        _statTile('Games', '${stats.totalGames}'),
                        _statTile('Best Streak', '${stats.bestStreak}'),
                        _statTile('Perfects', '${stats.perfectCount}'),
                        _statTile('Total XP', '${stats.totalXp}'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _label('Best Scores'),
                    const SizedBox(height: 12),
                    ...kGameModes.values
                        .where((mode) => !const {'extended', 'reverse', 'reverse100'}.contains(mode.id))
                        .map((mode) {
                      final best = stats.bestScores[mode.id];
                      return _scoreRow(mode.name, best != null ? formatScore(best) : '—');
                    }),
                    const SizedBox(height: 24),
                    _label('Achievements'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: const Color(0xFF1a1a2e),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${gs.achievements.length} / ${kAchievements.length} unlocked',
                              style: const TextStyle(color: Colors.white70, fontSize: 15)),
                          Text(
                            '${(gs.achievements.length / kAchievements.length * 100).round()}%',
                            style: const TextStyle(
                                color: Color(0xFFFF6B35), fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _label(String text) => Text(
        text.toUpperCase(),
        style: const TextStyle(
            fontSize: 11, letterSpacing: 2, color: Colors.white38, fontWeight: FontWeight.w600),
      );

  static Widget _statTile(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w300)),
          ],
        ),
      );

  static Widget _scoreRow(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15)),
            Text(value,
                style: const TextStyle(
                    color: Color(0xFFFF6B35), fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
