import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
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
                    mode.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isLocked ? Colors.white38 : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isLocked ? Colors.white24 : Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Target: ${mode.displayTarget}',
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
