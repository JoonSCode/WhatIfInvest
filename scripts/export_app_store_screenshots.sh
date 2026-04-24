#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ROOT_DIR"

"$ROOT_DIR/scripts/capture_app_store_raw_screenshots.sh"

for locale in ${WHATIFINVEST_SCREENSHOT_LOCALES:-en-US ko-KR}; do
  WHATIFINVEST_SCREENSHOT_RAW_LOCALE="$locale" \
    WHATIFINVEST_SCREENSHOT_GENERATED_LOCALE="$locale" \
    WHATIFINVEST_MARKETING_LOCALE="$locale" \
    "$ROOT_DIR/scripts/export_external_skill_app_store_screenshots.sh"
done
