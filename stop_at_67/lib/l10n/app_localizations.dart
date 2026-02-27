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
