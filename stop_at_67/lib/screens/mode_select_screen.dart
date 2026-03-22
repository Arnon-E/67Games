import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

import '../state/game_state.dart';
import '../engine/constants.dart';
import '../engine/progression.dart';
import '../theme/app_colors.dart';
import '../widgets/app_gradient_background.dart';
import '../widgets/mode_card.dart';
import '../widgets/screen_header.dart';

class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: l10n.modeSelectTitle,
                onBack: () => gs.setScreen(AppScreen.menu),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  children: kGameModes.values
                      .where((mode) => !const {'extended', 'reverse', 'reverse100', 'daily'}.contains(mode.id))
                      .map((mode) {
                    final locked = !isModeUnlocked(mode.id, gs.stats);
                    return ModeCard(
                      mode: mode,
                      isLocked: locked,
                      stats: gs.stats,
                      onTap: () {
                        if (mode.id == 'fortune') {
                          final success = gs.startFortuneSpin();
                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Need ${kFortuneCost} coins to spin  (you have ${gs.coins})',
                                ),
                                backgroundColor: AppColors.darkCard,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } else {
                          gs.selectMode(mode.id);
                          gs.startCountdown();
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
