import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Named text styles for Stop at 67.
/// Use these instead of inline TextStyle definitions.
abstract final class AppTextStyles {
  /// Large logo / timer numeral — 96px, thin weight
  static const TextStyle logoDisplay = TextStyle(
    fontSize: 96,
    fontWeight: FontWeight.w100,
    color: AppColors.textPrimary,
    letterSpacing: -4,
  );

  /// Running timer digit — 96px, light weight, tabular figures
  static const TextStyle timerDisplay = TextStyle(
    fontSize: 96,
    fontWeight: FontWeight.w200,
    color: AppColors.textPrimary,
    letterSpacing: -4,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Screen title in header bar — 24px, light weight
  static const TextStyle screenTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
    letterSpacing: 2,
  );

  /// All-caps section labels (STATISTICS, ACHIEVEMENTS…)
  static const TextStyle sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textDisabled,
    letterSpacing: 2,
  );

  /// Primary button label
  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.textPrimary,
  );

  /// Standard body / list-row value
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 15,
    color: AppColors.textPrimary,
  );

  /// Small caption / stat label
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textDisabled,
  );

  /// Large stat number in menu (games, best, streak)
  static const TextStyle stat = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w200,
    color: AppColors.textPrimary,
  );
}
