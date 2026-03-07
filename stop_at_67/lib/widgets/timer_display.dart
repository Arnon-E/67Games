import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TimerDisplay extends StatelessWidget {
  final String displayTime;
  final bool isBlind;
  final Color? ratingColor;
  final String? targetLabel;
  final String? blindModeLabel;

  const TimerDisplay({
    super.key,
    required this.displayTime,
    this.isBlind = false,
    this.ratingColor,
    this.targetLabel,
    this.blindModeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isBlind
        ? AppColors.textDisabled
        : (ratingColor ?? AppColors.gold);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ambient glow
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.25),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
              // Neon ring painter
              CustomPaint(
                size: const Size(280, 280),
                painter: _NeonRingPainter(
                  isBlind: isBlind,
                  ratingColor: ratingColor,
                ),
              ),
              // Timer text + glow
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: 240,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Text glow bloom
                          if (!isBlind)
                            Text(
                              displayTime,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.w700,
                                foreground: Paint()
                                  ..maskFilter = const MaskFilter.blur(
                                      BlurStyle.normal, 18)
                                  ..color = textColor.withValues(alpha: 0.6),
                                letterSpacing: -2,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          Text(
                            isBlind ? '?.??' : displayTime,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              letterSpacing: -2,
                              fontFeatures: const [FontFeature.tabularFigures()],
                              shadows: isBlind
                                  ? null
                                  : [
                                      Shadow(
                                        color: textColor.withValues(alpha: 0.8),
                                        blurRadius: 12,
                                      ),
                                      Shadow(
                                        color: AppColors.orange.withValues(alpha: 0.4),
                                        blurRadius: 30,
                                      ),
                                    ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (targetLabel != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      targetLabel!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        if (isBlind) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              blindModeLabel ?? 'BLIND MODE',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NeonRingPainter extends CustomPainter {
  final bool isBlind;
  final Color? ratingColor;

  const _NeonRingPainter({required this.isBlind, this.ratingColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 6;
    final innerRadius = size.width / 2 - 18;

    if (isBlind) {
      // Simple dim ring for blind mode
      final paint = Paint()
        ..color = AppColors.textHint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(center, outerRadius, paint);
      return;
    }

    // ── Outer orange arc (270°, starting from bottom-left, clockwise) ──
    final orangePaint = Paint()
      ..shader = SweepGradient(
        colors: [
          AppColors.orange.withValues(alpha: 0.0),
          AppColors.gold,
          AppColors.orange,
          AppColors.goldWarm,
          AppColors.orange.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.2, 0.55, 0.8, 1.0],
        startAngle: math.pi * 0.6,
        endAngle: math.pi * 2.6,
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      math.pi * 0.6,
      math.pi * 1.8,
      false,
      orangePaint,
    );

    // ── Bright hot-spot at top-right of outer ring ──
    final hotSpotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      -math.pi * 0.42,
      math.pi * 0.08,
      false,
      hotSpotPaint,
    );

    // ── Inner blue arc (bottom portion, partial) ──
    final bluePaint = Paint()
      ..shader = SweepGradient(
        colors: [
          AppColors.cyan.withValues(alpha: 0.0),
          AppColors.cyan.withValues(alpha: 0.9),
          const Color(0xFF7B9FFF).withValues(alpha: 0.7),
          AppColors.cyan.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.25, 0.65, 1.0],
        startAngle: math.pi * 0.9,
        endAngle: math.pi * 1.9,
      ).createShader(Rect.fromCircle(center: center, radius: innerRadius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      math.pi * 0.9,
      math.pi * 0.9,
      false,
      bluePaint,
    );

    // ── Tick marks on outer ring (dashed segment, bottom-right area) ──
    final tickPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = math.pi * 0.25 + i * (math.pi * 0.08);
      final innerTick = center +
          Offset(math.cos(angle) * (outerRadius - 12),
              math.sin(angle) * (outerRadius - 12));
      final outerTick = center +
          Offset(math.cos(angle) * (outerRadius + 2),
              math.sin(angle) * (outerRadius + 2));
      canvas.drawLine(innerTick, outerTick, tickPaint);
    }

    // ── Outer ring glow (blur layer) ──
    final glowPaint = Paint()
      ..color = AppColors.orange.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      math.pi * 0.6,
      math.pi * 1.8,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_NeonRingPainter old) =>
      old.isBlind != isBlind || old.ratingColor != ratingColor;
}
