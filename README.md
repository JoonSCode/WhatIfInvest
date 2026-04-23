# What If Invest

Standalone SwiftUI iOS app for exploring US stock and ETF what-if scenarios.

## Current Status

This repo starts from the Ariadne plan bundle in:

- `/Users/junsu/Develop/KinnoLabs/docs/ariadne/runs/2026-04-22-us-stock-what-if-ios-app/`

## MVP Direction

- calculator-first first run
- progressive compare mode
- bundled historical data plus refresh cache
- free basic save and share
- restrained monetization
- Coinbase-inspired `DESIGN.md` with light fintech surfaces and blue-first trust signals

## Build

```bash
xcodebuild -project WhatIfInvest.xcodeproj -scheme WhatIfInvest -destination 'generic/platform=iOS Simulator' build
```

## Design System

- Root design rules live in [DESIGN.md](/Users/junsu/Develop/KinnoLabs/TimeMachineInvest/DESIGN.md)
- Agents should load both [CLAUDE.md](/Users/junsu/Develop/KinnoLabs/TimeMachineInvest/CLAUDE.md) and [DESIGN.md](/Users/junsu/Develop/KinnoLabs/TimeMachineInvest/DESIGN.md) before substantial UI work
