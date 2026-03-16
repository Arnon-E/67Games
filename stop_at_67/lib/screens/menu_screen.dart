import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

import '../state/game_state.dart';
import '../engine/constants.dart';
import '../engine/types.dart';
import '../theme/app_colors.dart';
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

    final disableAnimations = MediaQuery.of(context).disableAnimations;

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
                        color: AppColors.darkElevated,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        l10n.menuLevel(levelInfo.level),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                    // Coins
                    Row(
                      children: [
                        const Icon(Icons.circle, color: AppColors.gold, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${gs.coins}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                    // Settings
                    GestureDetector(
                      onTap: () => gs.setScreen(AppScreen.settings),
                      child: const Icon(Icons.settings_outlined, color: AppColors.textDisabled, size: 24),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Logo with shimmer glow
              disableAnimations
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.menuLogo,
                          style: const TextStyle(
                            fontSize: 96,
                            fontWeight: FontWeight.w100,
                            color: AppColors.textPrimary,
                            letterSpacing: -4,
                          ),
                        ),
                        Text(
                          l10n.menuSubtitle,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textDisabled,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    )
                  : AnimatedBuilder(
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
                            colors: const [
                              AppColors.textPrimary,
                              AppColors.gold,
                              AppColors.textPrimary,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ).createShader(bounds);
                        },
                        child: Text(
                          l10n.menuLogo,
                          style: TextStyle(
                            fontSize: 96,
                            fontWeight: FontWeight.w100,
                            color: AppColors.textPrimary,
                            letterSpacing: -4,
                            shadows: [
                              Shadow(
                                color: AppColors.orange.withValues(alpha: glowOpacity),
                                blurRadius: 40,
                              ),
                              Shadow(
                                color: AppColors.gold.withValues(alpha: glowOpacity * 0.6),
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
                          color: AppColors.textDisabled,
                          letterSpacing: 1,
                          shadows: [
                            Shadow(
                              color: AppColors.orange.withValues(alpha: glowOpacity * 0.3),
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
                child: disableAnimations
                    ? SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: () => gs.setScreen(AppScreen.modeSelect),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange,
                            foregroundColor: AppColors.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            elevation: 12,
                            shadowColor: AppColors.orange.withValues(alpha: 0.5),
                          ),
                          child: const Text(
                            'PLAY',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      )
                    : AnimatedBuilder(
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
                              color: AppColors.orange.withValues(alpha: 0.3 + glowIntensity * 0.3),
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
                        backgroundColor: AppColors.orange,
                        foregroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 12,
                        shadowColor: AppColors.orange.withValues(alpha: 0.5),
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

              const SizedBox(height: 8),

              // Weekly missions card
              const _WeeklyMissionsCard(),

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
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.card_giftcard, color: AppColors.gold, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            l10n.menuDailyReward,
                            style: const TextStyle(
                              color: AppColors.gold,
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
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textDisabled),
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
          color: AppColors.darkElevated,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textDisabled, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: AppColors.textDisabled, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ── Weekly Missions Card ─────────────────────────────────────

class _WeeklyMissionsCard extends StatefulWidget {
  const _WeeklyMissionsCard();

  @override
  State<_WeeklyMissionsCard> createState() => _WeeklyMissionsCardState();
}

class _WeeklyMissionsCardState extends State<_WeeklyMissionsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final missionsState = gs.weeklyMissions;
    final missions = missionsState.missions;
    if (missions.isEmpty) return const SizedBox.shrink();

    // Count completed (progress >= target) and claimed
    int completed = 0;
    int claimed = 0;
    for (final mp in missions) {
      final def = kWeeklyMissions.firstWhere(
        (d) => d.id == mp.missionId,
        orElse: () => const WeeklyMissionDef(
          id: '', label: '', description: '', target: 0, type: '', rewardCoins: 0,
        ),
      );
      if (def.id.isEmpty) continue;
      if (mp.progress >= def.target) completed++;
      if (mp.claimed) claimed++;
    }
    final total = missions.length;
    final hasUnclaimed = completed > claimed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasUnclaimed
                  ? AppColors.gold.withValues(alpha: 0.5)
                  : AppColors.darkElevated,
            ),
          ),
          child: Column(
            children: [
              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Text('📋', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'WEEKLY MISSIONS',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            '$completed / $total complete',
                            style: TextStyle(
                              color: hasUnclaimed ? AppColors.gold : AppColors.textHint,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasUnclaimed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          'CLAIM!',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                  ],
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total > 0 ? completed / total : 0,
                    backgroundColor: AppColors.darkElevated,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      hasUnclaimed ? AppColors.gold : AppColors.orange,
                    ),
                    minHeight: 4,
                  ),
                ),
              ),

              // Expanded mission list
              if (_expanded)
                ...missions.map((mp) {
                  final def = kWeeklyMissions.firstWhere(
                    (d) => d.id == mp.missionId,
                    orElse: () => const WeeklyMissionDef(
                      id: '', label: '', description: '', target: 0, type: '', rewardCoins: 0,
                    ),
                  );
                  if (def.id.isEmpty) return const SizedBox.shrink();
                  return _MissionRow(
                    def: def,
                    progress: mp,
                    onClaim: () async {
                      await gs.claimMissionReward(def.id);
                    },
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  final WeeklyMissionDef def;
  final WeeklyMissionProgress progress;
  final VoidCallback onClaim;

  const _MissionRow({
    required this.def,
    required this.progress,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = progress.progress >= def.target;
    final isClaimed = progress.claimed;
    final pct = (progress.progress / def.target).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone && !isClaimed
              ? AppColors.gold.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Text(
            isClaimed ? '✅' : isDone ? '🎁' : '🎯',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 10),

          // Text + progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  def.label,
                  style: TextStyle(
                    color: isClaimed ? AppColors.textHint : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: isClaimed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  def.description,
                  style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: AppColors.darkCard,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isClaimed ? AppColors.textHint : AppColors.orange,
                          ),
                          minHeight: 3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${progress.progress.clamp(0, def.target)}/${def.target}',
                      style: const TextStyle(color: AppColors.textHint, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Reward + claim button
          const SizedBox(width: 10),
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, color: AppColors.gold, size: 10),
                  const SizedBox(width: 3),
                  Text(
                    '${def.rewardCoins}',
                    style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              if (isDone && !isClaimed) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onClaim,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: const Text(
                      'CLAIM',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
