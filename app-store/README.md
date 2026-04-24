# What If Invest App Store Automation

This directory is the canonical home for What If Invest submission assets and upload scaffolding.

## Screenshot Pipeline

The pipeline follows the Hi_Tomorrow raw-first shape:

1. `scripts/capture_app_store_raw_screenshots.sh`
2. `scripts/export_external_skill_app_store_screenshots.sh`
3. `scripts/asc_prepare_submission_assets.sh`

Raw captures land in:

- `app-store/screenshots/raw/en-US/iphone69`
- `app-store/screenshots/raw/ko-KR/iphone69`

Generated App Store PNGs land in:

- `app-store/screenshots/generated/en-US/iphone69`
- `app-store/screenshots/generated/ko-KR/iphone69`

Run from the repo root:

```bash
./scripts/export_app_store_screenshots.sh
```

## Metadata Drafts

Draft localization files live in:

- `app-store/localizations/app-info`
- `app-store/localizations/version`
- `app-store/site-content`

Current metadata locales:

- `en-US`
- `ko`

Replace placeholder URLs before upload if the production support/privacy URLs differ from the committed drafts.

## First Review Flow

```bash
cp .asc/env.example .asc/env
./scripts/asc_list_submission_ids.sh
./scripts/asc_prepare_submission_assets.sh
asc versions submit --version-id "$VERSION_ID"
```

`asc_prepare_submission_assets.sh` does not submit the app for review.

For a first review, create the App Store Connect app record in the web UI first, using bundle id `com.KinnoLabs.WhatIfInvest`. Apple's public API does not create new app records; the local automation starts once the record exists and `APP_ID`, `APP_INFO_ID`, and `VERSION_ID` can be discovered.
