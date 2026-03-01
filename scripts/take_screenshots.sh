#!/bin/bash
# Captures screenshots for README using iOS Simulator.
# Prereq: Boot simulator, run app once to dismiss onboarding (so game screen shows on next launch)
# Usage: ./scripts/take_screenshots.sh [device_id]
set -e
DEVICE_ID="${1:-6FB75CB1-3F2E-451C-AF9B-903485BE812D}"
DOCS="$(dirname "$0")/../docs"
mkdir -p "$DOCS"

echo "Starting app on simulator (ensure onboarding was dismissed previously)..."
flutter run -d "$DEVICE_ID" &
FLUTTER_PID=$!

echo "Waiting 25s for app to load and show game screen..."
sleep 25

echo "Capturing docs/game_screen.png..."
xcrun simctl io booted screenshot "$DOCS/game_screen.png"

echo "For settings_screen.png: tap the gear icon, wait 2s, then run:"
echo "  xcrun simctl io booted screenshot $DOCS/settings_screen.png"

kill $FLUTTER_PID 2>/dev/null || true
wait $FLUTTER_PID 2>/dev/null || true
echo "Done. Check $DOCS/game_screen.png"
