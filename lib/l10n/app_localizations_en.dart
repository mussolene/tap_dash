// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Color Sequence Game';

  @override
  String get score => 'Score';

  @override
  String get start => 'Start';

  @override
  String get gameOver => 'Game Over';

  @override
  String yourScore(Object score) {
    return 'Your score: $score';
  }

  @override
  String get restart => 'Restart';

  @override
  String get close => 'Close';

  @override
  String get congrats => 'Congrats!';

  @override
  String congratsScore(Object score) {
    return 'You reached a score of $score!';
  }
}
