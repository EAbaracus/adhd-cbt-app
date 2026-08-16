# UI Design Template Implementation Plan (Design System Consolidation + UX Rules)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
> **Spec:** `docs/superpowers/specs/2026-08-16-ui-design-template.md` (user-approved, commit `a9109d2`).

**Goal:** Implement the approved design system: (1) consolidate the missing component themes into `AppTheme.light` from existing tokens ONLY, (2) implement the 6 normative UX rules + contract details D1/D2 with tests, (3) minimal migration — Timer/Tasks/Progress/Settings/Thought Record/Wizard behaviors untouched.

**Commit discipline (§8 spec):** each task = ONE logical commit; design doc commit already exists; implementation commits are separate; final state goes through reviewer gate. No production DB writes. No new tokens — `white` is the only named exception (existing).

## Global Constraints

- G1: `app/lib/theme/app_theme.dart` remains the single canonical token source. No new tokens anywhere (hard verify in T1: grep new hex values).
- G2: R0 back/state separation — Back does `_index--` ONLY; no state mutation; completed checkpoint data preserved. Test asserts state snapshot unchanged.
- G3: D1 debounce race — generation-counter guard; late write after dispose/submit is a no-op; submit→delete cannot be undone by a stale write.
- G4: D2 persistence purity — failed `setValue` never enters `answers`; inline error is additional, not a substitute.
- G5: No hardcoded user-facing strings in touched screens (session/home/form) — all through `AppStrings` EN/TR, validation copy included.
- G6: Untouched behaviors: Timer, Tasks, Progress, Settings, Thought Record, Wizard (string migration of those = documented follow-up, out of scope).
- G7: Test gate: 95 existing tests green + new per-rule tests + `flutter analyze` clean.
- G8: Windows pitfall: `rm -rf build/unit_test_assets` before `flutter test --no-pub`; ephemeral `.packages` cleanup if pub fails.

---

### Task T1: Theme consolidation (9 component themes)

**Files:** `app/lib/theme/app_theme.dart` (modify); `app/test/theme_test.dart` (create).

**Seam:** `AppTheme.light` — add after existing `cardTheme`: `inputDecorationTheme`, `chipTheme`, `segmentedButtonTheme`, `dialogTheme`, `snackBarTheme`, `checkboxTheme`/`switchTheme`, `listTileTheme`, `progressIndicatorTheme`. Every color from `AppColors`, every radius from `AppTheme.radius*` (white only in FilledButton foreground — existing).

- [ ] **Step 1: Write failing theme test** — `theme_test.dart`:
```dart
// asserts each themed widget resolves tokens (no defaults):
// inputDecorationTheme.border color == AppColors.inputBorder;
// chipTheme selectedColor == AppColors.primary100, checkmarkColor primary700;
// dialogTheme backgroundColor == Colors.white, shape radius == radius12;
// snackBarTheme backgroundColor == AppColors.textPrimary;
// progressIndicatorTheme color == AppColors.primary500.
```

- [ ] **Step 2: Run to verify fail** → FAIL (theme entries absent).
- [ ] **Step 3: Implement** — add the 9 theme entries to `AppTheme.light` (exact values below):
```dart
inputDecorationTheme: InputDecorationTheme(
  filled: true, fillColor: Colors.white,
  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.inputBorder), borderRadius: BorderRadius.circular(AppTheme.radius8)),
  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary500, width: 2), borderRadius: BorderRadius.circular(AppTheme.radius8)),
  hintStyle: AppText.small.copyWith(color: AppColors.placeholder),
  labelStyle: AppText.small.copyWith(color: AppColors.textSecondary)),
chipTheme: ChipThemeData(
  backgroundColor: AppColors.panel, selectedColor: AppColors.primary100,
  side: BorderSide(color: AppColors.border),
  labelStyle: AppText.small.copyWith(color: AppColors.textSecondary),
  secondaryLabelStyle: AppText.small.copyWith(color: AppColors.primary700),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius12))),
segmentedButtonTheme: SegmentedButtonThemeData(
  style: ButtonStyle(
    foregroundColor: WidgetStatePropertyAll(AppColors.textSecondary),
    selectedForegroundColor: WidgetStatePropertyAll(AppColors.primary700),
    backgroundColor: WidgetStatePropertyAll(Colors.white),
    selectedBackgroundColor: WidgetStatePropertyAll(AppColors.primary100),
    side: WidgetStatePropertyAll(BorderSide(color: AppColors.border)),
    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius8))))),
dialogTheme: DialogThemeData(
  backgroundColor: Colors.white, elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius12), side: BorderSide(color: AppColors.border))),
snackBarTheme: SnackBarThemeData(
  backgroundColor: AppColors.textPrimary, contentTextStyle: AppText.small.copyWith(color: Colors.white),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius8))),
checkboxTheme: CheckboxThemeData(activeColor: AppColors.primary500),
switchTheme: SwitchThemeData(thumbColor: WidgetStatePropertyAll(AppColors.primary500)),
listTileTheme: ListTileThemeData(textColor: AppColors.textPrimary, iconColor: AppColors.textSecondary),
progressIndicatorTheme: ProgressIndicatorThemeData(color: AppColors.primary500),
```
(NOTE: `WidgetStatePropertyAll` — current Flutter 3.44 API; if the analyzer flags the older `MaterialStatePropertyAll` alias, use the current name.)

- [ ] **Step 4: Hard token verify** — `grep -oE '#[0-9A-Fa-f]{6}' app/lib/theme/app_theme.dart | sort -u` → set must equal the pre-existing token set (no new hex).
- [ ] **Step 5: Verify pass + commit** — theme_test green, full suite green → `git add app/lib/theme app/test/theme_test.dart` + commit `style(app): consolidate component themes from canonical tokens (design system T1)`.

---

### Task T2: SessionFlow — Back navigation (R0/R1) + direction indicator (R5)

**Files:** `app/lib/screens/session_screen.dart` (modify); `app/test/session_screen_test.dart` (modify — add tests).

**Seam:** `_SessionScreenState` — add `int _back()`; `_advance()` unchanged; caption string.

- [ ] **Step 1: Write failing tests** (append to session_screen_test.dart):
```dart
testWidgets('back returns to previous checkpoint, state snapshot unchanged (R0)', (tester) async {
  final s = _mkSession(); // 3 checkpoints
  await tester.pumpWidget(MaterialApp(home: SessionScreen(session: s)));
  await tester.tap(find.text('Done')); await tester.pump(); // -> cp2
  await tester.tap(find.text('Done')); await tester.pump(); // -> cp3
  final before = s.checkpoints.map((c) => c.state).toList(); // [completed, completed, current]
  await tester.tap(find.text('Back')); await tester.pump();
  expect(find.text('Map situations'), findsOneWidget); // cp2 visible
  expect(s.checkpoints.map((c) => c.state).toList(), before); // SNAPSHOT UNCHANGED
});

testWidgets('back is disabled on first checkpoint', (tester) async {
  final s = _mkSession();
  await tester.pumpWidget(MaterialApp(home: SessionScreen(session: s)));
  final back = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Back'));
  expect(back.onPressed, isNull);
});

testWidgets('completed checkpoint data preserved when revisited (R0)', (tester) async {
  final s = _mkSession();
  await tester.pumpWidget(MaterialApp(home: SessionScreen(session: s)));
  await tester.tap(find.text('Done')); await tester.pump();
  await tester.tap(find.text('Back')); await tester.pump();
  expect(s.checkpoints[0].state, CheckpointState.completed); // preserved
});

testWidgets('caption shows checkpoint position (R5)', (tester) async {
  final s = _mkSession(); // 2 checkpoints
  await tester.pumpWidget(MaterialApp(home: SessionScreen(session: s)));
  expect(find.textContaining('Checkpoint 1/2'), findsOneWidget);
  await tester.tap(find.text('Done')); await tester.pump();
  expect(find.textContaining('Checkpoint 2/2'), findsOneWidget);
});
```
(NOTE: `_mkSession` in session_screen_test currently builds 2 checkpoints; the R0 snapshot test needs 3 — extend the helper or build inline.)

- [ ] **Step 2: Run to verify fail** → FAIL.
- [ ] **Step 3: Implement** — in `build`: caption `'Session ${widget.session.order} · Checkpoint ${_index + 1}/${widget.session.checkpoints.length}'`; add `TextButton('Back', onPressed: _index > 0 ? () => setState(() => _index--) : null)` next to `Later` (before it). `_index--` ONLY — no state touch (G2).
- [ ] **Step 4: Verify pass + commit** — green → `git add app/lib/screens/session_screen.dart app/test/session_screen_test.dart` + commit `feat(app): session back navigation (R0) + checkpoint indicator (R5)`.

---

### Task T3: Home — active session distinction (R6)

**Files:** `app/lib/screens/home_screen.dart` (modify); `app/test/home_screen_test.dart` (create).

**Seam:** `_HomeScreenState._sessionCard` — wrap Card in `Container` with left accent bar when state == inProgress.

- [ ] **Step 1: Write failing test** — `home_screen_test.dart`: build engine with 1 session, complete one checkpoint via engine (state inProgress), pump HomeScreen(engine, db) inside AppScope; expect a `Container` with a `BoxDecoration` border-left primary500 for the in-progress card and none for available/completed. (Simplest assertion: find the session card's decoration via `tester.widget<Container>` keyed `Key('session-card-${s.id}')`.)
- [ ] **Step 2: Run to verify fail** → FAIL.
- [ ] **Step 3: Implement** — key the Card wrapper `Key('session-card-${s.id}')`; when `state == SessionState.inProgress`, add `BoxDecoration(border: Border(left: BorderSide(color: AppColors.primary500, width: 4)))` on the card container (accent bar; no full fill — spec §2.4).
- [ ] **Step 4: Verify pass + commit** → `feat(app): home marks the active session card (R6)`.

---

### Task T4: FormFlow — inline validation feedback (R4) + persistence purity (D2)

**Files:** `app/lib/forms/form_renderer.dart` (modify); `app/test/form_renderer_widget_test.dart` (modify — add tests).

**Seam:** `_FormScreenState` — add `final Map<String, String> _fieldErrors`; `_save()` collects failures; `_field()` renders error text under the widget.

- [ ] **Step 1: Write failing tests** (append to form_renderer_widget_test.dart):
```dart
testWidgets('invalid number shows inline error and never persists (D2)', (tester) async {
  Map<String, dynamic>? submitted;
  // form with number field 'n'
  await tester.pumpWidget(MaterialApp(home: FormScreen(form: f, onSubmit: (a) async => submitted = a)));
  await tester.enterText(find.byKey(const Key('number-n')), '-5');
  await tester.tap(find.widgetWithText(FilledButton, 'Save'));
  await tester.pumpAndSettle();
  expect(find.textContaining('valid number'), findsOneWidget); // inline error visible
  expect(submitted, isNull); // save blocked OR answers without 'n' — choose: save proceeds, 'n' absent
});
```
(NOTE: pick one contract and make it explicit: **save proceeds with valid fields, invalid field excluded + error shown** — matches D2 "invalid value never enters persistence". `submitted!['n']` must be null/absent.)
- [ ] **Step 2: Run to verify fail** → FAIL.
- [ ] **Step 3: Implement** — `_save()`: per field, when `setValue` returns false, `_fieldErrors[f.id] = AppStrings.tr(locale, 'form_invalid_value')`; on success clear error. `_field` renders `Text(error, style: small, color: red500)` under the field. G4: failed value never added to answers.
- [ ] **Step 4: Verify pass + commit** → `feat(app): inline validation feedback with persistence purity (R4/D2)`.

---

### Task T5: FormFlow — draft persist + restore (R2) with debounce race guard (D1)

**Files:** `app/lib/forms/draft_store.dart` (create); `app/lib/store/drift_draft_store.dart` (create); `app/lib/forms/form_renderer.dart` (modify); `app/lib/screens/session_screen.dart` (modify); `app/lib/store/app_database.dart` (no change — FormDrafts exists); `app/test/draft_store_test.dart` (create); `app/test/draft_flow_widget_test.dart` (create).

**Seam (spec §6 R2):**
- `abstract class DraftStore { Future<Map<String, dynamic>?> load(String formId); Future<void> save(String formId, Map<String, dynamic> answers); Future<void> delete(String formId); }`
- `class DriftDraftStore implements DraftStore` — reads/writes `form_drafts.answersJson` (jsonEncode/Decode), `updatedAt` stamped; insert on conflict update.
- `FormScreen` gains `final DraftStore? draftStore;` — initState: if draftStore != null, load → seed controller (`FormController.fromJson`). Change handler: debounce 400ms with **generation counter** (D1): `int _writeGen = 0;` per change → `final gen = ++_writeGen; Timer(400ms, () async { if (gen != _writeGen || !mounted) return; await draftStore!.save(formId, controller.toJson()); });`. On submit: `_writeGen++` (invalidate pending), `await draftStore?.delete(formId)` BEFORE `onSubmit`. On dispose: `_writeGen++` (late write becomes no-op).
- `session_screen.dart` `_openForm`: build `DriftDraftStore(AppScope.of(context)!.db!)` (db nullable → if null, draftStore null, degrade gracefully) and pass to FormScreen.

**Draft chain (user requirement):** `open → restore (load) → edit/debounce (400ms gen-guarded save) → back (dispose: pending invalidated; draft already saved) → reopen (restore again) → submit (gen++ → delete → onSubmit)`.

- [ ] **Step 1: Write failing unit tests** — `draft_store_test.dart` (DriftDraftStore with temp db): save→load roundtrip; delete→load null; overwrite latest wins.
- [ ] **Step 2: Write failing widget tests** — `draft_flow_widget_test.dart`:
```dart
// R2 chain: pump FormScreen with real DriftDraftStore + temp db;
// enter text, pump 500ms (debounce fires) -> draft row exists;
// unmount (back) -> reopen new FormScreen with same store -> text restored;
// submit -> draft row deleted.
// D1 race: enter text, IMMEDIATELY submit (before 400ms) -> draft deleted;
// pump 500ms -> draft must NOT reappear (stale generation no-op).
```
(NOTE: widget tests use `tester.pump(Duration(milliseconds: 500))` to fire the debounce; FakeAsync handles the Timer.)
- [ ] **Step 3: Run to verify fail** → FAIL.
- [ ] **Step 4: Implement** — per seams above.
- [ ] **Step 5: Verify pass + commit** → `feat(app): form draft persist+restore with debounce race guard (R2/D1)`.

---

### Task T6: Copy → AppStrings (R3) for touched screens

**Files:** `app/lib/l10n/app_strings.dart` (modify — add keys); `app/lib/screens/session_screen.dart`, `app/lib/screens/home_screen.dart`, `app/lib/forms/form_renderer.dart` (modify); affected tests updated.

**Keys to add (EN/TR):** `session_back`, `session_done`, `session_later`, `session_finish`, `session_open_form`, `session_complete_title` (EN "Great — you're done. See you next session." / TR "Harika, bir sonraki oturuma dön" — TR already exists as the current hardcode), `session_complete_body`, `session_back_home`, `form_save`, `form_invalid_value` (EN "Enter a valid value" / TR "Geçerli bir değer girin"), `home_state_completed`, `home_state_in_progress`, `home_state_available`, `session_caption` (template `Session %1 · Checkpoint %2/%3`).

**Seam:** screens read `AppLocale.of(context)?.code` (session/home already do for titles) and call `AppStrings.tr(code, key)`; `form_renderer` gets locale via AppLocale.

- [ ] **Step 1: Write failing test** — `app/test/copy_test.dart`: every hardcoded UI string in the three screens' build paths resolves through AppStrings (grep-based static test: `grep -n "'[A-Z][^']*'"` on the three files → each literal must be in an AppStrings key list or be a Key/icon/format; pragmatic approach: assert AppStrings contains the new keys AND a widget test pumps each screen asserting no Text widget's data equals a banned hardcoded literal list).
- [ ] **Step 2: Run to verify fail** — "Harika" literal still in session_screen.
- [ ] **Step 3: Implement** — move strings; update the 3 screens.
- [ ] **Step 4: Update affected tests** — session_screen_test / ritual_flow_test / form_renderer_widget_test / onboarding flows that assert hardcoded literals ('Done', 'Later', 'Finish session', 'Save', 'Open form') → assert via AppStrings or keep literals IF unchanged (R3 forbids NEW hardcodes; existing assertions on unchanged literals stay valid until their string moves — move them to AppStrings lookups to be safe).
- [ ] **Step 5: Verify pass + commit** → `feat(app): migrate touched-screen copy to AppStrings (R3)`.

---

### Task T7: Full gate + reviewer handoff

- [ ] **Step 1: Full verification**
```bash
cd app && rm -rf build/unit_test_assets
C:/Users/eltun/flutter/bin/flutter.bat test --no-pub
C:/Users/eltun/flutter/bin/flutter.bat analyze --no-pub | tail -1
grep -oE '#[0-9A-Fa-f]{6}' lib/theme/app_theme.dart | sort -u | wc -l   # unchanged token count
```
Expected: all tests green (95 existing + new), analyze clean, token set unchanged.
- [ ] **Step 2: Commit final if needed** (usually empty — tasks committed individually).
- [ ] **Step 3: Reviewer gate** — dispatch READ-ONLY reviewer (paid model) with brief: verify each rule R0-R6 + D1/D2 against spec §4, run the suite, tree cleanliness start/end, docs/ read forbidden (spec text in brief). Verdict APPROVED/REQUEST_CHANGES.

---

## Self-Review

1. **Spec coverage:** §4 rules R0-R6 → T2 (R0/R1/R5), T3 (R6), T4 (R4/D2), T5 (R2/D1), T6 (R3) ✓; §5 theme consolidation → T1 ✓; §6 minimal migration scope → tasks touch ONLY session/home/form + theme + l10n ✓; §7 test gate → T7 ✓.
2. **User requirement 1 (file+seam+test):** every task lists exact files, the seam symbol, and the test counterpart ✓.
3. **User requirement 2 (draft chain):** T5 encodes `open → restore → edit/debounce → back → reopen → submit/delete` with D1 (generation counter) and D2 (persistence purity, T4) verified separately ✓.
4. **User requirement 3 (logical commits + reviewer gate):** one commit per task; T7 reviewer gate ✓.
5. **Placeholder scan:** no TBD; the only NOTE is the WidgetStatePropertyAll API-name check and the D2 contract pick (save proceeds, invalid excluded) — both resolved explicitly.
6. **Consistency:** no new tokens (T1 hard-verify); `white` only in existing FilledButton + new dialog/snackbar/segmented surfaces — spec §1 allows white as the named exception (verify in T1 step 4 that added whites are `Colors.white` constants, not hex orphans).

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-08-16-ui-design-template-impl.md`. Inline execution (M1-M6 precedent), one commit per task, reviewer gate at the end (T7). Provider instability → inline is the reliable path; the T7 reviewer runs READ-ONLY with docs/ forbidden.
