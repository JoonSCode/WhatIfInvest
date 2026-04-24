# Ralph Execution Handoff

You are receiving a validated Ariadne planning bundle for execution through the Codex-native Ralph skill.
Treat the Ariadne bundle as authoritative and do not reopen planning unless execution discovers a real contradiction.

## Task Summary

- Bundle directory: `WhatIfInvest/docs/ariadne/asset-badges`
- Attempt id: `ralph-attempt-001`
- Attempt number: `1`
- Resolved Ariadne mode: `full`
- Resolved Ariadne profile: `brownfield`
- Selected plan id: `plan_swiftui_asset_badges`
- Selected plan title: `Unify asset visuals with a shared SwiftUI ticker badge`
- Selected plan summary: Create one reusable circular AssetBadgeView, integrate it into Explore and share surfaces, then verify build, visual legibility, accessibility, and absence of official logo assets.
- Bundle fingerprint: `sha256:578666074ad2e9b948245f72bfb48e086888173c851bf6141708364ab15bbf54`

## Source Of Truth

1. `plan.packet.json`: `WhatIfInvest/docs/ariadne/asset-badges/plan.packet.json`
2. `goal-tree.json`: `WhatIfInvest/docs/ariadne/asset-badges/goal-tree.json`
3. `spec.md`: `WhatIfInvest/docs/ariadne/asset-badges/spec.md`
4. `rationale.md`: `WhatIfInvest/docs/ariadne/asset-badges/rationale.md`

## Execution Scope

- Selection mode: `all_executable_leaves`
- Executable leaf ids: `task_asset_badge_component`, `task_explore_badge_integration`, `task_share_card_badge_integration`, `task_visual_accessibility_verification`
- Recommended dispatch order: `task_asset_badge_component`, `task_explore_badge_integration`, `task_share_card_badge_integration`, `task_visual_accessibility_verification`

## Execution Rules

- Treat the Ariadne bundle as the source of truth in this order: plan.packet.json, goal-tree.json, spec.md, rationale.md, planning-summary.md when present.
- Execute only the executable_leaf nodes included in execution_scope.
- Respect dependency order and do not dispatch a leaf before its dependencies complete.
- Run leaves in parallel only when file scopes do not overlap, risk is not high, and the leaf's consumer hints allow parallel execution.
- Do not reopen planning or widen scope unless execution discovers a real contradiction in the bundle or codebase.
- Gather fresh verification evidence before claiming a leaf is complete.
- Escalate contradictions through the allowed re-entry targets instead of guessing.

## Leaf Contracts

### `task_asset_badge_component` - Create the shared AssetBadgeView component

- Why: All screens need one consistent badge implementation instead of ad hoc circles, dots, and first-letter fallbacks.
- Description: Add a SwiftUI component that renders a circular badge for any AssetID using its tint and symbol, with compact, standard, and hero sizing.
- Risk level: `medium`

Done criteria:
- AssetBadgeView exists under the shared feature layer
- The component supports compact, standard, and hero sizes
- The badge uses asset.tint and asset.symbol
- Long symbols scale without overflowing the circular badge
- The badge exposes an accessibility label containing symbol and display name
- No PNG assets or official logos are introduced

Dependencies:
- None

File scope:
- `WhatIfInvest/WhatIfInvest/Features/Shared/AssetBadgeView.swift`

Verification:
- `build`: Build the app target after adding the component.
- `review`: Confirm the component has no official logo or image asset dependency.

Consumer hints:
- preferred_role: `implementer`
- needs_critic: `True`
- needs_verifier: `True`
- can_run_parallel: `False`
- expected_artifacts: `shared SwiftUI badge component`

### `task_explore_badge_integration` - Integrate AssetBadgeView into ExploreView

- Why: The main simulation surface is where users most often see selected and compared assets.
- Description: Replace ExploreView asset dots and first-letter badge with the shared badge, and enrich the menu Picker asset rows where SwiftUI supports it.
- Risk level: `medium`

Done criteria:
- ResultSummaryCard no longer uses symbol.prefix(1) as a badge
- Comparison rows use compact AssetBadgeView instead of a small tint dot
- Timeline legend uses compact AssetBadgeView instead of a small tint dot
- ScenarioEditorCard keeps the menu Picker and includes badge treatment where practical
- Existing scenario selection behavior is unchanged

Dependencies:
- `task_asset_badge_component`

File scope:
- `WhatIfInvest/WhatIfInvest/Features/Explore/ExploreView.swift`

Verification:
- `build`: Build the WhatIfInvest app target for iOS simulator.
- `manual`: Inspect the Explore screen with a primary scenario and at least one comparison.

Consumer hints:
- preferred_role: `implementer`
- needs_critic: `True`
- needs_verifier: `True`
- can_run_parallel: `True`
- expected_artifacts: `ExploreView badge integration`

### `task_share_card_badge_integration` - Integrate AssetBadgeView into ShareCardView

- Why: Share surfaces should use the same asset identity language as the app without becoming cluttered or logo-dependent.
- Description: Use the shared badge in the share card primary asset area and comparison rows while preserving the poster-like numeric hierarchy.
- Risk level: `medium`

Done criteria:
- Primary share-card asset area includes a hero-size AssetBadgeView
- Comparison rows use compact or standard AssetBadgeView instead of tint-only dots
- Current share-card title, metrics, disclaimer, and data-refresh copy remain intact
- Badge sizing does not clip in exported share-card rendering

Dependencies:
- `task_asset_badge_component`

File scope:
- `WhatIfInvest/WhatIfInvest/Features/Shared/ShareCardView.swift`

Verification:
- `build`: Build the WhatIfInvest app target for iOS simulator.
- `manual`: Render or preview the share card and inspect badge placement and clipping.

Consumer hints:
- preferred_role: `implementer`
- needs_critic: `True`
- needs_verifier: `True`
- can_run_parallel: `True`
- expected_artifacts: `ShareCardView badge integration`

### `task_visual_accessibility_verification` - Verify build, visual fit, accessibility, and asset hygiene

- Why: This is a UI consistency change, so code review alone is not enough; compact ticker legibility and share rendering need visual validation.
- Description: Run the final checks needed to confirm the badge system is safe to ship and does not introduce official-logo assets.
- Risk level: `low`

Done criteria:
- The app builds successfully for iOS simulator
- GOOGL, AMZN, and NVDA badges remain legible enough in compact contexts
- Accessibility labels identify assets without relying only on color
- Repository search shows no newly added official logo PNGs
- Share card rendering is visually acceptable

Dependencies:
- `task_explore_badge_integration`
- `task_share_card_badge_integration`

File scope:
- `WhatIfInvest/WhatIfInvest/Features/Shared/AssetBadgeView.swift`
- `WhatIfInvest/WhatIfInvest/Features/Explore/ExploreView.swift`
- `WhatIfInvest/WhatIfInvest/Features/Shared/ShareCardView.swift`
- `WhatIfInvest/.artifacts/ if screenshots are captured`

Verification:
- `command`: Run xcodebuild for the WhatIfInvest simulator target.
- `manual`: Inspect Explore and share-card surfaces on simulator or previews.
- `search`: Search for newly added PNG logo assets or official brand-logo references.

Consumer hints:
- preferred_role: `verifier`
- needs_critic: `False`
- needs_verifier: `True`
- can_run_parallel: `False`
- expected_artifacts: `build result`, `visual verification notes`

## Output Expectations

- Report which leaf ids completed, blocked, or were invalidated.
- Capture verification evidence for each dispatched leaf.
- List modified files or generated artifacts.
- If execution blocks, recommend exactly one re-entry target when possible.
- Persist execution feedback and executor result artifacts at the suggested root-level paths unless an explicit harness policy overrides them.

## Suggested Artifact Paths

- Attempt id: `ralph-attempt-001`
- Consumer feedback: `WhatIfInvest/docs/ariadne/asset-badges/codex-consumer-feedback.json`
- Executor result: `WhatIfInvest/docs/ariadne/asset-badges/ralph-executor.result.json`

Persist the result and feedback at these root-level paths for this attempt unless your harness has an explicit alternate retention policy.

## Re-entry Targets

- `local_reexploration`
- `brainstorming`
- `deep_interview`
- `human_review`
