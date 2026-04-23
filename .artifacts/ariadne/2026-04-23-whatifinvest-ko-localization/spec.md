# WhatIfInvest Korean Localization Spec

## Goal

Enable `WhatIfInvest` to present its existing English-first experience in Korean when the device/app language is Korean, while preserving English as the default fallback.

## Experience Contract

- Language selection follows the system/app preferred language.
- English remains the base copy.
- Korean copy should read naturally for a Korean-speaking retail user, not like a literal sentence-by-sentence translation.
- Brand and ticker identity stay recognizable.

## In Scope

- core navigation and tab labels
- explore, compare, save, share, and loading surfaces
- trust/disclaimer copy
- dynamic validation, summary, and share strings
- launch screen subtitle
- project localization configuration needed for English + Korean resources

## Out Of Scope

- in-app language switcher
- translating asset tickers
- changing product positioning or flow
- adding non-Korean languages

## Acceptance Criteria

- A Korean-language device sees the main UI in Korean across the primary user flow.
- Dynamic scenario summaries, validation messages, and share captions also localize.
- English fallback remains intact on non-Korean devices.
- The app builds cleanly after the localization changes.
