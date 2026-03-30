import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/game_state.dart';
import '../state/auth_state.dart';
import '../engine/types.dart';
import '../theme/app_colors.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/timer_display.dart';
import '../widgets/stop_button.dart';

/// Live 1v1 playing screen — timer with opponent status indicator.
class MatchPlayingScreen extends StatefulWidget {
  const MatchPlayingScreen({super.key});

  @override
  State<MatchPlayingScreen> createState() => _MatchPlayingScreenState();
}

class _MatchPlayingScreenState extends State<MatchPlayingScreen> {
  bool _stopped = false;

  Future<void> _onStop() async {
    if (_stopped) return;
    setState(() { _stopped = true; });
    Haptics.vibrate(HapticsType.medium).catchError((_) {});
    await context.read<GameState>().stopMatchGame();
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final auth = context.watch<AuthState>();
    final timerState = gs.timerState;
    final match = gs.currentMatch;
    final l10n = AppLocalizations.of(context);

    final targetDisplay = match != null
        ? _formatMs(match.targetMs)
        : '6.700s';

    // Check if the opponent has already stopped
    final myUid = auth.user?.uid;
    final opponentStopped = match != null && myUid != null && _opponentHasStopped(match, myUid);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        // Don't allow back during match play
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppGradientBackground(
          child: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title bar
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
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
                                      Shadow(color: AppColors.gold, blurRadius: 16),
                                      Shadow(color: AppColors.goldWarm, blurRadius: 32),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 1v1 badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          l10n.matchPlayingLive1v1,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.cyan,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Timer
                      TimerDisplay(
                        displayTime: timerState.displayTime,
                        isBlind: false,
                        targetLabel: null,
                        timerSkin: gs.loadout.timerSkin,
                      ),

                      const Spacer(),

                      // STOP button
                      StopButton(
                        onTap: _onStop,
                        disabled: _stopped,
                      ),

                      const SizedBox(height: 16),

                      // Opponent status
                      if (opponentStopped && !_stopped)
                        Text(
                          l10n.matchPlayingOpponentStopped,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.gold,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                      if (_stopped && !gs.matchPlayerStopped)
                        Text(
                          l10n.matchPlayingWaitingOpponent,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textDisabled,
                          ),
                        ),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _opponentHasStopped(MatchData match, String myUid) {
    if (match.player1.uid == myUid) {
      return match.player2?.score != null;
    } else {
      return match.player1.score != null;
    }
  }

  static String _formatMs(int ms) {
    final s = ms ~/ 1000;
    final millis = ms % 1000;
    return '$s.${millis.toString().padLeft(3, '0')}s';
  }
}
