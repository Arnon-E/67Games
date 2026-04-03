import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/game_state.dart';
import '../state/auth_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/game_button.dart';

/// Head-to-head results screen — compares both players' scores.
class MatchResultsScreen extends StatelessWidget {
  const MatchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final auth = context.watch<AuthState>();
    final match = gs.currentMatch;
    final l10n = AppLocalizations.of(context);

    if (match == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final myUid = auth.user?.uid ?? '';
    final bool isPlayer1 = match.player1.uid == myUid;
    final myPlayer = isPlayer1 ? match.player1 : match.player2!;
    final opponent = isPlayer1 ? match.player2! : match.player1;

    final bool isWinner = match.winnerUid == myUid;
    final bool isTie = match.isComplete && match.winnerUid == null;
    final bool isLoser = match.isComplete && !isWinner && !isTie;
    final versusName = gs.isBotMatch ? 'BOT' : opponent.displayName;

    final String outcomeText;
    final Color outcomeColor;
    final String outcomeEmoji;

    if (!match.isComplete) {
      outcomeText = l10n.matchResultsWaiting;
      outcomeColor = AppColors.textDisabled;
      outcomeEmoji = '⏳';
    } else if (isTie) {
      outcomeText = l10n.matchResultsTie;
      outcomeColor = AppColors.gold;
      outcomeEmoji = '🤝';
    } else if (isWinner) {
      outcomeText = l10n.matchResultsYouWin;
      outcomeColor = const Color(0xFF00FF88);
      outcomeEmoji = '🏆';
    } else {
      outcomeText = l10n.matchResultsYouLose;
      outcomeColor = const Color(0xFFFF4444);
      outcomeEmoji = '😔';
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Outcome
                Text(
                  outcomeEmoji,
                  style: const TextStyle(fontSize: 56),
                ),
                const SizedBox(height: 12),
                Text(
                  outcomeText,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: outcomeColor,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 14),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.textHint.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'VS $versusName',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textDisabled,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${l10n.matchSeriesWinsShort} ${gs.matchSeriesWins}  ${l10n.matchSeriesLossesShort} ${gs.matchSeriesLosses}  ${l10n.matchSeriesTiesShort} ${gs.matchSeriesTies}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Score comparison cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _PlayerResultCard(
                          name: l10n.matchResultsYou,
                          displayName: myPlayer.displayName,
                          score: myPlayer.score,
                          deviationMs: myPlayer.deviationMs,
                          isWinner: isWinner,
                          color: AppColors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PlayerResultCard(
                          name: l10n.matchResultsOpponent,
                          displayName: opponent.displayName,
                          score: opponent.score,
                          deviationMs: opponent.deviationMs,
                          isWinner: isLoser, // opponent is winner if we lost
                          color: AppColors.cyan,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // Action buttons
                if (match.isComplete) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: GameButton(
                      label: gs.isBotMatch
                          ? l10n.matchResultsPlayAgain
                          : l10n.matchResultsPlayAgain,
                      onPressed: () async {
                        final acceptSpeedUp = await _showRematchSpeedDialog(
                          context,
                          isBotMatch: gs.isBotMatch,
                        );
                        if (!context.mounted || acceptSpeedUp == null) return;
                        if (gs.isBotMatch) {
                          await gs.rematchBot(increaseSpeed: acceptSpeedUp);
                        } else {
                          await gs.startMatchmaking(acceptSpeedUp: acceptSpeedUp);
                        }
                      },
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: GameButton(
                      label: l10n.commonMenu,
                      onPressed: () async => gs.matchReturnToMenu(),
                      primary: false,
                      width: double.infinity,
                    ),
                  ),
                ],

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showRematchSpeedDialog(
    BuildContext context, {
    required bool isBotMatch,
  }) {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: Text(
            l10n.matchResultsRematchSpeedTitle,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            isBotMatch
                ? l10n.matchResultsRematchSpeedBodyBot
                : l10n.matchResultsRematchSpeedBody,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.matchResultsRematchSpeedNormal),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.matchResultsRematchSpeedUp),
            ),
          ],
        );
      },
    );
  }
}

class _PlayerResultCard extends StatelessWidget {
  final String name;
  final String displayName;
  final int? score;
  final int? deviationMs;
  final bool isWinner;
  final Color color;

  const _PlayerResultCard({
    required this.name,
    required this.displayName,
    required this.score,
    required this.deviationMs,
    required this.isWinner,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: isWinner
            ? Border.all(color: AppColors.gold, width: 2)
            : Border.all(color: AppColors.textHint, width: 1),
      ),
      child: Column(
        children: [
          // Label (YOU / OPPONENT)
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Score
          Text(
            score != null ? '$score' : '—',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w300,
              color: isWinner ? AppColors.gold : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.resultsScore,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 8),
          // Deviation
          Text(
            deviationMs != null ? '${deviationMs}ms' : '—',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            l10n.resultsDeviation,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textDisabled,
            ),
          ),
          if (isWinner) ...[
            const SizedBox(height: 8),
            const Text('👑', style: TextStyle(fontSize: 20)),
          ],
        ],
      ),
    );
  }
}
