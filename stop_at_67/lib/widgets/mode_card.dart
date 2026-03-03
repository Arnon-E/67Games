import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../engine/types.dart';
import '../engine/constants.dart';
import '../theme/app_colors.dart';

class ModeCard extends StatelessWidget {
  final GameMode mode;
  final bool isLocked;
  final VoidCallback? onTap;
  final PlayerStats? stats;

  const ModeCard({
    super.key,
    required this.mode,
    this.isLocked = false,
    this.onTap,
    this.stats,
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

  String? _unlockLabel() {
    final condition = mode.unlockCondition;
    if (condition == null) return null;
    switch (condition.type) {
      case 'games_played':
        return 'Play ${condition.value} games';
      case 'mode_games_played':
        final modeName = kGameModes[condition.modeId]?.name ?? condition.modeId ?? '';
        return 'Play ${condition.value} $modeName games';
      case 'score':
        final modeName = kGameModes[condition.modeId]?.name ?? condition.modeId ?? '';
        return 'Score ${condition.value}+ in $modeName';
      default:
        return null;
    }
  }

  String? _unlockProgress() {
    final s = stats;
    final condition = mode.unlockCondition;
    if (s == null || condition == null || !isLocked) return null;
    switch (condition.type) {
      case 'games_played':
        return '${s.totalGames}/${condition.value}';
      case 'mode_games_played':
        final current = s.modeGamesPlayed[condition.modeId ?? ''] ?? 0;
        return '$current/${condition.value}';
      case 'score':
        final current = s.bestScores[condition.modeId ?? ''] ?? 0;
        return '$current/${condition.value}';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unlockLabel = _unlockLabel();
    final progress = _unlockProgress();

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
                  if (unlockLabel != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          isLocked ? Icons.lock_clock : Icons.info_outline,
                          size: 12,
                          color: isLocked
                              ? AppColors.textHint
                              : AppColors.textDisabled.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isLocked && progress != null
                              ? '$unlockLabel ($progress)'
                              : unlockLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: isLocked
                                ? AppColors.textHint
                                : AppColors.textDisabled.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
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
