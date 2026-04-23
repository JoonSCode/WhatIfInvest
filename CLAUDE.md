# CLAUDE.md (WhatIfInvest)

This repository contains the standalone iOS app for the US stock what-if simulator planned in Ariadne.

## Core Product Rules

1. Keep the app SwiftUI-first.
2. Keep the first-run experience calculator-first, not board-first.
3. Story mode comes before compare mode.
4. Basic save and basic share stay free.
5. Do not place ads above the fold in the result experience.
6. Always keep adjusted-close basis and exclusions visible near results.

## MVP Shape

- Supported assets: US major ETFs plus the Magnificent 7
- Modes: lump sum and recurring monthly contribution
- Surfaces: single scenario, progressive comparison, animated year-by-year chart
- Local save and basic share included
- Bundled historical data with refreshable local cache

## Engineering Notes

- Prefer `@Observable` and modern SwiftUI data flow.
- Avoid UIKit except when SwiftUI requires an adapter for system share or app lifecycle integration.
- Keep feature code split into small files under `WhatIfInvest/`.
- If product rules change, update this file and `SPECIFICATION.md`.

