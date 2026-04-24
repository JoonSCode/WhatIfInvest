#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./asc_common.sh
source "$SCRIPT_DIR/asc_common.sh"

require_asc
require_auth

: "${ASC_VERSION_LOCALIZATION_ID:?ASC_VERSION_LOCALIZATION_ID is required}"
: "${ASC_SCREENSHOT_DIR:?ASC_SCREENSHOT_DIR is required}"

ASC_SCREENSHOT_DISPLAY_TYPE="${ASC_SCREENSHOT_DISPLAY_TYPE:-APP_IPHONE_67}"
ASC_SCREENSHOT_SET_ID="${ASC_SCREENSHOT_SET_ID:-}"

shopt -s nullglob
files=("$ASC_SCREENSHOT_DIR"/*.png)

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No PNG screenshots found in $ASC_SCREENSHOT_DIR" >&2
  exit 1
fi

if [[ -z "$ASC_SCREENSHOT_SET_ID" ]]; then
  list_output="$(
    asc screenshot-sets list \
      --localization-id "$ASC_VERSION_LOCALIZATION_ID" \
      --output json
  )"
  ASC_SCREENSHOT_SET_ID="$(json_lookup_id_by_display_type "$ASC_SCREENSHOT_DISPLAY_TYPE" <<<"$list_output")"

  if [[ -z "$ASC_SCREENSHOT_SET_ID" ]]; then
    create_output=""
    if ! create_output="$(
      asc screenshot-sets create \
        --localization-id "$ASC_VERSION_LOCALIZATION_ID" \
        --display-type "$ASC_SCREENSHOT_DISPLAY_TYPE" \
        --output json
    )"; then
      list_output="$(
        asc screenshot-sets list \
          --localization-id "$ASC_VERSION_LOCALIZATION_ID" \
          --output json
      )"
      ASC_SCREENSHOT_SET_ID="$(json_lookup_id_by_display_type "$ASC_SCREENSHOT_DISPLAY_TYPE" <<<"$list_output")"
    else
      ASC_SCREENSHOT_SET_ID="$(json_first_id <<<"$create_output")"
    fi
  fi

  if [[ -z "$ASC_SCREENSHOT_SET_ID" ]]; then
    echo "Unable to determine screenshot set id from asc output." >&2
    exit 1
  fi
fi

for file in "${files[@]}"; do
  asc screenshots upload --set-id "$ASC_SCREENSHOT_SET_ID" --file "$file"
done
