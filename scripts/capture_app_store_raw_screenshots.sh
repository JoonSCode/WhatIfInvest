#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_IDENTIFIER="WhatIfInvestUITests/WhatIfInvestAppStoreScreenshotExportTests/testCaptureRawScreenshots"
DEFAULT_DESTINATION="platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4.1"
DESTINATION="${DESTINATION:-}"

if [[ -z "${DEVELOPER_DIR:-}" ]] && [[ -d "/Applications/Xcode.app/Contents/Developer" ]]; then
  export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
fi

resolve_destination() {
  if [[ -n "$DESTINATION" ]]; then
    printf '%s\n' "$DESTINATION"
    return 0
  fi

  python3 - <<'PY'
import json
import subprocess
import sys

preferred_names = ["iPhone 17 Pro", "iPhone 17 Pro Max", "iPhone 16 Pro"]

raw = subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "-j"], text=True)
data = json.loads(raw)

best = None
for runtime, devices in data.get("devices", {}).items():
    if "iOS" not in runtime:
        continue
    version = runtime.split("iOS-")[-1].replace("-", ".")
    for device in devices:
        if not device.get("isAvailable"):
            continue
        name = device.get("name")
        udid = device.get("udid")
        if not name or not udid:
            continue
        name_rank = preferred_names.index(name) if name in preferred_names else len(preferred_names)
        version_parts = tuple(int(part) for part in version.split(".") if part.isdigit())
        candidate = (-name_rank, version_parts, udid)
        if best is None or candidate > best:
            best = candidate

if best is None:
    print("platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4.1")
else:
    print(f"platform=iOS Simulator,id={best[2]}")
PY
}

DESTINATION="$(resolve_destination)"

cd "$ROOT_DIR"

xcodebuild test \
  -project "WhatIfInvest.xcodeproj" \
  -scheme "WhatIfInvest" \
  -skipMacroValidation \
  -skipPackagePluginValidation \
  -destination "$DESTINATION" \
  -only-testing:"$TEST_IDENTIFIER"
