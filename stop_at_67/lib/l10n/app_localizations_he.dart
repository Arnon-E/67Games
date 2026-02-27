// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get commonBack => 'חזור';

  @override
  String get commonMenu => 'תפריט';

  @override
  String get commonPlay => 'שחק';

  @override
  String get commonPlayAgain => 'שחק שוב';

  @override
  String get commonShare => 'שתף';

  @override
  String get commonLoading => 'טוען...';

  @override
  String get commonCancel => 'בטל';

  @override
  String get commonConfirm => 'אשר';

  @override
  String get commonClose => 'סגור';

  @override
  String get menuLogo => '6.7';

  @override
  String get menuSubtitle => 'עצור בשש נקודה שבע';

  @override
  String get menuGames => 'משחקים';

  @override
  String get menuBest => 'הטוב ביותר';

  @override
  String get menuStreak => 'רצף';

  @override
  String get menuLeaderboard => 'לוח מובילים';

  @override
  String get menuProfile => 'פרופיל';

  @override
  String get menuShop => 'חנות';

  @override
  String get menuSettings => 'הגדרות';

  @override
  String menuLevel(int level) {
    return 'רמה $level';
  }

  @override
  String get menuDailyReward => 'פרס יומי';

  @override
  String get menuSessionTitle => 'סשן';

  @override
  String get menuSessionGames => 'משחקים';

  @override
  String get menuSessionBest => 'הטוב ביותר';

  @override
  String get menuSessionCoins => 'מטבעות';

  @override
  String get modeSelectTitle => 'בחר מצב';

  @override
  String get modeSelectBack => '→ חזור';

  @override
  String get countdownGetReady => 'היה מוכן';

  @override
  String get playingBlindMode => 'מצב עיוור';

  @override
  String get playingTapHint => 'הקש בכל מקום כדי לעצור';

  @override
  String get playingTarget => 'יעד';

  @override
  String get resultsNewBest => 'שיא חדש!';

  @override
  String get resultsPerfectStop => 'עצירה מושלמת!';

  @override
  String get resultsScore => 'ניקוד';

  @override
  String get resultsStoppedAt => 'נעצר ב';

  @override
  String get resultsDeviation => 'סטייה';

  @override
  String get resultsStreak => 'רצף';

  @override
  String get resultsMultiplier => 'מכפיל';

  @override
  String get resultsXp => 'נק\' ניסיון';

  @override
  String get resultsPersonalBest => 'שיא אישי חדש!';

  @override
  String get resultsNearMiss => 'כמעט! נסה שוב!';

  @override
  String get settingsTitle => 'הגדרות';

  @override
  String get settingsSubscriptionStatus => 'סטטוס מנוי';

  @override
  String get settingsPlan => 'תוכנית';

  @override
  String get settingsPlanFree => 'חינם';

  @override
  String get settingsPlanPro => 'Stop at 67 Pro';

  @override
  String get settingsExpires => 'פג תוקף';

  @override
  String get settingsFeatures => 'תכונות';

  @override
  String get settingsFeatureNoAds => 'ללא פרסומות';

  @override
  String get settingsFeature2xXP => 'כפל נק\' ניסיון';

  @override
  String get settingsFeatureCosmetics => 'קוסמטיקה בלעדית';

  @override
  String get settingsFeatureSupport => 'תמיכה עדיפה';

  @override
  String get settingsAccount => 'חשבון';

  @override
  String get settingsRestorePurchases => 'שחזר רכישות';

  @override
  String get settingsLogout => 'התנתק';

  @override
  String get settingsLanguage => 'שפה';

  @override
  String get settingsSelectLanguage => 'בחר שפה';

  @override
  String get settingsVersion => 'Stop at 67 גרסה 1.0.0';

  @override
  String get settingsPrivacyPolicy => 'מדיניות פרטיות';

  @override
  String get settingsTermsOfService => 'תנאי שירות';

  @override
  String get settingsLoadingSettings => 'טוען הגדרות...';

  @override
  String get alertsSuccess => 'הצלחה';

  @override
  String get alertsError => 'שגיאה';

  @override
  String get alertsPurchasesRestored => 'רכישות שוחזרו בהצלחה';

  @override
  String get alertsNoPurchases => 'אין רכישות';

  @override
  String get alertsNoPurchasesFound => 'לא נמצאו רכישות קודמות';

  @override
  String get alertsRestoreFailed => 'שחזור רכישות נכשל';

  @override
  String get alertsWelcomePremium => 'ברוך הבא לפרימיום!';

  @override
  String get alertsPurchaseFailed => 'הרכישה נכשלה. אנא נסה שוב.';

  @override
  String get alertsLoggedOut => 'מנותק';

  @override
  String get alertsLoggedOutMessage => 'התנתקת';

  @override
  String get languagesEn => 'English';

  @override
  String get languagesHe => 'עברית';

  @override
  String get languagesRu => 'Русский';
}
