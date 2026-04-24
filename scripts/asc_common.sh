#!/usr/bin/env bash

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASC_ENV_FILE="${ASC_ENV_FILE:-$ROOT_DIR/.asc/env}"

if [[ -f "$ASC_ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ASC_ENV_FILE"
fi

require_asc() {
  if ! command -v asc >/dev/null 2>&1; then
    echo "asc is not installed. Install it first: brew install tddworks/tap/asccli" >&2
    exit 1
  fi
}

require_auth() {
  asc auth check >/dev/null
}

strings_value() {
  local file_path="$1"
  local key="$2"
  plutil -extract "$key" raw -o - "$file_path" 2>/dev/null || true
}

normalized_metadata_value() {
  local value="$1"

  if [[ "$value" == https://example.com/* ]]; then
    return 1
  fi

  if [[ -z "$value" ]]; then
    return 1
  fi

  printf '%s\n' "$value"
}

json_first_id() {
  python3 -c '
import json
import sys

payload = json.load(sys.stdin)
data = payload.get("data")

if isinstance(data, dict):
    print(data.get("id", ""))
elif isinstance(data, list) and data:
    first = data[0] or {}
    print(first.get("id", "") if isinstance(first, dict) else "")
else:
    print("")
'
}

json_lookup_id_by_locale() {
  local target_locale="$1"
  python3 -c '
import json
import sys

target = sys.argv[1]
payload = json.load(sys.stdin)

for item in payload.get("data", []):
    locale = item.get("locale")
    if not locale:
        locale = (item.get("attributes") or {}).get("locale")
    if locale == target:
        print(item.get("id", ""))
        break
' "$target_locale"
}

json_lookup_id_by_display_type() {
  local target_display_type="$1"
  python3 -c '
import json
import sys

target = sys.argv[1]
payload = json.load(sys.stdin)

for item in payload.get("data", []):
    display_type = (
        item.get("screenshotDisplayType")
        or item.get("displayType")
        or (item.get("attributes") or {}).get("screenshotDisplayType")
        or (item.get("attributes") or {}).get("displayType")
        or ""
    )
    if display_type == target:
        print(item.get("id", ""))
        break
' "$target_display_type"
}
