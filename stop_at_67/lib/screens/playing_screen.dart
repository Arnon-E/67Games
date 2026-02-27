import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

import '../state/game_state.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/timer_display.dart';
import '../widgets/tap_area.dart';

class PlayingScreen extends StatefulWidget {
  const PlayingScreen({super.key});

  @override
  State<PlayingScreen> createState() => _PlayingScreenState();
}

class _PlayingScreenState extends State<PlayingScreen> {
  bool _stopped = false;

  Future<void> _onTap() async {
    if (_stopped) return;
    _stopped = true;
    Haptics.vibrate(HapticsType.medium).catchError((_) {});
    await context.read<GameState>().stopGame();
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final l10n = AppLocalizations.of(context);
    final timerState = gs.timerState;
    final mode = gs.currentMode;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        // Back during gameplay → stop timer and return to menu
        context.read<GameState>().returnToMenu();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppGradientBackground(
          child: TapArea(
            onTap: _onTap,
            child: SizedBox.expand(
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TimerDisplay(
                        displayTime: timerState.displayTime,
                        isBlind: gs.isBlindMode,
                        targetLabel: mode != null
                            ? '${l10n.playingTarget}: ${mode.displayTarget}'
                            : null,
                      ),
                      const SizedBox(height: 64),
                      Text(
                        l10n.playingTapHint,
                        style: const TextStyle(
                          fontSize: 14,
                          letterSpacing: 2,
                          color: Colors.white24,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  if (mode?.id == 'surge')
                    Positioned(
                      top: 16,
                      right: 20,
                      child: _SurgeSpeedBadge(
                        multiplier: timerState.speedMultiplier,
                        failStreak: gs.surgeFailStreak,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SurgeSpeedBadge extends StatelessWidget {
  final double multiplier;
  final int failStreak;

  const _SurgeSpeedBadge({required this.multiplier, required this.failStreak});

  @override
  Widget build(BuildContext context) {
    final livesLeft = (3 - failStreak).clamp(0, 3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Text(
            '${multiplier.toStringAsFixed(2)}×',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final filled = i < livesLeft;
            return Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                filled ? Icons.favorite : Icons.favorite_border,
                size: 14,
                color: filled ? Colors.redAccent : Colors.white24,
              ),
            );
          }),
        ),
      ],
    );
  }
}
