#!/bin/bash
# Run tap_dash on iOS Simulator in debug mode.
# Requires: Xcode, CocoaPods (brew install cocoapods)
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
cd "$(dirname "$0")"
flutter run -d ios --debug
