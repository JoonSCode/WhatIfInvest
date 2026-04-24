#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./asc_common.sh
source "$SCRIPT_DIR/asc_common.sh"

require_asc
require_auth

: "${APP_INFO_ID:?Set APP_INFO_ID in .asc/env or the shell environment first.}"

localization_dir="$ROOT_DIR/app-store/localizations/app-info"
shopt -s nullglob
files=("$localization_dir"/*.strings)

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No app info localization files found in $localization_dir" >&2
  exit 1
fi

list_json="$(asc app-info-localizations list --app-info-id "$APP_INFO_ID" --output json)"

for file_path in "${files[@]}"; do
  locale="$(basename "$file_path" .strings)"
  name="$(strings_value "$file_path" name)"
  subtitle="$(strings_value "$file_path" subtitle)"
  privacy_policy_url="$(strings_value "$file_path" privacyPolicyUrl)"
  privacy_policy_url="$(normalized_metadata_value "$privacy_policy_url" || true)"

  if [[ -z "$name" ]]; then
    echo "Skipping $locale: missing required key 'name'." >&2
    continue
  fi

  localization_id="$(json_lookup_id_by_locale "$locale" <<<"$list_json")"

  if [[ -z "$localization_id" ]]; then
    create_json=""
    if ! create_json="$(
      asc app-info-localizations create \
        --app-info-id "$APP_INFO_ID" \
        --locale "$locale" \
        --name "$name" \
        --output json
    )"; then
      list_json="$(asc app-info-localizations list --app-info-id "$APP_INFO_ID" --output json)"
      localization_id="$(json_lookup_id_by_locale "$locale" <<<"$list_json")"
    else
      localization_id="$(json_first_id <<<"$create_json")"
    fi

    if [[ -z "$localization_id" ]]; then
      list_json="$(asc app-info-localizations list --app-info-id "$APP_INFO_ID" --output json)"
      localization_id="$(json_lookup_id_by_locale "$locale" <<<"$list_json")"
    fi

    list_json="$(asc app-info-localizations list --app-info-id "$APP_INFO_ID" --output json)"
  fi

  update_args=(asc app-info-localizations update --localization-id "$localization_id" --name "$name")

  if [[ -n "$subtitle" ]]; then
    update_args+=(--subtitle "$subtitle")
  fi

  if [[ -n "${privacy_policy_url:-}" ]]; then
    update_args+=(--privacy-policy-url "$privacy_policy_url")
  fi

  update_output=""
  if ! update_output="$("${update_args[@]}" 2>&1 >/dev/null)"; then
    if [[ "$update_output" == *"ENTITY_ERROR.ATTRIBUTE.INVALID.INVALID_STATE"* ]]; then
      echo "warning: app info localization is locked in the current App Store Connect state for $locale ($localization_id); skipping name/subtitle update" >&2
      continue
    fi

    echo "$update_output" >&2
    exit 1
  fi

  echo "Upserted app info localization: $locale ($localization_id)"
done
