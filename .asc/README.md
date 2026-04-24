# asc Integration

This directory holds the environment template for WhatIfInvest's repo-local `asc` submission scripts.

## CLI Baseline

- Verified against the same local baseline as Hi_Tomorrow: `asc` `0.1.66`
- Install with `brew install tddworks/tap/asccli`
- Authenticate with `asc auth login`

Authentication example:

```bash
asc auth login \
  --key-id <key-id> \
  --issuer-id <issuer-id> \
  --private-key-path /absolute/path/AuthKey_<key-id>.p8
```

## First Review Setup

1. Copy `.asc/env.example` to `.asc/env`.
2. Create or confirm the What If Invest app record in App Store Connect for bundle id `com.KinnoLabs.WhatIfInvest`.
3. Run `./scripts/asc_list_submission_ids.sh` to discover `APP_ID`, `APP_INFO_ID`, and `VERSION_ID`.
4. Fill `.asc/env`.
5. Run `./scripts/asc_prepare_submission_assets.sh`.

Apple currently requires new App Store app records to be created in the App Store Connect web UI. The App Store Connect API and this `asc` baseline can manage existing app records, versions, localizations, screenshots, builds, and bundle IDs, but not create the app record itself.

The prepare script does not submit for review. It captures/generates screenshots, upserts metadata, uploads screenshots, and runs `asc versions check-readiness`.

Review submission stays explicit:

```bash
asc versions submit --version-id "$VERSION_ID"
```
