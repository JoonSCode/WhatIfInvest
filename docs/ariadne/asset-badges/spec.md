# WhatIfInvest Asset Badge Unification Spec

## Goal

Unify WhatIfInvest asset visuals with app-owned SwiftUI badges so ETF and stock scenarios feel intentional without using official logos or PNG assets.

## In Scope

- Add a reusable `AssetBadgeView`.
- Render badges as circles with existing per-asset tint and centered ticker text.
- Support compact, standard, and hero-size use cases.
- Apply the badge in `ExploreView` asset display surfaces.
- Apply the badge in `ShareCardView`.
- Keep the existing menu-style asset `Picker`.
- Preserve accessibility labels for symbol and display name.

## Out Of Scope

- Official company, ETF provider, or platform logos.
- PNG asset generation or bundled logo files.
- Renaming `Asset`, `Ticker`, or Korean terminology.
- Abstract background patterns or sector illustrations.
- Adding new supported assets.

## Functional Requirements

- Each current `AssetID` must render through the same badge component.
- The badge must use `asset.symbol` as the visible text.
- The badge must use `asset.tint` as the primary visual differentiator.
- The badge must scale text so longer tickers do not overflow the circle.
- The badge must provide an accessibility label based on symbol and display name.
- Existing screen layout should remain recognizable after badge insertion.

## Technical Requirements

- Place the shared component under `WhatIfInvest/WhatIfInvest/Features/Shared/`.
- Avoid project-file churn unless Xcode synchronized groups fail to include the new Swift file.
- Use SwiftUI only.
- Do not introduce external image loading or asset pipeline dependencies.
- Avoid new localized strings unless the implementation introduces new visible copy.

## Verification

- Build with the WhatIfInvest iOS simulator scheme.
- Inspect Explore primary result, comparison rows, timeline legend, and asset picker behavior.
- Inspect ShareCardView export or preview.
- Confirm no official logo PNGs or brand marks were added.
- Confirm compact badge sizes remain legible enough for `GOOGL`, `AMZN`, and `NVDA`.
