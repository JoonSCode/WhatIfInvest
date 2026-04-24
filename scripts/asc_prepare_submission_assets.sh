#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./asc_common.sh
source "$SCRIPT_DIR/asc_common.sh"

require_asc
require_auth

: "${APP_INFO_ID:?Set APP_INFO_ID in .asc/env or the shell environment first.}"
: "${VERSION_ID:?Set VERSION_ID in .asc/env or the shell environment first.}"

has_png_screenshots() {
  local path="$1"
  [[ -d "$path" ]] && find "$path" -maxdepth 1 -type f -name '*.png' -print -quit | grep -q .
}

resolve_screenshot_dir() {
  local locale="$1"
  local base_dir="$ROOT_DIR/app-store/screenshots/generated"
  local language="${locale%%[-_]*}"
  local -a candidates=(
    "$base_dir/$locale/iphone69"
    "$base_dir/${locale//_/-}/iphone69"
    "$base_dir/${locale//-/_}/iphone69"
    "$base_dir/$language/iphone69"
  )
  local candidate

  for candidate in "${candidates[@]}"; do
    if has_png_screenshots "$candidate"; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  if [[ "$language" == "$locale" ]]; then
    for candidate in "$base_dir/$language-"*/iphone69 "$base_dir/${language}_"*/iphone69; do
      if has_png_screenshots "$candidate"; then
        printf '%s\n' "$candidate"
        return 0
      fi
    done
  fi

  return 1
}

"$SCRIPT_DIR/export_app_store_screenshots.sh"
"$SCRIPT_DIR/asc_upsert_app_info_localizations.sh"
"$SCRIPT_DIR/asc_upsert_version_localizations.sh"

version_localizations_json="$(asc version-localizations list --version-id "$VERSION_ID" --output json)"
source_locale="${ASC_SCREENSHOT_SOURCE_LOCALE:-en-US}"
source_screenshot_dir="$(resolve_screenshot_dir "$source_locale" || true)"

if [[ -z "$source_screenshot_dir" ]]; then
  echo "Missing screenshot source directory for locale: $source_locale" >&2
  exit 1
fi

shopt -s nullglob
files=("$ROOT_DIR"/app-store/localizations/version/*.strings)

for file_path in "${files[@]}"; do
  locale="$(basename "$file_path" .strings)"
  localization_id="$(json_lookup_id_by_locale "$locale" <<<"$version_localizations_json")"

  if [[ -z "$localization_id" ]]; then
    echo "Unable to find version localization ID for $locale after upsert." >&2
    exit 1
  fi

  screenshot_dir="$(resolve_screenshot_dir "$locale" || true)"
  if [[ -z "$screenshot_dir" ]]; then
    screenshot_dir="$source_screenshot_dir"
  fi

  ASC_VERSION_LOCALIZATION_ID="$localization_id" \
    ASC_SCREENSHOT_DIR="$screenshot_dir" \
    ASC_SCREENSHOT_DISPLAY_TYPE="${ASC_SCREENSHOT_DISPLAY_TYPE:-APP_IPHONE_67}" \
    "$SCRIPT_DIR/asc_upload_screenshots.sh"
done

asc versions check-readiness --version-id "$VERSION_ID" --output table
