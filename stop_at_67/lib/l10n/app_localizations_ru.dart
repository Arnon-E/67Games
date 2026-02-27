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

  @override
  String get leaderboardTitle => 'Таблица лидеров';

  @override
  String get leaderboardYourBest => 'Ваш рекорд';

  @override
  String get leaderboardSignInToCompete => 'Войдите, чтобы соревноваться';

  @override
  String get leaderboardSignOut => 'Выйти';

  @override
  String get leaderboardNoScores => 'Результатов пока нет';

  @override
  String get leaderboardBeFirst => 'Будьте первым!';

  @override
  String get leaderboardSignInToSee => 'Войдите, чтобы увидеть рейтинг';

  @override
  String get leaderboardScoresGlobal => 'Ваши результаты появятся глобально';

  @override
  String get profileTitle => 'Профиль';

  @override
  String profileLevel(int level) {
    return 'Уровень $level';
  }

  @override
  String get profileStatistics => 'Статистика';

  @override
  String get profileGames => 'Игры';

  @override
  String get profileBestStreak => 'Лучшая серия';

  @override
  String get profilePerfects => 'Идеальных';

  @override
  String get profileTotalXp => 'Всего опыта';

  @override
  String get profileBestScores => 'Лучшие результаты';

  @override
  String get profileAchievements => 'Достижения';

  @override
  String profileAchievementsUnlocked(int unlocked, int total) {
    return '$unlocked / $total получено';
  }

  @override
  String get shopTitle => 'Магазин';

  @override
  String shopCoins(int count) {
    return '$count монет';
  }

  @override
  String get shopOwned => 'Куплено';

  @override
  String shopPurchased(String name) {
    return '$name куплено!';
  }

  @override
  String get shopCategoryTimerSkins => 'Облики таймера';

  @override
  String get shopCategoryBackgrounds => 'Фоны';

  @override
  String get shopCategoryCelebrations => 'Празднования';

  @override
  String get shopItemNeonTimerName => 'Неоновый таймер';

  @override
  String get shopItemNeonTimerDesc => 'Светящийся неоновый дисплей';

  @override
  String get shopItemGoldTimerName => 'Золотой таймер';

  @override
  String get shopItemGoldTimerDesc => 'Роскошный золотой дисплей';

  @override
  String get shopItemPurpleHazeName => 'Фиолетовый туман';

  @override
  String get shopItemPurpleHazeDesc => 'Глубокий фиолетовый фон';

  @override
  String get shopItemOceanDeepName => 'Глубина океана';

  @override
  String get shopItemOceanDeepDesc => 'Тёмная морская тема';

  @override
  String get shopItemFireworksName => 'Фейерверк';

  @override
  String get shopItemFireworksDesc => 'Отпразднуйте с фейерверком';

  @override
  String modeCardTarget(String target) {
    return 'Цель: $target';
  }

  @override
  String get modeClassicName => 'Классика';

  @override
  String get modeClassicDesc => 'Остановите таймер ровно на 6.7 секундах';

  @override
  String get modeExtendedName => 'Расширенный';

  @override
  String get modeExtendedDesc =>
      'Главное испытание — остановитесь на 67 секундах';

  @override
  String get modeBlindName => 'Слепой';

  @override
  String get modeBlindDesc =>
      'Таймер скрывается через 3 секунды — доверьтесь инстинктам';

  @override
  String get modeReverseName => 'Обратный';

  @override
  String get modeReverseDesc => 'Обратный отсчёт с 10 — остановитесь на 3.3';

  @override
  String get modeReverse100Name => 'Обратный 100';

  @override
  String get modeReverse100Desc =>
      'Обратный отсчёт со 100 — остановитесь на 33';

  @override
  String get modeDailyName => 'Ежедневный вызов';

  @override
  String get modeDailyDesc => 'Одна попытка в день — соревнуйтесь глобально';

  @override
  String get modeSurgeName => 'Волна';

  @override
  String get modeSurgeDesc =>
      'Таймер ускоряется каждую игру — как долго продержитесь?';

  @override
  String get surgeResetTitle => 'СБРОС ВОЛНЫ';

  @override
  String get surgeResetBody =>
      '3 неудачи подряд.\nСкорость сбрасывается до 1×.';

  @override
  String get surgeResetWatchAd => 'СМОТРЕТЬ РЕКЛАМУ — СОХРАНИТЬ СКОРОСТЬ';

  @override
  String get surgeResetAccept => 'ОК, СБРОСИТЬ ДО 1×';
}
