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
    final gs = context.read<GameState>();
    final mode = gs.currentMode;

    // Double Tap: first user tap records the midpoint, second stops the timer
    if (mode != null && mode.doubleTap && gs.doubleTapPhase == 1) {
      gs.doubleTapMid();
      return; // Do not stop yet; wait for the second tap
    }

    _stopped = true;
    Haptics.vibrate(HapticsType.medium).catchError((_) {});
    await gs.stopGame();
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final timerState = gs.timerState;
    final mode = gs.currentMode;
    final l10n = AppLocalizations.of(context);

    // Moving Target: show the dynamic target in the title
    final String targetDisplay = (mode != null && mode.movingTarget)
        ? _formatMs(gs.movingTargetCurrentMs)
        : (mode?.displayTarget ?? '67');

    // Double Tap: tap hint changes based on phase
    String? doubleTapHint;
    if (mode != null && mode.doubleTap) {
      doubleTapHint = gs.doubleTapPhase == 1
          ? l10n.playingDoubleTapMidHint
          : l10n.playingDoubleTapStopHint;
    }

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
                    // Title bar: "Stop at X.XXXs"
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: l10n.playingStopAt,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            TextSpan(
                              text: targetDisplay,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: AppColors.gold,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: AppColors.gold,
                                    blurRadius: 16,
                                  ),
                                  Shadow(
                                    color: AppColors.goldWarm,
                                    blurRadius: 32,
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

                    // Double Tap hint label below timer
                    if (doubleTapHint != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        doubleTapHint,
                        style: TextStyle(
                          fontSize: 14,
                          color: gs.doubleTapPhase == 2
                              ? AppColors.orange
                              : AppColors.textDisabled,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],

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

                // Calibration badge (top-right overlay)
                if (mode != null && mode.isCalibration)
                  Positioned(
                    top: 16,
                    right: 20,
                    child: _CalibrationBadge(
                      attempt: gs.calibrationResults.length + 1,
                      total: mode.calibrationRounds,
                    ),
                  ),

                // Pressure badge (top-right overlay)
                if (mode != null && mode.isPressure)
                  Positioned(
                    top: 16,
                    right: 20,
                    child: _PressureBadge(
                      toleranceMs: gs.pressureTolerance,
                      roundsSucceeded: gs.pressureRoundsSucceeded,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Formats milliseconds as "X.XXXs" for Moving Target title display.
  static String _formatMs(int ms) {
    final s = ms ~/ 1000;
    final millis = ms % 1000;
    return '$s.${millis.toString().padLeft(3, '0')}s';
  }
}

// ── Surge speed badge ────────────────────────────────────────

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

// ── Calibration attempt badge ────────────────────────────────

class _CalibrationBadge extends StatelessWidget {
  final int attempt;
  final int total;
  const _CalibrationBadge({required this.attempt, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        '$attempt / $total',
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.cyan,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ── Pressure tolerance badge ─────────────────────────────────

class _PressureBadge extends StatelessWidget {
  final int toleranceMs;
  final int roundsSucceeded;
  const _PressureBadge({required this.toleranceMs, required this.roundsSucceeded});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5), width: 1),
          ),
          child: Text(
            '±${toleranceMs}ms',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        if (roundsSucceeded > 0) ...[
          const SizedBox(height: 4),
          Text(
            '🔥 $roundsSucceeded',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
