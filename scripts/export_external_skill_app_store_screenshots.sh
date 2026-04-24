#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GENERATOR_DIR="$ROOT_DIR/app-store/marketing-generator"
RAW_LOCALE="${WHATIFINVEST_SCREENSHOT_RAW_LOCALE:-en-US}"
RAW_DEVICE_DIR="${WHATIFINVEST_SCREENSHOT_RAW_DEVICE_DIR:-iphone69}"
RAW_INPUT_DIR="$ROOT_DIR/app-store/screenshots/raw/$RAW_LOCALE/$RAW_DEVICE_DIR"
GENERATED_LOCALE="${WHATIFINVEST_SCREENSHOT_GENERATED_LOCALE:-en-US}"
GENERATED_OUTPUT_DIR="$ROOT_DIR/app-store/screenshots/generated/$GENERATED_LOCALE/iphone69"
PORT="${WHATIFINVEST_MARKETING_PORT:-$(python3 - <<'PY'
import socket
s = socket.socket()
s.bind(('127.0.0.1', 0))
print(s.getsockname()[1])
s.close()
PY
)}"
APP_ICON_SOURCE="$ROOT_DIR/WhatIfInvest/Assets.xcassets/AppIcon.appiconset/1024.png"
APP_ICON_DEST="$GENERATOR_DIR/public/app-icon.png"
RAW_DEST_DIR="$GENERATOR_DIR/public/raw"
MOCKUP_SOURCE="${WHATIFINVEST_MARKETING_MOCKUP_SOURCE:-$ROOT_DIR/app-store/marketing-generator/assets/mockup.png}"
MOCKUP_DEST="$GENERATOR_DIR/public/mockup.png"
MARKETING_LOCALE="${WHATIFINVEST_MARKETING_LOCALE:-$GENERATED_LOCALE}"

if [[ ! -d "$GENERATOR_DIR" ]]; then
  echo "Missing generator directory: $GENERATOR_DIR" >&2
  exit 1
fi

if [[ ! -d "$RAW_INPUT_DIR" ]]; then
  echo "Missing raw screenshot directory: $RAW_INPUT_DIR" >&2
  exit 1
fi

if [[ ! -f "$APP_ICON_SOURCE" ]]; then
  echo "Missing app icon asset: $APP_ICON_SOURCE" >&2
  exit 1
fi

if [[ ! -f "$MOCKUP_SOURCE" ]]; then
  echo "Missing mockup asset: $MOCKUP_SOURCE" >&2
  exit 1
fi

mkdir -p "$RAW_DEST_DIR" "$GENERATED_OUTPUT_DIR"
rm -f "$RAW_DEST_DIR"/*.png

cp "$APP_ICON_SOURCE" "$APP_ICON_DEST"
cp "$MOCKUP_SOURCE" "$MOCKUP_DEST"
cp "$RAW_INPUT_DIR"/*.png "$RAW_DEST_DIR"/

if [[ ! -d "$GENERATOR_DIR/node_modules" || "$GENERATOR_DIR/package-lock.json" -nt "$GENERATOR_DIR/node_modules" ]]; then
  if [[ -f "$GENERATOR_DIR/package-lock.json" ]]; then
    (cd "$GENERATOR_DIR" && npm ci)
  else
    (cd "$GENERATOR_DIR" && npm install)
  fi
fi

if ! (cd "$GENERATOR_DIR" && node - <<'NODE'
const { chromium } = require('playwright');
const fs = require('node:fs');
process.exit(fs.existsSync(chromium.executablePath()) ? 0 : 1);
NODE
); then
  (cd "$GENERATOR_DIR" && npx playwright install chromium)
fi

server_pid=""
lock_file="$GENERATOR_DIR/.next/dev/lock"
if [[ -f "$lock_file" ]]; then
  stale_pid="$(lsof -t "$lock_file" 2>/dev/null | head -n 1 || true)"
  if [[ -n "$stale_pid" ]]; then
    kill "$stale_pid" >/dev/null 2>&1 || true
    wait "$stale_pid" 2>/dev/null || true
    sleep 1
  fi
fi

cleanup() {
  if [[ -n "$server_pid" ]] && kill -0 "$server_pid" 2>/dev/null; then
    kill "$server_pid" >/dev/null 2>&1 || true
    wait "$server_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT

(cd "$GENERATOR_DIR" && WHATIFINVEST_MARKETING_LOCALE="$MARKETING_LOCALE" npm run dev -- --hostname 127.0.0.1 --port "$PORT") >/tmp/whatifinvest-marketing-generator.log 2>&1 &
server_pid=$!

for attempt in $(seq 1 60); do
  if curl -fsI "http://127.0.0.1:$PORT" >/dev/null 2>&1; then
    break
  fi
  sleep 1
  if ! kill -0 "$server_pid" 2>/dev/null; then
    echo "Generator dev server exited unexpectedly. See /tmp/whatifinvest-marketing-generator.log" >&2
    exit 1
  fi
  if [[ "$attempt" == "60" ]]; then
    echo "Timed out waiting for generator dev server. See /tmp/whatifinvest-marketing-generator.log" >&2
    exit 1
  fi
done

rm -rf "$GENERATED_OUTPUT_DIR"/*
(cd "$GENERATOR_DIR" && WHATIFINVEST_MARKETING_PORT="$PORT" WHATIFINVEST_MARKETING_LOCALE="$MARKETING_LOCALE" WHATIFINVEST_GENERATED_OUTPUT="$GENERATED_OUTPUT_DIR" node export.mjs)

echo "Generated App Store screenshots in $GENERATED_OUTPUT_DIR"
