// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get commonBack => 'Назад';

  @override
  String get commonMenu => 'Меню';

  @override
  String get commonPlay => 'ИГРАТЬ';

  @override
  String get commonPlayAgain => 'Играть снова';

  @override
  String get commonShare => 'Поделиться';

  @override
  String get commonLoading => 'Загрузка...';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonConfirm => 'Подтвердить';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get menuLogo => '6.7';

  @override
  String get menuSubtitle => 'Остановись на шесть точка семь';

  @override
  String get menuGames => 'Игры';

  @override
  String get menuBest => 'Лучший';

  @override
  String get menuStreak => 'Серия';

  @override
  String get menuLeaderboard => 'Таблица лидеров';

  @override
  String get menuProfile => 'Профиль';

  @override
  String get menuShop => 'Магазин';

  @override
  String get menuSettings => 'Настройки';

  @override
  String menuLevel(int level) {
    return 'Уровень $level';
  }

  @override
  String get menuDailyReward => 'Ежедневная награда';

  @override
  String get menuSessionTitle => 'Сессия';

  @override
  String get menuSessionGames => 'Игры';

  @override
  String get menuSessionBest => 'Лучший';

  @override
  String get menuSessionCoins => 'Монеты';

  @override
  String get modeSelectTitle => 'Выбор режима';

  @override
  String get modeSelectBack => '← Назад';

  @override
  String get countdownGetReady => 'ПРИГОТОВЬТЕСЬ';

  @override
  String get playingBlindMode => 'СЛЕПОЙ РЕЖИМ';

  @override
  String get playingTapHint => 'НАЖМИТЕ КУДА УГОДНО, ЧТОБЫ ОСТАНОВИТЬ';

  @override
  String get playingTarget => 'Цель';

  @override
  String get resultsNewBest => 'НОВЫЙ РЕКОРД!';

  @override
  String get resultsPerfectStop => 'ИДЕАЛЬНАЯ ОСТАНОВКА!';

  @override
  String get resultsScore => 'Счет';

  @override
  String get resultsStoppedAt => 'Остановлено на';

  @override
  String get resultsDeviation => 'Отклонение';

  @override
  String get resultsStreak => 'Серия';

  @override
  String get resultsMultiplier => 'Множитель';

  @override
  String get resultsXp => 'Опыт';

  @override
  String get resultsPersonalBest => 'НОВЫЙ ЛИЧНЫЙ РЕКОРД!';

  @override
  String get resultsNearMiss => 'Почти! Попробуйте снова!';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsSubscriptionStatus => 'Статус подписки';

  @override
  String get settingsPlan => 'План';

  @override
  String get settingsPlanFree => 'Бесплатно';

  @override
  String get settingsPlanPro => 'Stop at 67 Pro';

  @override
  String get settingsExpires => 'Истекает';

  @override
  String get settingsFeatures => 'Функции';

  @override
  String get settingsFeatureNoAds => 'Без рекламы';

  @override
  String get settingsFeature2xXP => '2x Опыта';

  @override
  String get settingsFeatureCosmetics => 'Эксклюзивная косметика';

  @override
  String get settingsFeatureSupport => 'Приоритетная поддержка';

  @override
  String get settingsAccount => 'Аккаунт';

  @override
  String get settingsRestorePurchases => 'Восстановить покупки';

  @override
  String get settingsLogout => 'Выйти';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsSelectLanguage => 'Выберите язык';

  @override
  String get settingsVersion => 'Stop at 67 v1.0.0';

  @override
  String get settingsPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get settingsTermsOfService => 'Условия использования';

  @override
  String get settingsLoadingSettings => 'Загрузка настроек...';

  @override
  String get alertsSuccess => 'Успешно';

  @override
  String get alertsError => 'Ошибка';

  @override
  String get alertsPurchasesRestored => 'Покупки успешно восстановлены';

  @override
  String get alertsNoPurchases => 'Нет покупок';

  @override
  String get alertsNoPurchasesFound => 'Предыдущих покупок не найдено';

  @override
  String get alertsRestoreFailed => 'Не удалось восстановить покупки';

  @override
  String get alertsWelcomePremium => 'Добро пожаловать в Премиум!';

  @override
  String get alertsPurchaseFailed =>
      'Покупка не удалась. Пожалуйста, попробуйте снова.';

  @override
  String get alertsLoggedOut => 'Вышли';

  @override
  String get alertsLoggedOutMessage => 'Вы вышли из системы';

  @override
  String get languagesEn => 'English';

  @override
  String get languagesHe => 'עברית';

  @override
  String get languagesRu => 'Русский';
}
