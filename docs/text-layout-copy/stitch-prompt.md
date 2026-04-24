# Stitch Prompt

Use the attached design rules to redesign WhatIfInvest so text does not overflow in English or Korean.

Important constraints:

- Keep the current trust-first fintech tone.
- Do not redesign the app into a trading dashboard.
- The goal is not overflow recovery. The goal is layouts and copy that prevent overflow.
- Change structure before changing font size.
- Keep money values, returns, time spans, trust notes, disclaimers, and snapshot freshness fully visible.
- Use short labels and structured metadata blocks instead of long fused summary sentences.
- Use stacked fallbacks on narrow widths.
- Avoid relying on truncation except for low-risk secondary labels.
- Avoid using text scaling as the default strategy.

Please redesign these surfaces:

1. Explore
2. Library
3. Share Card
4. Trust Notes
5. Loading overlay

For each surface:

- propose a layout that remains stable with long English and Korean text
- propose shorter copy where needed
- preserve important financial meaning
- prefer label/value/support patterns over sentence-like summaries

Use the accompanying `design.md` as the system-level rule set and `screens.md` as the surface-level requirement set.
