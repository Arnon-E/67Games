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
  _Particle({
    required this.x, required this.y,
    required this.vx, required this.vy,
    required this.alpha, required this.size,
    required this.color,
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
  static const int _maxBursts = 6;

  static const List<Color> _colors = [
    Color(0xFFFFD700), Color(0xFFFF6B35), Color(0xFF00DDFF),
    Color(0xFF00FF88), Color(0xFFFF00CC), Color(0xFFFFFFFF),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
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
      for (final p in _particles) {
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.15; // gravity
        p.vx *= 0.98; // drag
        p.alpha -= 0.012;
      }
      _particles.removeWhere((p) => p.alpha <= 0);
    });
  }

  void _spawnBurst() {
    final size = MediaQuery.of(context).size;
    final x = 0.2 + _rng.nextDouble() * 0.6; // 20–80% width
    final y = 0.1 + _rng.nextDouble() * 0.4; // 10–50% height
    final color = _colors[_rng.nextInt(_colors.length)];
    const count = 40;

    for (int i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi;
      final speed = 2.0 + _rng.nextDouble() * 4.0;
      _particles.add(_Particle(
        x: x * size.width,
        y: y * size.height,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed,
        alpha: 1.0,
        size: 2.0 + _rng.nextDouble() * 3.0,
        color: color,
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
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

// ── Results screen ───────────────────────────────────────────

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  static bool _isExcellent(String? tier) =>
      tier == 'perfect' || tier == 'incredible' || tier == 'excellent';

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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AppGradientBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
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

                    ScoreDisplay(result: result),

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
                            onPressed: () => _share(context, result, mode.name, l10n),
                            primary: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Fireworks overlay — only for excellent and above
          if (showFireworks) const _FireworksOverlay(),
        ],
      ),
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
