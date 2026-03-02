import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../engine/types.dart';
import '../theme/app_colors.dart';

class ModeCard extends StatelessWidget {
  final GameMode mode;
  final bool isLocked;
  final VoidCallback? onTap;

  const ModeCard({
    super.key,
    required this.mode,
    this.isLocked = false,
    this.onTap,
  });

  String _localName(AppLocalizations l10n) {
    return switch (mode.id) {
      'classic' => l10n.modeClassicName,
      'extended' => l10n.modeExtendedName,
      'blind' => l10n.modeBlindName,
      'reverse' => l10n.modeReverseName,
      'reverse100' => l10n.modeReverse100Name,
      'daily' => l10n.modeDailyName,
      'surge' => l10n.modeSurgeName,
      _ => mode.name,
    };
  }

  String _localDesc(AppLocalizations l10n) {
    return switch (mode.id) {
      'classic' => l10n.modeClassicDesc,
      'extended' => l10n.modeExtendedDesc,
      'blind' => l10n.modeBlindDesc,
      'reverse' => l10n.modeReverseDesc,
      'reverse100' => l10n.modeReverse100Desc,
      'daily' => l10n.modeDailyDesc,
      'surge' => l10n.modeSurgeDesc,
      _ => mode.description,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isLocked
              ? AppColors.darkCard.withValues(alpha: 0.5)
              : AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked
                ? AppColors.textHint
                : AppColors.orange.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _localName(l10n),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isLocked ? AppColors.textDisabled : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _localDesc(l10n),
                    style: TextStyle(
                      fontSize: 13,
                      color: isLocked ? AppColors.textHint : AppColors.textDisabled,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.modeCardTarget(mode.displayTarget),
                    style: TextStyle(
                      fontSize: 12,
                      color: isLocked ? AppColors.textHint : AppColors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              const Icon(Icons.lock_outline, color: AppColors.textDisabled, size: 24)
            else
              const Icon(Icons.chevron_right, color: AppColors.textDisabled, size: 24),
          ],
        ),
      ),
    );
  }
}
