import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keySound = 'sound_enabled';
const _keyHaptics = 'haptics_enabled';
const _keyTheme = 'theme_mode';
const _keyNumColors = 'num_colors';

/// Supported color counts for difficulty (4, 6, 8).
const List<int> numColorsOptions = [4, 6, 8];

/// Application settings, persisted via shared_preferences.
class AppSettings {
  final bool soundEnabled;
  final bool hapticsEnabled;
  final ThemeMode themeMode;
  final int numColors;

  const AppSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.themeMode = ThemeMode.system,
    this.numColors = 4,
  });

  AppSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    ThemeMode? themeMode,
    int? numColors,
  }) =>
      AppSettings(
        soundEnabled: soundEnabled ?? this.soundEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        themeMode: themeMode ?? this.themeMode,
        numColors: numColors ?? this.numColors,
      );
}

/// Service for loading and persisting app settings.
class SettingsService {
  SettingsService._(SharedPreferences prefs)
      : _prefs = prefs,
        settings = ValueNotifier<AppSettings>(AppSettings(
          soundEnabled: prefs.getBool(_keySound) ?? true,
          hapticsEnabled: prefs.getBool(_keyHaptics) ?? true,
          themeMode: _themeModeFromInt(prefs.getInt(_keyTheme) ?? 0),
          numColors: _clampNumColors(prefs.getInt(_keyNumColors) ?? 4),
        ));

  final SharedPreferences _prefs;
  final ValueNotifier<AppSettings> settings;

  static ThemeMode _themeModeFromInt(int v) {
    return switch (v) {
      1 => ThemeMode.light,
      2 => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static int _clampNumColors(int v) {
    return numColorsOptions.contains(v) ? v : 4;
  }

  static int _themeModeToInt(ThemeMode m) {
    return switch (m) {
      ThemeMode.light => 1,
      ThemeMode.dark => 2,
      ThemeMode.system => 0,
    };
  }

  static Future<SettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService._(prefs);
  }

  AppSettings get current => settings.value;

  Future<void> setSoundEnabled(bool v) async {
    await _prefs.setBool(_keySound, v);
    settings.value = settings.value.copyWith(soundEnabled: v);
  }

  Future<void> setHapticsEnabled(bool v) async {
    await _prefs.setBool(_keyHaptics, v);
    settings.value = settings.value.copyWith(hapticsEnabled: v);
  }

  Future<void> setThemeMode(ThemeMode m) async {
    await _prefs.setInt(_keyTheme, _themeModeToInt(m));
    settings.value = settings.value.copyWith(themeMode: m);
  }

  Future<void> setNumColors(int n) async {
    final v = _clampNumColors(n);
    await _prefs.setInt(_keyNumColors, v);
    settings.value = settings.value.copyWith(numColors: v);
  }
}
