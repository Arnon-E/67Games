import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he'),
    Locale('ru')
  ];

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get commonMenu;

  /// No description provided for @commonPlay.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get commonPlay;

  /// No description provided for @commonPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get commonPlayAgain;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @menuLogo.
  ///
  /// In en, this message translates to:
  /// **'6.7'**
  String get menuLogo;

  /// No description provided for @menuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stop at six point seven'**
  String get menuSubtitle;

  /// No description provided for @menuGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get menuGames;

  /// No description provided for @menuBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get menuBest;

  /// No description provided for @menuStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get menuStreak;

  /// No description provided for @menuLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get menuLeaderboard;

  /// No description provided for @menuProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get menuProfile;

  /// No description provided for @menuShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get menuShop;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String menuLevel(int level);

  /// No description provided for @menuDailyReward.
  ///
  /// In en, this message translates to:
  /// **'Daily Reward'**
  String get menuDailyReward;

  /// No description provided for @menuSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get menuSessionTitle;

  /// No description provided for @menuSessionGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get menuSessionGames;

  /// No description provided for @menuSessionBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get menuSessionBest;

  /// No description provided for @menuSessionCoins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get menuSessionCoins;

  /// No description provided for @modeSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Mode'**
  String get modeSelectTitle;

  /// No description provided for @modeSelectBack.
  ///
  /// In en, this message translates to:
  /// **'← Back'**
  String get modeSelectBack;

  /// No description provided for @countdownGetReady.
  ///
  /// In en, this message translates to:
  /// **'GET READY'**
  String get countdownGetReady;

  /// No description provided for @playingStopAt.
  ///
  /// In en, this message translates to:
  /// **'Stop at '**
  String get playingStopAt;

  /// No description provided for @playingStop.
  ///
  /// In en, this message translates to:
  /// **'STOP'**
  String get playingStop;

  /// No description provided for @playingBlindMode.
  ///
  /// In en, this message translates to:
  /// **'BLIND MODE'**
  String get playingBlindMode;

  /// No description provided for @playingTapHint.
  ///
  /// In en, this message translates to:
  /// **'TAP ANYWHERE TO STOP'**
  String get playingTapHint;

  /// No description provided for @playingTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get playingTarget;

  /// No description provided for @resultsNewBest.
  ///
  /// In en, this message translates to:
  /// **'NEW BEST!'**
  String get resultsNewBest;

  /// No description provided for @resultsPerfectStop.
  ///
  /// In en, this message translates to:
  /// **'PERFECT STOP!'**
  String get resultsPerfectStop;

  /// No description provided for @resultsScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get resultsScore;

  /// No description provided for @resultsStoppedAt.
  ///
  /// In en, this message translates to:
  /// **'Stopped At'**
  String get resultsStoppedAt;

  /// No description provided for @resultsDeviation.
  ///
  /// In en, this message translates to:
  /// **'Deviation'**
  String get resultsDeviation;

  /// No description provided for @resultsStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get resultsStreak;

  /// No description provided for @resultsMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Multiplier'**
  String get resultsMultiplier;

  /// No description provided for @resultsXp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get resultsXp;

  /// No description provided for @resultsPersonalBest.
  ///
  /// In en, this message translates to:
  /// **'NEW PERSONAL BEST!'**
  String get resultsPersonalBest;

  /// No description provided for @resultsNearMiss.
  ///
  /// In en, this message translates to:
  /// **'So close! Try again!'**
  String get resultsNearMiss;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubscriptionStatus.
  ///
  /// In en, this message translates to:
  /// **'Subscription Status'**
  String get settingsSubscriptionStatus;

  /// No description provided for @settingsPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get settingsPlan;

  /// No description provided for @settingsPlanFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get settingsPlanFree;

  /// No description provided for @settingsPlanPro.
  ///
  /// In en, this message translates to:
  /// **'Stop at 67 Pro'**
  String get settingsPlanPro;

  /// No description provided for @settingsExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get settingsExpires;

  /// No description provided for @settingsFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get settingsFeatures;

  /// No description provided for @settingsFeatureNoAds.
  ///
  /// In en, this message translates to:
  /// **'No Ads'**
  String get settingsFeatureNoAds;

  /// No description provided for @settingsFeature2xXP.
  ///
  /// In en, this message translates to:
  /// **'2x XP'**
  String get settingsFeature2xXP;

  /// No description provided for @settingsFeatureCosmetics.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Cosmetics'**
  String get settingsFeatureCosmetics;

  /// No description provided for @settingsFeatureSupport.
  ///
  /// In en, this message translates to:
  /// **'Priority Support'**
  String get settingsFeatureSupport;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get settingsRestorePurchases;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsSound;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get settingsSelectLanguage;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Stop at 67 v1.0.0'**
  String get settingsVersion;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsLoadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Loading settings...'**
  String get settingsLoadingSettings;

  /// No description provided for @alertsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get alertsSuccess;

  /// No description provided for @alertsError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get alertsError;

  /// No description provided for @alertsPurchasesRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully'**
  String get alertsPurchasesRestored;

  /// No description provided for @alertsNoPurchases.
  ///
  /// In en, this message translates to:
  /// **'No Purchases'**
  String get alertsNoPurchases;

  /// No description provided for @alertsNoPurchasesFound.
  ///
  /// In en, this message translates to:
  /// **'No previous purchases found'**
  String get alertsNoPurchasesFound;

  /// No description provided for @alertsRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore purchases'**
  String get alertsRestoreFailed;

  /// No description provided for @alertsWelcomePremium.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Premium!'**
  String get alertsWelcomePremium;

  /// No description provided for @alertsPurchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get alertsPurchaseFailed;

  /// No description provided for @alertsLoggedOut.
  ///
  /// In en, this message translates to:
  /// **'Logged Out'**
  String get alertsLoggedOut;

  /// No description provided for @alertsLoggedOutMessage.
  ///
  /// In en, this message translates to:
  /// **'You have been logged out'**
  String get alertsLoggedOutMessage;

  /// No description provided for @languagesEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languagesEn;

  /// No description provided for @languagesHe.
  ///
  /// In en, this message translates to:
  /// **'עברית'**
  String get languagesHe;

  /// No description provided for @languagesRu.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languagesRu;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardYourBest.
  ///
  /// In en, this message translates to:
  /// **'Your Best'**
  String get leaderboardYourBest;

  /// No description provided for @leaderboardSignInToCompete.
  ///
  /// In en, this message translates to:
  /// **'Sign in to compete'**
  String get leaderboardSignInToCompete;

  /// No description provided for @leaderboardSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get leaderboardSignOut;

  /// No description provided for @leaderboardNoScores.
  ///
  /// In en, this message translates to:
  /// **'No scores yet'**
  String get leaderboardNoScores;

  /// No description provided for @leaderboardBeFirst.
  ///
  /// In en, this message translates to:
  /// **'Be the first to play!'**
  String get leaderboardBeFirst;

  /// No description provided for @leaderboardSignInToSee.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see rankings'**
  String get leaderboardSignInToSee;

  /// No description provided for @leaderboardScoresGlobal.
  ///
  /// In en, this message translates to:
  /// **'Your scores will appear globally'**
  String get leaderboardScoresGlobal;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String profileLevel(int level);

  /// No description provided for @profileStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get profileStatistics;

  /// No description provided for @profileGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get profileGames;

  /// No description provided for @profileBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get profileBestStreak;

  /// No description provided for @profilePerfects.
  ///
  /// In en, this message translates to:
  /// **'Perfects'**
  String get profilePerfects;

  /// No description provided for @profileTotalXp.
  ///
  /// In en, this message translates to:
  /// **'Total Score'**
  String get profileTotalXp;

  /// No description provided for @profileBestScores.
  ///
  /// In en, this message translates to:
  /// **'Best Scores'**
  String get profileBestScores;

  /// No description provided for @profileAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get profileAchievements;

  /// No description provided for @profileGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileGuest;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @profileAchievementsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} / {total} unlocked'**
  String profileAchievementsUnlocked(int unlocked, int total);

  /// No description provided for @shopTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopTitle;

  /// No description provided for @shopCoins.
  ///
  /// In en, this message translates to:
  /// **'{count} coins'**
  String shopCoins(int count);

  /// No description provided for @shopOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get shopOwned;

  /// No description provided for @shopEquipped.
  ///
  /// In en, this message translates to:
  /// **'Equipped'**
  String get shopEquipped;

  /// No description provided for @shopEquip.
  ///
  /// In en, this message translates to:
  /// **'Equip'**
  String get shopEquip;

  /// No description provided for @shopPurchased.
  ///
  /// In en, this message translates to:
  /// **'{name} purchased!'**
  String shopPurchased(String name);

  /// No description provided for @shopCategoryTimerSkins.
  ///
  /// In en, this message translates to:
  /// **'Timer Skins'**
  String get shopCategoryTimerSkins;

  /// No description provided for @shopCategoryBackgrounds.
  ///
  /// In en, this message translates to:
  /// **'Backgrounds'**
  String get shopCategoryBackgrounds;

  /// No description provided for @shopCategoryCelebrations.
  ///
  /// In en, this message translates to:
  /// **'Celebrations'**
  String get shopCategoryCelebrations;

  /// No description provided for @shopItemNeonTimerName.
  ///
  /// In en, this message translates to:
  /// **'Neon Timer'**
  String get shopItemNeonTimerName;

  /// No description provided for @shopItemNeonTimerDesc.
  ///
  /// In en, this message translates to:
  /// **'Glowing neon display'**
  String get shopItemNeonTimerDesc;

  /// No description provided for @shopItemGoldTimerName.
  ///
  /// In en, this message translates to:
  /// **'Gold Timer'**
  String get shopItemGoldTimerName;

  /// No description provided for @shopItemGoldTimerDesc.
  ///
  /// In en, this message translates to:
  /// **'Luxurious gold display'**
  String get shopItemGoldTimerDesc;

  /// No description provided for @shopItemPurpleHazeName.
  ///
  /// In en, this message translates to:
  /// **'Purple Haze'**
  String get shopItemPurpleHazeName;

  /// No description provided for @shopItemPurpleHazeDesc.
  ///
  /// In en, this message translates to:
  /// **'Deep purple background'**
  String get shopItemPurpleHazeDesc;

  /// No description provided for @shopItemOceanDeepName.
  ///
  /// In en, this message translates to:
  /// **'Ocean Deep'**
  String get shopItemOceanDeepName;

  /// No description provided for @shopItemOceanDeepDesc.
  ///
  /// In en, this message translates to:
  /// **'Dark ocean theme'**
  String get shopItemOceanDeepDesc;

  /// No description provided for @shopItemFireworksName.
  ///
  /// In en, this message translates to:
  /// **'Fireworks'**
  String get shopItemFireworksName;

  /// No description provided for @shopItemFireworksDesc.
  ///
  /// In en, this message translates to:
  /// **'Celebrate with fireworks'**
  String get shopItemFireworksDesc;

  /// No description provided for @modeCardTarget.
  ///
  /// In en, this message translates to:
  /// **'Target: {target}'**
  String modeCardTarget(String target);

  /// No description provided for @modeClassicName.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get modeClassicName;

  /// No description provided for @modeClassicDesc.
  ///
  /// In en, this message translates to:
  /// **'Stop the timer at exactly 6.7 seconds'**
  String get modeClassicDesc;

  /// No description provided for @modeExtendedName.
  ///
  /// In en, this message translates to:
  /// **'Extended'**
  String get modeExtendedName;

  /// No description provided for @modeExtendedDesc.
  ///
  /// In en, this message translates to:
  /// **'The ultimate test - stop at 67 seconds'**
  String get modeExtendedDesc;

  /// No description provided for @modeBlindName.
  ///
  /// In en, this message translates to:
  /// **'Blind'**
  String get modeBlindName;

  /// No description provided for @modeBlindDesc.
  ///
  /// In en, this message translates to:
  /// **'Timer hides after 3 seconds - trust your instincts'**
  String get modeBlindDesc;

  /// No description provided for @modeReverseName.
  ///
  /// In en, this message translates to:
  /// **'Reverse'**
  String get modeReverseName;

  /// No description provided for @modeReverseDesc.
  ///
  /// In en, this message translates to:
  /// **'Countdown from 10 - stop at 3.3'**
  String get modeReverseDesc;

  /// No description provided for @modeReverse100Name.
  ///
  /// In en, this message translates to:
  /// **'Reverse 100'**
  String get modeReverse100Name;

  /// No description provided for @modeReverse100Desc.
  ///
  /// In en, this message translates to:
  /// **'Countdown from 100 - stop at 33'**
  String get modeReverse100Desc;

  /// No description provided for @modeDailyName.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get modeDailyName;

  /// No description provided for @modeDailyDesc.
  ///
  /// In en, this message translates to:
  /// **'One attempt per day - compete globally'**
  String get modeDailyDesc;

  /// No description provided for @modeSurgeName.
  ///
  /// In en, this message translates to:
  /// **'Accelerate'**
  String get modeSurgeName;

  /// No description provided for @modeSurgeDesc.
  ///
  /// In en, this message translates to:
  /// **'Timer speeds up every game — how long can you keep up?'**
  String get modeSurgeDesc;

  /// No description provided for @modeDoubleTapName.
  ///
  /// In en, this message translates to:
  /// **'Double Tap'**
  String get modeDoubleTapName;

  /// No description provided for @modeDoubleTapDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap at 3.35s then stop at 6.7s — test your rhythm'**
  String get modeDoubleTapDesc;

  /// No description provided for @modeMovingTargetName.
  ///
  /// In en, this message translates to:
  /// **'Moving Target'**
  String get modeMovingTargetName;

  /// No description provided for @modeMovingTargetDesc.
  ///
  /// In en, this message translates to:
  /// **'Each round the target shifts — stay adaptable'**
  String get modeMovingTargetDesc;

  /// No description provided for @modeCalibrationName.
  ///
  /// In en, this message translates to:
  /// **'Calibration'**
  String get modeCalibrationName;

  /// No description provided for @modeCalibrationDesc.
  ///
  /// In en, this message translates to:
  /// **'5 attempts averaged — track your consistency'**
  String get modeCalibrationDesc;

  /// No description provided for @modePressureName.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get modePressureName;

  /// No description provided for @modePressureDesc.
  ///
  /// In en, this message translates to:
  /// **'Hit within tolerance — it tightens each success'**
  String get modePressureDesc;

  /// No description provided for @modeFortuneName.
  ///
  /// In en, this message translates to:
  /// **'Fortune'**
  String get modeFortuneName;

  /// No description provided for @modeFortuneDesc.
  ///
  /// In en, this message translates to:
  /// **'Spin the wheel — fate picks your mode and multiplier'**
  String get modeFortuneDesc;

  /// No description provided for @modeFortuneSpinToReveal.
  ///
  /// In en, this message translates to:
  /// **'🎰  Spin to reveal'**
  String get modeFortuneSpinToReveal;

  /// No description provided for @fortuneTitle.
  ///
  /// In en, this message translates to:
  /// **'Fortune'**
  String get fortuneTitle;

  /// No description provided for @fortuneCostPerSpin.
  ///
  /// In en, this message translates to:
  /// **'Costs {cost} coins per spin'**
  String fortuneCostPerSpin(int cost);

  /// No description provided for @fortuneSpinButton.
  ///
  /// In en, this message translates to:
  /// **'🎰  SPIN'**
  String get fortuneSpinButton;

  /// No description provided for @fortuneSpinningButton.
  ///
  /// In en, this message translates to:
  /// **'SPINNING...'**
  String get fortuneSpinningButton;

  /// No description provided for @fortuneSpinHint.
  ///
  /// In en, this message translates to:
  /// **'Tap SPIN to reveal your mode and multiplier'**
  String get fortuneSpinHint;

  /// No description provided for @fortuneMultiplierBadge.
  ///
  /// In en, this message translates to:
  /// **'{mult} Score & XP Multiplier'**
  String fortuneMultiplierBadge(String mult);

  /// No description provided for @fortunePlayButton.
  ///
  /// In en, this message translates to:
  /// **'PLAY  {mult}'**
  String fortunePlayButton(String mult);

  /// No description provided for @fortuneBoostLabel.
  ///
  /// In en, this message translates to:
  /// **'🎰  FORTUNE BOOST'**
  String get fortuneBoostLabel;

  /// No description provided for @fortuneRespinButton.
  ///
  /// In en, this message translates to:
  /// **'🔄  Spin Again — {cost} coins'**
  String fortuneRespinButton(int cost);

  /// No description provided for @fortuneRespinCantAfford.
  ///
  /// In en, this message translates to:
  /// **'Not enough coins to spin again'**
  String get fortuneRespinCantAfford;

  /// No description provided for @playingDoubleTapMidHint.
  ///
  /// In en, this message translates to:
  /// **'TAP AT 3.35s'**
  String get playingDoubleTapMidHint;

  /// No description provided for @playingDoubleTapStopHint.
  ///
  /// In en, this message translates to:
  /// **'STOP AT 6.7s'**
  String get playingDoubleTapStopHint;

  /// No description provided for @resultsNextAttempt.
  ///
  /// In en, this message translates to:
  /// **'Next Attempt'**
  String get resultsNextAttempt;

  /// No description provided for @resultsCalibrationAttempt.
  ///
  /// In en, this message translates to:
  /// **'Attempt {current} / {total}'**
  String resultsCalibrationAttempt(int current, int total);

  /// No description provided for @resultsCalibrationSummary.
  ///
  /// In en, this message translates to:
  /// **'CALIBRATION SUMMARY'**
  String get resultsCalibrationSummary;

  /// No description provided for @resultsCalibrationAttemptLabel.
  ///
  /// In en, this message translates to:
  /// **'Attempt'**
  String get resultsCalibrationAttemptLabel;

  /// No description provided for @resultsCalibrationAvgDeviation.
  ///
  /// In en, this message translates to:
  /// **'Avg Deviation'**
  String get resultsCalibrationAvgDeviation;

  /// No description provided for @resultsPressureCleared.
  ///
  /// In en, this message translates to:
  /// **'ROUND CLEARED ✓'**
  String get resultsPressureCleared;

  /// No description provided for @resultsPressureEliminated.
  ///
  /// In en, this message translates to:
  /// **'ELIMINATED ✗'**
  String get resultsPressureEliminated;

  /// No description provided for @resultsPressureRounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds Survived'**
  String get resultsPressureRounds;

  /// No description provided for @resultsPressureNextTolerance.
  ///
  /// In en, this message translates to:
  /// **'Next Tolerance'**
  String get resultsPressureNextTolerance;

  /// No description provided for @resultsPressureCurrentTolerance.
  ///
  /// In en, this message translates to:
  /// **'Current Tolerance'**
  String get resultsPressureCurrentTolerance;

  /// No description provided for @resultsPressureNextRound.
  ///
  /// In en, this message translates to:
  /// **'Next Round'**
  String get resultsPressureNextRound;

  /// No description provided for @pressureRetry.
  ///
  /// In en, this message translates to:
  /// **'TRY AGAIN'**
  String get pressureRetry;

  /// No description provided for @pressureWatchAd.
  ///
  /// In en, this message translates to:
  /// **'WATCH AD — EXTRA ATTEMPT'**
  String get pressureWatchAd;

  /// No description provided for @pressureGameOver.
  ///
  /// In en, this message translates to:
  /// **'ACCEPT GAME OVER'**
  String get pressureGameOver;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authCompeteGlobally.
  ///
  /// In en, this message translates to:
  /// **'Compete Globally'**
  String get authCompeteGlobally;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to appear on the leaderboard\nand track your rank worldwide.'**
  String get authSubtitle;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get authSigningIn;

  /// No description provided for @authPlayAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Play as Guest'**
  String get authPlayAsGuest;

  /// No description provided for @authEnterDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Enter your display name'**
  String get authEnterDisplayName;

  /// No description provided for @surgeResetTitle.
  ///
  /// In en, this message translates to:
  /// **'ACCELERATE RESET'**
  String get surgeResetTitle;

  /// No description provided for @surgeResetBody.
  ///
  /// In en, this message translates to:
  /// **'No lives left!\nSpeed resets to 1×.'**
  String get surgeResetBody;

  /// No description provided for @surgeResetWatchAd.
  ///
  /// In en, this message translates to:
  /// **'WATCH AD — GET 1 LIFE'**
  String get surgeResetWatchAd;

  /// No description provided for @surgeResetAccept.
  ///
  /// In en, this message translates to:
  /// **'OK, RESET TO 1×'**
  String get surgeResetAccept;

  /// No description provided for @surgeResetTotalScore.
  ///
  /// In en, this message translates to:
  /// **'Total score: {score}'**
  String surgeResetTotalScore(int score);

  /// No description provided for @surgeFailLabel.
  ///
  /// In en, this message translates to:
  /// **'GAME OVER'**
  String get surgeFailLabel;

  /// No description provided for @resultsTotalScore.
  ///
  /// In en, this message translates to:
  /// **'Total Score'**
  String get resultsTotalScore;

  /// No description provided for @resultsLives.
  ///
  /// In en, this message translates to:
  /// **'Lives'**
  String get resultsLives;

  /// No description provided for @resultsLivesHeartEmoji.
  ///
  /// In en, this message translates to:
  /// **'❤️'**
  String get resultsLivesHeartEmoji;

  /// No description provided for @weeklyMissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY MISSIONS'**
  String get weeklyMissionsTitle;

  /// No description provided for @weeklyMissionPlay10Label.
  ///
  /// In en, this message translates to:
  /// **'Game Grinder'**
  String get weeklyMissionPlay10Label;

  /// No description provided for @weeklyMissionPlay10Desc.
  ///
  /// In en, this message translates to:
  /// **'Play 10 games in any mode'**
  String get weeklyMissionPlay10Desc;

  /// No description provided for @weeklyMissionPerfect3Label.
  ///
  /// In en, this message translates to:
  /// **'Perfectionist'**
  String get weeklyMissionPerfect3Label;

  /// No description provided for @weeklyMissionPerfect3Desc.
  ///
  /// In en, this message translates to:
  /// **'Get 3 Perfect stops (0ms off)'**
  String get weeklyMissionPerfect3Desc;

  /// No description provided for @weeklyMissionModes3Label.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get weeklyMissionModes3Label;

  /// No description provided for @weeklyMissionModes3Desc.
  ///
  /// In en, this message translates to:
  /// **'Play 3 different game modes'**
  String get weeklyMissionModes3Desc;

  /// No description provided for @weeklyMissionScore900Label.
  ///
  /// In en, this message translates to:
  /// **'Sharpshooter'**
  String get weeklyMissionScore900Label;

  /// No description provided for @weeklyMissionScore900Desc.
  ///
  /// In en, this message translates to:
  /// **'Score 900+ in a single game'**
  String get weeklyMissionScore900Desc;

  /// No description provided for @weeklyMissionStreak5Label.
  ///
  /// In en, this message translates to:
  /// **'On Fire'**
  String get weeklyMissionStreak5Label;

  /// No description provided for @weeklyMissionStreak5Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach a streak of 5 in one session'**
  String get weeklyMissionStreak5Desc;

  /// No description provided for @leaderboardAllTime.
  ///
  /// In en, this message translates to:
  /// **'ALL TIME'**
  String get leaderboardAllTime;

  /// No description provided for @leaderboardThisWeek.
  ///
  /// In en, this message translates to:
  /// **'🏆 THIS WEEK'**
  String get leaderboardThisWeek;

  /// No description provided for @leaderboardWeeklyTournament.
  ///
  /// In en, this message translates to:
  /// **'🏆  Weekly Tournament'**
  String get leaderboardWeeklyTournament;

  /// No description provided for @leaderboardResetsIn.
  ///
  /// In en, this message translates to:
  /// **'Resets in {time}'**
  String leaderboardResetsIn(String time);

  /// No description provided for @weeklyMissionsProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} / {total} complete'**
  String weeklyMissionsProgress(int completed, int total);

  /// No description provided for @weeklyMissionsClaim.
  ///
  /// In en, this message translates to:
  /// **'CLAIM!'**
  String get weeklyMissionsClaim;

  /// No description provided for @weeklyMissionsClaimButton.
  ///
  /// In en, this message translates to:
  /// **'CLAIM'**
  String get weeklyMissionsClaimButton;

  /// No description provided for @settingsHowToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get settingsHowToPlay;

  /// No description provided for @settingsHowToPlayIntro.
  ///
  /// In en, this message translates to:
  /// **'Tap the screen to stop the timer at exactly the target time. The closer you are, the higher your score (up to 1000). A perfect stop (0ms off) earns a streak bonus.'**
  String get settingsHowToPlayIntro;

  /// No description provided for @settingsRulesClassicTitle.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get settingsRulesClassicTitle;

  /// No description provided for @settingsRulesClassicBody.
  ///
  /// In en, this message translates to:
  /// **'Stop the timer at exactly 6.700 seconds. The game that started it all.'**
  String get settingsRulesClassicBody;

  /// No description provided for @settingsRulesBlindTitle.
  ///
  /// In en, this message translates to:
  /// **'Blind'**
  String get settingsRulesBlindTitle;

  /// No description provided for @settingsRulesBlindBody.
  ///
  /// In en, this message translates to:
  /// **'The timer displays for 3 seconds, then hides. Stop it at 6.700 seconds without being able to see the clock.'**
  String get settingsRulesBlindBody;

  /// No description provided for @settingsRulesSurgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Accelerate'**
  String get settingsRulesSurgeTitle;

  /// No description provided for @settingsRulesSurgeBody.
  ///
  /// In en, this message translates to:
  /// **'Same 6.700s target, but the timer speeds up a little after each game. See how many rounds you can keep up.'**
  String get settingsRulesSurgeBody;

  /// No description provided for @settingsRulesDoubleTapTitle.
  ///
  /// In en, this message translates to:
  /// **'Double Tap'**
  String get settingsRulesDoubleTapTitle;

  /// No description provided for @settingsRulesDoubleTapBody.
  ///
  /// In en, this message translates to:
  /// **'Tap once at 3.350 seconds, then tap again to stop at 6.700 seconds. Both taps count toward your score.'**
  String get settingsRulesDoubleTapBody;

  /// No description provided for @settingsRulesMovingTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'Moving Target'**
  String get settingsRulesMovingTargetTitle;

  /// No description provided for @settingsRulesMovingTargetBody.
  ///
  /// In en, this message translates to:
  /// **'The target time shifts every round. Stay adaptable — you won\'t know exactly where to stop until the round begins.'**
  String get settingsRulesMovingTargetBody;

  /// No description provided for @settingsRulesCalibrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Calibration'**
  String get settingsRulesCalibrationTitle;

  /// No description provided for @settingsRulesCalibrationBody.
  ///
  /// In en, this message translates to:
  /// **'Make 5 attempts in a row. Your score is based on the average deviation across all 5 — consistency is everything.'**
  String get settingsRulesCalibrationBody;

  /// No description provided for @settingsRulesPressureTitle.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get settingsRulesPressureTitle;

  /// No description provided for @settingsRulesPressureBody.
  ///
  /// In en, this message translates to:
  /// **'Stop within the allowed tolerance window. Each success tightens the window. Survive as many rounds as you can.'**
  String get settingsRulesPressureBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'he', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
