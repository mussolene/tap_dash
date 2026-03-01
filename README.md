# tap_dash

**Color Sequence Game** — a Simon Says-style memory game built with Flutter. Watch the sequence of colored buttons, then repeat it. Each round adds one more color to remember.

## Features

- 4-color grid (red, green, blue, yellow) with sound and haptic feedback
- Synthesized xylophone-style notes for each color
- Confetti celebration every 5 points
- Light/dark theme (system-based) and Settings screen (sound, haptics, theme)
- Onboarding "How to play" on first launch
- Localization: English and Russian
- Runs on iOS, Android, Web, macOS, Linux, Windows

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.6.0+)
- Dart SDK ^3.6.0

### Installation

```bash
git clone <repository-url>
cd tap_dash
flutter pub get
```

### Run

```bash
# iOS Simulator (requires Xcode, CocoaPods: brew install cocoapods)
./run_ios.sh
# or: DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer flutter run -d ios --debug

# Run on connected device or emulator
flutter run

# Build for release
flutter build apk      # Android
flutter build ios      # iOS
flutter build web      # Web
```

`run_ios.sh` sets `DEVELOPER_DIR` for Xcode and runs the app on the iOS Simulator in debug mode. Use it when the default `flutter run -d ios` fails due to Xcode path issues.

### Test

```bash
flutter analyze
flutter test
flutter test --coverage   # Generate coverage report; required ≥90% for lib/
```

**Test coverage:** Coverage for `lib/` must be at least 90%. Run `flutter test --coverage` before submitting changes.

## Project Structure

```
lib/
├── main.dart              # App entry, DI bootstrap
├── screens/
│   ├── initial_screen.dart    # Routes to onboarding or game (first launch)
│   ├── onboarding_screen.dart # "How to play" welcome (first launch only)
│   ├── game_screen.dart       # Main game screen
│   └── settings_screen.dart   # Sound, haptics, theme settings
├── widgets/
│   ├── color_button.dart      # Color grid button
│   └── settings_tile.dart     # Settings row widget
├── services/
│   ├── audio_service.dart           # Synthesized xylophone audio
│   ├── game_stats_service.dart      # High score, games played, onboarding flag
│   ├── games_services_controller.dart # Game Center / Play Games (leaderboard)
│   └── settings_service.dart        # Sound, haptics, theme
├── game/
│   └── game_state.dart       # Pure game logic (testable)
└── l10n/                    # Localizations (en, ru)
```

## Build for Store

**Android:**
- Release APK: `flutter build apk`
- App Bundle (Play Store): `flutter build appbundle`

**iOS:**
- Archive via Xcode: Open `ios/Runner.xcworkspace`, Product → Archive
- Or: `flutter build ios` then archive in Xcode

**Web:**
- `flutter build web` — output in `build/web/`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `flutter pub get` fails | Ensure Flutter SDK is on PATH; run `flutter doctor` |
| iOS build / CocoaPods errors | `cd ios && pod install && cd ..`; ensure Xcode CLI: `sudo xcode-select -s /Applications/Xcode.app` |
| `flutter analyze` warnings | Fix lints in `analysis_options.yaml`; run `dart format .` |
| Tests fail | Run `flutter test --coverage`; ensure coverage ≥90% for new code |

## License

See [LICENSE](LICENSE) for details.
