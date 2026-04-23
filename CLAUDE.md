# CLAUDE.md (WhatIfInvest)

This repository contains the standalone iOS app for the US stock what-if simulator planned in Ariadne.

## Core Product Rules

1. Keep the app SwiftUI-first.
2. Keep the first-run experience calculator-first, not board-first.
3. Story mode comes before compare mode.
4. Basic save and basic share stay free.
5. Do not place ads above the fold in the result experience.
6. Always keep adjusted-close basis and exclusions visible near results.
7. Follow `DESIGN.md` for visual system decisions.

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
- For material UI changes, review with multiple expert lenses: brand/product, SwiftUI implementation, fintech accessibility, and growth/shareability.
- Keep Apple default controls and interaction surfaces where possible. Do not custom-skin standard `Picker`, `DatePicker`, `TextField`, `List`, `TabView`, or segmented controls unless explicitly requested.
- Treat English and Korean as required shipping languages for user-facing feature work.
- When adding or changing user-facing copy, update `WhatIfInvest/Support/L10n.swift` and the matching entries in `WhatIfInvest/en.lproj/Localizable.strings` and `WhatIfInvest/ko.lproj/Localizable.strings`.
- If a feature touches launch, share, export, or other system-visible copy, localize those resources too, including strings files and any UI tests that assert visible text.
- Korean copy should be meaning-first and product-appropriate, not a literal English-to-Korean translation.
- Do not consider a user-facing feature complete until both English and Korean flows have been updated together.
- If product rules change, update this file and `SPECIFICATION.md`.
