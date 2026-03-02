import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class GameButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final double? width;

  const GameButton({
    super.key,
    required this.label,
    this.onPressed,
    this.primary = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? AppColors.orange : AppColors.darkElevated,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: primary ? 8 : 2,
          shadowColor: primary
              ? AppColors.orange.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
        child: Text(label, style: AppTextStyles.buttonPrimary),
      ),
    );
  }
}
