import 'package:flutter/material.dart';
import 'package:tap_dash/l10n/app_localizations.dart';
import 'package:tap_dash/services/settings_service.dart'
    show AppSettings, SettingsService, numColorsOptions, speedOptions;
import 'package:tap_dash/widgets/settings_tile.dart';

/// Settings screen: sound, haptics, theme, and optional leaderboard link.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.settingsService,
    this.onShowLeaderboard,
    super.key,
  });

  final SettingsService settingsService;
  final VoidCallback? onShowLeaderboard;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
      ),
      body: ValueListenableBuilder<AppSettings>(
        valueListenable: settingsService.settings,
        builder: (context, appSettings, _) {
          return ListView(
            children: [
              if (onShowLeaderboard != null)
                ListTile(
                  leading: const Icon(Icons.leaderboard),
                  title: Text(loc.leaderboard),
                  onTap: onShowLeaderboard,
                ),
              SettingsTile(
                title: loc.sound,
                value: appSettings.soundEnabled,
                onChanged: settingsService.setSoundEnabled,
                icon: Icons.volume_up,
              ),
              SettingsTile(
                title: loc.haptics,
                value: appSettings.hapticsEnabled,
                onChanged: settingsService.setHapticsEnabled,
                icon: Icons.vibration,
              ),
              SettingsTileSelector<ThemeMode>(
                title: loc.theme,
                value: appSettings.themeMode,
                options: const [
                  ThemeMode.system,
                  ThemeMode.light,
                  ThemeMode.dark,
                ],
                labelBuilder: (m) => switch (m) {
                  ThemeMode.system => loc.themeSystem,
                  ThemeMode.light => loc.themeLight,
                  ThemeMode.dark => loc.themeDark,
                },
                onChanged: settingsService.setThemeMode,
                icon: Icons.palette,
              ),
              SettingsTileSelector<int>(
                title: loc.difficulty,
                value: appSettings.numColors,
                options: numColorsOptions,
                labelBuilder: (n) => loc.numColorsLabel('$n'),
                onChanged: settingsService.setNumColors,
                icon: Icons.grid_view,
              ),
              SettingsTileSelector<double>(
                title: loc.speed,
                value: appSettings.speedMultiplier,
                options: speedOptions,
                labelBuilder: (s) => s == 1.0
                    ? loc.speedNormal
                    : s == 1.25
                        ? loc.speedFast
                        : s == 1.5
                            ? loc.speedFaster
                            : loc.speedFastest,
                onChanged: settingsService.setSpeedMultiplier,
                icon: Icons.speed,
              ),
            ],
          );
        },
      ),
    );
  }
}
