import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/game_state.dart';
import '../state/auth_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/game_button.dart';
import '../widgets/wrestler_avatar.dart';
import '../engine/types.dart';
import '../engine/constants.dart';

/// Head-to-head results screen — compares both players' scores.
/// In fight mode, shows HP damage and an auto-continue countdown.
class MatchResultsScreen extends StatefulWidget {
  const MatchResultsScreen({super.key});

  @override
  State<MatchResultsScreen> createState() => _MatchResultsScreenState();
}

class _MatchResultsScreenState extends State<MatchResultsScreen>
    with SingleTickerProviderStateMixin {
  /// Auto-continue countdown for fight mode (seconds remaining).
  int _autoContinueSeconds = 3;
  Timer? _autoContinueTimer;
  late AnimationController _hitController;
  late Animation<double> _hitScale;

  @override
  void initState() {
    super.initState();
    _hitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _hitScale = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _hitController, curve: Curves.elasticOut),
    );

    // In fight mode (fight not over), start auto-continue timer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gs = context.read<GameState>();
      if (gs.fightModeActive && !gs.isFightOver) {
        _hitController.forward().then((_) => _hitController.reverse());
        _startAutoContinue(gs);
      }
      // After fight series ends (KO), show interstitial once the KO animation
      // finishes (~2.2s). The ad shows between the KO scene and when the player
      // taps a button, which is the most natural break point.
      if (gs.isFightOver && !gs.isBotMatch) {
        Future.delayed(const Duration(milliseconds: 2400), () {
          if (!mounted) return;
          context.read<GameState>().ads.showInterstitial();
        });
      }
    });
  }

  void _startAutoContinue(GameState gs) {
    _autoContinueTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() { _autoContinueSeconds--; });
      if (_autoContinueSeconds <= 0) {
        t.cancel();
        gs.fightNextRound();
      }
    });
  }

  @override
  void dispose() {
    _autoContinueTimer?.cancel();
    _hitController.dispose();
    super.dispose();
  }

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
    final versusName = gs.isBotMatch ? l10n.matchBotName : opponent.displayName;

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
      outcomeText = gs.fightModeActive ? l10n.fightRoundWin : l10n.matchResultsYouWin;
      outcomeColor = const Color(0xFF00FF88);
      outcomeEmoji = gs.fightModeActive ? '🥊' : '🏆';
    } else {
      outcomeText = gs.fightModeActive ? l10n.fightRoundLoss : l10n.matchResultsYouLose;
      outcomeColor = const Color(0xFFFF4444);
      outcomeEmoji = gs.fightModeActive ? '💥' : '😔';
    }

    // Fight mode: KO outcome overrides round outcome
    if (gs.isFightOver) {
      final iKO = gs.opponentFightHp <= 0;
      return _buildFightKOScreen(
        context: context,
        gs: gs,
        l10n: l10n,
        iWon: iKO,
        myUid: auth.user?.uid ?? '',
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                // Outcome
                AnimatedBuilder(
                  animation: _hitScale,
                  builder: (_, child) => Transform.scale(
                    scale: gs.fightModeActive ? _hitScale.value : 1.0,
                    child: child,
                  ),
                  child: Text(
                    outcomeEmoji,
                    style: const TextStyle(fontSize: 56),
                  ),
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

                // Fight mode: damage + HP info
                if (gs.fightModeActive) ...[
                  const SizedBox(height: 10),
                  _FightDamageRow(
                    myDamage: gs.lastRoundOpponentDamage,
                    opponentDamage: gs.lastRoundMyDamage,
                    myHp: gs.myFightHp,
                    opponentHp: gs.opponentFightHp,
                    maxHp: GameState.kFightMaxHp,
                    speedMultiplier: match.speedMultiplier,
                    l10n: l10n,
                  ),
                ] else ...[
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
                          l10n.matchResultsVs(versusName),
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
                ],

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
                          isTie: isTie,
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
                          isTie: isTie,
                          color: AppColors.cyan,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Action buttons
                if (match.isComplete) ...[
                  // Fight mode: auto-continue or manual next round
                  if (gs.fightModeActive) ...[
                    if (gs.fightRematchSearching) ...[
                      // Silently re-queuing — show a spinner while we wait.
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.orange,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Connecting...',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: GameButton(
                          label: l10n.fightNextRound(_autoContinueSeconds),
                          onPressed: () {
                            _autoContinueTimer?.cancel();
                            gs.fightNextRound();
                          },
                          width: double.infinity,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: GameButton(
                        label: l10n.commonMenu,
                        onPressed: gs.fightRematchSearching
                            ? null
                            : () => gs.matchReturnToMenu(),
                        primary: false,
                        width: double.infinity,
                      ),
                    ),
                  ] else ...[
                    // Standard quick match buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: GameButton(
                        label: l10n.matchResultsPlayAgain,
                        onPressed: () async {
                          final acceptSpeedUp = await _showRematchSpeedDialog(context);
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
                ],

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── KO Screen (fight over) ────────────────────────────────────

  Widget _buildFightKOScreen({
    required BuildContext context,
    required GameState gs,
    required AppLocalizations l10n,
    required bool iWon,
    required String myUid,
  }) {
    final mySkinId = gs.loadout.wrestlerSkin;
    final mySkin = wrestlerSkinById(mySkinId);

    // Resolve opponent's skin from match data, falling back to classic.
    final match = gs.currentMatch;
    String oppSkinId = 'wrestler_default';
    if (match != null) {
      final oppPlayer = match.player1.uid == myUid ? match.player2 : match.player1;
      oppSkinId = oppPlayer?.wrestlerSkin ?? 'wrestler_default';
    }
    final oppSkin = wrestlerSkinById(oppSkinId);

    final winningSkin = iWon ? mySkin : oppSkin;
    final losingSkin  = iWon ? oppSkin : mySkin;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              // Mortal Kombat-style punch animation
              _KOFightScene(
                winningSkin: winningSkin,
                losingSkin: losingSkin,
              ),

              const SizedBox(height: 16),

              // KNOCKOUT text
              Text(
                iWon ? l10n.fightKnockout : l10n.fightKnockedOut,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: iWon ? const Color(0xFF00FF88) : const Color(0xFFFF4444),
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.fightRoundsPlayed(gs.fightRound - 1),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textDisabled,
                  letterSpacing: 1,
                ),
              ),

              // HP summary
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _HpSummary(
                      label: l10n.matchResultsYou,
                      hp: gs.myFightHp,
                      maxHp: GameState.kFightMaxHp,
                      color: AppColors.orange,
                    ),
                    const Text('VS', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.gold,
                    )),
                    _HpSummary(
                      label: l10n.matchResultsOpponent,
                      hp: gs.opponentFightHp,
                      maxHp: GameState.kFightMaxHp,
                      color: AppColors.cyan,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GameButton(
                  label: l10n.fightPlayAgain,
                  onPressed: () => gs.isBotMatch
                      ? gs.startFightVsBot()
                      : gs.startFightMatchmaking(),
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GameButton(
                  label: l10n.commonMenu,
                  onPressed: () => gs.matchReturnToMenu(),
                  primary: false,
                  width: double.infinity,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showRematchSpeedDialog(BuildContext context) {
    final gs = context.read<GameState>();
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
            gs.isBotMatch
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

// ── Fight damage + HP display ─────────────────────────────────

class _FightDamageRow extends StatelessWidget {
  final int myDamage;
  final int opponentDamage;
  final int myHp;
  final int opponentHp;
  final int maxHp;
  final double speedMultiplier;
  final AppLocalizations l10n;

  const _FightDamageRow({
    required this.myDamage,
    required this.opponentDamage,
    required this.myHp,
    required this.opponentHp,
    required this.maxHp,
    required this.speedMultiplier,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Speed multiplier
          if (speedMultiplier > 1.0) ...[
            Text(
              '${speedMultiplier.toStringAsFixed(1)}× ${l10n.fightSpeedLabel}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
          ],
          // HP bars
          Row(
            children: [
              // My HP
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(maxHp, (i) => Icon(
                      i < myHp ? Icons.favorite : Icons.favorite_border,
                      color: i < myHp ? Colors.redAccent : AppColors.textHint,
                      size: 18,
                    )),
                  ),
                  if (opponentDamage > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '−$opponentDamage HP',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFFF4444),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
              const Spacer(),
              // Center
              Text(
                l10n.fightHpLabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textDisabled,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              // Opponent HP
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(maxHp, (i) => Icon(
                      i < opponentHp ? Icons.favorite : Icons.favorite_border,
                      color: i < opponentHp ? Colors.redAccent : AppColors.textHint,
                      size: 18,
                    )).reversed.toList(),
                  ),
                  if (myDamage > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '−$myDamage HP',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF00FF88),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Mortal Kombat-style KO fight animation ────────────────────

class _KOFightScene extends StatefulWidget {
  final WrestlerSkin winningSkin;
  final WrestlerSkin losingSkin;

  const _KOFightScene({required this.winningSkin, required this.losingSkin});

  @override
  State<_KOFightScene> createState() => _KOFightSceneState();
}

class _KOFightSceneState extends State<_KOFightScene>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    // Play once, stay on last frame
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static double _interval(double t, double from, double to) =>
      ((t - from) / (to - from)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = _ctrl.value;

          // Phase timing:
          // 0.00–0.30 → winner steps in (slides right)
          // 0.25–0.60 → punch arm extends
          // 0.55–0.70 → impact flash
          // 0.60–0.90 → loser knocked back (slides + tilts)
          // 0.75–1.00 → loser stays knocked (isKnocked=true)

          final stepIn   = Curves.easeIn.transform(_interval(t, 0.0, 0.30));
          final punch    = Curves.easeOut.transform(_interval(t, 0.25, 0.60));
          final flashRaw = _interval(t, 0.55, 0.70);
          final flash    = flashRaw < 0.5 ? flashRaw * 2 : (1.0 - flashRaw) * 2;
          final knockRaw = Curves.easeIn.transform(_interval(t, 0.60, 0.90));
          final isKnocked = t > 0.75;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Winner (left, steps in toward center) ──
              Positioned(
                left: 20.0 + stepIn * 24.0,
                bottom: 0,
                child: WrestlerAvatar(
                  skin: widget.winningSkin,
                  size: 88,
                  mirrored: false,
                  punchProgress: punch,
                ),
              ),

              // ── Loser (right, knocked back but stays visible) ──
              Positioned(
                right: 20.0 - knockRaw * 12.0,
                bottom: knockRaw * 4.0,
                child: Transform.rotate(
                  angle: knockRaw * 0.3,
                  alignment: Alignment.bottomCenter,
                  child: WrestlerAvatar(
                    skin: widget.losingSkin,
                    size: 88,
                    mirrored: true,
                    isKnocked: isKnocked,
                  ),
                ),
              ),

              // ── Impact burst (💥 appears at contact point) ──
              if (punch > 0.7 && knockRaw < 0.8)
                Positioned(
                  right: 80,
                  bottom: 70,
                  child: Opacity(
                    opacity: (1.0 - knockRaw * 1.1).clamp(0.0, 1.0),
                    child: Text(
                      '💥',
                      style: TextStyle(fontSize: 20 + punch * 14),
                    ),
                  ),
                ),

              // ── Stars above knocked fighter ──
              if (isKnocked)
                Positioned(
                  right: 24 - knockRaw * 28,
                  bottom: 100,
                  child: Opacity(
                    opacity: ((t - 0.75) / 0.25).clamp(0.0, 1.0),
                    child: const Text('✨⭐✨', style: TextStyle(fontSize: 14)),
                  ),
                ),

              // ── White flash on impact ──
              if (flash > 0)
                Positioned.fill(
                  child: Opacity(
                    opacity: (flash * 0.75).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── HP summary row ────────────────────────────────────────────

class _HpSummary extends StatelessWidget {
  final String label;
  final int hp;
  final int maxHp;
  final Color color;

  const _HpSummary({
    required this.label,
    required this.hp,
    required this.maxHp,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(
          fontSize: 10, color: color, fontWeight: FontWeight.w700, letterSpacing: 1.5,
        )),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxHp, (i) => Icon(
            i < hp ? Icons.favorite : Icons.favorite_border,
            color: i < hp ? Colors.redAccent : AppColors.textHint,
            size: 18,
          )),
        ),
      ],
    );
  }
}

class _PlayerResultCard extends StatelessWidget {
  final String name;
  final String displayName;
  final int? score;
  final int? deviationMs;
  final bool isWinner;
  final bool isTie;
  final Color color;

  const _PlayerResultCard({
    required this.name,
    required this.displayName,
    required this.score,
    required this.deviationMs,
    required this.isWinner,
    required this.isTie,
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
        border: (isWinner || isTie)
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
              color: (isWinner || isTie) ? AppColors.gold : AppColors.textPrimary,
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
          if (isWinner || isTie) ...[
            const SizedBox(height: 8),
            Text(isTie ? '🤝' : '👑', style: const TextStyle(fontSize: 20)),
          ],
        ],
      ),
    );
  }
}
