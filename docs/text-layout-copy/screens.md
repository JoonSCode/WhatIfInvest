# WhatIfInvest Screen Requirements For Text-Safe Layouts

## Overview

This document turns the app-wide system into screen-specific requirements.

## Shared Requirement

Replace long fused summary strings with structured fields whenever a surface is width-sensitive.

The current high-risk shared pattern is the scenario summary string assembled in:

- `WhatIfInvest/WhatIfInvest/Features/Shared/UIFormatting.swift`

## 1. Explore

Source:

- `WhatIfInvest/WhatIfInvest/Features/Explore/ExploreView.swift`

### Result header

Current risk:

- large currency value competes with the asset badge in a horizontal row

Target:

- keep the currency value intact
- allow the header text to wrap
- let the badge yield before the value
- if needed, stack badge support below the value instead of squeezing the row

### Control row

Current risk:

- status summary and utility actions already use `ViewThatFits`, but the summary is still a fused sentence

Target:

- keep the adaptive stack behavior
- shorten the summary copy
- consider splitting status chips into separate compact items instead of one long sentence
- keep Share and More as icon-only utility buttons with localized accessibility labels

### Comparison rows

Current risk:

- long scenario summary plus result summary plus destructive action all compete in one row

Target:

- main text block gets width priority
- allow the scenario description to use up to two lines
- keep result summary on its own line
- move the remove action below on narrow layouts rather than forcing text compression

### Editor summary strip

Current risk:

- category label and scenario summary are forced into a single horizontal strip

Target:

- use stacked metadata on narrower widths
- separate asset/date from contribution mode/amount
- do not rely on one combined sentence

### Chart legend area

Current risk:

- long asset display names truncate in small adaptive capsules

Target:

- keep symbol always visible
- allow the display name to truncate only as secondary text
- maintain a stable legend rhythm

## 2. Library

Source:

- `WhatIfInvest/WhatIfInvest/Features/Library/LibraryView.swift`

Current risk:

- saved scenario summary, saved-at timestamp, and two buttons create vertical crowding and width pressure

Target:

- keep row content as a text-first stack
- allow scenario summary to wrap to two lines
- keep saved-at text as secondary support
- move actions below the text block with equal visual weight
- do not let button width decide row text layout

## 3. Share Card

Source:

- `WhatIfInvest/WhatIfInvest/Features/Shared/ShareCardView.swift`
- `WhatIfInvest/WhatIfInvest/Services/ShareCardExporter.swift`

Current risk:

- fixed 1080 x 1350 export canvas
- very large value text
- one fused scenario line
- long disclaimer and snapshot text
- long comparison rows

Target:

- keep value as the visual anchor
- break scenario metadata into separate blocks
- avoid one-line combined comparison strings
- treat disclaimer and snapshot as separate multiline footer lines
- use scaling only for very large display text if spacing alone cannot solve it

Recommended structure:

1. brand
2. hero statement
3. asset symbol
4. current value
5. metadata row or stack: start date, contribution mode, amount
6. metric cards
7. comparison list with one value per line
8. disclaimer
9. snapshot note

## 4. Trust Notes

Source:

- `WhatIfInvest/WhatIfInvest/Features/Shared/UIFormatting.swift`

Current risk:

- provider label and snapshot sentence can become too long, especially in Korean

Target:

- keep trust items as separate bullet-like lines
- keep snapshot info split into date and provider if needed
- preserve meaning over compactness

## 5. Loading Overlay

Source:

- `WhatIfInvest/WhatIfInvest/RootView.swift`

Current risk:

- currently low, but title width is less constrained than body width

Target:

- ensure title and subtitle both wrap cleanly
- keep the card centered and readable under larger text sizes

## Copy Targets

### Replace fused strings

Rework these patterns:

- scenario descriptor
- comparison result summary when width gets tight
- trust snapshot line if provider naming grows

### Keep short labels short

Good candidates for strict brevity:

- buttons
- section titles
- menu labels
- tabs

### Keep explanatory text single-purpose

Each support sentence should explain one thing:

- basis
- exclusions
- freshness
- saved timestamp

## Priority Order

1. Share card
2. Shared scenario text model
3. Explore result and comparison surfaces
4. Library rows
5. Trust notes
6. Loading overlay
