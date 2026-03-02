import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const ScreenHeader({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: const Icon(Icons.arrow_back_ios, color: AppColors.textSecondary, size: 20),
            ),
          if (onBack != null) const SizedBox(width: 12),
          Text(title, style: AppTextStyles.screenTitle),
        ],
      ),
    );
  }
}
