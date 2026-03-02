import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Centralized ThemeData for Stop at 67.
/// Use [AppTheme.darkTheme] in MaterialApp.theme.
abstract final class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkPrimary,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.orange,
      secondary: AppColors.orange,
      surface: AppColors.darkCard,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      headlineLarge: AppTextStyles.screenTitle,
      labelSmall: AppTextStyles.sectionLabel,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orange,
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 8,
        shadowColor: const Color.fromRGBO(255, 107, 53, 0.4),
        textStyle: AppTextStyles.buttonPrimary,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.orange,
    ),
  );
}
