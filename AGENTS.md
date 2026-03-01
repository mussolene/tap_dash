# Agent Guide — tap_dash

Context for AI agents working on this Flutter project.

## Project Overview

**tap_dash** is a Simon Says-style memory game. The app shows a sequence of colored buttons (red, green, blue, yellow); the player must repeat the sequence. Each round adds one more color. Wrong tap ends the game.

## Game Mechanics

- **Colors:** 4 buttons (indices 0–3), stored in `colors` list
- **Sequence:** Grows by one random color per round (`sequence.add(Random().nextInt(4))`)
- **Flow:** `main` → `InitialScreen` → (`OnboardingScreen` | `GameScreen`); in game: `startGame` → `nextRound` → `playSequence` → user taps → `onColorTap` → correct: next round / wrong: game over
- **Score:** Incremented on each successful round
- **Celebration:** Milestone badge + melody every 5 points
- **Progression:** High score persisted; speed increases every 5 rounds

## Code Structure

| Path | Purpose |
|------|---------|
| `lib/main.dart` | App entry, `MyApp` |
| `lib/screens/initial_screen.dart` | Routes to onboarding or game based on first launch |
| `lib/screens/onboarding_screen.dart` | "How to play" welcome screen (first launch only) |
| `lib/screens/game_screen.dart` | Main game screen |
| `lib/screens/settings_screen.dart` | Settings screen (sound, haptics, theme) |
| `lib/widgets/color_button.dart` | Color grid button widget |
| `lib/widgets/settings_tile.dart` | Settings row widget |
| `lib/services/audio_service.dart` | Synthesized xylophone audio (implements [AudioServiceInterface]) |
| `lib/services/audio_service_interface.dart` | Abstract interface for audio; inject mock in tests |
| `lib/game/random_provider.dart` | Abstraction for random; inject for deterministic tests |
| `lib/services/game_stats_service.dart` | High score, games played, onboarding flag |
| `lib/services/games_services_controller.dart` | Game Center (iOS) / Play Games (Android) integration |
| `lib/services/settings_service.dart` | Sound, haptics, theme settings |
| `lib/game/game_state.dart` | Pure game logic (testable) |
| `lib/l10n/` | Localizations (en, ru) |
| `test/` | Widget and unit tests |
| `pubspec.yaml` | Dependencies: flutter_sound, vibration, flutter_spinkit, intl, games_services, shared_preferences |

## Commands

```bash
flutter pub get        # Install dependencies
flutter analyze        # Static analysis
flutter test           # Run tests
flutter test --coverage  # Run tests with coverage; lib/ must be ≥90%
flutter run            # Run app
flutter build apk      # Android release
flutter build web      # Web release
```

## Localization

- Edit `lib/l10n/app_en.arb` and `app_ru.arb`
- Config: `l10n.yaml` (synthesis options)
- Run `flutter gen-l10n` (or rely on `generate: true` in pubspec)
- Use `AppLocalizations.of(context)!.keyName` in widgets

## Game Center / Play Games

Leaderboards are integrated via `games_services`. To enable:

**iOS:** Create a leaderboard in [App Store Connect](https://appstoreconnect.apple.com/) → Game Center, note its ID, and set `_iosLeaderboardId` in `games_services_controller.dart`.

**Android:** Configure [Play Games Services](https://play.google.com/console/) in Google Play Console, get the `games-ids.xml` from Configuration → Credentials → Get resources, and replace `android/app/src/main/res/values/games-ids.xml`.

**iOS:** Add Game Center capability and `ios/Runner/Runner.entitlements` for leaderboard access.

See: https://docs.flutter.dev/cookbook/games/achievements-leaderboard

## Architecture

- **DI:** `main()` creates `SettingsService` and `GameStatsService`, passes into `MyApp` → `InitialScreen`. `InitialScreen` chooses between `OnboardingScreen` (first launch) and `GameScreen` (subsequent launches). No globals except `GamesServicesController.instance`.
- **GameState:** Pure logic in `lib/game/game_state.dart`; `GameScreen` owns the instance and updates UI based on `processTap` results.
- **Flow:** `startGame` → `nextRound` → `playSequence` → user taps → `onColorTap` → correct: next round / wrong: game over

## Documentation Map

- **User:** [README](README.md) — install, run, build, troubleshooting
- **Contributor:** [CONTRIBUTING](CONTRIBUTING.md) — commits, process
- **Agent:** This file (AGENTS.md) — structure, conventions
- **Rules:** `.cursor/rules/` — Flutter, tests, docs-first

Before major changes: re-read AGENTS.md and relevant rules.

## Pre-Commit Checklist

- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] Coverage ≥90% for `lib/` (`flutter test --coverage`)
- [ ] No new `print` or debug code in production paths
- [ ] New strings added to both `app_en.arb` and `app_ru.arb` when needed
