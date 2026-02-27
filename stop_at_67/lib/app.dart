import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';

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
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0a0a0f),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B35),
          secondary: Color(0xFFFF6B35),
          surface: Color(0xFF1a1a2e),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
        ),
        useMaterial3: true,
      ),
      home: const _ScreenSwitcher(),
    );
  }
}

class _ScreenSwitcher extends StatelessWidget {
  const _ScreenSwitcher();

  /// Returns the screen to go back to, or null if we should exit the app.
  AppScreen? _backTarget(AppScreen screen) => switch (screen) {
    AppScreen.menu        => null, // exit app
    AppScreen.modeSelect  => AppScreen.menu,
    AppScreen.countdown   => AppScreen.modeSelect,
    AppScreen.playing     => null, // handled by PlayingScreen's own PopScope
    AppScreen.results     => AppScreen.menu,
    AppScreen.settings    => AppScreen.menu,
    AppScreen.leaderboard => AppScreen.menu,
    AppScreen.profile     => AppScreen.menu,
    AppScreen.shop        => AppScreen.menu,
    AppScreen.auth        => AppScreen.leaderboard,
  };

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final screen = gs.screen;
    final languageState = context.watch<LanguageState>();

    final backTarget = _backTarget(screen);

    Widget child = _buildScreen(screen);

    if (languageState.isRTL) {
      child = Directionality(textDirection: TextDirection.rtl, child: child);
    }

    return PopScope(
      canPop: backTarget == null, // menu screen: allow exit
      onPopInvokedWithResult: (_, __) {
        if (backTarget != null) {
          if (backTarget == AppScreen.menu) {
            gs.returnToMenu();
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
      AppScreen.menu        => const MenuScreen(),
      AppScreen.modeSelect  => const ModeSelectScreen(),
      AppScreen.countdown   => const CountdownScreen(),
      AppScreen.playing     => const PlayingScreen(),
      AppScreen.results     => const ResultsScreen(),
      AppScreen.settings    => const SettingsScreen(),
      AppScreen.leaderboard => const LeaderboardScreen(),
      AppScreen.profile     => const ProfileScreen(),
      AppScreen.shop        => const ShopScreen(),
      AppScreen.auth        => const AuthScreen(),
    };
  }
}
