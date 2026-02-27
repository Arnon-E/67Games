import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../engine/types.dart';

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
              ? const Color(0xFF1a1a2e).withValues(alpha: 0.5)
              : const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked
                ? Colors.white12
                : const Color(0xFFFF6B35).withValues(alpha: 0.3),
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
                      color: isLocked ? Colors.white38 : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _localDesc(l10n),
                    style: TextStyle(
                      fontSize: 13,
                      color: isLocked ? Colors.white24 : Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.modeCardTarget(mode.displayTarget),
                    style: TextStyle(
                      fontSize: 12,
                      color: isLocked
                          ? Colors.white24
                          : const Color(0xFFFF6B35),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              const Icon(Icons.lock_outline, color: Colors.white38, size: 24)
            else
              const Icon(Icons.chevron_right, color: Colors.white54, size: 24),
          ],
        ),
      ),
    );
  }
}
