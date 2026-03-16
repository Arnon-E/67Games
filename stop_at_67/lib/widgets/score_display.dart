import 'package:flutter/material.dart';
import '../engine/types.dart';
import '../engine/scoring.dart';

class ScoreDisplay extends StatelessWidget {
  final ScoreResult result;
  /// Optional label override (e.g. "FAIL" for Accelerate mode).
  final String? labelOverride;
  /// Optional colour override for the label.
  final Color? labelColorOverride;

  const ScoreDisplay({
    super.key,
    required this.result,
    this.labelOverride,
    this.labelColorOverride,
  });

  @override
  Widget build(BuildContext context) {
    final rating = result.rating;
    final displayLabel = labelOverride ?? rating.label;
    final displayColor = labelColorOverride ?? rating.color;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rating label
        Text(
          displayLabel,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: displayColor,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),

        // Score value
        Text(
          formatScore(result.finalScore),
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w200,
            color: Colors.white,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 4),

        // Deviation
        Text(
          formatDeviation(result.deviationMs),
          style: TextStyle(
            fontSize: 20,
            color: rating.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
