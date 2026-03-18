import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Displays a burst of gold coin particles that fly from [fromOffset] to [toOffset].
///
/// Usage:
/// ```dart
/// CoinFlyAnimation.show(
///   context: context,
///   fromOffset: sourcePos,
///   toOffset: coinWidgetPos,
///   coinAmount: 50,
/// );
/// ```
class CoinFlyAnimation {
  static OverlayEntry? _activeEntry;

  static void show({
    required BuildContext context,
    required Offset fromOffset,
    required Offset toOffset,
    required int coinAmount,
    VoidCallback? onComplete,
  }) {
    _activeEntry?.remove();
    _activeEntry = null;

    // Gling-gling haptic: two quick taps
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 120), () {
      HapticFeedback.lightImpact();
    });

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _CoinFlyWidget(
        fromOffset: fromOffset,
        toOffset: toOffset,
        coinAmount: coinAmount,
        onComplete: () {
          entry.remove();
          _activeEntry = null;
          onComplete?.call();
        },
      ),
    );
    _activeEntry = entry;
    Overlay.of(context).insert(entry);
  }
}

class _CoinPath {
  final double delay;
  final Offset controlPoint;
  _CoinPath({required this.delay, required this.controlPoint});
}

class _CoinFlyWidget extends StatefulWidget {
  final Offset fromOffset;
  final Offset toOffset;
  final int coinAmount;
  final VoidCallback onComplete;

  const _CoinFlyWidget({
    required this.fromOffset,
    required this.toOffset,
    required this.coinAmount,
    required this.onComplete,
  });

  @override
  State<_CoinFlyWidget> createState() => _CoinFlyWidgetState();
}

class _CoinFlyWidgetState extends State<_CoinFlyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _rng = Random();
  late final List<_CoinPath> _coins;

  @override
  void initState() {
    super.initState();
    final numCoins = (widget.coinAmount / 10).clamp(3.0, 9.0).round();
    _coins = List.generate(numCoins, (i) {
      // Control point arcs upward and sideways for a nice curved path
      final spreadX = (_rng.nextDouble() - 0.5) * 140;
      final arcY = -60 - _rng.nextDouble() * 80;
      return _CoinPath(
        delay: i * 0.06,
        controlPoint: Offset(
          widget.fromOffset.dx + spreadX,
          widget.fromOffset.dy + arcY,
        ),
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Quadratic Bezier interpolation.
  Offset _bezier(Offset p0, Offset p1, Offset p2, double t) {
    final mt = 1 - t;
    return Offset(
      mt * mt * p0.dx + 2 * mt * t * p1.dx + t * t * p2.dx,
      mt * mt * p0.dy + 2 * mt * t * p1.dy + t * t * p2.dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return IgnorePointer(
          child: Stack(
            children: _coins.map((coin) {
              final available = 1.0 - coin.delay;
              final rawT = available <= 0
                  ? 1.0
                  : (_controller.value - coin.delay) / available;
              final t = rawT.clamp(0.0, 1.0);
              if (t <= 0) return const SizedBox.shrink();

              final curved = Curves.easeInCubic.transform(t);
              final pos = _bezier(
                widget.fromOffset,
                coin.controlPoint,
                widget.toOffset,
                curved,
              );

              // Fade in quickly, fade out near destination
              final opacity = t < 0.12
                  ? t / 0.12
                  : t > 0.78
                      ? (1.0 - t) / 0.22
                      : 1.0;

              // Shrink slightly as it reaches the target
              final size = 15.0 + (7.0 - 15.0) * curved;

              return Positioned(
                left: pos.dx - size / 2,
                top: pos.dy - size / 2,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.65 * opacity),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '✦',
                        style: TextStyle(
                          fontSize: size * 0.55,
                          color: Colors.white.withValues(alpha: opacity.clamp(0.0, 1.0)),
                          height: 1,
                        ),
                      ),
                    ),
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
