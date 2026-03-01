import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_dash/l10n/app_localizations.dart';
import 'package:tap_dash/screens/onboarding_screen.dart';
import 'package:tap_dash/services/game_stats_service.dart';
import 'package:tap_dash/services/settings_service.dart';
import 'package:tap_dash/widgets/color_button.dart';

void main() {
  late SettingsService settingsService;

  Future<void> pumpOnboarding(WidgetTester tester, GameStatsService stats,
      {VoidCallback? onComplete}) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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
        home: OnboardingScreen(
          settingsService: settingsService,
          gameStatsService: stats,
          onComplete: onComplete ?? () {},
        ),
      ),
    );
  }

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    settingsService = await SettingsService.create();
  });

  testWidgets('OnboardingScreen displays How to play and steps', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'has_seen_onboarding': false});
    final gameStatsService = await GameStatsService.create();

    await pumpOnboarding(tester, gameStatsService);
    await tester.pump();

    expect(find.text('How to play'), findsOneWidget);
    expect(find.byType(ColorButton), findsNWidgets(4));
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('OnboardingScreen Start tap calls setHasSeenOnboarding and onComplete',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'has_seen_onboarding': false});
    final gameStatsService = await GameStatsService.create();
    var onCompleteCalled = false;

    await pumpOnboarding(
      tester,
      gameStatsService,
      onComplete: () => onCompleteCalled = true,
    );
    await tester.pump();

    await tester.tap(find.text('Start'));
    await tester.pump();

    expect(onCompleteCalled, isTrue);
    expect(gameStatsService.hasSeenOnboarding, isTrue);
  });
}
