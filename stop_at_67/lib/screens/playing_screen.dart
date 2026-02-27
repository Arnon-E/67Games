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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
            ),
          ),
        ),
      ),
    );
  }
}
