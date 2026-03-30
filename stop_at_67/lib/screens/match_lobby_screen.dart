import 'dart:async';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/game_state.dart';
import '../engine/types.dart';
import '../theme/app_colors.dart';
import '../widgets/app_gradient_background.dart';

/// Pre-game lobby: shows both matched players and a countdown before play.
class MatchLobbyScreen extends StatefulWidget {
  const MatchLobbyScreen({super.key});

  @override
  State<MatchLobbyScreen> createState() => _MatchLobbyScreenState();
}

class _MatchLobbyScreenState extends State<MatchLobbyScreen> {
  int _countdown = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 800), _tick);
  }

  void _tick(Timer _) {
    if (!mounted) return;
    Haptics.vibrate(HapticsType.light).catchError((_) {});
    setState(() {
      if (_countdown > 1) {
        _countdown--;
      } else {
        _timer?.cancel();
        // Transition match to playing
        context.read<GameState>().matchCountdownComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final match = gs.currentMatch;
    final l10n = AppLocalizations.of(context);

    final player1Name = match?.player1.displayName ?? 'Player 1';
    final player2Name = match?.player2?.displayName ?? 'Player 2';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // VS header
                Text(
                  l10n.matchLobbyTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDisabled,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 40),

                // Player cards
                _PlayerCard(name: player1Name, color: AppColors.orange),
                const SizedBox(height: 20),
                const Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 20),
                _PlayerCard(name: player2Name, color: AppColors.cyan),

                const SizedBox(height: 48),

                // Countdown
                Text(
                  l10n.matchLobbyGetReady,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textDisabled,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$_countdown',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w200,
                    color: AppColors.textPrimary,
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

class _PlayerCard extends StatelessWidget {
  final String name;
  final Color color;
  const _PlayerCard({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, color: color, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
