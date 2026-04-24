# WhatIfInvest Text Layout and Copy System

## Objective

Design the app so text does not overflow in normal use across English and Korean.

The primary strategy is not overflow recovery. The primary strategy is resilient layout plus concise copy.

## Product Fit

- Keep the existing trust-first, Coinbase-inspired visual system.
- Preserve clarity for beginner investors.
- Do not trade credibility for decorative layout tricks.
- Keep finance assumptions visible, especially on result and share surfaces.

## Core Principle

When text becomes long, change the structure before changing the font size.

Use this order:

1. Shorten the copy without changing meaning.
2. Split one long string into label, value, and supporting text.
3. Switch the layout so the text has room.
4. Allow wrapping for important text.
5. Use truncation only for secondary repeated labels.
6. Use text scaling only as a narrow exception on poster-like surfaces.

## Non-Negotiable Rules

### 1. Protect meaning first

Never hide or truncate:

- money values
- return values
- time span labels
- trust and disclaimer copy
- data freshness labels
- scenario assumptions that change interpretation

### 2. Layout-first resilience

Default to adaptive composition:

- horizontal row when content is short
- vertical stack when content becomes long
- `ViewThatFits` or equivalent fallback behavior for mixed-width clusters

Do not rely on fixed-height text containers for primary content.

### 3. Copy-first brevity

Use short, stable product language:

- action labels should be one clear action
- section titles should be short nouns or noun phrases
- supporting text should carry only one idea per sentence

Avoid combining asset, date, mode, amount, and result into a single sentence when the same information can be scanned faster as separate fields.

### 4. Wrap important text

Important text should wrap before it truncates:

- scenario summaries
- trust notes
- result headers
- share card disclaimers
- saved scenario descriptions

Target behavior:

- allow two lines for dense row summaries
- allow natural multiline behavior for explanatory text
- reserve single-line truncation for low-risk supporting labels

### 5. Keep values visually stable

Use monospaced digits for volatile numeric values so rows do not jitter when numbers change.

This is a stability rule, not an overflow fix.

### 6. No scale-down as the default

Do not solve overflow by shrinking text across the app.

`minimumScaleFactor` is acceptable only when all of the following are true:

- the surface is poster-like or fixed-canvas
- the text is already large display text
- the text still remains readable
- there is no loss of key financial meaning

### 7. Bilingual by default

Every rule must hold in:

- English
- Korean
- longer formatted dates
- larger currency values
- Dynamic Type growth

Do not assume English string length as the layout baseline.

## Information Structure Rules

### Label / Value / Support split

Prefer:

- label
- primary value
- support text

Instead of:

- one fused sentence

Examples:

- good: asset symbol, start date, contribution mode, amount as separate fields
- risky: one long `scenarioDescriptor` sentence reused across multiple screens

### Primary and secondary content

Primary:

- what the user is evaluating now

Secondary:

- context that helps interpretation but does not lead the scan path

Tertiary:

- extra explanation, method notes, and refresh metadata

Primary content gets first access to width.

## Component Rules

### Buttons

- keep labels short
- do not use sentence-like labels
- if a label becomes long, reduce the copy before reducing type
- if the action needs explanation, move explanation outside the button
- icon-only is acceptable for universal utility actions such as Share and More when the button keeps a localized accessibility label

### Cards

- metrics and values must remain intact
- supporting copy may wrap
- stacked metrics are preferred over squeezed horizontal rows once width becomes tight

### List rows

- two-line row summaries are preferred to one-line truncation when the row drives user choice
- destructive and utility actions should not fight the main text for width
- if actions and text compete, move actions below the content
- Share and More may stay as icon-only trailing utilities; primary actions still need visible text

### Chart legends

- legend items may truncate if the full name is available elsewhere
- do not use truncation if the legend is the only place a series can be identified
- keep color plus text, not color alone

### Share surfaces

- fixed canvas does not justify hidden meaning
- reduce field count before reducing meaning
- move from one fused summary line to grouped blocks
- keep disclaimer and snapshot text intact

## Copy Style

- calm
- factual
- scan-friendly
- one idea per sentence
- no hype language

Prefer short domain terms over explanatory phrases when the meaning is already clear in context.

## What To Avoid

- one long display string reused in every screen
- single-line layouts for complex financial summaries
- truncating values or disclaimers
- hiding long content behind hover-only affordances
- using font shrinking as the main plan
- making Korean fit by weakening meaning

## Success Criteria

- major screens do not overflow in English or Korean
- key financial content is never clipped or hidden
- share cards remain readable at fixed export size
- long strings create layout adaptation, not visual breakage
- the same rules can be used by design, implementation, and Stitch
