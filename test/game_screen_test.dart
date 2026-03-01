import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_dash/l10n/app_localizations.dart';
import 'package:tap_dash/screens/game_screen.dart';
import 'package:tap_dash/screens/settings_screen.dart';
import 'package:tap_dash/services/game_stats_service.dart';
import 'package:tap_dash/services/settings_service.dart';
import 'package:tap_dash/widgets/color_button.dart';
import 'mock_audio_service.dart';

void main() {
  late SettingsService settingsService;
  late GameStatsService gameStatsService;

  Future<void> pumpGameScreen(
    WidgetTester tester, {
    MockAudioService? audioService,
    DeterministicRandomProvider? randomProvider,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: GameScreen(
          settingsService: settingsService,
          gameStatsService: gameStatsService,
          audioService: audioService ?? MockAudioService(),
          randomProvider: randomProvider,
        ),
      ),
    );
  }

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    settingsService = await SettingsService.create();
    gameStatsService = await GameStatsService.create();
  });

  Future<void> playUntilWrong(WidgetTester tester, int wrongColorIndex) async {
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    await tester.tap(find.byType(ColorButton).at(wrongColorIndex));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
  }

  testWidgets('GameScreen displays Start button and four color buttons',
      (WidgetTester tester) async {
    await pumpGameScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Start'), findsOneWidget);
    expect(find.byType(ColorButton), findsNWidgets(4));
  });

  testWidgets('GameScreen settings icon opens SettingsScreen',
      (WidgetTester tester) async {
    await pumpGameScreen(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('GameScreen correct tap advances round',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpGameScreen(tester, randomProvider: DeterministicRandomProvider([0]));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    await tester.tap(find.byType(ColorButton).first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('1'), findsWidgets);
  });

  testWidgets('GameScreen Start then wrong tap shows game over',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpGameScreen(tester, randomProvider: DeterministicRandomProvider([0]));
    await tester.pumpAndSettle();

    await playUntilWrong(tester, 1);

    expect(find.text('Game Over'), findsOneWidget);
  });

  testWidgets('GameScreen game over with high score shows score vs best',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'high_score': 10, 'games_played': 1});
    gameStatsService = await GameStatsService.create();
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpGameScreen(tester, randomProvider: DeterministicRandomProvider([0]));
    await tester.pumpAndSettle();

    await playUntilWrong(tester, 1);

    expect(find.text('Game Over'), findsOneWidget);
    expect(find.textContaining('Best'), findsWidgets);
  });

  testWidgets('GameScreen game over Close dismisses dialog',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpGameScreen(tester, randomProvider: DeterministicRandomProvider([0]));
    await tester.pumpAndSettle();

    await playUntilWrong(tester, 1);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Game Over'), findsNothing);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('GameScreen game over Play again restarts game',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpGameScreen(tester, randomProvider: DeterministicRandomProvider([0]));
    await tester.pumpAndSettle();

    await playUntilWrong(tester, 1);

    await tester.tap(find.text('Play again'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Game Over'), findsNothing);
  });
}
