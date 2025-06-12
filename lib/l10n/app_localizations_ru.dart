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
}
