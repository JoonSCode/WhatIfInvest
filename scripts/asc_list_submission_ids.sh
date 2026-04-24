#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./asc_common.sh
source "$SCRIPT_DIR/asc_common.sh"

require_asc
require_auth

if [[ -z "${APP_ID:-}" ]]; then
  if [[ -n "${BUNDLE_IDENTIFIER:-}" ]]; then
    echo "# bundle id for BUNDLE_IDENTIFIER=$BUNDLE_IDENTIFIER"
    asc bundle-ids list --identifier "$BUNDLE_IDENTIFIER" --output table
    echo
  fi

  echo "# apps"
  asc apps list --output table --limit "${ASC_APP_LIMIT:-50}"
  exit 0
fi

echo "# apps"
asc apps list --output table --limit "${ASC_APP_LIMIT:-50}"
echo

echo "# app infos for APP_ID=$APP_ID"
asc app-infos list --app-id "$APP_ID" --output table
echo

echo "# versions for APP_ID=$APP_ID"
asc versions list --app-id "$APP_ID" --output table
echo

if [[ -n "${APP_INFO_ID:-}" ]]; then
  echo "# app info localizations for APP_INFO_ID=$APP_INFO_ID"
  asc app-info-localizations list --app-info-id "$APP_INFO_ID" --output table
  echo
fi

if [[ -n "${VERSION_ID:-}" ]]; then
  echo "# version localizations for VERSION_ID=$VERSION_ID"
  asc version-localizations list --version-id "$VERSION_ID" --output table
fi
