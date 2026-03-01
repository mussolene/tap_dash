import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_dash/services/game_stats_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameStatsService', () {
    test('create loads initial values from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'high_score': 10,
        'games_played': 3,
        'has_seen_onboarding': true,
      });
      final service = await GameStatsService.create();

      expect(service.highScore, 10);
      expect(service.gamesPlayed, 3);
      expect(service.hasSeenOnboarding, isTrue);
    });

    test('create uses defaults when prefs empty', () async {
      SharedPreferences.setMockInitialValues({});
      final service = await GameStatsService.create();

      expect(service.highScore, 0);
      expect(service.gamesPlayed, 0);
      expect(service.hasSeenOnboarding, isFalse);
    });

    test('recordGame increments gamesPlayed and returns false when not new record',
        () async {
      SharedPreferences.setMockInitialValues({
        'high_score': 15,
        'games_played': 2,
      });
      final service = await GameStatsService.create();

      final wasNewRecord = await service.recordGame(10);

      expect(wasNewRecord, isFalse);
      expect(service.gamesPlayed, 3);
      expect(service.highScore, 15);
    });

    test('recordGame updates highScore and returns true when new record',
        () async {
      SharedPreferences.setMockInitialValues({
        'high_score': 5,
        'games_played': 1,
      });
      final service = await GameStatsService.create();

      final wasNewRecord = await service.recordGame(20);

      expect(wasNewRecord, isTrue);
      expect(service.gamesPlayed, 2);
      expect(service.highScore, 20);
    });

    test('setHasSeenOnboarding persists and updates flag', () async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': false});
      final service = await GameStatsService.create();

      expect(service.hasSeenOnboarding, isFalse);
      await service.setHasSeenOnboarding();

      expect(service.hasSeenOnboarding, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_onboarding'), isTrue);
    });

    test('setHasSeenOnboarding no-op when already seen', () async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
      final service = await GameStatsService.create();

      await service.setHasSeenOnboarding();

      expect(service.hasSeenOnboarding, isTrue);
    });
  });
}
