import 'dart:async';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/game_state.dart';
import '../state/auth_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/wrestler_avatar.dart';
import '../engine/types.dart';
import '../engine/constants.dart';

/// Pre-game lobby: shows both matched players and a countdown before play.
class MatchLobbyScreen extends StatefulWidget {
  const MatchLobbyScreen({super.key});

  @override
  State<MatchLobbyScreen> createState() => _MatchLobbyScreenState();
}

class _MatchLobbyScreenState extends State<MatchLobbyScreen> {
  static const _kCountdownIntervalMs = 800;
  int _countdown = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: _kCountdownIntervalMs), _tick);
  }

  void _tick(Timer _) {
    if (!mounted) return;
    Haptics.vibrate(HapticsType.light).catchError((_) {});
    setState(() {
      if (_countdown > 1) {
        _countdown--;
      } else {
        _timer?.cancel();
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
    final auth = context.watch<AuthState>();
    final match = gs.currentMatch;
    final l10n = AppLocalizations.of(context);
    final isFight = gs.fightModeActive;

    final player1Name = match?.player1.displayName ?? 'Player 1';
    final player2Name = match?.player2?.displayName ?? 'Player 2';
    final speedMultiplier = match?.speedMultiplier ?? 1.0;
    final hasSpeedUp = speedMultiplier > 1.0;
    final speedRequested = match?.speedUpRequested ?? false;

    // Determine which skin to use for each player
    final myUid = auth.user?.uid;
    final iAmPlayer1 = myUid == match?.player1.uid;

    final mySkinId = gs.loadout.wrestlerSkin;
    // Opponent always gets a random visual skin (we don't know their loadout)
    // Use a stable skin based on their display name for consistency
    final opponentSkin = kWrestlerSkins[
      (iAmPlayer1 ? (player2Name.hashCode) : (player1Name.hashCode)).abs() %
          kWrestlerSkins.length
    ];
    final mySkin = wrestlerSkinById(mySkinId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Fight mode round badge
                if (isFight) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.orange.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      l10n.fightRoundLabel(gs.fightRound),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orange,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
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
                ],

                // Player cards with wrestlers in fight mode
                if (isFight)
                  _FightLobbyRow(
                    player1Name: iAmPlayer1 ? player1Name : player2Name,
                    player2Name: iAmPlayer1 ? player2Name : player1Name,
                    mySkin: mySkin,
                    opponentSkin: opponentSkin,
                    myHp: gs.myFightHp,
                    opponentHp: gs.opponentFightHp,
                    maxHp: GameState.kFightMaxHp,
                  )
                else ...[
                  _PlayerCard(name: player1Name, color: AppColors.orange),
                  const SizedBox(height: 20),
                  Text(
                    l10n.matchLobbyVs,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _PlayerCard(name: player2Name, color: AppColors.cyan),
                ],

                const SizedBox(height: 28),

                // Speed badge — shown when both agreed to speed up
                if (hasSpeedUp)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
                    ),
                    child: Text(
                      '⚡ ${speedMultiplier.toStringAsFixed(2)}×  ${l10n.matchLobbySpeedUp}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  )
                else if (speedRequested)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.textHint.withValues(alpha: 0.45)),
                    ),
                    child: Text(
                      l10n.matchResultsRematchSpeedBody,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 20),

                const SizedBox(height: 20),

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

// ── Fight lobby: side-by-side wrestlers with HP bars ──────────

class _FightLobbyRow extends StatelessWidget {
  final String player1Name;
  final String player2Name;
  final WrestlerSkin mySkin;
  final WrestlerSkin opponentSkin;
  final int myHp;
  final int opponentHp;
  final int maxHp;

  const _FightLobbyRow({
    required this.player1Name,
    required this.player2Name,
    required this.mySkin,
    required this.opponentSkin,
    required this.myHp,
    required this.opponentHp,
    required this.maxHp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // My side
          _FighterCard(
            name: player1Name,
            skin: mySkin,
            hp: myHp,
            maxHp: maxHp,
            color: AppColors.orange,
            mirrored: false,
          ),

          // VS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: const [
                Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.gold,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),

          // Opponent side
          _FighterCard(
            name: player2Name,
            skin: opponentSkin,
            hp: opponentHp,
            maxHp: maxHp,
            color: AppColors.cyan,
            mirrored: true,
          ),
        ],
      ),
    );
  }
}

class _FighterCard extends StatelessWidget {
  final String name;
  final WrestlerSkin skin;
  final int hp;
  final int maxHp;
  final Color color;
  final bool mirrored;

  const _FighterCard({
    required this.name,
    required this.skin,
    required this.hp,
    required this.maxHp,
    required this.color,
    required this.mirrored,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // HP hearts
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxHp, (i) {
            final filled = i < hp;
            return Icon(
              filled ? Icons.favorite : Icons.favorite_border,
              color: filled ? Colors.redAccent : AppColors.textHint,
              size: 18,
            );
          }),
        ),
        const SizedBox(height: 8),
        // Wrestler
        WrestlerAvatar(skin: skin, size: 90, mirrored: mirrored),
        const SizedBox(height: 8),
        // Name
        SizedBox(
          width: 110,
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Original simple player card (quick match) ────────────────

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
