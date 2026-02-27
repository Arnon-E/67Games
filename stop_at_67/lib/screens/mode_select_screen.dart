import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

import '../state/game_state.dart';
import '../engine/constants.dart';
import '../engine/progression.dart';
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
                      .where((mode) => !const {'extended', 'reverse', 'reverse100'}.contains(mode.id))
                      .map((mode) {
                    final locked = !isModeUnlocked(mode.id, gs.stats);
                    return ModeCard(
                      mode: mode,
                      isLocked: locked,
                      onTap: () {
                        gs.selectMode(mode.id);
                        gs.startCountdown();
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
