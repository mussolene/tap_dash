#!/usr/bin/env bash
# Updates pubspec.yaml version from the given tag or the latest git tag.
# Usage: ./scripts/set_version_from_tag.sh [v1.2.0]
# If no argument: uses latest tag (git describe --tags --abbrev=0).

set -e
cd "$(dirname "$0")/.."

TAG="${1:-$(git describe --tags --abbrev=0 2>/dev/null || echo 'v0.0.0')}"
VERSION="${TAG#v}"
# Build number: 1.2.0 -> 10200 for Android versionCode
IFS=. read -r ma mi pa <<< "$VERSION"
BUILD_NUMBER=$((ma*10000 + mi*100 + ${pa:-0}))

echo "Setting version to $VERSION+$BUILD_NUMBER (from tag $TAG)"

if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' "s/^version: .*/version: $VERSION+$BUILD_NUMBER/" pubspec.yaml
else
  sed -i "s/^version: .*/version: $VERSION+$BUILD_NUMBER/" pubspec.yaml
fi
