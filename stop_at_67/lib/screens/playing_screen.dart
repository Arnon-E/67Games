import 'dart:math';
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
      final bool midHit = gs.doubleTapMid();
      if (!midHit) {
        // Midpoint missed too badly — end the game immediately
        _stopped = true;
        Haptics.vibrate(HapticsType.error).catchError((_) {});
        await gs.stopGame();
      }
      return; // Either way, do not fall through to normal stop handling
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
        body: _SurgeAwareBackground(
          backgroundSkin: gs.loadout.background,
          surgeMultiplier: mode?.id == 'surge' ? gs.surgeSpeedMultiplier : 1.0,
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
                      timerSkin: gs.loadout.timerSkin,
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

                // Surge / Accelerate badge (top-right overlay)
                if (mode?.id == 'surge')
                  Positioned(
                    top: 16,
                    right: 20,
                    child: _SurgeSpeedBadge(
                      multiplier: timerState.speedMultiplier,
                      lives: gs.surgeLives,
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
  final int lives;

  const _SurgeSpeedBadge({required this.multiplier, required this.lives});

  @override
  Widget build(BuildContext context) {
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
          children: [
            Icon(
              Icons.favorite,
              size: 14,
              color: lives > 0 ? Colors.redAccent : AppColors.textHint,
            ),
            const SizedBox(width: 2),
            Text(
              '×$lives',
              style: TextStyle(
                fontSize: 12,
                color: lives > 0 ? Colors.redAccent : AppColors.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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

// ── Surge-aware background ────────────────────────────────────
//
// < 2×  : normal gradient (AppGradientBackground)
// ≥ 2×  : glowing colour-shifting background
// ≥ 3×  : same glow + a rapid flicker overlay

class _SurgeAwareBackground extends StatelessWidget {
  final Widget child;
  final String backgroundSkin;
  final double surgeMultiplier;

  const _SurgeAwareBackground({
    required this.child,
    required this.backgroundSkin,
    required this.surgeMultiplier,
  });

  @override
  Widget build(BuildContext context) {
    if (surgeMultiplier < 2.0) {
      return AppGradientBackground(backgroundSkin: backgroundSkin, child: child);
    }
    // ≥ 2×: glowing background (optionally with flicker at ≥ 3×)
    return _SurgeGlowBackground(
      flicker: surgeMultiplier >= 3.0,
      child: child,
    );
  }
}

/// Animated colour-shifting "glow" background for Accelerate mode at ≥2× speed.
class _SurgeGlowBackground extends StatefulWidget {
  final Widget child;
  final bool flicker;

  const _SurgeGlowBackground({required this.child, required this.flicker});

  @override
  State<_SurgeGlowBackground> createState() => _SurgeGlowBackgroundState();
}

class _SurgeGlowBackgroundState extends State<_SurgeGlowBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const List<List<Color>> _glowSets = [
    [Color(0xFF1a0040), Color(0xFF3d0080), Color(0xFF0a0025)],
    [Color(0xFF002040), Color(0xFF0060a0), Color(0xFF001030)],
    [Color(0xFF200040), Color(0xFF5000a0), Color(0xFF100020)],
    [Color(0xFF003040), Color(0xFF0080b0), Color(0xFF001520)],
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final idx = (t * _glowSets.length).floor() % _glowSets.length;
        final nextIdx = (idx + 1) % _glowSets.length;
        final blend = (t * _glowSets.length) - idx;

        final colors = List.generate(3, (i) =>
          Color.lerp(_glowSets[idx][i], _glowSets[nextIdx][i], blend)!,
        );

        // Respect global animation preferences and avoid high-frequency flicker.
        final bool disableAnimations = MediaQuery.disableAnimationsOf(context);

        // Flicker: opacity oscillation when at max speed (≥ 3×), unless animations are disabled.
        final double flickerAlpha;
        if (disableAnimations) {
          // Keep opacity constant when animations are disabled for accessibility.
          flickerAlpha = 1.0;
        } else if (widget.flicker) {
          // Use a safer, lower-frequency flicker (e.g., 2 Hz) to reduce risk for photosensitive users.
          const double flickerFrequencyHz = 2.0;
          flickerAlpha = 0.85 + 0.15 * sin(t * 2 * pi * flickerFrequencyHz);
        } else {
          flickerAlpha = 1.0;
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: flickerAlpha.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: colors,
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            widget.child,
          ],
        );
      },
      child: widget.child,
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
