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

  @override
  String milestoneLevel(Object level) {
    return 'Level $level';
  }

  @override
  String roundLength(Object count) {
    return '$count colors';
  }

  @override
  String get settings => 'Settings';

  @override
  String get sound => 'Sound';

  @override
  String get haptics => 'Haptics';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String bestScore(Object score) {
    return 'Best: $score';
  }

  @override
  String get playAgain => 'Play again';

  @override
  String newRecord(Object score) {
    return 'New record: $score!';
  }

  @override
  String get greatRun => 'Great run!';

  @override
  String get almostThere => 'Almost there!';

  @override
  String get soClose => 'So close!';

  @override
  String scoreVsBest(Object best, Object score) {
    return 'Your score: $score | Best: $best';
  }

  @override
  String awayFromBest(Object diff) {
    return '$diff away from your best!';
  }

  @override
  String get round => 'Round';

  @override
  String stepProgress(Object current, Object total) {
    return '$current / $total';
  }

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get howToPlay => 'How to play';

  @override
  String get onboardingStep1 => 'Watch the sequence of colors';

  @override
  String get onboardingStep2 => 'Repeat the sequence by tapping the buttons';

  @override
  String get onboardingStep3 =>
      'Each round adds one more color. Don\'t make a mistake!';
}
