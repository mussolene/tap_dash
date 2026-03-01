import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_dash/l10n/app_localizations.dart';
import 'package:tap_dash/screens/game_screen.dart';
import 'package:tap_dash/screens/initial_screen.dart';
import 'package:tap_dash/screens/onboarding_screen.dart';
import 'package:tap_dash/services/game_stats_service.dart';
import 'package:tap_dash/services/settings_service.dart';
import 'mock_audio_service.dart';

void main() {
  late SettingsService settingsService;

  Future<void> pumpInitialScreen(WidgetTester tester, GameStatsService stats) async {
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
        home: InitialScreen(
          settingsService: settingsService,
          gameStatsService: stats,
          audioService: MockAudioService(),
        ),
      ),
    );
  }

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    settingsService = await SettingsService.create();
  });

  testWidgets('InitialScreen shows GameScreen when hasSeenOnboarding is true',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
    final gameStatsService = await GameStatsService.create();

    await pumpInitialScreen(tester, gameStatsService);
    await tester.pumpAndSettle();

    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });

  testWidgets('InitialScreen shows OnboardingScreen when hasSeenOnboarding is false',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'has_seen_onboarding': false});
    final gameStatsService = await GameStatsService.create();

    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpInitialScreen(tester, gameStatsService);
    await tester.pump();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(GameScreen), findsNothing);
  });
}
