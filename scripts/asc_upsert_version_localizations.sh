#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./asc_common.sh
source "$SCRIPT_DIR/asc_common.sh"

require_asc
require_auth

: "${VERSION_ID:?Set VERSION_ID in .asc/env or the shell environment first.}"

localization_dir="$ROOT_DIR/app-store/localizations/version"
shopt -s nullglob
files=("$localization_dir"/*.strings)

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No version localization files found in $localization_dir" >&2
  exit 1
fi

list_json="$(asc version-localizations list --version-id "$VERSION_ID" --output json)"

for file_path in "${files[@]}"; do
  locale="$(basename "$file_path" .strings)"
  description="$(strings_value "$file_path" description)"
  keywords="$(strings_value "$file_path" keywords)"
  whats_new="$(strings_value "$file_path" whatsNew)"
  support_url="$(strings_value "$file_path" supportUrl)"
  marketing_url="$(strings_value "$file_path" marketingUrl)"
  promotional_text="$(strings_value "$file_path" promotionalText)"
  support_url="$(normalized_metadata_value "$support_url" || true)"
  marketing_url="$(normalized_metadata_value "$marketing_url" || true)"

  localization_id="$(json_lookup_id_by_locale "$locale" <<<"$list_json")"

  if [[ -z "$localization_id" ]]; then
    create_json=""
    if ! create_json="$(
      asc version-localizations create \
        --version-id "$VERSION_ID" \
        --locale "$locale" \
        --output json
    )"; then
      list_json="$(asc version-localizations list --version-id "$VERSION_ID" --output json)"
      localization_id="$(json_lookup_id_by_locale "$locale" <<<"$list_json")"
    else
      localization_id="$(json_first_id <<<"$create_json")"
    fi

    if [[ -z "$localization_id" ]]; then
      list_json="$(asc version-localizations list --version-id "$VERSION_ID" --output json)"
      localization_id="$(json_lookup_id_by_locale "$locale" <<<"$list_json")"
    fi

    list_json="$(asc version-localizations list --version-id "$VERSION_ID" --output json)"
  fi

  update_args=(asc version-localizations update --localization-id "$localization_id")

  if [[ -n "$description" ]]; then
    update_args+=(--description "$description")
  fi

  if [[ -n "$keywords" ]]; then
    update_args+=(--keywords "$keywords")
  fi

  if [[ "${ASC_INCLUDE_WHATS_NEW:-0}" == "1" && -n "$whats_new" ]]; then
    update_args+=(--whats-new "$whats_new")
  fi

  if [[ -n "${support_url:-}" ]]; then
    update_args+=(--support-url "$support_url")
  fi

  if [[ -n "${marketing_url:-}" ]]; then
    update_args+=(--marketing-url "$marketing_url")
  fi

  if [[ -n "$promotional_text" ]]; then
    update_args+=(--promotional-text "$promotional_text")
  fi

  "${update_args[@]}" >/dev/null
  echo "Upserted version localization: $locale ($localization_id)"
done
