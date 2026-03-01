import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_dash/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService', () {
    test('create loads initial values from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'sound_enabled': true,
        'haptics_enabled': false,
        'theme_mode': 1,
      });
      final service = await SettingsService.create();

      expect(service.current.soundEnabled, isTrue);
      expect(service.current.hapticsEnabled, isFalse);
      expect(service.current.themeMode, ThemeMode.light);
    });

    test('create uses defaults when prefs empty', () async {
      SharedPreferences.setMockInitialValues({});
      final service = await SettingsService.create();

      expect(service.current.soundEnabled, isTrue);
      expect(service.current.hapticsEnabled, isTrue);
      expect(service.current.themeMode, ThemeMode.system);
    });

    test('setSoundEnabled updates value and notifies', () async {
      SharedPreferences.setMockInitialValues({'sound_enabled': true});
      final service = await SettingsService.create();
      AppSettings? lastSettings;
      service.settings.addListener(() {
        lastSettings = service.settings.value;
      });

      await service.setSoundEnabled(false);

      expect(service.current.soundEnabled, isFalse);
      expect(lastSettings?.soundEnabled, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('sound_enabled'), isFalse);
    });

    test('setHapticsEnabled updates value and notifies', () async {
      SharedPreferences.setMockInitialValues({'haptics_enabled': true});
      final service = await SettingsService.create();

      await service.setHapticsEnabled(false);

      expect(service.current.hapticsEnabled, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('haptics_enabled'), isFalse);
    });

    test('setThemeMode updates value for all modes', () async {
      SharedPreferences.setMockInitialValues({});
      final service = await SettingsService.create();

      await service.setThemeMode(ThemeMode.light);
      expect(service.current.themeMode, ThemeMode.light);

      await service.setThemeMode(ThemeMode.dark);
      expect(service.current.themeMode, ThemeMode.dark);

      await service.setThemeMode(ThemeMode.system);
      expect(service.current.themeMode, ThemeMode.system);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_mode'), 0);
    });
  });
}
