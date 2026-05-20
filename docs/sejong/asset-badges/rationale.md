# WhatIfInvest Asset Badge Rationale

The selected design uses app-owned SwiftUI badges because official logos create trademark, permission, and maintenance risk. The goal is not to make WhatIfInvest look like a trading terminal or a brand directory; the goal is to make the selected asset easier to recognize inside a beginner-friendly historical simulator.

The badge stays circular because the current result summary already uses a circular color badge. Keeping that shape reduces visual churn while replacing the weak first-letter fallback with a more meaningful ticker treatment.

Color plus ticker was selected over abstract patterns to keep the first pass simple and verifiable. Patterns remain a retained alternative if later visual review shows that tint alone is too weak. Rounded-square hero badges also remain a retained alternative for share-card polish, but they are not part of this approved pass.

The menu Picker remains in place because project guidance prefers Apple default controls unless there is a strong product reason to custom-skin them. The implementation should enrich asset rows where SwiftUI supports it, but it should not replace the picker with a bespoke selection grid in this pass.

The implementation should create one shared component first, then integrate it into app and share surfaces. This keeps the UI consistent and gives future work a single boundary for adding PNG support, richer patterns, or alternate shapes if those decisions are approved later.
