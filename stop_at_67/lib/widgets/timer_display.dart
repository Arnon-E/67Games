import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  final String displayTime;
  final bool isBlind;
  final Color? ratingColor;
  final String? targetLabel;

  const TimerDisplay({
    super.key,
    required this.displayTime,
    this.isBlind = false,
    this.ratingColor,
    this.targetLabel,
  });

  @override
  Widget build(BuildContext context) {
    final color = isBlind
        ? const Color(0xFF666666)
        : (ratingColor ?? Colors.white);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glow + timer
        Stack(
          alignment: Alignment.center,
          children: [
            if (ratingColor != null && !isBlind)
              Container(
                width: 300,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(75),
                  boxShadow: [
                    BoxShadow(
                      color: ratingColor!.withValues(alpha: 0.35),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            Text(
              isBlind ? '?.???' : displayTime,
              style: TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.w200,
                color: color,
                letterSpacing: -4,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),

        if (targetLabel != null) ...[
          const SizedBox(height: 8),
          Text(
            targetLabel!,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0x66FFFFFF),
            ),
          ),
        ],

        if (isBlind) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'BLIND MODE',
              style: TextStyle(
                fontSize: 14,
                color: Color(0x99FFFFFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
