import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Returns the gradient for a background skin ID.
RadialGradient backgroundSkinGradient(String skinId) => switch (skinId) {
  'bg_purple' => const RadialGradient(
      center: Alignment(0.0, -0.1),
      radius: 1.2,
      colors: [Color(0xFF6B21C8), Color(0xFF2D0A6B), Color(0xFF0D0020)],
      stops: [0.0, 0.5, 1.0],
    ),
  'bg_ocean' => const RadialGradient(
      center: Alignment(0.0, -0.1),
      radius: 1.2,
      colors: [Color(0xFF0A6EA8), Color(0xFF053660), Color(0xFF000D1A)],
      stops: [0.0, 0.5, 1.0],
    ),
  'bg_ember' => const RadialGradient(
      center: Alignment(0.0, -0.1),
      radius: 1.2,
      colors: [Color(0xFFB03000), Color(0xFF5A1200), Color(0xFF0F0200)],
      stops: [0.0, 0.5, 1.0],
    ),
  'bg_arctic' => const RadialGradient(
      center: Alignment(0.0, -0.1),
      radius: 1.2,
      colors: [Color(0xFF0AABCC), Color(0xFF055A70), Color(0xFF001218)],
      stops: [0.0, 0.5, 1.0],
    ),
  'bg_crimson' => const RadialGradient(
      center: Alignment(0.0, -0.1),
      radius: 1.2,
      colors: [Color(0xFF8B0000), Color(0xFF420000), Color(0xFF0F0000)],
      stops: [0.0, 0.5, 1.0],
    ),
  _ => const RadialGradient(
      center: Alignment(0.0, -0.1),
      radius: 0.9,
      colors: [
        AppColors.darkPurple,
        AppColors.darkSecondary,
        AppColors.darkPrimary,
      ],
      stops: [0.0, 0.45, 1.0],
    ),
};

class AppGradientBackground extends StatelessWidget {
  final Widget child;
  final String backgroundSkin;

  const AppGradientBackground({
    super.key,
    required this.child,
    this.backgroundSkin = 'bg_default',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: backgroundSkinGradient(backgroundSkin)),
      child: child,
    );
  }
}
