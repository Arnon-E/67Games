import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Returns the gradient for a background skin ID.
RadialGradient backgroundSkinGradient(String skinId) => switch (skinId) {
  'bg_purple' => const RadialGradient(
      center: Alignment(0.0, -0.1),
      radius: 0.9,
      colors: [Color(0xFF3D1070), Color(0xFF1A0540), AppColors.darkPrimary],
      stops: [0.0, 0.45, 1.0],
    ),
  'bg_ocean' => const RadialGradient(
      center: Alignment(0.0, -0.1),
      radius: 0.9,
      colors: [Color(0xFF0A3A5C), Color(0xFF051828), AppColors.darkPrimary],
      stops: [0.0, 0.45, 1.0],
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
