# WhatIfInvest Korean Localization Rationale

This is a brownfield localization pass, not a product redesign. The safest choice is to keep the app's current SwiftUI structure and route all user-facing copy through a small central localization layer, backed by standard iOS string resources. That keeps English as the base language, lets Korean ride on the system language setting, and avoids scattering ad hoc conditional copy across views.

An in-app language picker was not selected because the user request only asked for Korean support, not a manual override surface. Adding a settings-level language control would widen scope into preference persistence and UX decisions that the current app does not need.

Literal translation was also rejected as the copy strategy. This app is curiosity-driven and explanatory, so Korean needs to sound like natural product language. Short action labels stay concise, trust notes stay precise, and finance-specific brand names remain recognizable where translating them would reduce clarity.
