// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Цветовая последовательность';

  @override
  String get score => 'Счёт';

  @override
  String get start => 'Старт';

  @override
  String get gameOver => 'Конец игры';

  @override
  String yourScore(Object score) {
    return 'Ваш счёт: $score';
  }

  @override
  String get restart => 'Заново';

  @override
  String get close => 'Закрыть';

  @override
  String get congrats => 'Поздравляем!';

  @override
  String congratsScore(Object score) {
    return 'Вы достигли счёта $score!';
  }

  @override
  String milestoneLevel(Object level) {
    return 'Уровень $level';
  }

  @override
  String roundLength(Object count) {
    return '$count цветов';
  }

  @override
  String get settings => 'Настройки';

  @override
  String get sound => 'Звук';

  @override
  String get haptics => 'Вибрация';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String bestScore(Object score) {
    return 'Рекорд: $score';
  }

  @override
  String get playAgain => 'Играть снова';

  @override
  String newRecord(Object score) {
    return 'Новый рекорд: $score!';
  }

  @override
  String get greatRun => 'Отличная попытка!';

  @override
  String get almostThere => 'Почти получилось!';

  @override
  String get soClose => 'Так близко!';

  @override
  String scoreVsBest(Object best, Object score) {
    return 'Счёт: $score | Рекорд: $best';
  }

  @override
  String awayFromBest(Object diff) {
    return 'До рекорда: $diff';
  }

  @override
  String get round => 'Раунд';

  @override
  String stepProgress(Object current, Object total) {
    return '$current из $total';
  }

  @override
  String get leaderboard => 'Таблица лидеров';

  @override
  String get howToPlay => 'Как играть';

  @override
  String get onboardingStep1 => 'Смотри на последовательность цветов';

  @override
  String get onboardingStep2 => 'Повтори последовательность, нажимая на кнопки';

  @override
  String get onboardingStep3 =>
      'Каждый раунд добавляет один цвет. Не ошибайся!';

  @override
  String get difficulty => 'Сложность';

  @override
  String numColorsLabel(Object count) {
    return '$count цветов';
  }
}
