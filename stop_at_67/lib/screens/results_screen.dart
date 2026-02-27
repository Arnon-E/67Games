import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';

import '../state/game_state.dart';
import '../engine/scoring.dart';
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
    )..addListener(_tick);
    _controller.forward();
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
    )..forward();
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
        body: l10n.surgeResetBody,
        watchAdLabel: l10n.surgeResetWatchAd,
        acceptLabel: l10n.surgeResetAccept,
        onAccept: () {
          Navigator.of(ctx).pop();
          gs.surgeAcceptReset();
        },
        onWatchAd: () async {
          Navigator.of(ctx).pop();
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
      return const Scaffold(backgroundColor: Color(0xFF0a0a0f));
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
    return Column(
      children: [
        const SizedBox(height: 24),

        // Badges
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isPerfect)
              _badge(l10n.resultsPerfectStop, const Color(0xFFFFD700)),
            if (isPersonalBest && !isPerfect)
              _badge(l10n.resultsPersonalBest, const Color(0xFFFF6B35)),
            if (isNearMiss && !isPersonalBest && !isPerfect)
              _badge(l10n.resultsNearMiss, Colors.white54),
          ],
        ),
        if (isPerfect || isPersonalBest || isNearMiss)
          const SizedBox(height: 16),

        const Spacer(),

        // Bouncy score for excellent+, regular for others
        showFireworks
            ? _BouncyScore(child: ScoreDisplay(result: result))
            : ScoreDisplay(result: result),

        const SizedBox(height: 40),

        // Detail rows
        _detailRow(l10n.resultsStoppedAt, formatDeviation(result.stoppedAtMs)),
        const SizedBox(height: 8),
        _detailRow(l10n.resultsDeviation, formatDeviation(result.deviationMs)),
        const SizedBox(height: 8),
        _detailRow(l10n.resultsStreak,
            '${gs.currentStreakValue > 1 ? "🔥 " : ""}${gs.currentStreakValue}'),
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
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 15)),
        Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
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

// ── Surge reset dialog ───────────────────────────────────────

class _SurgeResetDialog extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1a1a2e),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚡', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onWatchAd,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF00DDFF).withValues(alpha: 0.15),
                  foregroundColor: const Color(0xFF00DDFF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF00DDFF), width: 1),
                  ),
                ),
                child: Text(
                  watchAdLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onAccept,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white38,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  acceptLabel,
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
