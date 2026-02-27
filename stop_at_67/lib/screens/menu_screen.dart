import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

import '../state/game_state.dart';
import '../engine/constants.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/daily_reward_modal.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gs = context.read<GameState>();
      if (gs.dailyRewards.canClaim) {
        _showDailyReward();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showDailyReward() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const DailyRewardModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final l10n = AppLocalizations.of(context);
    final levelInfo = levelFromXp(gs.stats.totalXp);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Level chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2a2a3e),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        l10n.menuLevel(levelInfo.level),
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                    // Coins
                    Row(
                      children: [
                        const Icon(Icons.circle, color: Color(0xFFFFD700), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${gs.coins}',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    // Settings
                    GestureDetector(
                      onTap: () => gs.setScreen(AppScreen.settings),
                      child: const Icon(Icons.settings_outlined, color: Colors.white54, size: 24),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Logo with shimmer glow
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  final glowOpacity = 0.15 + _glowAnimation.value * 0.25;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) {
                          final offset = _glowAnimation.value * 2 - 0.5;
                          return LinearGradient(
                            begin: Alignment(-1.0 + offset, 0),
                            end: Alignment(0.0 + offset, 0),
                            colors: [
                              Colors.white,
                              const Color(0xFFFFD700),
                              Colors.white,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ).createShader(bounds);
                        },
                        child: Text(
                          l10n.menuLogo,
                          style: TextStyle(
                            fontSize: 96,
                            fontWeight: FontWeight.w100,
                            color: Colors.white,
                            letterSpacing: -4,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFFF6B35).withValues(alpha: glowOpacity),
                                blurRadius: 40,
                              ),
                              Shadow(
                                color: const Color(0xFFFFD700).withValues(alpha: glowOpacity * 0.6),
                                blurRadius: 80,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        l10n.menuSubtitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white38,
                          letterSpacing: 1,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFFF6B35).withValues(alpha: glowOpacity * 0.3),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 48),

              // Stats row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statItem(l10n.menuGames, '${gs.stats.totalGames}'),
                    _statItem(
                      l10n.menuBest,
                      gs.stats.bestScores.isEmpty
                          ? '—'
                          : '${gs.stats.bestScores.values.reduce((a, b) => a > b ? a : b)}',
                    ),
                    _statItem(l10n.menuStreak, '${gs.currentStreakValue}'),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // PLAY button with pulse
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final glowIntensity = _glowAnimation.value;
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B35).withValues(alpha: 0.3 + glowIntensity * 0.3),
                              blurRadius: 20 + glowIntensity * 20,
                              spreadRadius: glowIntensity * 8,
                            ),
                          ],
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () => gs.setScreen(AppScreen.modeSelect),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 12,
                        shadowColor: const Color(0xFFFF6B35).withValues(alpha: 0.5),
                      ),
                      child: Text(
                        l10n.commonPlay,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Secondary nav row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _navButton(l10n.menuLeaderboard, Icons.leaderboard_outlined,
                      () => gs.setScreen(AppScreen.leaderboard)),
                  const SizedBox(width: 16),
                  _navButton(l10n.menuProfile, Icons.person_outline,
                      () => gs.setScreen(AppScreen.profile)),
                  const SizedBox(width: 16),
                  _navButton(l10n.menuShop, Icons.store_outlined,
                      () => gs.setScreen(AppScreen.shop)),
                ],
              ),

              const Spacer(),

              // Daily reward button (if available)
              if (gs.dailyRewards.canClaim)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: GestureDetector(
                    onTap: _showDailyReward,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.card_giftcard, color: Color(0xFFFFD700), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            l10n.menuDailyReward,
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w200,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _navButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a3e),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white54, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
