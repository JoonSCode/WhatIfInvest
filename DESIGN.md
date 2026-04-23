# What If Invest DESIGN.md

This project uses a Coinbase-inspired financial UI system adapted for a beginner-friendly historical investing simulator.

Source inspiration:
- Primary: [Coinbase DESIGN.md](https://raw.githubusercontent.com/VoltAgent/awesome-design-md/main/design-md/coinbase/DESIGN.md)
- Secondary reference for warmth/shareability only: [Wise DESIGN.md](https://raw.githubusercontent.com/VoltAgent/awesome-design-md/main/design-md/wise/DESIGN.md)
- Collection: [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md)

## Product Tone

- Trust-first, not hype-first.
- Teach and compare; do not look like a trading terminal.
- Let the "fun" come from time replay, comparison, and motion, not from loud chrome.
- Feel credible enough for money-adjacent decisions, but still lightweight and curious.

## Visual Direction

- Base the app on a clean blue-and-white fintech palette.
- Keep most screens light by default so charts, dates, and money figures stay legible.
- Use blue for brand and primary interaction.
- Reserve green and red for performance semantics only.
- Keep depth subtle. Prefer contrast, spacing, and borders over heavy shadows.

## Color Tokens

- Brand primary: `#0052FF`
- Brand hover / active: `#578BFA`
- Text primary: `#0A0B0D`
- Text secondary: `#5B616E`
- Surface base: `#FFFFFF`
- Surface subtle: `#EEF0F3`
- Border soft: blue-gray at low opacity
- Success: separate semantic green, never reused as a brand color
- Error: separate semantic red, never reused as a brand color

## Typography

- Headings should feel clear and confident, not ultra-light and not ultra-condensed.
- Body text should prioritize readability on iPhone-sized screens.
- Money, returns, and year labels should use tabular numerals or monospaced digits where possible.
- Avoid billboard-scale headers except in share surfaces.

## Shape and Spacing

- Small radius: `8`
- Medium radius: `16`
- Large card radius: `32`
- Primary CTA radius: `56`
- Use generous vertical spacing and large tap targets.
- Do not make every control a giant pill unless it improves clarity.

## Component Rules

### Cards
- Use bright surfaces with soft borders.
- Favor large rounded rectangles over glossy floating panels.
- Keep metric cards simple and scan-friendly.

### Buttons
- Primary CTA: Coinbase blue fill, white label, pill-like radius.
- Secondary CTA: subtle surface, blue or dark label, visible border when needed.
- Do not use neon gradients, glassmorphism, or crypto-exchange styling.

### Forms
- Keep Apple system controls as the default baseline.
- Do not custom-skin `Picker`, `DatePicker`, `TextField`, `List`, `TabView`, or segmented controls unless there is a strong product reason.
- Persistent labels above inputs when helpful.
- Keep pickers and date controls visually consistent with the rest of the form.
- One primary action per interaction cluster.

### Charts
- X axis is always time.
- Y axis is always amount.
- Charts stay on light surfaces by default.
- Brand blue is not a chart series color by default if it conflicts with interaction or selection states.
- Comparison series must remain distinguishable without relying on red/green alone.

### Share Surfaces
- Keep the big, poster-like numeric hierarchy.
- Use the Coinbase base system for trust and clarity.
- Allow a small amount of warmth in the background so shares do not feel sterile.
- Share cards should look polished, not institutional.

## Don'ts

- Do not use a dark-first neobank or trading-dashboard look.
- Do not use purple-premium fintech styling as the dominant mood.
- Do not make green a brand color in the core UI.
- Do not hide important assumptions, exclusions, or data freshness.
- Do not use color alone to communicate gain/loss or selection.

## Review Lenses

For material UI changes, evaluate through these lenses:
- Brand/product fit
- SwiftUI implementation fit
- Fintech accessibility and chart readability
- Growth/shareability without trust erosion
