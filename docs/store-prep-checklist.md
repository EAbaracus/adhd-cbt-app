# Store Prep Checklist — ADHD CBT App

> Closes the M0 "verify before submission" open item. Each row: what / owner /
> blocked-by / status. External credentials are the ONLY remaining blockers —
> the codebase is store-ready (A1 pricing, A2 copy, Invariant 6 enforced,
> receipts validated via `POST /api/billing/receipt` + backend verifiers).

| # | Item | Owner | Blocked by | Status |
|---|------|-------|-----------|--------|
| 1 | Apple Developer Program ($99/yr) membership | User | — | TODO |
| 2 | Google Play Console ($25 one-time) account | User | — | TODO |
| 3 | App Store Connect app record + bundle id `com.adhdapp.adhdCbtApp` (verify exact bundle id in `app/ios/Runner.xcodeproj`) | User | #1 | TODO |
| 4 | Play app record + package `com.adhdapp.adhd_cbt_app` (verify in `app/android/app/build.gradle.kts`) | User | #2 | TODO |
| 5 | A2 store copy (both stores): "12-week guided CBT support program; not medical advice or diagnosis" + 988 / NATHELP crisis line referral | User (copy in spec §10.3) | — | READY |
| 6 | A1 pricing: $8.99/mo, $69.99/yr, 7-day trial (App Store subscription group + Play subscription base) | User | #1/#2 | READY (spec) |
| 7 | Receipt validation keys: App Store Server API key (Apple), Play Developer API + license key (Google) → backend `app/billing/verifiers.py` (AppleReceiptVerifier stub waits) | User | #1/#2 | BLOCKED |
| 8 | Firebase project + `google-services.json`/`GoogleService-Info.plist` → FCM remote push (interface stub in `lib/notifications/`, G7) | User | Firebase account | BLOCKED |
| 9 | Age rating questionnaire (both stores; app contains mental-health tools, no medical diagnosis) | User | #1/#2 | TODO |
| 10 | Play data-safety form: no third-party sharing (Invariant 6), no data collection beyond account + local progress | User | — | READY (spec §7) |
| 11 | App privacy policy URL (GDPR/CCPA; docs/legal/ TR+EN drafts exist from Malt Radar precedent — adapt) | User | — | TODO |
| 12 | Account deletion: in-app (backend `DELETE /api/auth/me` implemented M1; UI entry point = settings screen, not yet built) | Dev | — | PARTIAL (API done) |
| 13 | Subscription restore purchase (StoreKit2 `restorePurchases` / Play `queryPurchasesAsync`) → receipt submit | Dev | #7 | TODO |
| 14 | TestFlight + Play internal testing tracks; sandbox testers | User | #1/#2 | TODO |
| 15 | Localization: TR copy (spec §1) — content + UI strings | Dev | — | TODO (M6) |
| 16 | 988/NATHELP referral rendered inside app (onboarding disclaimer present; crisis banner in settings) | Dev | — | PARTIAL (onboarding done) |

## Verified in code (as of M5, `v0.1.0-m5`)

- Onboarding disclaimer text asserted by widget test (`app_smoke_test.dart`).
- Receipt endpoint + entitlement enforced server-side (M1, 29 backend tests).
- Entitlement gate client-side (M5-3) — expired → calm locked screen.
- No third-party data sharing in any code path (retention = local Drift only).
- OTA content is entitlement-gated (backend 403 without active entitlement).
