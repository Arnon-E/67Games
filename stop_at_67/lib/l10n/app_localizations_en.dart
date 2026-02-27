// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonBack => 'Back';

  @override
  String get commonMenu => 'Menu';

  @override
  String get commonPlay => 'PLAY';

  @override
  String get commonPlayAgain => 'Play Again';

  @override
  String get commonShare => 'Share';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonClose => 'Close';

  @override
  String get menuLogo => '6.7';

  @override
  String get menuSubtitle => 'Stop at six point seven';

  @override
  String get menuGames => 'Games';

  @override
  String get menuBest => 'Best';

  @override
  String get menuStreak => 'Streak';

  @override
  String get menuLeaderboard => 'Leaderboard';

  @override
  String get menuProfile => 'Profile';

  @override
  String get menuShop => 'Shop';

  @override
  String get menuSettings => 'Settings';

  @override
  String menuLevel(int level) {
    return 'Level $level';
  }

  @override
  String get menuDailyReward => 'Daily Reward';

  @override
  String get menuSessionTitle => 'Session';

  @override
  String get menuSessionGames => 'Games';

  @override
  String get menuSessionBest => 'Best';

  @override
  String get menuSessionCoins => 'Coins';

  @override
  String get modeSelectTitle => 'Select Mode';

  @override
  String get modeSelectBack => '← Back';

  @override
  String get countdownGetReady => 'GET READY';

  @override
  String get playingBlindMode => 'BLIND MODE';

  @override
  String get playingTapHint => 'TAP ANYWHERE TO STOP';

  @override
  String get playingTarget => 'Target';

  @override
  String get resultsNewBest => 'NEW BEST!';

  @override
  String get resultsPerfectStop => 'PERFECT STOP!';

  @override
  String get resultsScore => 'Score';

  @override
  String get resultsStoppedAt => 'Stopped At';

  @override
  String get resultsDeviation => 'Deviation';

  @override
  String get resultsStreak => 'Streak';

  @override
  String get resultsMultiplier => 'Multiplier';

  @override
  String get resultsXp => 'XP';

  @override
  String get resultsPersonalBest => 'NEW PERSONAL BEST!';

  @override
  String get resultsNearMiss => 'So close! Try again!';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubscriptionStatus => 'Subscription Status';

  @override
  String get settingsPlan => 'Plan';

  @override
  String get settingsPlanFree => 'Free';

  @override
  String get settingsPlanPro => 'Stop at 67 Pro';

  @override
  String get settingsExpires => 'Expires';

  @override
  String get settingsFeatures => 'Features';

  @override
  String get settingsFeatureNoAds => 'No Ads';

  @override
  String get settingsFeature2xXP => '2x XP';

  @override
  String get settingsFeatureCosmetics => 'Exclusive Cosmetics';

  @override
  String get settingsFeatureSupport => 'Priority Support';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsRestorePurchases => 'Restore Purchases';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsSelectLanguage => 'Select Language';

  @override
  String get settingsVersion => 'Stop at 67 v1.0.0';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsLoadingSettings => 'Loading settings...';

  @override
  String get alertsSuccess => 'Success';

  @override
  String get alertsError => 'Error';

  @override
  String get alertsPurchasesRestored => 'Purchases restored successfully';

  @override
  String get alertsNoPurchases => 'No Purchases';

  @override
  String get alertsNoPurchasesFound => 'No previous purchases found';

  @override
  String get alertsRestoreFailed => 'Failed to restore purchases';

  @override
  String get alertsWelcomePremium => 'Welcome to Premium!';

  @override
  String get alertsPurchaseFailed => 'Purchase failed. Please try again.';

  @override
  String get alertsLoggedOut => 'Logged Out';

  @override
  String get alertsLoggedOutMessage => 'You have been logged out';

  @override
  String get languagesEn => 'English';

  @override
  String get languagesHe => 'עברית';

  @override
  String get languagesRu => 'Русский';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get leaderboardYourBest => 'Your Best';

  @override
  String get leaderboardSignInToCompete => 'Sign in to compete';

  @override
  String get leaderboardSignOut => 'Sign out';

  @override
  String get leaderboardNoScores => 'No scores yet';

  @override
  String get leaderboardBeFirst => 'Be the first to play!';

  @override
  String get leaderboardSignInToSee => 'Sign in to see rankings';

  @override
  String get leaderboardScoresGlobal => 'Your scores will appear globally';

  @override
  String get profileTitle => 'Profile';

  @override
  String profileLevel(int level) {
    return 'Level $level';
  }

  @override
  String get profileStatistics => 'Statistics';

  @override
  String get profileGames => 'Games';

  @override
  String get profileBestStreak => 'Best Streak';

  @override
  String get profilePerfects => 'Perfects';

  @override
  String get profileTotalXp => 'Total XP';

  @override
  String get profileBestScores => 'Best Scores';

  @override
  String get profileAchievements => 'Achievements';

  @override
  String profileAchievementsUnlocked(int unlocked, int total) {
    return '$unlocked / $total unlocked';
  }

  @override
  String get shopTitle => 'Shop';

  @override
  String shopCoins(int count) {
    return '$count coins';
  }

  @override
  String get shopOwned => 'Owned';

  @override
  String shopPurchased(String name) {
    return '$name purchased!';
  }

  @override
  String get shopCategoryTimerSkins => 'Timer Skins';

  @override
  String get shopCategoryBackgrounds => 'Backgrounds';

  @override
  String get shopCategoryCelebrations => 'Celebrations';

  @override
  String get shopItemNeonTimerName => 'Neon Timer';

  @override
  String get shopItemNeonTimerDesc => 'Glowing neon display';

  @override
  String get shopItemGoldTimerName => 'Gold Timer';

  @override
  String get shopItemGoldTimerDesc => 'Luxurious gold display';

  @override
  String get shopItemPurpleHazeName => 'Purple Haze';

  @override
  String get shopItemPurpleHazeDesc => 'Deep purple background';

  @override
  String get shopItemOceanDeepName => 'Ocean Deep';

  @override
  String get shopItemOceanDeepDesc => 'Dark ocean theme';

  @override
  String get shopItemFireworksName => 'Fireworks';

  @override
  String get shopItemFireworksDesc => 'Celebrate with fireworks';

  @override
  String modeCardTarget(String target) {
    return 'Target: $target';
  }

  @override
  String get modeClassicName => 'Classic';

  @override
  String get modeClassicDesc => 'Stop the timer at exactly 6.7 seconds';

  @override
  String get modeExtendedName => 'Extended';

  @override
  String get modeExtendedDesc => 'The ultimate test - stop at 67 seconds';

  @override
  String get modeBlindName => 'Blind';

  @override
  String get modeBlindDesc =>
      'Timer hides after 3 seconds - trust your instincts';

  @override
  String get modeReverseName => 'Reverse';

  @override
  String get modeReverseDesc => 'Countdown from 10 - stop at 3.3';

  @override
  String get modeReverse100Name => 'Reverse 100';

  @override
  String get modeReverse100Desc => 'Countdown from 100 - stop at 33';

  @override
  String get modeDailyName => 'Daily Challenge';

  @override
  String get modeDailyDesc => 'One attempt per day - compete globally';

  @override
  String get modeSurgeName => 'Surge';

  @override
  String get modeSurgeDesc =>
      'Timer speeds up every game — how long can you keep up?';

  @override
  String get surgeResetTitle => 'SURGE RESET';

  @override
  String get surgeResetBody => '3 fails in a row.\nSpeed resets to 1×.';

  @override
  String get surgeResetWatchAd => 'WATCH AD — KEEP SPEED';

  @override
  String get surgeResetAccept => 'OK, RESET TO 1×';
}
