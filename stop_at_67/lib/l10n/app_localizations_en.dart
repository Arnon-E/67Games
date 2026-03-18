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
  String get playingStopAt => 'Stop at ';

  @override
  String get playingStop => 'STOP';

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
  @override
  String get settingsSound => 'Sound';

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
  String get profileTotalXp => 'Total Score';

  @override
  String get profileBestScores => 'Best Scores';

  @override
  String get profileAchievements => 'Achievements';

  @override
  String get profileGuest => 'Guest';

  @override
  String get profileSignOut => 'Sign Out';

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
  String get shopEquipped => 'Equipped';

  @override
  String get shopEquip => 'Equip';

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
  String get modeSurgeName => 'Accelerate';

  @override
  String get modeSurgeDesc =>
      'Timer speeds up every game — how long can you keep up?';

  @override
  String get modeDoubleTapName => 'Double Tap';

  @override
  String get modeDoubleTapDesc =>
      'Tap at 3.35s then stop at 6.7s — test your rhythm';

  @override
  String get modeMovingTargetName => 'Moving Target';

  @override
  String get modeMovingTargetDesc =>
      'Each round the target shifts — stay adaptable';

  @override
  String get modeCalibrationName => 'Calibration';

  @override
  String get modeCalibrationDesc =>
      '5 attempts averaged — track your consistency';

  @override
  String get modePressureName => 'Pressure';

  @override
  String get modePressureDesc =>
      'Hit within tolerance — it tightens each success';

  @override
  String get playingDoubleTapMidHint => 'TAP AT 3.35s';

  @override
  String get playingDoubleTapStopHint => 'STOP AT 6.7s';

  @override
  String get resultsNextAttempt => 'Next Attempt';

  @override
  String resultsCalibrationAttempt(int current, int total) {
    return 'Attempt $current / $total';
  }

  @override
  String get resultsCalibrationSummary => 'CALIBRATION SUMMARY';

  @override
  String get resultsCalibrationAttemptLabel => 'Attempt';

  @override
  String get resultsCalibrationAvgDeviation => 'Avg Deviation';

  @override
  String get resultsPressureCleared => 'ROUND CLEARED ✓';

  @override
  String get resultsPressureEliminated => 'ELIMINATED ✗';

  @override
  String get resultsPressureRounds => 'Rounds Survived';

  @override
  String get resultsPressureNextTolerance => 'Next Tolerance';

  @override
  String get resultsPressureCurrentTolerance => 'Current Tolerance';

  @override
  String get resultsPressureNextRound => 'Next Round';

  @override
  String get pressureRetry => 'TRY AGAIN';

  @override
  String get pressureWatchAd => 'WATCH AD — EXTRA ATTEMPT';

  @override
  String get pressureGameOver => 'ACCEPT GAME OVER';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authCompeteGlobally => 'Compete Globally';

  @override
  String get authSubtitle =>
      'Sign in to appear on the leaderboard\nand track your rank worldwide.';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authSigningIn => 'Signing in…';

  @override
  String get authPlayAsGuest => 'Play as Guest';

  @override
  String get authEnterDisplayName => 'Enter your display name';

  @override
  String get surgeResetTitle => 'ACCELERATE RESET';

  @override
  String get surgeResetBody => 'No lives left!\nSpeed resets to 1×.';

  @override
  String get surgeResetWatchAd => 'WATCH AD — GET 1 LIFE';

  @override
  String get surgeResetAccept => 'OK, RESET TO 1×';

  @override
  String surgeResetTotalScore(int score) {
    return 'Total score: $score';
  }

  @override
  String get surgeFailLabel => 'GAME OVER';

  @override
  String get resultsTotalScore => 'Total Score';

  @override
  String get resultsLives => 'Lives';

  @override
  String get resultsLivesHeartEmoji => '❤️';

  @override
  String get weeklyMissionsTitle => 'WEEKLY MISSIONS';

  @override
  String get weeklyMissionPlay10Label => 'Game Grinder';

  @override
  String get weeklyMissionPlay10Desc => 'Play 10 games in any mode';

  @override
  String get weeklyMissionPerfect3Label => 'Perfectionist';

  @override
  String get weeklyMissionPerfect3Desc => 'Get 3 Perfect stops (0ms off)';

  @override
  String get weeklyMissionModes3Label => 'Explorer';

  @override
  String get weeklyMissionModes3Desc => 'Play 3 different game modes';

  @override
  String get weeklyMissionScore900Label => 'Sharpshooter';

  @override
  String get weeklyMissionScore900Desc => 'Score 900+ in a single game';

  @override
  String get weeklyMissionStreak5Label => 'On Fire';

  @override
  String get weeklyMissionStreak5Desc => 'Reach a streak of 5 in one session';

  @override
  String get leaderboardAllTime => 'ALL TIME';

  @override
  String get leaderboardThisWeek => '🏆 THIS WEEK';

  @override
  String get leaderboardWeeklyTournament => '🏆  Weekly Tournament';

  @override
  String leaderboardResetsIn(String time) {
    return 'Resets in $time';
  }

  @override
  String weeklyMissionsProgress(int completed, int total) {
    return '$completed / $total complete';
  }

  @override
  String get weeklyMissionsClaim => 'CLAIM!';

  @override
  String get weeklyMissionsClaimButton => 'CLAIM';

  @override
  String get settingsHowToPlay => 'How to Play';

  @override
  String get settingsHowToPlayIntro =>
      'Tap the screen to stop the timer at exactly the target time. The closer you are, the higher your score (up to 1000). A perfect stop (0ms off) earns a streak bonus.';

  @override
  String get settingsRulesClassicTitle => 'Classic';

  @override
  String get settingsRulesClassicBody =>
      'Stop the timer at exactly 6.700 seconds. The game that started it all.';

  @override
  String get settingsRulesBlindTitle => 'Blind';

  @override
  String get settingsRulesBlindBody =>
      'The timer displays for 3 seconds, then hides. Stop it at 6.700 seconds without being able to see the clock.';

  @override
  String get settingsRulesSurgeTitle => 'Accelerate';

  @override
  String get settingsRulesSurgeBody =>
      'Same 6.700s target, but the timer speeds up a little after each game. See how many rounds you can keep up.';

  @override
  String get settingsRulesDoubleTapTitle => 'Double Tap';

  @override
  String get settingsRulesDoubleTapBody =>
      'Tap once at 3.350 seconds, then tap again to stop at 6.700 seconds. Both taps count toward your score.';

  @override
  String get settingsRulesMovingTargetTitle => 'Moving Target';

  @override
  String get settingsRulesMovingTargetBody =>
      'The target time shifts every round. Stay adaptable — you won\'t know exactly where to stop until the round begins.';

  @override
  String get settingsRulesCalibrationTitle => 'Calibration';

  @override
  String get settingsRulesCalibrationBody =>
      'Make 5 attempts in a row. Your score is based on the average deviation across all 5 — consistency is everything.';

  @override
  String get settingsRulesPressureTitle => 'Pressure';

  @override
  String get settingsRulesPressureBody =>
      'Stop within the allowed tolerance window. Each success tightens the window. Survive as many rounds as you can.';
}
