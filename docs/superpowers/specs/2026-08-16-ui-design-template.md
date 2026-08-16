# UI Design Template & Design System — ADHD CBT App

> **Status:** APPROVED (user review, 2026-08-16)
> **Scope:** Design system documentation + theme consolidation + minimal UX-rule migration.
> **Canonical source of tokens:** `app/lib/theme/app_theme.dart` (AppColors, AppText, AppTheme). This document DERIVES from it; it does not replace it. New tokens are NOT introduced by this work — `white` is the only named exception (FilledButton foreground, already present).
> **Hard gates:** no new screens, no architecture change, no production DB write, Timer/Tasks/Progress/Settings/Thought Record/Wizard behaviors untouched, 95 existing tests + new UX tests + analyze clean.

---

## 1. Tokens (canonical, from app_theme.dart)

| Group | Token | Value | Role |
|---|---|---|---|
| Grey | `AppColors.bg` | #F6F8FA | scaffold bg |
| | `panel` | #F0F3F6 | cards-on-bg, inset wells |
| | `border` | #E2E6EB | card/dialog borders |
| | `inputBorder` | #C6CCD4 | input outlines |
| | `placeholder` | #A3ABB5 | hint text |
| | `textTertiary` | #7C8490 | caption, meta |
| | `textSecondary` | #565E6A | supporting text |
| | `textPrimary` | #1F242C | body/headings (never pure black) |
| Primary | `primary100/300/500/600/700/900` | blue scale (base 500 #2F5FD0) | actions, selected states, accents |
| Accent | `red500/900`, `green500/900`, `amber500/900` | tint(base)/text-on-tint | task priority, status (dark-on-tint, never grey-on-color) |
| Type | `AppText.caption 12 / small 14 / body 16 / lead 18 / subtitle 20 / section 24 / h2 30 / h1 36` | logical px, hand-crafted | 8 sizes max — no orphans |
| Spacing | `AppTheme.spacing4..64` (4,8,12,16,24,32,48,64) | px | 8-step scale, ~25%+ relative gaps |
| Radius | `radius8`, `radius12` | px | buttons/inputs 8, cards/dialogs 12 |

**Contrast (WCAG spot-checks):** textPrimary on white ≈ 15:1 ✓ · textSecondary on white ≈ 7.6:1 ✓ · textTertiary on white ≈ 4.6:1 ✓ (≥4.5 normal) · primary500 white text ≈ 6.3:1 ✓ · green900/amber900/red900 on their 15% tints: dark-on-tint flip, ≥7:1 ✓. Text colors in any single view ≤ 3.

## 2. Component recipes (stock Material, themed)

1. **Buttons — action pyramid.** One `FilledButton` (primary500/white) per view; `OutlinedButton` (textSecondary + border) for secondaries; `TextButton` for tertiary/link-style. Destructive actions are styled to hierarchy position, NOT semantics: delete lives in a settings row (textSecondary + icon), the *confirmation* dialog carries the heavy styling (G2 rule from M6).
2. **Inputs.** `TextField` with themed InputDecoration: enabled border inputBorder, focused border primary500 (2px), hint placeholder, label textSecondary. Never per-widget ad-hoc decoration.
3. **Chips.** `ChoiceChip`: unselected = panel bg + textSecondary, selected = primary100 bg + primary700 text + primary500 border. Used for: language, error catalog, timer presets, A/B/C.
4. **Cards.** `Card`: white, border, radius12, elevation 0. In-progress/active variant gets a **primary500 left accent bar** (4px) — accent-border pattern; never a full colored fill.
5. **Dialogs.** `AlertDialog`: white, radius12, border. Confirmation of destructive actions requires explicit input (type "delete"), never one-tap.
6. **Empty states.** Icon (40px, textTertiary) + one-line title (body, textSecondary) + optional calm hint. No red, no urgency. Primary CTA visible when the action exists.
7. **Scale selector** (form field kind scale_0_3/100): 40px tappable circles, selected = primary500 fill + white text, unselected = panel + textSecondary. Neutral by default — selection state is the only signal (I1).

## 3. Screen patterns

| Pattern | Screens | Structure |
|---|---|---|
| Onboarding | onboarding, age gate, account | Linear 2-step PageView, primary action gated on consent, disclaimer header |
| SessionFlow | session_screen | Sequential checkpoints: caption (`Session N · Checkpoint M/TOTAL`), title (h2), paragraphs (body, max ~600px width), primary action + Later, **Back between checkpoints** |
| FormFlow | form_renderer, thought record, wizard | Field list, draft persistence, inline validation feedback, Save/Finish primary |
| ListScreen | home (sessions), task list | Card list, state badges (dark-on-tint), accent bar for active item, empty state |
| Timer | timer_screen | Preset chips → big mono time (h1 56px), Pause/Resume/Finish, park list |
| Settings | settings_screen | Section titles (subtitle) + ListTiles, crisis banner card, language segmented control |

## 4. Normative UX rules (from adversarial UX pass, user-approved)

> R0 — **Back/state separation contract:** The user can navigate back to a previous checkpoint *before completing it*; completed checkpoint data is never lost and can be revisited/re-edited when needed. Back performs navigation (`_index--`) ONLY — it MUST NOT mutate any checkpoint state. Verified in tests as **state snapshot unchanged**, not merely "previous checkpoint appeared".

1. 🔴 **SessionFlow back navigation mandatory.** Back button between checkpoints; R0 applies.
2. 🔴 **FormFlow draft persist+restore mandatory.** Drafts persist to `form_drafts`; back/leave NEVER destroys a draft; reopening restores it; submit deletes it.
   - **Contract detail D1 — debounce race:** the 400ms debounce write must be cancelled/ordered so a late write can never land *after* dispose, and can never resurrect a draft *after* submit deleted it. Implementation: per-form write generation counter — the pending debounce write carries the generation captured at schedule time; dispose/submit increments the generation; the write is a no-op if its generation is stale.
3. 🔴 **No hardcoded user-facing strings.** All copy goes through `AppStrings` (EN/TR). Hardcoded user-facing strings are a review-blocking defect. Validation/error copy included (localization over hardcode).
4. 🟡 **Validation must produce visible inline feedback.** A failed `setValue` shows an inline error under the field.
   - **Contract detail D2 — persistence purity:** `setValue == false` means the invalid value MUST NOT enter persistence (`answers` map) — error display is additional, not a substitute. Verified by test: after failed input + save attempt, the persisted answers map contains no invalid value.
5. 🟡 **SessionFlow direction indicator.** Long flows show `Checkpoint N/M` (and session number) in the caption.
6. 🟡 **Home distinguishes the active session.** The current/in-progress session card is visually separated (primary accent bar) from available/completed cards.

## 5. Theme consolidation (Section 2, approved)

Add to `AppTheme.light` — derived ONLY from existing tokens:
`inputDecorationTheme` (inputBorder/placeholder/textPrimary/primary500), `chipTheme` (primary100/500, textSecondary, radius8), `segmentedButtonTheme` (primary500/border), `dialogTheme` (white, radius12, border), `snackBarTheme` (dark surface textPrimary, radius8), `checkboxTheme`/`switchTheme` (primary500), `listTileTheme` (textPrimary/textSecondary), `progressIndicatorTheme` (primary500).

## 6. Minimal migration (Section 3, approved)

Implement the 6 rules (Section 4) in the touched screens only:

| Rule | File(s) | Change |
|---|---|---|
| R1 back nav | `session_screen.dart` | Back button (`_index--` only, R0) |
| R2 draft persist | `form_renderer.dart`, `session_screen.dart`, `home_screen.dart` | Wire `form_drafts` (debounce 400ms, generation-counter race guard D1, submit→delete) |
| R3 copy | `session_screen.dart`, `home_screen.dart`, `form_renderer.dart` + AppStrings | Hardcoded strings → AppStrings (EN/TR); includes "Harika" completion card and validation copy |
| R4 validation | `form_renderer.dart` | Inline error on failed setValue; D2 persistence purity |
| R5 indicator | `session_screen.dart` | Caption `Session N · Checkpoint M/TOTAL` |
| R6 home active | `home_screen.dart` | Primary accent bar on in-progress session card |

**Untouched:** Timer, Tasks, Progress, Settings, Thought Record, Wizard behaviors (AppStrings migration of their strings is a documented follow-up, NOT this change).

## 7. Testing gate

- 95 existing app tests stay green (no behavior change outside the 6 rules).
- New tests: one per rule — R0 state-snapshot unchanged (deep copy of checkpoint states before/after Back), R2 draft roundtrip + debounce-race (late write after submit does not resurrect), R3 AppStrings completeness for touched keys, R4 invalid value absent from answers + inline error visible, R5 caption, R6 accent bar present on in-progress card.
- `flutter analyze` clean; content/backend suites untouched and green.

## 8. Commit discipline

- This document: single docs-only commit `docs(ui): define canonical design system and UX rules`.
- Implementation (Section 6): SEPARATE change, goes through reviewer gate before merge. Design contract and code change never mix in one commit.

## 9. Open items (out of scope, documented)

- Full AppStrings migration of Timer/Tasks/Progress/Settings/Thought Record/Wizard strings (follow-up).
- Visual regression harness / golden tests (follow-up; widget tests suffice for this change).
