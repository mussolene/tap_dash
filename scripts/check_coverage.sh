#!/usr/bin/env bash
# Check that lib/ coverage is at least 90%.
# Run from project root after: flutter test --coverage
set -e

MIN_COVERAGE=90
LCOV_FILE=coverage/lcov.info

if [ ! -f "$LCOV_FILE" ]; then
  echo "Error: $LCOV_FILE not found. Run 'flutter test --coverage' first."
  exit 1
fi

# Exclude platform-specific and generated files (per docs/TEST_COVERAGE_AUDIT.md):
# - l10n: generated from ARB (app_localizations*.dart)
# - audio_service: FlutterSound platform API
# - games_services_controller: Game Center / Play Games platform API

# Try lcov first (available in CI)
if command -v lcov >/dev/null 2>&1; then
  lcov --extract "$LCOV_FILE" 'lib/*' -o coverage/lib_extract.info --ignore-errors unused 2>/dev/null || true
  if [ -f coverage/lib_extract.info ]; then
    lcov --remove coverage/lib_extract.info \
      '*l10n/*' '*audio_service.dart*' '*games_services_controller*' \
      -o coverage/lib.info --ignore-errors unused 2>/dev/null || true
    rm -f coverage/lib_extract.info
    if [ -f coverage/lib.info ]; then
      SUMMARY=$(lcov --summary coverage/lib.info 2>&1 | grep "lines" || true)
      if [ -n "$SUMMARY" ]; then
        COVERAGE=$(echo "$SUMMARY" | sed -n 's/.*: \([0-9]*\.\?[0-9]*\)%.*/\1/p')
      fi
    fi
  fi
fi

# Fallback: parse lcov.info with awk (no lcov installed)
skip_file=0
if [ -z "$COVERAGE" ]; then
  RESULT=$(awk '
    /^SF:/ {
      if (prev_sf != "" && index(prev_sf, "lib/") == 1 && lf != "" && lh != "" && !skip) {
        total_lf += lf + 0
        total_lh += lh + 0
      }
      prev_sf = substr($0, 4)
      skip = (index(prev_sf, "l10n/") > 0 || index(prev_sf, "audio_service.dart") > 0 || index(prev_sf, "games_services_controller") > 0)
      lf = lh = ""
      next
    }
    /^LF:/ { split($0, a, ":"); lf = a[2]; next }
    /^LH:/ { split($0, a, ":"); lh = a[2]; next }
    END {
      if (prev_sf != "" && index(prev_sf, "lib/") == 1 && lf != "" && lh != "" && !skip) {
        total_lf += lf + 0
        total_lh += lh + 0
      }
      if (total_lf > 0) {
        pct = (total_lh / total_lf) * 100
        printf "%.1f", pct
      }
    }
  ' "$LCOV_FILE")
  COVERAGE="$RESULT"
fi

if [ -z "$COVERAGE" ]; then
  echo "Error: Could not compute coverage."
  exit 1
fi

PASS=$(echo "$COVERAGE $MIN_COVERAGE" | awk '{if ($1 >= $2) print 1; else print 0}')
echo "lib/ coverage: ${COVERAGE}% (minimum: ${MIN_COVERAGE}%)"

if [ "$PASS" -eq 0 ]; then
  echo "FAIL: Coverage ${COVERAGE}% is below ${MIN_COVERAGE}%"
  exit 1
fi

echo "PASS: Coverage meets ${MIN_COVERAGE}% minimum"
