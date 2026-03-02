import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/game_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/timer_display.dart';
import '../widgets/stop_button.dart';

class PlayingScreen extends StatefulWidget {
  const PlayingScreen({super.key});

  @override
  State<PlayingScreen> createState() => _PlayingScreenState();
}

class _PlayingScreenState extends State<PlayingScreen> {
  bool _stopped = false;

  Future<void> _onStop() async {
    if (_stopped) return;
    _stopped = true;
    Haptics.vibrate(HapticsType.medium).catchError((_) {});
    await context.read<GameState>().stopGame();
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final timerState = gs.timerState;
    final mode = gs.currentMode;
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        context.read<GameState>().returnToMenu();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppGradientBackground(
          child: SafeArea(
            child: Stack(
              children: [
                // Floor glow reflection at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, 1.0),
                        radius: 0.8,
                        colors: [
                          AppColors.orange.withValues(alpha: 0.18),
                          AppColors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned.fill(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title bar: "Stop at 67"
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: l10n.playingStopAt,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            TextSpan(
                              text: mode != null
                                  ? mode.displayTarget
                                  : '67',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.gold,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: AppColors.gold,
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Neon ring timer
                    TimerDisplay(
                      displayTime: timerState.displayTime,
                      isBlind: gs.isBlindMode,
                      targetLabel: null, // shown in title instead
                    ),

                    const Spacer(),

                    // STOP orb button
                    StopButton(
                      onTap: _onStop,
                      disabled: _stopped,
                    ),

                    const SizedBox(height: 60),
                  ],
                  ),
                ),

                // Surge badge (top-right overlay)
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
            color: AppColors.textPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.textHint, width: 1),
          ),
          child: Text(
            '${multiplier.toStringAsFixed(2)}×',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
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
                color: filled ? Colors.redAccent : AppColors.textHint,
              ),
            );
          }),
        ),
      ],
    );
  }
}
