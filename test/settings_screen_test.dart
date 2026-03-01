import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_dash/l10n/app_localizations.dart';
import 'package:tap_dash/screens/settings_screen.dart';
import 'package:tap_dash/services/settings_service.dart';
import 'package:tap_dash/widgets/settings_tile.dart';

void main() {
  late SettingsService settingsService;

  Future<void> pumpSettings(WidgetTester tester, {VoidCallback? onShowLeaderboard}) async {
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
        home: SettingsScreen(
          settingsService: settingsService,
          onShowLeaderboard: onShowLeaderboard,
        ),
      ),
    );
  }

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    settingsService = await SettingsService.create();
  });

  testWidgets('SettingsScreen displays Settings title and tiles', (WidgetTester tester) async {
    await pumpSettings(tester);
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byType(SettingsTile), findsNWidgets(2));
    expect(find.byType(SettingsTileSelector<ThemeMode>), findsOneWidget);
  });

  testWidgets('SettingsScreen haptics Switch toggles', (WidgetTester tester) async {
    await pumpSettings(tester);
    await tester.pumpAndSettle();

    expect(settingsService.current.hapticsEnabled, isTrue);
    final switches = find.byType(Switch);
    await tester.tap(switches.last);
    await tester.pumpAndSettle();

    expect(settingsService.current.hapticsEnabled, isFalse);
  });

  testWidgets('SettingsScreen Switch toggles sound', (WidgetTester tester) async {
    await pumpSettings(tester);
    await tester.pumpAndSettle();

    expect(settingsService.current.soundEnabled, isTrue);
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(settingsService.current.soundEnabled, isFalse);
  });

  testWidgets('SettingsScreen SettingsTileSelector opens theme picker', (WidgetTester tester) async {
    await pumpSettings(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SettingsTileSelector<ThemeMode>));
    await tester.pumpAndSettle();

    expect(find.text('Theme'), findsWidgets);
    expect(find.text('System'), findsWidgets);
    expect(find.text('Light'), findsWidgets);
    expect(find.text('Dark'), findsWidgets);
  });

  testWidgets('SettingsScreen theme picker selects Dark and updates', (WidgetTester tester) async {
    await pumpSettings(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SettingsTileSelector<ThemeMode>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();

    expect(settingsService.current.themeMode, ThemeMode.dark);
  });

  testWidgets('SettingsScreen shows leaderboard when onShowLeaderboard provided',
      (WidgetTester tester) async {
    await pumpSettings(tester, onShowLeaderboard: () {});
    await tester.pumpAndSettle();

    expect(find.text('Leaderboard'), findsOneWidget);
  });
}
