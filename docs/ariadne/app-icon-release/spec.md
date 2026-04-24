# WhatIfInvest App Icon And First Review Readiness Spec

## Goal

Prepare WhatIfInvest for first App Store review by adding finished app branding, matching launch-screen treatment, and Hi_Tomorrow-style App Store Connect automation.

## In Scope

- Generate a blue-and-white fintech app icon for What If Invest.
- Populate `AppIcon.appiconset` with required iOS icon PNGs and metadata.
- Add a launch-screen image asset derived from the app icon.
- Update `LaunchScreen.storyboard` to use the icon mark with the existing title/subtitle copy.
- Add `.asc` setup docs, env template, ASC helper scripts, App Store metadata drafts, and support/privacy drafts.
- Build, test where practical, archive, and attempt ASC id discovery.

## Out Of Scope

- App Store review submission without explicit final confirmation.
- New app features, paywalls, ads, analytics, or product-copy rewrites outside metadata.
- Committing ASC API keys, private keys, or other credentials.
- Official company, ETF, or brokerage logos.

## Requirements

- The icon should communicate hindsight investing and growth without looking like a trading terminal.
- App and launch visuals should follow `DESIGN.md`: clean, trust-first, light, Coinbase-like blue and white.
- ASC automation should mirror the shape of Hi_Tomorrow's scripts while using WhatIfInvest paths and names.
- First-review env setup should tolerate initially missing App Store Connect ids.
- Remaining blockers after archive/readiness attempts must be explicit.

## Verification

- Validate the Ariadne bundle.
- Inspect icon source and derived sizes.
- Run `xcodebuild build` or tests for simulator.
- Run `xcodebuild archive` for generic iOS.
- Run ASC list/readiness commands when authenticated and ids exist.

