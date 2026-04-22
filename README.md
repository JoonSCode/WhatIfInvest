# TimeMachineInvest

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

## Build

```bash
xcodebuild -project TimeMachineInvest.xcodeproj -scheme TimeMachineInvest -destination 'generic/platform=iOS Simulator' build
```
