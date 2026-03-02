import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppGradientBackground extends StatelessWidget {
  final Widget child;

  const AppGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // Radial gradient that mimics the deep purple-indigo atmosphere from the promo art
        gradient: RadialGradient(
          center: Alignment(0.0, -0.1),
          radius: 0.9,
          colors: [
            AppColors.darkPurple,   // vivid purple core
            AppColors.darkSecondary, // rich dark purple mid
            AppColors.darkPrimary,  // near-black outer edge
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: child,
    );
  }
}
