# tap_dash

**Color Sequence Game** — a Simon Says-style memory game built with Flutter. Watch the sequence of colored buttons, then repeat it. Each round adds one more color to remember.

## Features

- 4-color grid (red, green, blue, yellow) with sound and haptic feedback
- Synthesized xylophone-style notes for each color
- Confetti celebration every 5 points
- Light/dark theme (system-based)
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
# iOS Simulator (open Simulator first: open -a Simulator)
./run_ios.sh
# or: DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer flutter run -d ios --debug

# Run on connected device or emulator
flutter run

# Build for release
flutter build apk      # Android
flutter build ios      # iOS
flutter build web      # Web
```

### Test

```bash
flutter analyze
flutter test
```

## Project Structure

```
lib/
├── main.dart           # App entry point
├── screens/            # Screens
│   └── game_screen.dart
├── widgets/            # Reusable widgets
│   └── color_button.dart
├── services/           # Platform services
│   └── audio_service.dart
├── game/               # Game logic
│   └── game_state.dart
└── l10n/               # Localizations (en, ru)
```

## License

See [LICENSE](LICENSE) for details.
