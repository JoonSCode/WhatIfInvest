# WhatIfInvest Text Layout and Copy Implementation Plan

## Goal

Move the app from overflow-prone text composition to layout-safe, bilingual-first composition.

## Priority

1. Design system rule adoption
2. Accessibility and bilingual safety
3. Fast practical rollout

## Phase 1: Shared text model cleanup

### Task 1

Refactor shared scenario presentation so surfaces do not depend on one long sentence.

Primary files:

- `WhatIfInvest/WhatIfInvest/Features/Shared/UIFormatting.swift`
- `WhatIfInvest/WhatIfInvest/Support/L10n.swift`
- `WhatIfInvest/WhatIfInvest/en.lproj/Localizable.strings`
- `WhatIfInvest/WhatIfInvest/ko.lproj/Localizable.strings`

Expected change:

- replace fused scenario descriptor usage with structured fields or shorter variants by surface

### Task 2

Define per-surface copy tiers:

- short label
- row summary
- share summary
- accessibility label

This prevents one string from carrying every context.

## Phase 2: Surface layout changes

### Task 3

Refactor Explore result and comparison surfaces.

Primary files:

- `WhatIfInvest/WhatIfInvest/Features/Explore/ExploreView.swift`

Expected change:

- stacked fallbacks for width-sensitive rows
- wider text priority for content over trailing actions
- no clipping of result values

### Task 4

Refactor Library rows into text-first stacks with secondary actions.

Primary files:

- `WhatIfInvest/WhatIfInvest/Features/Library/LibraryView.swift`

Expected change:

- scenario summary can wrap
- buttons no longer force text compression

### Task 5

Refactor ShareCard into block-based metadata instead of fused summary lines.

Primary files:

- `WhatIfInvest/WhatIfInvest/Features/Shared/ShareCardView.swift`
- `WhatIfInvest/WhatIfInvest/Services/ShareCardExporter.swift`

Expected change:

- fixed export remains readable with long strings
- footer lines stay intact
- comparison rows stop behaving like one-line ticker strings

### Task 6

Refine trust-note composition.

Primary files:

- `WhatIfInvest/WhatIfInvest/Features/Shared/UIFormatting.swift`

Expected change:

- provider and freshness metadata can wrap or split cleanly

## Phase 3: Verification

### Task 7

Verify English and Korean layouts on:

- Explore
- Library
- Share card export
- loading overlay

### Task 8

Verify resilience with:

- larger currency amounts
- long provider labels
- Dynamic Type growth

## Engineering Notes

- prefer layout changes before text scaling
- preserve accessibility identifiers
- preserve finance meaning while shortening copy
- keep key values and disclaimers fully visible

## Done Criteria

- no primary surface overflows in English or Korean
- no key finance text is clipped
- share card survives fixed-size export
- implementation follows the design system in `design.md`
