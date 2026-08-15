# ADHD CBT App — Design Spec

> Working repo name: `adhd-cbt-app` · Final product name: **OPEN ITEM** (product-name-prescreen)
> Date: 2026-08-15 · Status: APPROVED WITH MINOR CHANGES + MARKET AMENDMENTS A1-A4 (research gate, user-approved)
> Reference source (concept only, NEVER copied): Safren, Sprich, Perlman & Otto, *Mastering Your Adult ADHD: A Cognitive-Behavioral Treatment Program, Client Workbook* (OUP, 2005)

## 1. Product

Guided **12-week CBT program** for adult ADHD, shipped as a self-help mobile app (iOS + Android), multi-user, subscription-based.

- **Digital coach model**: sequential sessions, weekly homework + reminders, weekly symptom score charts.
- **All program content is ORIGINAL** — the OUP workbook is a conceptual reference only (CBT techniques are not copyrightable; text is). No verbatim copying.
- **Clinical framing**: supportive tool — "not a diagnosis, not therapy". Disclaimers in onboarding + store listing.
- **Language**: EN first; TR localization later. Content pipeline is l10n-ready from day 1.
- **Revenue**: monthly/yearly subscription via H2 billing. Decided price anchor (market research A1): **$8.99/month, $69.99/year, 7-day free trial** — trial mechanics stay implementation-level, no entitlement-contract impact.

## 2. Locked Decisions

| # | Karar | Seçim |
|---|---|---|
| 1 | Audience | Real users, store product, multi-user |
| 2 | Shape | Guided 12-week program (digital coach) |
| 3 | Platform | Flutter, iOS + Android |
| 4 | AI | NONE in MVP; hook points reserved in Forms Engine schemas |
| 5 | Accounts | **Mandatory account + cloud sync** — deliberate override of the "no login wall" preference, recorded for this product only |
| 6 | Revenue | Subscription (monthly/yearly) |
| 7 | Scope | Full 12-week skeleton + all core modules: psychoeducation, Org/Planning (Ch4-7), Distractibility (Ch8-9), Adaptive Thinking (Ch10-12), Procrastination (Ch13), Relapse Prevention (Ch14) |
| 8 | Language | EN first, TR after |
| 9 | Architecture | **A: Custom FastAPI + Flutter + content-as-data** (reuses `user-accounts-auth-sync`, Malt Radar API discipline, `free-tier-backend-hosting`) |
| 10 | Program engine | **G2**: completion-based state, NOT week_number; catch-up and skip are normal flows |
| 11 | Sync | **F2**: device-primary, cloud = snapshot backup, restore = explicit replacement; NO LWW contract (single active device) |
| 12 | Content | **E3**: immutable bundled v1 + versioned OTA (atomic activation) |
| 13 | UX philosophy | **I1 anti-engagement** — the product's distinguishing principle: no streaks, no red "you missed it" language, no aggressive push; the app must not violate the principles it teaches |
| 14 | Billing | **H2**: native StoreKit2 + Play Billing + server-side receipt validation. RECORDED: notably higher implementation/ops cost than RevenueCat — accepted as implementation-cost decision, not architecture |

## 3. Architecture

```
┌─ Flutter app (iOS + Android) ───────────────────────────────┐
│  UI — anti-engagement (I1)                                   │
│  Program Engine (G2): pure Dart state machine,               │
│        state = completed steps, NOT week_number              │
│  Modules (content-JSON-driven):                              │
│    • Calendar+TaskList (Ch4-5): A/B/C priority, breakdown    │
│    • Timer — distractibility delay (Ch8-9)                   │
│    • Problem-Solving form (Ch6): 6-step wizard               │
│    • Thought Record (Ch10-12): 3→4 column, errors catalog    │
│    • Symptom Checklist + progress charts (weekly ritual)     │
│    • Procrastination (Ch13): pros/cons + perfectionism       │
│    • Relapse (Ch14): strategy value, 1-month review          │
│  Forms Engine: schema-driven form renderer (forms = data)    │
│  Local store: SQLite (Drift) — every entity carries          │
│        device_id, updated_at, schema_version                 │
│  Sync client: backup/restore (F2), offline-first, retry q    │
│  Content runtime: bundle v1 (immutable) + OTA manifest       │
└────────────────────────┬────────────────────────────────────┘
                         │ REST, per-user bearer (JWT)
┌────────────────────────▼────────────────────────────────────┐
│  FastAPI backend (user-accounts-auth-sync patterns)         │
│  Auth: email+password (bcrypt, JWT); Google/Apple later     │
│  Sync: F2 endpoints — backup, restore (idempotent)          │
│  Billing (H2): receipt validation + entitlement; trial      │
│  Content: versioned JSON serving (future CMS)               │
│  DB: SQLite (free-tier VM) → Postgres migration path        │
└─────────────────────────────────────────────────────────────┘
```

Monorepo: `app/` + `backend/` + `content/`.

## 4. Components (9 product modules + 2 infrastructure runtimes)

1. **Program Engine** — pure Dart state machine; per-checkpoint states: `completed`, `in_progress`, `deferred/skipped`, `current/next candidate`; unlock rules by completed prerequisites; skip/catch-up flows; "missed week" = normal state, never punishment (I1/G2). `week_number` may exist as metadata but is never the progression source of truth.
2. **Forms Engine** — schema-driven renderer; every form (checklist, thought record, problem-solving, pros/cons) is JSON schema; new form = data, not code; AI hook points reserved in schema (MVP-closed).
3. **Calendar+TaskList** — single task center; appointments calendar + to-do with A/B/C priority; task breakdown into steps.
4. **Timer (distractibility delay)** — attention-span gauge (self-timed), chunk timer, "delay the distraction" + active ignoring; environment checklist.
5. **Problem-Solving wizard** — 6-step: define, brainstorm, pros/cons, select action plan, steps, review.
6. **Thought Record** — progressive 3→4 column; thinking errors catalog; rational response guide.
7. **Symptom Checklist + charts** — weekly ritual: ADHD symptom scale + medication adherence + module review; progress charts.
8. **Procrastination module** — pros/cons motivational analysis; perfectionism cognitive restructuring.
9. **Relapse Prevention** — strategy value ratings (0-100), 1-month review reminder, booster content.
10. **Sync client** — backup/restore (F2), offline-first, retry queue; see §5.
11. **Content runtime** — bundle v1 (immutable) + OTA manifest + atomic promote; see §5.

## 5. Data Flows (4 lanes)

| Lane | Flow | Critical rule |
|---|---|---|
| Content | bundle v1 (immutable) → OTA manifest check on launch → download new → atomic promote → render | corrupt/incomplete/incompatible OTA → fall back to bundle; NEVER partial render (§7.2) |
| Program state | local-first mutation (Drift) → periodic sync push (snapshot backup) → explicit restore on new device | local = canonical; sync never blocks local use |
| Timer sessions | fully local; only session logs sync | timer state = local canonical; notification = recovery UX only |
| Forms/scores | local-first → sync backup; restored on device change | F2 single active device |

**F2 contract**: assumes one active writer device at a time. Multi-device concurrent editing / conflict resolution is out of MVP scope.

## 6. Error Handling

- **Sync**: queue + exponential backoff; silent to user but visible state ("last backup: X"); restore idempotent (see §7.3).
- **Auth**: JWT expiry → silent refresh → fail → session closes; LOCAL DB AND PENDING SYNC QUEUE SURVIVE (§7.4).
- **Billing**: launch + periodic entitlement check; receipt refresh; grace period; entitlement loss = premium content/features locked ONLY — local history/forms/progress remain readable (§7.4).
- **Timer**: persist on every state transition; notification denied → in-app fallback (sound/vibration); accuracy never depends on notification system.
- **OTA**: manifest hash verification; half-downloaded package cleaned + retried; atomic promote (§7.2).

## 7. Global Constraints — NON-NEGOTIABLE INVARIANTS (frozen)

```text
1. Local state hiçbir network failure tarafından bloke edilmez.   (local-first, offline-first)
2. OTA activation atomiktir; invalid content active olamaz.       (download→temp→hash/verify→schema validate→atomic promote→active_version swap; any fail → temp deleted, active unchanged)
3. Restore atomiktir ve idempotenttir.                            (restore(snapshot_id) → same snapshot → same result; no duplicate entities; validate snapshot → stage complete snapshot → single transaction → atomically replace local syncable state → activate snapshot; failure leaves previous local state UNCHANGED)
4. Auth/billing failure local user data'yı silemez.               (logout ≠ data deletion; entitlement loss = premium lock only)
5. Program progression calendar/week_number değil state/completion tarafından belirlenir.
6. Kullanıcı verisi üçüncü taraf reklam/ticari amaçla asla paylaşılamaz. (A3; Apple §5.1.3, FTC BetterHelp $7.8M emsali; in-app hesap silme zorunlu — Apple §5.1.1, GDPR/CCPA right-to-deletion)
```

Derived constraints: no LWW contract; sync = snapshot backup; timer local canonical; no streaks / no red "missed" language / no aggressive push (I1); missed-week UI copy standard (A4): "Harika, bir sonraki oturuma dön" — never streaks/points/certificates; retention metrics instrumented from M5 (day-30 retention, weekly checkpoint completion).

## 8. Testing Strategy (frozen pyramid)

```
                E2E / Integration
              ─────────────────────
             Timer / Restore / Billing
           ──────────────────────────
            Flutter Widget / Golden
          ─────────────────────────────
           Backend Contract / pytest
        ─────────────────────────────────
         Program + Forms Pure Unit Tests
      ───────────────────────────────────────
```

Acceptance tests per area:

- **Program**: skipped session · catch-up · prerequisite · resume after long absence · no calendar punishment
- **Forms**: invalid schema rejected · unknown field handled · migration/schema_version · persisted draft restore
- **Sync**: offline mutation · retry/backoff · duplicate push · interrupted restore · repeated restore idempotency
- **Restore** (invariant enforcement): transaction failure · previous local state remains intact
- **OTA**: bad hash · corrupt archive · incomplete download · incompatible schema · rollback to bundle · activation failure after validation → `active_version` unchanged · previous active content remains renderable
- **Auth**: expired access token · successful refresh · failed refresh · local data survives logout
- **Billing**: valid receipt · invalid receipt · grace period · entitlement loss · restore purchase
- **Timer**: foreground→background→foreground · process kill · notification denied · persisted state recovery

Method: TDD + subagent-driven development; feature work in separate worktrees + PR review (established workflow).

## 9. Milestones

| MS | Content | Deliverable |
|---|---|---|
| M0 | Repo + content schema + content authoring pipeline (12 weeks EN content as data) | Biggest risk; schema-validated, l10n-ready pipeline |
| M1 | Backend: auth + sync (idempotent contract) + billing receipt validation | API contract tests green |
| M2 | App core: Program Engine (pure Dart) + content runtime (bundle + atomic OTA) + onboarding | Engine unit + widget tests |
| M3 | Forms Engine + Calendar/TaskList + Timer + Problem-Solving | Form schema tests + timer integration |
| M4 | Thought Record + Symptom Checklist + progress charts | Weekly ritual complete |
| M5 | Live OTA + push (FCM/APNs) + entitlement integration + store prep + retention instrumentation (A4) | Store submission |

## 10. Open Items

1. **Name** — product-name-prescreen (trademark + domain + store name); before M0.
2. **Store setup** — store accounts + applicable privacy/data-protection requirements (mental-health category may trigger extra review; privacy policy for health-adjacent data: no third-party ad sharing, in-app account deletion, GDPR/CCPA right-to-deletion — A3). Current fees/policies to be verified before submission.
3. **Medical framing** — store/listing copy: "12-week guided CBT support program; not medical advice or diagnosis" (Apple §1.4.1); onboarding + footer 988/NATHELP referral; positioning "supportive guide, not human coach" (A2).
4. **Repo structure** — monorepo (`app/`, `backend/`, `content/`); created in M0 (skeleton already initialized with this spec).
5. **TR l10n** — pipeline l10n-ready; TR content in v2.
6. **AI hooks** — reserved in Forms Engine schemas (Thought Record columns); closed in MVP.

## 11. Book → App Mapping (conceptual reference)

| Book module | Key technique/form | App component |
|---|---|---|
| Ch1-3 Psychoeducation | ADHD facts, CBT cycle, meds+CBT | Onboarding: interactive psychoeducation, family invite (v2) |
| Ch4-5 Calendar+Notebook | one-system rule, A/B/C priority | Calendar+TaskList module |
| Ch6 Problem solving | 6-step Problem-Solving Form | Problem-Solving wizard |
| Ch7 Papers | mail sorting, filing system | Digital checklist/guide (physical world) |
| Ch8-9 Distractibility | attention-span gauge, distractibility delay, environment modification | Timer module + environment checklist |
| Ch10-12 Adaptive thinking | Thought Record 3→4 col, thinking errors, self-coaching | Thought Record module + errors catalog |
| Ch13 Procrastination | pros/cons, perfectionism restructuring | Procrastination module |
| Ch14 Relapse prevention | charting progress, strategy value, booster | Charts + strategy ratings + 1-month review |

## 12. Weekly Ritual (per-session skeleton, from the book)

Symptom checklist + score → medication adherence → review of previous modules' tools → new skill (content) → in-session exercise → home practice assignment → anticipate difficulties. Engine models this as checkpoints, calendar-independent (G2).
