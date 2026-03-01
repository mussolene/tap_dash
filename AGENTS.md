# Agent Guide — tap_dash

Context for AI agents working on this Flutter project.

## Project Overview

**tap_dash** is a Simon Says-style memory game. The app shows a sequence of colored buttons (red, green, blue, yellow); the player must repeat the sequence. Each round adds one more color. Wrong tap ends the game.

## Game Mechanics

- **Colors:** 4 buttons (indices 0–3), stored in `colors` list
- **Sequence:** Grows by one random color per round (`sequence.add(Random().nextInt(4))`)
- **Flow:** `startGame` → `nextRound` → `playSequence` → user taps → `onColorTap` → correct: next round / wrong: game over
- **Score:** Incremented on each successful round
- **Celebration:** Confetti + melody every 5 points

## Code Structure

| Path | Purpose |
|------|---------|
| `lib/main.dart` | App entry, `MyApp` |
| `lib/screens/game_screen.dart` | Main game screen |
| `lib/widgets/color_button.dart` | Color grid button widget |
| `lib/services/audio_service.dart` | Synthesized xylophone audio (injectable, no globals) |
| `lib/game/game_state.dart` | Pure game logic (testable) |
| `lib/l10n/` | Localizations (en, ru) |
| `test/` | Widget and unit tests |
| `pubspec.yaml` | Dependencies: flutter_sound, confetti, vibration, flutter_spinkit, intl |

## Commands

```bash
flutter pub get        # Install dependencies
flutter analyze        # Static analysis
flutter test           # Run tests
flutter run            # Run app
flutter build apk      # Android release
flutter build web      # Web release
```

## Localization

- Edit `lib/l10n/app_en.arb` and `app_ru.arb`
- Run `flutter gen-l10n` (or rely on `generate: true` in pubspec)
- Use `AppLocalizations.of(context)!.keyName` in widgets

## Pre-Commit Checklist

- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] No new `print` or debug code in production paths
- [ ] New strings added to both `app_en.arb` and `app_ru.arb` when needed
