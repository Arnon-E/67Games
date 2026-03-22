import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';

import '../engine/constants.dart';
import '../state/game_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_gradient_background.dart';

// ── Wheel painter ─────────────────────────────────────────────

class _WheelPainter extends CustomPainter {
  final double angle;

  const _WheelPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 2;
    final n = kFortuneSegments.length;
    final segAngle = (math.pi * 2) / n;

    for (int i = 0; i < n; i++) {
      final seg = kFortuneSegments[i];
      final startA = angle + i * segAngle - math.pi / 2;
      final endA = startA + segAngle;
      final midA = startA + segAngle / 2;

      // Segment fill
      final fillPaint = Paint()..color = seg.color;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startA, segAngle, true, fillPaint,
      );

      // Subtle radial highlight
      final hlPaint = Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withValues(alpha: 0.08), Colors.transparent],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startA, segAngle, true, hlPaint,
      );

      // Divider line
      final divPaint = Paint()
        ..color = AppColors.gold.withValues(alpha: 0.25)
        ..strokeWidth = 1.0;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + math.cos(startA) * radius, cy + math.sin(startA) * radius),
        divPaint,
      );

      // Emoji
      final emojiDist = radius * 0.60;
      final emX = cx + math.cos(midA) * emojiDist;
      final emY = cy + math.sin(midA) * emojiDist;

      final emojiPainter = TextPainter(
        text: TextSpan(
          text: seg.emoji,
          style: const TextStyle(fontSize: 16),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(emX, emY);
      canvas.rotate(midA + math.pi / 2);
      emojiPainter.paint(
        canvas,
        Offset(-emojiPainter.width / 2, -emojiPainter.height / 2),
      );
      canvas.restore();

      // Multiplier label
      final multDist = radius * 0.38;
      final mX = cx + math.cos(midA) * multDist;
      final mY = cy + math.sin(midA) * multDist;
      final multStr = seg.multiplier == seg.multiplier.truncateToDouble()
          ? '${seg.multiplier.toInt()}×'
          : '${seg.multiplier}×';

      final multPainter = TextPainter(
        text: TextSpan(
          text: multStr,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: seg.textColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(mX, mY);
      canvas.rotate(midA + math.pi / 2);
      multPainter.paint(
        canvas,
        Offset(-multPainter.width / 2, -multPainter.height / 2),
      );
      canvas.restore();
    }

    // Outer rim
    final rimPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(cx, cy), radius, rimPaint);

    // Outer rim glow
    final rimGlow = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(cx, cy), radius, rimGlow);

    // Center hub
    const hubRadius = 20.0;
    final hubGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.gold.withValues(alpha: 0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(cx, cy), radius: hubRadius * 2.5,
      ));
    canvas.drawCircle(Offset(cx, cy), hubRadius * 2.5, hubGlow);

    final hubGrad = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        colors: [
          Colors.white.withValues(alpha: 0.6),
          AppColors.gold,
          AppColors.orange,
          AppColors.goldDark,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(cx, cy), radius: hubRadius,
      ));
    canvas.drawCircle(Offset(cx, cy), hubRadius, hubGrad);

    final hubBorder = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), hubRadius, hubBorder);
  }

  @override
  bool shouldRepaint(_WheelPainter old) => old.angle != angle;
}

// ── Result card ───────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final FortuneSegment segment;
  final VoidCallback onPlay;

  const _ResultCard({required this.segment, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final modeName = kGameModes[segment.modeId]?.name ?? segment.modeId;
    final modeDesc = kGameModes[segment.modeId]?.description ?? '';
    final multStr = segment.multiplier == segment.multiplier.truncateToDouble()
        ? '${segment.multiplier.toInt()}×'
        : '${segment.multiplier}×';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.45), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Text(segment.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      modeName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      modeDesc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Multiplier badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0.2),
                  AppColors.orange.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎰', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  '$multStr Score & XP Multiplier',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                    shadows: [
                      Shadow(
                        color: AppColors.gold.withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Play button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'PLAY  $multStr',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fortune Wheel Screen ──────────────────────────────────────

class FortuneWheelScreen extends StatefulWidget {
  const FortuneWheelScreen({super.key});

  @override
  State<FortuneWheelScreen> createState() => _FortuneWheelScreenState();
}

class _FortuneWheelScreenState extends State<FortuneWheelScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _angle = 0;
  double _velocity = 0;
  bool _spinning = false;
  int? _resultIndex;

  static const double _deceleration = 0.985;
  static const double _stopThreshold = 0.002;

  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!_spinning || _velocity.abs() < _stopThreshold) {
      if (_spinning) {
        setState(() {
          _spinning = false;
          _resultIndex = _computeSegmentIndex();
        });
        Haptics.vibrate(HapticsType.success).catchError((_) {});
      }
      return;
    }
    setState(() {
      _angle = (_angle + _velocity) % (math.pi * 2);
      _velocity *= _deceleration;
    });
  }

  void _spin() {
    if (_spinning) return;
    setState(() {
      _resultIndex = null;
      _velocity = 0.22 + _rng.nextDouble() * 0.18;
      _spinning = true;
    });
    Haptics.vibrate(HapticsType.medium).catchError((_) {});
  }

  /// Returns the segment index currently under the pointer (top = -π/2).
  int _computeSegmentIndex() {
    final n = kFortuneSegments.length;
    final segAngle = (math.pi * 2) / n;
    // Pointer is at the top: subtract angle to find which segment is at top
    final norm = ((-_angle - math.pi / 2) % (math.pi * 2) + math.pi * 2) % (math.pi * 2);
    return (norm / segAngle).floor() % n;
  }

  void _playResult() {
    final idx = _resultIndex!;
    final seg = kFortuneSegments[idx];
    context.read<GameState>().applyFortuneResult(seg.modeId, seg.multiplier);
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final hasResult = _resultIndex != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => gs.setScreen(AppScreen.modeSelect),
                      child: const Icon(Icons.arrow_back_ios,
                          color: AppColors.textSecondary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('Fortune', style: AppTextStyles.screenTitle),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(
                            '${gs.coins}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Subtitle
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 12),
                child: Text(
                  'Costs ${kFortuneCost} coins per spin',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textDisabled,
                  ),
                ),
              ),

              // Pointer
              const _Pointer(),

              // Wheel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CustomPaint(
                    painter: _WheelPainter(angle: _angle),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Spin button or result card
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutBack,
                transitionBuilder: (child, anim) => SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: hasResult
                    ? _ResultCard(
                        key: const ValueKey('result'),
                        segment: kFortuneSegments[_resultIndex!],
                        onPlay: _playResult,
                      )
                    : Padding(
                        key: const ValueKey('spin'),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _spinning ? null : _spin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _spinning
                                      ? AppColors.darkElevated
                                      : AppColors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  _spinning ? 'SPINNING...' : '🎰  SPIN',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Tap SPIN to reveal your mode and multiplier',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pointer extends StatelessWidget {
  const _Pointer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(24, 20),
      painter: _PointerPainter(),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.gold
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(path, Paint()..color = AppColors.gold);
  }

  @override
  bool shouldRepaint(_PointerPainter old) => false;
}
