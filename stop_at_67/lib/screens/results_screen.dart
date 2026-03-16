import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';

import '../state/game_state.dart';
import '../engine/scoring.dart';
import '../engine/types.dart';
import '../theme/app_colors.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/score_display.dart';
import '../widgets/game_button.dart';

// ── Fireworks particle system ────────────────────────────────

class _Particle {
  double x, y, vx, vy, alpha, size;
  final Color color;
  final bool isStar;
  _Particle({
    required this.x, required this.y,
    required this.vx, required this.vy,
    required this.alpha, required this.size,
    required this.color,
    this.isStar = false,
  });
}

class _FireworksOverlay extends StatefulWidget {
  const _FireworksOverlay();

  @override
  State<_FireworksOverlay> createState() => _FireworksOverlayState();
}

class _FireworksOverlayState extends State<_FireworksOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _rng = Random();
  int _burstCount = 0;
  static const int _maxBursts = 12;

  static const List<Color> _colors = [
    Color(0xFFFFD700), Color(0xFFFF6B35), Color(0xFF00DDFF),
    Color(0xFF00FF88), Color(0xFFFF00CC), Color(0xFFFFFFFF),
    Color(0xFFFF3366), Color(0xFF66FF33), Color(0xFF9933FF),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..addListener(_tick)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _burstCount = 0;
        }
      });
    _controller.repeat();
  }

  void _tick() {
    if (!mounted) return;
    final t = _controller.value;

    // Spawn bursts at intervals
    final targetBursts = (t * _maxBursts).floor() + 1;
    if (_burstCount < targetBursts && _burstCount < _maxBursts) {
      _burstCount++;
      _spawnBurst();
    }

    // Update particles
    setState(() {
      final newParticles = <_Particle>[];
      for (final p in _particles) {
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.12; // gravity
        p.vx *= 0.97; // drag
        p.alpha -= 0.008;

        // Sparkle trail: randomly spawn small child particles
        if (_rng.nextDouble() < 0.05 && p.alpha > 0.3) {
          newParticles.add(_Particle(
            x: p.x,
            y: p.y,
            vx: (_rng.nextDouble() - 0.5) * 0.5,
            vy: (_rng.nextDouble() - 0.5) * 0.5,
            alpha: p.alpha * 0.6,
            size: p.size * 0.4,
            color: p.color,
          ));
        }
      }
      _particles.addAll(newParticles);
      _particles.removeWhere((p) => p.alpha <= 0);
    });
  }

  void _spawnBurst() {
    final size = MediaQuery.of(context).size;
    final x = 0.1 + _rng.nextDouble() * 0.8; // 10–90% width
    final y = 0.05 + _rng.nextDouble() * 0.5; // 5–55% height
    final color = _colors[_rng.nextInt(_colors.length)];
    const count = 60;

    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi;
      final speed = 2.0 + _rng.nextDouble() * 5.0;
      _particles.add(_Particle(
        x: x * size.width,
        y: y * size.height,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        alpha: 1.0,
        size: 2.0 + _rng.nextDouble() * 4.0,
        color: color,
        isStar: _rng.nextDouble() < 0.3,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ParticlePainter(_particles),
        size: Size.infinite,
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.alpha.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      if (p.isStar) {
        _drawStar(canvas, Offset(p.x, p.y), p.size * 1.5, paint);
      } else {
        canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const points = 4;
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * 0.4;
      final angle = (i * pi / points) - pi / 2;
      final point = Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

// ── Color-shifting celebration background ────────────────────

class _CelebrationBackground extends StatefulWidget {
  final Widget child;
  const _CelebrationBackground({required this.child});

  @override
  State<_CelebrationBackground> createState() => _CelebrationBackgroundState();
}

class _CelebrationBackgroundState extends State<_CelebrationBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const List<List<Color>> _colorSets = [
    [Color(0xFF0a0a2f), Color(0xFF1a0a4e), Color(0xFF2a0a3e)],
    [Color(0xFF0a1a3f), Color(0xFF0a2a5e), Color(0xFF1a0a4e)],
    [Color(0xFF1a0a2e), Color(0xFF2a0a4e), Color(0xFF0a1a3e)],
    [Color(0xFF0a0a3f), Color(0xFF1a1a5e), Color(0xFF2a0a2e)],
    [Color(0xFF0a1a2e), Color(0xFF0a2a3e), Color(0xFF1a0a4e)],
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final idx = (t * _colorSets.length).floor() % _colorSets.length;
        final nextIdx = (idx + 1) % _colorSets.length;
        final blend = (t * _colorSets.length) - idx;

        final colors = List.generate(3, (i) =>
          Color.lerp(_colorSets[idx][i], _colorSets[nextIdx][i], blend)!,
        );

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ── Floating emoji confetti ──────────────────────────────────

class _EmojiConfetti extends StatefulWidget {
  const _EmojiConfetti();

  @override
  State<_EmojiConfetti> createState() => _EmojiConfettiState();
}

class _EmojiConfettiState extends State<_EmojiConfetti>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rng = Random();
  late final List<_FloatingEmoji> _emojis;

  static const List<String> _emojiPool = [
    '🎉', '⭐', '🌟', '✨', '💫', '🔥', '🎯', '🏆', '💎', '🎊',
    '🌈', '⚡', '💥', '🎮', '🥳',
  ];

  @override
  void initState() {
    super.initState();
    _emojis = List.generate(18, (_) => _FloatingEmoji(
      emoji: _emojiPool[_rng.nextInt(_emojiPool.length)],
      x: _rng.nextDouble(),
      startY: 1.0 + _rng.nextDouble() * 0.3,
      speed: 0.15 + _rng.nextDouble() * 0.25,
      wobbleSpeed: 1.0 + _rng.nextDouble() * 2.0,
      wobbleAmount: 0.02 + _rng.nextDouble() * 0.04,
      size: 18 + _rng.nextDouble() * 16,
      delay: _rng.nextDouble() * 0.4,
    ));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return IgnorePointer(
          child: ExcludeSemantics(
            child: Stack(
              children: _emojis.where((e) => t > e.delay).map((e) {
              final progress = ((t - e.delay) / (1.0 - e.delay)).clamp(0.0, 1.0);
              final y = e.startY - progress * (e.startY + 0.3) * e.speed / 0.2;
              final x = e.x + sin(progress * e.wobbleSpeed * 2 * pi) * e.wobbleAmount;
              final opacity = progress < 0.1
                  ? progress / 0.1
                  : progress > 0.7
                      ? (1.0 - progress) / 0.3
                      : 1.0;

              return Positioned(
                left: x * MediaQuery.of(context).size.width,
                top: y * MediaQuery.of(context).size.height,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Text(
                    e.emoji,
                    style: TextStyle(fontSize: e.size),
                  ),
                ),
              );
            }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _FloatingEmoji {
  final String emoji;
  final double x, startY, speed, wobbleSpeed, wobbleAmount, size, delay;
  const _FloatingEmoji({
    required this.emoji,
    required this.x,
    required this.startY,
    required this.speed,
    required this.wobbleSpeed,
    required this.wobbleAmount,
    required this.size,
    required this.delay,
  });
}

// ── Bouncy score wrapper ─────────────────────────────────────

class _BouncyScore extends StatefulWidget {
  final Widget child;
  const _BouncyScore({required this.child});

  @override
  State<_BouncyScore> createState() => _BouncyScoreState();
}

class _BouncyScoreState extends State<_BouncyScore>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.92), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.05), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: widget.child,
    );
  }
}

// ── Results screen ───────────────────────────────────────────

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _surgeDialogShown = false;

  static bool _isExcellent(String? tier) =>
      tier == 'perfect' || tier == 'incredible' || tier == 'excellent';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gs = context.read<GameState>();
    if (gs.surgePendingReset && !_surgeDialogShown) {
      _surgeDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showSurgeResetDialog();
      });
    }
  }

  Future<void> _showSurgeResetDialog() async {
    final gs = context.read<GameState>();
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SurgeResetDialog(
        title: l10n.surgeResetTitle,
        body:
            '${l10n.surgeResetBody}\n\n${l10n.surgeResetTotalScore(gs.surgeCumulativeScore)}',
        watchAdLabel: l10n.surgeResetWatchAd,
        acceptLabel: l10n.surgeResetAccept,
        onAccept: () {
          Navigator.of(ctx).pop();
          gs.surgeAcceptReset();
        },
        onWatchAd: () async {
          // The dialog manages its own dismissal after the ad finishes.
          await gs.surgeWatchAdRetry();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final l10n = AppLocalizations.of(context);
    final result = gs.lastResult;
    final mode = gs.currentMode;

    if (result == null || mode == null) {
      return const Scaffold(backgroundColor: AppColors.darkPrimary);
    }

    final deviation = result.deviationMs;
    final isNearMiss = deviation > 0 && deviation <= 20;
    final bestScore = gs.stats.bestScores[mode.id] ?? 0;
    final isPersonalBest = result.finalScore > 0 && result.finalScore == bestScore;
    final isPerfect = deviation == 0;
    final showFireworks = _isExcellent(result.rating.tier);

    // Use celebration background for excellent+, regular background otherwise
    final Widget background = showFireworks
        ? _CelebrationBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildResultContent(context, gs, l10n, result, isPerfect,
                    isPersonalBest, isNearMiss, showFireworks),
              ),
            ),
          )
        : AppGradientBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildResultContent(context, gs, l10n, result, isPerfect,
                    isPersonalBest, isNearMiss, showFireworks),
              ),
            ),
          );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          background,

          // Fireworks overlay — only for excellent and above
          if (showFireworks) const _FireworksOverlay(),

          // Emoji confetti — only for excellent and above
          if (showFireworks) const _EmojiConfetti(),
        ],
      ),
    );
  }

  Widget _buildResultContent(
    BuildContext context,
    GameState gs,
    AppLocalizations l10n,
    dynamic result,
    bool isPerfect,
    bool isPersonalBest,
    bool isNearMiss,
    bool showFireworks,
  ) {
    final mode = gs.currentMode!;

    // ── Calibration: interim round (1–4 of 5) ───────────────
    if (mode.isCalibration &&
        gs.calibrationResults.length < mode.calibrationRounds) {
      return _buildCalibrationInterimContent(context, gs, l10n, result);
    }

    // ── Calibration: final round summary ────────────────────
    if (mode.isCalibration &&
        gs.calibrationResults.length >= mode.calibrationRounds) {
      return _buildCalibrationSummaryContent(context, gs, l10n, result,
          isPerfect, isPersonalBest, showFireworks);
    }

    // ── Pressure: success round ──────────────────────────────
    if (mode.isPressure && gs.pressureLastRoundSuccess) {
      return _buildPressureSuccessContent(context, gs, l10n, result);
    }

    // ── Pressure: first failure — free retry ─────────────────
    if (mode.isPressure && !gs.pressureLastRoundSuccess && gs.pressureFailAttempts == 1 && !gs.pressurePendingAdRetry) {
      return _buildPressureFreeRetryContent(context, gs, l10n, result);
    }

    // ── Pressure: second failure — ad retry offered ──────────
    if (mode.isPressure && !gs.pressureLastRoundSuccess && gs.pressurePendingAdRetry) {
      return _buildPressureAdRetryContent(context, gs, l10n, result);
    }

    // ── Pressure: failure (game over, all retries exhausted) ─
    if (mode.isPressure && !gs.pressureLastRoundSuccess) {
      return _buildPressureFailureContent(context, gs, l10n, result,
          isPersonalBest, showFireworks);
    }

    // ── Normal result ────────────────────────────────────────

    // Accelerate mode: show FAIL for anything below excellent
    final bool isSurge = mode.id == 'surge';
    final bool surgeIsFail = isSurge && !_isExcellent(result.rating.tier);
    final String? surgeLabelOverride =
        surgeIsFail ? l10n.surgeFailLabel : null;
    final Color? surgeColorOverride =
        surgeIsFail ? const Color(0xFFFF4444) : null;

    return Column(
      children: [
        const SizedBox(height: 24),

        // Badges
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isPerfect)
              _badge(l10n.resultsPerfectStop, AppColors.gold),
            if (isPersonalBest && !isPerfect)
              _badge(l10n.resultsPersonalBest, AppColors.orange),
            if (isNearMiss && !isPersonalBest && !isPerfect)
              _badge(l10n.resultsNearMiss, AppColors.textDisabled),
          ],
        ),
        if (isPerfect || isPersonalBest || isNearMiss)
          const SizedBox(height: 16),

        const Spacer(),

        // Bouncy score for excellent+, regular for others
        showFireworks
            ? _BouncyScore(
                child: ScoreDisplay(
                  result: result,
                  labelOverride: surgeLabelOverride,
                  labelColorOverride: surgeColorOverride,
                ),
              )
            : ScoreDisplay(
                result: result,
                labelOverride: surgeLabelOverride,
                labelColorOverride: surgeColorOverride,
              ),

        const SizedBox(height: 40),

        // Detail rows
        _detailRow(l10n.resultsStoppedAt, formatDeviation(result.stoppedAtMs)),
        const SizedBox(height: 8),
        _detailRow(l10n.resultsDeviation, formatDeviation(result.deviationMs)),
        const SizedBox(height: 8),
        // Accelerate: show cumulative score and lives instead of streak
        if (isSurge) ...[
          _detailRow(l10n.resultsTotalScore, '${gs.surgeCumulativeScore}'),
          const SizedBox(height: 8),
          _detailRow(l10n.resultsLives, '${l10n.resultsLivesHeartEmoji} ${gs.surgeLives}'),
        ] else ...[
          _detailRow(l10n.resultsStreak,
              '${gs.currentStreakValue > 1 ? "🔥 " : ""}${gs.currentStreakValue}'),
        ],
        const SizedBox(height: 8),
        _detailRow(l10n.resultsXp, '+${result.xpEarned} XP'),

        const Spacer(),

        // Action buttons
        GameButton(
          label: l10n.commonPlayAgain,
          onPressed: () => gs.playAgain(),
          width: double.infinity,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GameButton(
                label: l10n.commonMenu,
                onPressed: () => gs.returnToMenu(),
                primary: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GameButton(
                label: l10n.commonShare,
                onPressed: () => _share(context, result, gs.currentMode!.name, l10n),
                primary: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Calibration interim (attempts 1–4) ─────────────────────

  Widget _buildCalibrationInterimContent(
    BuildContext context,
    GameState gs,
    AppLocalizations l10n,
    ScoreResult result,
  ) {
    final mode = gs.currentMode!;
    final attemptNum = gs.calibrationResults.length; // already added
    return Column(
      children: [
        const SizedBox(height: 24),
        _badge(
          l10n.resultsCalibrationAttempt(attemptNum, mode.calibrationRounds),
          AppColors.cyan,
        ),
        const SizedBox(height: 16),
        const Spacer(),
        ScoreDisplay(result: result),
        const SizedBox(height: 40),
        _detailRow(l10n.resultsDeviation, formatDeviation(result.deviationMs)),
        const SizedBox(height: 8),
        _detailRow(l10n.resultsStoppedAt, formatDeviation(result.stoppedAtMs)),
        const Spacer(),
        GameButton(
          label: l10n.resultsNextAttempt,
          onPressed: () => gs.playAgain(),
          width: double.infinity,
        ),
        const SizedBox(height: 12),
        GameButton(
          label: l10n.commonMenu,
          onPressed: () => gs.returnToMenu(),
          primary: false,
          width: double.infinity,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Calibration final summary (after attempt 5) ───────────

  Widget _buildCalibrationSummaryContent(
    BuildContext context,
    GameState gs,
    AppLocalizations l10n,
    ScoreResult avgResult,
    bool isPerfect,
    bool isPersonalBest,
    bool showFireworks,
  ) {
    final attempts = gs.calibrationResults;
    return Column(
      children: [
        const SizedBox(height: 24),
        _badge(l10n.resultsCalibrationSummary, AppColors.cyan),
        const SizedBox(height: 16),
        if (isPersonalBest) ...[
          _badge(l10n.resultsPersonalBest, AppColors.orange),
          const SizedBox(height: 8),
        ],
        const Spacer(),
        showFireworks
            ? _BouncyScore(child: ScoreDisplay(result: avgResult))
            : ScoreDisplay(result: avgResult),
        const SizedBox(height: 24),
        // Individual attempt deviations
        ...List.generate(attempts.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _detailRow(
              '${l10n.resultsCalibrationAttemptLabel} ${i + 1}',
              formatDeviation(attempts[i].deviationMs),
            ),
          );
        }),
        const SizedBox(height: 8),
        _detailRow(
          l10n.resultsCalibrationAvgDeviation,
          formatDeviation(avgResult.deviationMs),
        ),
        const SizedBox(height: 8),
        _detailRow(l10n.resultsXp, '+${avgResult.xpEarned} XP'),
        const Spacer(),
        GameButton(
          label: l10n.commonPlayAgain,
          onPressed: () => gs.playAgain(),
          width: double.infinity,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GameButton(
                label: l10n.commonMenu,
                onPressed: () => gs.returnToMenu(),
                primary: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GameButton(
                label: l10n.commonShare,
                onPressed: () =>
                    _share(context, avgResult, gs.currentMode!.name, l10n),
                primary: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Pressure success round ────────────────────────────────

  Widget _buildPressureSuccessContent(
    BuildContext context,
    GameState gs,
    AppLocalizations l10n,
    ScoreResult result,
  ) {
    final nextTolerance = gs.pressureTolerance; // already tightened
    return Column(
      children: [
        const SizedBox(height: 24),
        _badge(l10n.resultsPressureCleared, const Color(0xFF00FF88)),
        const SizedBox(height: 16),
        const Spacer(),
        ScoreDisplay(result: result),
        const SizedBox(height: 40),
        _detailRow(l10n.resultsDeviation, formatDeviation(result.deviationMs)),
        const SizedBox(height: 8),
        _detailRow(
          l10n.resultsPressureRounds,
          '${gs.pressureRoundsSucceeded}',
        ),
        const SizedBox(height: 8),
        _detailRow(
          l10n.resultsPressureNextTolerance,
          '±${nextTolerance}ms',
        ),
        const Spacer(),
        GameButton(
          label: l10n.resultsPressureNextRound,
          onPressed: () => gs.playAgain(),
          width: double.infinity,
        ),
        const SizedBox(height: 12),
        GameButton(
          label: l10n.commonMenu,
          onPressed: () => gs.returnToMenu(),
          primary: false,
          width: double.infinity,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Pressure: first failure — free retry ─────────────────

  Widget _buildPressureFreeRetryContent(
    BuildContext context,
    GameState gs,
    AppLocalizations l10n,
    ScoreResult result,
  ) {
    return Column(
      children: [
        const SizedBox(height: 24),
        _badge(l10n.resultsPressureEliminated, Colors.redAccent),
        const SizedBox(height: 16),
        const Spacer(),
        ScoreDisplay(result: result),
        const SizedBox(height: 40),
        _detailRow(l10n.resultsPressureRounds, '${gs.pressureRoundsSucceeded}'),
        const SizedBox(height: 8),
        _detailRow(l10n.resultsDeviation, formatDeviation(result.deviationMs)),
        const SizedBox(height: 8),
        _detailRow(l10n.resultsPressureCurrentTolerance, '±${gs.pressureTolerance}ms'),
        const Spacer(),
        GameButton(
          label: l10n.pressureRetry,
          onPressed: () => gs.pressureFreeRetry(),
          width: double.infinity,
        ),
        const SizedBox(height: 12),
        GameButton(
          label: l10n.commonMenu,
          onPressed: () => gs.returnToMenu(),
          primary: false,
          width: double.infinity,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Pressure: second failure — ad retry ──────────────────

  Widget _buildPressureAdRetryContent(
    BuildContext context,
    GameState gs,
    AppLocalizations l10n,
    ScoreResult result,
  ) {
    return _PressureAdRetryContent(
      gs: gs,
      l10n: l10n,
      result: result,
      buildBadge: _badge,
      buildDetailRow: _detailRow,
    );
  }

  // ── Pressure failure (game over) ─────────────────────────

  Widget _buildPressureFailureContent(
    BuildContext context,
    GameState gs,
    AppLocalizations l10n,
    ScoreResult result,
    bool isPersonalBest,
    bool showFireworks,
  ) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _badge(l10n.resultsPressureEliminated, Colors.redAccent),
            if (isPersonalBest) ...[
              const SizedBox(width: 8),
              _badge(l10n.resultsPersonalBest, AppColors.orange),
            ],
          ],
        ),
        const SizedBox(height: 16),
        const Spacer(),
        showFireworks
            ? _BouncyScore(child: ScoreDisplay(result: result))
            : ScoreDisplay(result: result),
        const SizedBox(height: 40),
        _detailRow(
          l10n.resultsPressureRounds,
          '${gs.pressureRoundsSucceeded}',
        ),
        const SizedBox(height: 8),
        _detailRow(l10n.resultsDeviation, formatDeviation(result.deviationMs)),
        const SizedBox(height: 8),
        _detailRow(l10n.resultsXp, '+${result.xpEarned} XP'),
        const Spacer(),
        GameButton(
          label: l10n.commonPlayAgain,
          onPressed: () => gs.playAgain(),
          width: double.infinity,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GameButton(
                label: l10n.commonMenu,
                onPressed: () => gs.returnToMenu(),
                primary: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GameButton(
                label: l10n.commonShare,
                onPressed: () =>
                    _share(context, result, gs.currentMode!.name, l10n),
                primary: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textDisabled, fontSize: 15)),
        Text(value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Future<void> _share(
      BuildContext context, result, String modeName, AppLocalizations l10n) async {
    try {
      final text = 'I scored ${result.finalScore} in Stop at 67 ($modeName mode)!\n'
          'Deviation: ${formatDeviation(result.deviationMs)}\n'
          'Can you beat me?';
      await Share.share(text);
    } catch (_) {}
  }
}

// ── Pressure ad retry content ────────────────────────────────

class _PressureAdRetryContent extends StatefulWidget {
  final GameState gs;
  final AppLocalizations l10n;
  final ScoreResult result;
  final Widget Function(String, Color) buildBadge;
  final Widget Function(String, String) buildDetailRow;

  const _PressureAdRetryContent({
    required this.gs,
    required this.l10n,
    required this.result,
    required this.buildBadge,
    required this.buildDetailRow,
  });

  @override
  State<_PressureAdRetryContent> createState() => _PressureAdRetryContentState();
}

class _PressureAdRetryContentState extends State<_PressureAdRetryContent> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final gs = widget.gs;
    final l10n = widget.l10n;
    final result = widget.result;
    return Column(
      children: [
        const SizedBox(height: 24),
        widget.buildBadge(l10n.resultsPressureEliminated, Colors.redAccent),
        const SizedBox(height: 16),
        const Spacer(),
        ScoreDisplay(result: result),
        const SizedBox(height: 40),
        widget.buildDetailRow(l10n.resultsPressureRounds, '${gs.pressureRoundsSucceeded}'),
        const SizedBox(height: 8),
        widget.buildDetailRow(l10n.resultsDeviation, formatDeviation(result.deviationMs)),
        const SizedBox(height: 8),
        widget.buildDetailRow(l10n.resultsPressureCurrentTolerance, '±${gs.pressureTolerance}ms'),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() => _isLoading = true);
                    await gs.pressureWatchAdRetry();
                    if (mounted) setState(() => _isLoading = false);
                  },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.cyan.withValues(alpha: 0.15),
              foregroundColor: AppColors.cyan,
              disabledForegroundColor: AppColors.cyan.withValues(alpha: 0.4),
              disabledBackgroundColor: AppColors.cyan.withValues(alpha: 0.07),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cyan),
                  )
                : Text(
                    l10n.pressureWatchAd,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 1),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        GameButton(
          label: l10n.pressureGameOver,
          onPressed: () => gs.pressureAcceptGameOver(),
          primary: false,
          width: double.infinity,
        ),
        const SizedBox(height: 12),
        GameButton(
          label: l10n.commonMenu,
          onPressed: () => gs.returnToMenu(),
          primary: false,
          width: double.infinity,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Surge reset dialog ───────────────────────────────────────

class _SurgeResetDialog extends StatefulWidget {
  final String title;
  final String body;
  final String watchAdLabel;
  final String acceptLabel;
  final VoidCallback onAccept;
  final Future<void> Function() onWatchAd;

  const _SurgeResetDialog({
    required this.title,
    required this.body,
    required this.watchAdLabel,
    required this.acceptLabel,
    required this.onAccept,
    required this.onWatchAd,
  });

  @override
  State<_SurgeResetDialog> createState() => _SurgeResetDialogState();
}

class _SurgeResetDialogState extends State<_SurgeResetDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚡', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              widget.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.body,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textDisabled, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() => _isLoading = true);
                        await widget.onWatchAd();
                        if (mounted) Navigator.of(context).pop();
                      },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.cyan.withValues(alpha: 0.15),
                  foregroundColor: AppColors.cyan,
                  disabledForegroundColor: AppColors.cyan.withValues(alpha: 0.4),
                  disabledBackgroundColor: AppColors.cyan.withValues(alpha: 0.07),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.cyan, width: 1),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyan),
                        ),
                      )
                    : Text(
                        widget.watchAdLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isLoading ? null : widget.onAccept,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textDisabled,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  widget.acceptLabel,
                  style: const TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
