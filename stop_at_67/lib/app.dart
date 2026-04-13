import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

import 'state/game_state.dart';
import 'state/language_state.dart';
import 'screens/menu_screen.dart';
import 'screens/mode_select_screen.dart';
import 'screens/countdown_screen.dart';
import 'screens/playing_screen.dart';
import 'screens/results_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/fortune_wheel_screen.dart';
import 'screens/matchmaking_screen.dart';
import 'screens/match_lobby_screen.dart';
import 'screens/match_playing_screen.dart';
import 'screens/match_results_screen.dart';
import 'screens/fight_invite_screen.dart';

class StopAt67App extends StatelessWidget {
  const StopAt67App({super.key});

  @override
  Widget build(BuildContext context) {
    final languageState = context.watch<LanguageState>();

    return MaterialApp(
      title: 'Stop at 67',
      debugShowCheckedModeBanner: false,
      locale: languageState.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.darkTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: child!,
      ),
      home: const _ScreenSwitcher(),
    );
  }
}

class _ScreenSwitcher extends StatelessWidget {
  const _ScreenSwitcher();

  /// Returns the screen to go back to, or null if we should exit the app.
  AppScreen? _backTarget(AppScreen screen) => switch (screen) {
    AppScreen.menu          => null, // exit app
    AppScreen.modeSelect    => AppScreen.menu,
    AppScreen.fortuneWheel  => AppScreen.modeSelect,
    AppScreen.countdown     => AppScreen.modeSelect,
    AppScreen.playing       => null, // handled by PlayingScreen's own PopScope
    AppScreen.results       => AppScreen.menu,
    AppScreen.settings      => AppScreen.menu,
    AppScreen.leaderboard   => AppScreen.menu,
    AppScreen.profile       => AppScreen.menu,
    AppScreen.shop          => AppScreen.menu,
    AppScreen.auth          => AppScreen.menu,
    AppScreen.matchmaking   => AppScreen.menu,
    AppScreen.matchLobby    => null, // can't leave a matched lobby
    AppScreen.matchPlaying  => null, // can't leave during play
    AppScreen.matchResults  => AppScreen.menu,
    AppScreen.fightInvite   => AppScreen.menu,
  };

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final screen = gs.screen;
    final languageState = context.watch<LanguageState>();

    final backTarget = _backTarget(screen);
    final allowSystemPop = screen == AppScreen.menu;

    Widget child = _buildScreen(screen);

    if (languageState.isRTL) {
      child = Directionality(textDirection: TextDirection.rtl, child: child);
    }

    return PopScope(
      canPop: allowSystemPop,
      onPopInvokedWithResult: (_, __) {
        if (allowSystemPop) return;

        if (backTarget != null) {
          // Results screen needs game-state cleanup; all others just navigate.
          if (screen == AppScreen.results || screen == AppScreen.playing) {
            gs.returnToMenu();
          } else if (screen == AppScreen.matchmaking) {
            gs.cancelMatchmaking();
          } else if (screen == AppScreen.matchResults) {
            gs.matchReturnToMenu();
          } else if (screen == AppScreen.fightInvite) {
            gs.cancelFightInvite();
          } else {
            gs.setScreen(backTarget);
          }
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey(screen),
          child: child,
        ),
      ),
    );
  }

  Widget _buildScreen(AppScreen screen) {
    return switch (screen) {
      AppScreen.menu          => const MenuScreen(),
      AppScreen.modeSelect    => const ModeSelectScreen(),
      AppScreen.fortuneWheel  => const FortuneWheelScreen(),
      AppScreen.countdown     => const CountdownScreen(),
      AppScreen.playing       => const PlayingScreen(),
      AppScreen.results       => const ResultsScreen(),
      AppScreen.settings      => const SettingsScreen(),
      AppScreen.leaderboard   => const LeaderboardScreen(),
      AppScreen.profile       => const ProfileScreen(),
      AppScreen.shop          => const ShopScreen(),
      AppScreen.auth          => const AuthScreen(),
      AppScreen.matchmaking   => const MatchmakingScreen(),
      AppScreen.matchLobby    => const MatchLobbyScreen(),
      AppScreen.matchPlaying  => const MatchPlayingScreen(),
      AppScreen.matchResults  => const MatchResultsScreen(),
      AppScreen.fightInvite   => const FightInviteScreen(),
    };
  }
}
