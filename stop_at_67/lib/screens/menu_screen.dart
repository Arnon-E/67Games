import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

import '../state/game_state.dart';
import '../engine/constants.dart';
import '../engine/types.dart';
import '../theme/app_colors.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/coin_fly_animation.dart';
import '../widgets/daily_reward_modal.dart';
import '../widgets/update_dialog.dart';
import '../services/update_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with TickerProviderStateMixin {
  static bool _updateCheckedThisSession = false; // guard against repeated checks within one session

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  // Coin animation state
  final GlobalKey _coinKey = GlobalKey();
  int _prevCoins = -1;
  late AnimationController _coinBounceController;
  late Animation<double> _coinBounceAnimation;

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

    _coinBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _coinBounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.45), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.45, end: 0.88), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _coinBounceController, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gs = context.read<GameState>();
      _prevCoins = gs.coins;
      if (gs.dailyRewards.canClaim) {
        _showDailyReward();
      }
      _checkForUpdate();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _coinBounceController.dispose();
    super.dispose();
  }

  void _showDailyReward() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const DailyRewardModal(),
    );
  }

  Future<void> _checkForUpdate() async {
    if (_updateCheckedThisSession) return;
    _updateCheckedThisSession = true;
    final required = await UpdateService.isUpdateRequired();
    if (required && mounted) {
      // Persist that we notified for this build before showing the dialog,
      // so relaunching the app doesn't repeat it until a new build is installed.
      await UpdateService.markUpdateDialogShown();
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const UpdateDialog(),
      );
    }
  }

  void _triggerCoinAnimation(int delta, {Offset? sourceOffset}) {
    if (MediaQuery.of(context).disableAnimations) {
      _coinBounceController.forward(from: 0);
      return;
    }

    final RenderBox? box =
        _coinKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      _coinBounceController.forward(from: 0);
      return;
    }

    final coinPos = box.localToGlobal(box.size.center(Offset.zero));
    final screenSize = MediaQuery.of(context).size;
    final from = sourceOffset ??
        Offset(screenSize.width / 2, screenSize.height * 0.82);

    CoinFlyAnimation.show(
      context: context,
      fromOffset: from,
      toOffset: coinPos,
      coinAmount: delta,
      onComplete: () {
        if (mounted) _coinBounceController.forward(from: 0);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final l10n = AppLocalizations.of(context);
    final levelInfo = levelFromXp(gs.stats.totalXp);

    final disableAnimations = MediaQuery.of(context).disableAnimations;

    // Detect coin increase and trigger fly animation
    if (_prevCoins >= 0 && gs.coins > _prevCoins) {
      final delta = gs.coins - _prevCoins;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _triggerCoinAnimation(delta);
      });
    }
    _prevCoins = gs.coins;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
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
                    // Coins with bounce animation on increase
                    AnimatedBuilder(
                      animation: _coinBounceAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: _coinBounceAnimation.value,
                        child: child,
                      ),
                      child: Row(
                        key: _coinKey,
                        children: [
                          const Icon(Icons.circle, color: AppColors.gold, size: 14),
                          const SizedBox(width: 4),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) => ScaleTransition(
                              scale: anim,
                              child: child,
                            ),
                            child: Text(
                              '${gs.coins}',
                              key: ValueKey(gs.coins),
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
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

              // Rotating per-mode stats
              const _RotatingModeStats(),

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

              // 1v1 Multiplayer button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => gs.startMatchmaking(),
                    icon: const Icon(Icons.people, size: 20),
                    label: Text(
                      l10n.menuMultiplayer,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cyan,
                      side: BorderSide(color: AppColors.cyan.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
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
          ),
        ),
      ),
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

// ── Rotating per-mode stats ──────────────────────────────────

class _RotatingModeStats extends StatefulWidget {
  const _RotatingModeStats();

  @override
  State<_RotatingModeStats> createState() => _RotatingModeStatsState();
}

class _RotatingModeStatsState extends State<_RotatingModeStats> {
  int _modeIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      final gs = context.read<GameState>();
      final playedModes = _getPlayedModes(gs);
      if (playedModes.length > 1) {
        setState(() => _modeIndex = (_modeIndex + 1) % playedModes.length);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _modeNameL10n(String modeId, AppLocalizations l10n) => switch (modeId) {
    'classic'      => l10n.modeClassicName,
    'extended'     => l10n.modeExtendedName,
    'blind'        => l10n.modeBlindName,
    'reverse'      => l10n.modeReverseName,
    'reverse100'   => l10n.modeReverse100Name,
    'daily'        => l10n.modeDailyName,
    'surge'        => l10n.modeSurgeName,
    'doubletap'    => l10n.modeDoubleTapName,
    'movingtarget' => l10n.modeMovingTargetName,
    'calibration'  => l10n.modeCalibrationName,
    'pressure'     => l10n.modePressureName,
    _              => modeId,
  };

  List<String> _getPlayedModes(GameState gs) {
    final played = gs.stats.modeGamesPlayed.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toList();
    return played.isEmpty ? ['classic'] : played;
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final l10n = AppLocalizations.of(context);
    final playedModes = _getPlayedModes(gs);

    // Clamp index in case modes list shrinks
    final safeIndex = _modeIndex.clamp(0, playedModes.length - 1);
    final modeId = playedModes[safeIndex];
    final modeName = _modeNameL10n(modeId, l10n);
    final best = gs.stats.bestScores[modeId] ?? 0;
    final streak = gs.currentStreakValue;
    final hasPlayed = gs.stats.modeGamesPlayed.values.any((v) => v > 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: hasPlayed
            ? Column(
                key: ValueKey('$modeId-$safeIndex'),
                children: [
                  Text(
                    modeName.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statItem(l10n.menuGames, '${gs.stats.modeGamesPlayed[modeId] ?? 0}'),
                      _statItem(l10n.menuBest, best > 0 ? '$best' : '—'),
                      _statItem(l10n.menuStreak, '$streak'),
                    ],
                  ),
                ],
              )
            : Row(
                key: const ValueKey('global'),
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statItem(l10n.menuGames, '${gs.stats.totalGames}'),
                  _statItem(
                    l10n.menuBest,
                    gs.stats.bestScores.isEmpty
                        ? '—'
                        : '${gs.stats.bestScores.values.reduce((a, b) => a > b ? a : b)}',
                  ),
                  _statItem(l10n.menuStreak, '$streak'),
                ],
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
}

// ── Mission l10n helpers ─────────────────────────────────────

String _missionLabel(String id, AppLocalizations l10n) => switch (id) {
  'play_10'   => l10n.weeklyMissionPlay10Label,
  'perfect_3' => l10n.weeklyMissionPerfect3Label,
  'modes_3'   => l10n.weeklyMissionModes3Label,
  'score_900' => l10n.weeklyMissionScore900Label,
  'streak_5'  => l10n.weeklyMissionStreak5Label,
  _           => id,
};

String _missionDesc(String id, AppLocalizations l10n) => switch (id) {
  'play_10'   => l10n.weeklyMissionPlay10Desc,
  'perfect_3' => l10n.weeklyMissionPerfect3Desc,
  'modes_3'   => l10n.weeklyMissionModes3Desc,
  'score_900' => l10n.weeklyMissionScore900Desc,
  'streak_5'  => l10n.weeklyMissionStreak5Desc,
  _           => id,
};

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
    final l10n = AppLocalizations.of(context);
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
                          Text(
                            l10n.weeklyMissionsTitle,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            l10n.weeklyMissionsProgress(completed, total),
                            style: TextStyle(
                              color: hasUnclaimed ? AppColors.gold : AppColors.textHint,
                              fontSize: 11,
                            ),
                            textDirection: TextDirection.ltr,
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
                          l10n.weeklyMissionsClaim,
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
    final l10n = AppLocalizations.of(context);
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
                  _missionLabel(def.id, l10n),
                  style: TextStyle(
                    color: isClaimed ? AppColors.textHint : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: isClaimed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _missionDesc(def.id, l10n),
                  style: const TextStyle(color: AppColors.textDisabled, fontSize: 11),
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
                    child: Text(
                      l10n.weeklyMissionsClaimButton,
                      style: const TextStyle(
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
