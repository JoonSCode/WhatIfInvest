# AGENTS.md

Primary project instructions live in `CLAUDE.md` and `DESIGN.md` in this repository.

Always load and follow the copies from the current checkout/worktree:
- `CLAUDE.md`
- `DESIGN.md`

When this repo is checked out under KinnoLabs, also use the parent operating docs and skills when they exist:
- Root context: `/Users/junsu/Develop/KinnoLabs/AGENTS.md`
- Session continuity: `/Users/junsu/Develop/KinnoLabs/docs/SESSION_CONTINUITY.md`
- Session wrap: `/Users/junsu/Develop/KinnoLabs/.agents/skills/session-wrap/SKILL.md`
- History insight: `/Users/junsu/Develop/KinnoLabs/.agents/skills/history-insight/SKILL.md`
- Session analyzer: `/Users/junsu/Develop/KinnoLabs/.agents/skills/session-analyzer/SKILL.md`

Use parent `history-insight` for prior decisions or cross-session context before relying on memory alone. For long-running or handoff-heavy work, create/update the parent resume capsule pattern when available. Before a meaningful session ends, run parent `session-wrap` to capture learnings, documentation updates, automation candidates, and follow-ups.

Before shipping user-facing feature work, treat English and Korean localization as part of done.
New copy should go through `WhatIfInvest/Support/L10n.swift` and the matching `en.lproj` and `ko.lproj` resources.
Korean copy should be phrased for product meaning and tone, not as a literal line-by-line translation.
