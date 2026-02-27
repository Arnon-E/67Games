import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'services/storage_service.dart';
import 'services/sound_service.dart';
import 'services/ads_service.dart';
import 'services/subscription_service.dart';
import 'services/auth_service.dart';
import 'services/leaderboard_service.dart';
import 'state/game_state.dart';
import 'state/language_state.dart';
import 'state/subscription_state.dart';
import 'state/auth_state.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set dark system UI overlays
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0a0a0f),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize Firebase
  await Firebase.initializeApp();

  // Instantiate services
  final storage = StorageService();
  final sound = SoundService();
  final ads = AdsService();
  final subscriptions = SubscriptionService();
  final authService = AuthService();
  final leaderboard = LeaderboardService();

  // Initialize in parallel
  await Future.wait([
    sound.init(),
    ads.initialize(),
  ]);

  // Build state objects
  final languageState = LanguageState(storage);
  final subscriptionState = SubscriptionState(subscriptions);
  final authState = AuthState(authService);
  final gameState = GameState(
    storage: storage,
    sound: sound,
    ads: ads,
    authState: authState,
    leaderboard: leaderboard,
  );

  await Future.wait([
    languageState.initialize(),
    subscriptionState.initialize(),
    authState.initialize(),
    gameState.init(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageState),
        ChangeNotifierProvider.value(value: subscriptionState),
        ChangeNotifierProvider.value(value: authState),
        ChangeNotifierProvider.value(value: gameState),
        Provider.value(value: leaderboard),
      ],
      child: const StopAt67App(),
    ),
  );
}
