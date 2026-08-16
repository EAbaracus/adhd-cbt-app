<p align="center">
  <kbd>🇬🇧 <b>English</b></kbd> ·
  <a href="README.tr.md"><kbd>🇹🇷 Türkçe</kbd></a>
</p>

# ADHD CBT — 12-Week Guided Program

> A calm, science-grounded 12-week CBT self-help program for adults with ADHD.
> **No streaks. No guilt. No judgment.** The program cannot punish you — that's the design.

A local-first mobile program built on the techniques of evidence-based CBT for adult ADHD
(organization skills, attention training, cognitive restructuring, relapse prevention),
delivered as **versioned content**, rendered by a **pure-Dart program engine**, and
surrounded by a deliberately *anti-engagement* UX.

**English + Türkçe. 13 sessions. 8 clinical forms. 145 tests. Zero gamification.**

---

## Why this app exists

Most habit apps assume you'll quit — so they gamify: streaks, badges, pressure.
But for ADHD, **pressure is the problem, not the solution**. Years of struggling
teach a person to expect failure; the apps that punish a missed week just feed
that loop.

This program works the other way:

- **Miss a week?** You'll see *"Missing a session is part of the process, not a failure of it."*
- **Skip an exercise?** It stays skipped — no red badges, no "YOU'RE FALLING BEHIND".
- **Lose focus mid-session?** The timer parks your distraction instead of fighting it.
- **Half-fill a form?** It's saved the moment you type — back, reopen, continue.

Every screen, every string, every state machine was built around one invariant:
**the user is never punished.**

## What's inside

| Layer | What it does |
|---|---|
| **12-week curriculum** | 6 modules — psychoeducation, organization & planning, distractibility, adaptive thinking, procrastination, relapse prevention. Each session: ritual check-in → skill reading → exercise → home practice → anticipate-the-week. |
| **8 clinical forms** | Weekly symptom check (18-item), medication adherence, attention gauge, Thought Record, 6-step problem solving, pros/cons, module review, strategy rating. |
| **Program engine** | Pure-Dart state machine: completed / in-progress / skipped / next-candidate. No date logic, no calendar punishment. |
| **Forms engine** | Schema-driven renderer — **a new form is data, not code**. Add fields, migrate, ship. |
| **Live OTA** | Versioned content bundles with sha256 manifests, staged atomic activation, automatic rollback on any failure. |
| **Sync + entitlement** | Optional FastAPI backend: per-user encrypted bearer auth (PBKDF2-HMAC-SHA256), idempotent sync, receipt validation with 3-day grace. |
| **Localization** | Full EN/TR content — 13 sessions and 8 forms translated, locale-aware rendering with graceful fallback. |

## Architecture

```
content/            versioned, validated JSON (single source of truth)
   └─ tools/        validate.py + build.py → sha256 manifest bundle
        │
        ├─▶ app/    Flutter (local-first, Drift/SQLite)
        │             ProgramEngine → Sessions → Forms → Drift
        │             Assets bundle → OTA diff → atomic promote
        │
        └─▶ backend/ FastAPI (optional account layer)
                      auth · sync · content API · billing/entitlement
```

**Content-as-data is the core bet:** sessions, forms, and clinical copy are JSON
artifacts with schemas and hermetic tests — not Flutter code. The medical content
and the app that renders it evolve independently.

## Tech stack

| Piece | Choice |
|---|---|
| App | Flutter 3.44 / Dart 3.12 — **pure-Dart engine** (zero Flutter imports in logic layers) |
| Local store | Drift/SQLite, schema-versioned migrations |
| Backend | FastAPI + SQLite, stdlib-only crypto (PBKDF2-HMAC-SHA256, 240k iterations) |
| Content | JSON Schema (draft 2020-12) + custom validator + deterministic builder |
| Design | Refactoring-UI-grounded token system — `AppTheme` is the single canonical source; ad-hoc values are a review-blocking defect |

## Getting started

```bash
# Content pipeline (validate + test + build bundle)
cd content
./.venv/Scripts/python.exe -m pytest tests -q
./.venv/Scripts/python.exe -m tools.validate
./.venv/Scripts/python.exe -m tools.build          # → build/ (sha256 manifest)

# Backend
cd backend
.venv/Scripts/python.exe -m pytest tests/ -q
.venv/Scripts/python.exe -m uvicorn app.main:create_app --factory --port 8123

# Flutter app
cd app
flutter test --no-pub
flutter run
```

## Testing

**145 tests, hermetic and deterministic** — content (21), backend (29), app (95):

- schema validation, formRef/ISO-date/duplicate invariants, bundle determinism
- auth enumeration-resistance, per-user sync isolation, entitlement gating
- engine state machine acceptance, atomic-OTA rollback, crash-safe timer recovery
- UX rules as tests: draft persistence race guards, state-snapshot immutability, copy standards

## Roadmap

| Milestone | Tag | Delivered |
|---|---|---|
| M0 — Content pipeline | `v0.1.0-content` | schemas, validator, builder, 13 sessions, 8 forms |
| M1 — Backend | `v0.1.0-backend` | auth, sync, content API, billing/entitlement |
| M2 — App core | `v0.1.0-app` | program engine, content runtime, atomic promote, onboarding |
| M3 — Forms + tools | `v0.1.0-m3` | forms engine, task list, timer, problem-solving, Drift |
| M4 — Ritual + charts | `v0.1.0-m4` | weekly ritual, thought record, symptom charts |
| M5 — Live OTA + push | `v0.1.0-m5` | OTA client, notifications, entitlement gate, retention |
| M6 — Settings + TR | `v0.1.0-m6`, `v0.1.0-tr` | account deletion, crisis banner, full TR localization |

*Next:* store submission (external credentials), UI design-system consolidation, reviewer-gated hardening.

## Disclaimer

This is a **self-help support tool, not medical advice, diagnosis, or therapy.**
The program follows the structure of evidence-based CBT for adult ADHD; it does
not replace a clinician. If you're in crisis, reach out to local emergency
services or a mental-health hotline (US: **988**).

---

*Built deliberately: calm colors, one primary action per screen, and a completion
card that says "Harika — bir sonraki oturuma dön" without ever asking why you left.*
