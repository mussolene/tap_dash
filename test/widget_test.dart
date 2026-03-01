import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_dash/main.dart';
import 'package:tap_dash/services/game_stats_service.dart';
import 'package:tap_dash/services/settings_service.dart';
import 'package:tap_dash/widgets/color_button.dart';
import 'package:tap_dash/widgets/settings_tile.dart';

import 'mock_audio_service.dart';

void main() {
  late SettingsService settingsService;
  late GameStatsService gameStatsService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
    settingsService = await SettingsService.create();
    gameStatsService = await GameStatsService.create();
  });

  testWidgets('Color Sequence Game displays initial UI', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(
        settingsService: settingsService,
        gameStatsService: gameStatsService,
        locale: const Locale('en'),
        audioService: MockAudioService(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0'), findsWidgets); // Score in header
    expect(find.text('Start'), findsOneWidget); // Start button in header
  });

  testWidgets('MyApp theme updates when settings change', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(
        settingsService: settingsService,
        gameStatsService: gameStatsService,
        locale: const Locale('en'),
        audioService: MockAudioService(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SettingsTileSelector<ThemeMode>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();

    expect(settingsService.current.themeMode, ThemeMode.dark);
  });

  testWidgets('Game has four color buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(
        settingsService: settingsService,
        gameStatsService: gameStatsService,
        locale: const Locale('en'),
        audioService: MockAudioService(),
      ),
    );
    await tester.pumpAndSettle();

    final colorButtons = find.byType(ColorButton);
    expect(colorButtons, findsNWidgets(4));
  });
}
