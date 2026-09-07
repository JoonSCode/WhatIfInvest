# AGENTS.md

Primary project instructions live in `CLAUDE.md` and `DESIGN.md` in this repository.

Always load and follow the copies from the current checkout/worktree:
- `CLAUDE.md`
- `DESIGN.md`

When checked out under KinnoLabs, use the available parent operating docs from that checkout. In a separate worktree, resolve the intended parent before loading shared guidance:
- Root context: `../AGENTS.md`
- Session continuity: `../docs/SESSION_CONTINUITY.md`

Use parent `history-insight` for prior decisions or cross-session context before relying on memory alone. For long-running or handoff-heavy work, create/update the parent resume capsule pattern when available. Before a meaningful session ends, run parent `session-wrap` to capture learnings, documentation updates, automation candidates, and follow-ups.

Before shipping user-facing feature work, treat English and Korean localization as part of done.
New copy should go through `WhatIfInvest/Support/L10n.swift` and the matching `en.lproj` and `ko.lproj` resources.
Korean copy should be phrased for product meaning and tone, not as a literal line-by-line translation.

Optional continuity skills (`session-wrap`, `history-insight`, `session-analyzer`) are selected from the current installed catalog. If absent, use the available parent `docs/SESSION_CONTINUITY.md` or a concise local handoff; do not require missing repo-local skill paths.
