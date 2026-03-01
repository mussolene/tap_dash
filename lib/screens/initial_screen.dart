import 'package:flutter/material.dart';
import 'package:tap_dash/screens/game_screen.dart';
import 'package:tap_dash/screens/onboarding_screen.dart';
import 'package:tap_dash/services/audio_service_interface.dart';
import 'package:tap_dash/services/game_stats_service.dart';
import 'package:tap_dash/services/settings_service.dart';

/// Decides whether to show onboarding or the game based on first-launch flag.
class InitialScreen extends StatefulWidget {
  const InitialScreen({
    required this.settingsService,
    required this.gameStatsService,
    this.audioService,
    super.key,
  });

  final SettingsService settingsService;
  final GameStatsService gameStatsService;

  /// Optional; passed to [GameScreen] for testing.
  final AudioServiceInterface? audioService;

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.gameStatsService.hasSeenOnboarding) {
      return GameScreen(
        settingsService: widget.settingsService,
        gameStatsService: widget.gameStatsService,
        audioService: widget.audioService,
      );
    }
    return OnboardingScreen(
      settingsService: widget.settingsService,
      gameStatsService: widget.gameStatsService,
      onComplete: () => setState(() {}),
    );
  }
}
