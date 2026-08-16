# M4 Ritual + Charts (Thought Record, Symptom Checklist, Progress Charts) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close the weekly ritual loop (spec §12): every formRef checkpoint in a session opens the referenced form (Forms Engine), submissions persist, symptom scores chart over time, and the Thought Record gets its progressive 3→4 column module — the weekly ritual is complete.

**Architecture:** A new Drift `form_submissions` table (schema v2, additive migration — M3's migration fixture pattern) stores every form answer set. `ScoreCalculator` (pure Dart) derives the symptom total from `symptom-checklist` submissions (sum of s1..s18, 0-54 scale). Charts are a dependency-free custom painter (I1: calm, no gamification flourishes). SessionScreen gains form routing: checkpoint with `formRef` → loads the referenced FormDefinition (content `forms/` via ContentRuntime) → FormScreen → on submit: save submission + complete the checkpoint (the ritual flows: symptom-checklist → medication-adherence → module-review…). Thought Record is a specialized progressive widget (situation → thought → error catalog → rational response) built on FormController, reusing the `thought-record` content form.

**Tech Stack:** Flutter 3.44.1, Drift (schema v2), existing Forms Engine (M3). Tests `--no-pub`; Windows `rm -rf build/unit_test_assets` pitfall.

## Global Constraints

- G1: `lib/forms/score_calculator.dart`, `lib/forms/thought_record_controller.dart` pure Dart; only screens/renderers import Flutter (M3 G1 precedent).
- G2: Submission is append-only history; scores chart reads submissions, never drafts.
- G3: Ritual submit = save submission THEN complete checkpoint (both in one flow; failure leaves checkpoint incomplete and submission unsaved — no half-state).
- G4: Thought Record progressive: situation+thought → thinking error (catalog) → rational response; user can revisit earlier steps (Back); no forced completion.
- G5: Charts: symptom total per submission over time (line chart, 2 colors max, no animation loop); empty state = calm message + hint, never red.
- G6: Schema v2 migration additive (new table only); migration test proves v1 data survives.
- G7: `content_runtime.loadForms()` mirrors `loadSessions()`; unknown form ref in a session → checkpoint opens read-only note instead of crashing.

---

### Task M4-1: form_submissions table (schema v2) + ScoreCalculator

**Files:**
- Modify: `app/lib/store/tables.dart` (add FormSubmissions)
- Modify: `app/lib/store/app_database.dart` (include table)
- Create: `app/lib/forms/score_calculator.dart`
- Create: `app/test/score_calculator_test.dart`
- Modify: `app/test/database_test.dart` (v1→v2 migration preserves data — now real)

**Interfaces:**
- Consumes: Drift (M3-1).
- Produces: `FormSubmissions` table: `id TEXT PK, formId TEXT, answersJson TEXT, submittedAt TEXT, updatedAt TEXT`; `class ScoreCalculator { static int? symptomTotal(Map<String,dynamic> answers) }` — sums `s1..s18` ints (0-3 each → 0-54); returns null when any of the 18 keys missing/non-int (invalid submission never charts).

- [ ] **Step 1: Write failing tests**

`app/test/score_calculator_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/forms/score_calculator.dart';

Map<String, dynamic> _full(List<int> values) =>
    {for (var i = 1; i <= 18; i++) 's$i': values[i - 1]};

void main() {
  test('sums 18 symptom items', () {
    final s = ScoreCalculator.symptomTotal(_full(List.filled(18, 1)));
    expect(s, 18);
    expect(ScoreCalculator.symptomTotal(_full(List.filled(18, 3))), 54);
    expect(ScoreCalculator.symptomTotal(_full(List.filled(18, 0))), 0);
  });

  test('missing key -> null (never charts partial)', () {
    final a = _full(List.filled(18, 1))..remove('s9');
    expect(ScoreCalculator.symptomTotal(a), isNull);
  });

  test('non-int value -> null', () {
    final a = _full(List.filled(18, 1))..['s3'] = 'high';
    expect(ScoreCalculator.symptomTotal(a), isNull);
  });
}
```

Append to `app/test/database_test.dart`:
```dart
test('v1 -> v2 migration preserves data and adds form_submissions', () async {
  final dir = Directory.systemTemp.createTempSync('mig2_');
  final db1 = AppDatabase.open('${dir.path}/app.db', schemaVersion: 1);
  await db1.into(db1.userSettings).insert(UserSettingsCompanion.insert(key: 'a', value: 'b'));
  await db1.close();
  final db2 = AppDatabase.open('${dir.path}/app.db', schemaVersion: 2);
  expect((await db2.select(db2.userSettings).get()).single.value, 'b');
  expect(db2.allTables.map((t) => t.actualTableName), contains('form_submissions'));
  await db2.close();
});
```
(NOTE: AppDatabase's default schemaVersion becomes 2 in this task; the open() param defaults update.)

- [ ] **Step 2: Run to verify fail** → FAIL (no table, no score_calculator).
- [ ] **Step 3: Implement**

`tables.dart` add:
```dart
class FormSubmissions extends Table {
  TextColumn get id => text()();
  TextColumn get formId => text()();
  TextColumn get answersJson => text()();
  TextColumn get submittedAt => text()();
  TextColumn get updatedAt => text()();
  @override
  Set<Column> get primaryKey => {id};
}
```
`app_database.dart`: add `FormSubmissions` to the `@DriftDatabase(tables: [...])` list; default `schemaVersion = 2`; onUpgrade: `if (from < 2) await m.createTable(formSubmissions);` (additive).

`score_calculator.dart`:
```dart
/// Pure Dart. Symptom checklist total = s1..s18 (0-3 each). Null = invalid.
class ScoreCalculator {
  static int? symptomTotal(Map<String, dynamic> answers) {
    var total = 0;
    for (var i = 1; i <= 18; i++) {
      final v = answers['s$i'];
      if (v is! int || v < 0 || v > 3) return null;
      total += v;
    }
    return total;
  }
}
```

- [ ] **Step 4: Regenerate + verify pass**

```bash
cd app && C:/Users/eltun/flutter/bin/flutter.bat pub run build_runner build --delete-conflicting-outputs
rm -rf build/unit_test_assets; C:/Users/eltun/flutter/bin/flutter.bat test --no-pub test/score_calculator_test.dart test/database_test.dart
```
Expected: `6 passed`.

- [ ] **Step 5: Commit**

```bash
git add app/lib/store app/lib/forms/score_calculator.dart app/test
git commit -m "feat(app): form submissions (schema v2) + symptom score calculator"
```

---

### Task M4-2: Thought Record module (progressive 3→4 column)

**Files:**
- Create: `app/lib/forms/thought_record_controller.dart` (pure Dart)
- Create: `app/lib/forms/thought_record_screen.dart`
- Create: `app/test/thought_record_test.dart`

**Interfaces:**
- Consumes: `FormController` (M3-3), the `thought-record` content form (fields: situation, automatic_thought, thinking_error [options], rational_response).
- Produces: `ThoughtRecordController extends FormController` — adds `List<String> get errorOptions` (from field options), `int get progressSteps` (0..3); `ThoughtRecordScreen(form, {onSubmit})`: 3 progressive steps — (1) situation + automatic thought, (2) thinking error picker (catalog chips from options), (3) rational response; Back always available; Finish submits.

- [ ] **Step 1: Write failing tests**

`app/test/thought_record_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/forms/form_definition.dart';
import 'package:adhd_cbt_app/forms/thought_record_controller.dart';
import 'package:adhd_cbt_app/forms/thought_record_screen.dart';

FormDefinition _trForm() => FormDefinition(
    id: 'thought-record', type: 'thought_record', title: 'Thought record',
    fields: [
      FieldDefinition(id: 'situation', kind: FieldKind.textarea, label: 'Situation'),
      FieldDefinition(id: 'automatic_thought', kind: FieldKind.textarea, label: 'Automatic thought'),
      FieldDefinition(id: 'thinking_error', kind: FieldKind.text, label: 'Thinking error',
          options: ['all-or-nothing', 'catastrophizing', 'mind-reading']),
      FieldDefinition(id: 'rational_response', kind: FieldKind.textarea, label: 'Rational response'),
    ]);

void main() {
  test('error catalog read from field options', () {
    final c = ThoughtRecordController(_trForm());
    expect(c.errorOptions, containsAll(['all-or-nothing', 'catastrophizing']));
  });

  testWidgets('progressive steps: situation -> error -> response', (tester) async {
    Map<String, dynamic>? submitted;
    await tester.pumpWidget(MaterialApp(
        home: ThoughtRecordScreen(form: _trForm(), onSubmit: (a) async => submitted = a)));
    // step 1
    await tester.enterText(find.byKey(const Key('tr-situation')), 'missed a deadline');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    // step 2: catalog chips
    await tester.tap(find.text('catastrophizing'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    // step 3
    await tester.enterText(find.byKey(const Key('tr-rational')), 'I can still fix it');
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(submitted, isNotNull);
    expect(submitted!['situation'], 'missed a deadline');
    expect(submitted!['thinking_error'], 'catastrophizing');
    expect(submitted!['rational_response'], 'I can still fix it');
  });

  testWidgets('back returns to earlier step', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ThoughtRecordScreen(form: _trForm())));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Thinking error'), findsOneWidget);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Situation'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run to verify fail** → FAIL.
- [ ] **Step 3: Implement controller + screen**

`thought_record_controller.dart`:
```dart
import 'form_controller.dart';
import 'form_definition.dart';

class ThoughtRecordController extends FormController {
  ThoughtRecordController(super.form);
  List<String> get errorOptions {
    for (final f in form.fields) {
      if (f.id == 'thinking_error') return f.options;
    }
    return const [];
  }
}
```

`thought_record_screen.dart`: StatefulWidget, `_step` 0..2; step widgets: (0) two TextFields (keys `tr-situation`, `tr-automatic`), (1) Wrap of ChoiceChips from `errorOptions` (key `tr-error-<option>`, selected state primary fill — I1 calm), (2) TextField (key `tr-rational`); Next/Back/Finish wired to `onSubmit(controller.toJson())`.

- [ ] **Step 4: Run to verify pass** → `3 passed`.
- [ ] **Step 5: Commit** → `git add app/lib/forms app/test/thought_record_test.dart` + commit "feat(app): thought record — progressive 3-step with error catalog".

---

### Task M4-3: Ritual wiring — formRef checkpoints open forms

**Files:**
- Modify: `app/lib/content/content_runtime.dart` (add `loadForms()`)
- Modify: `app/lib/store/bootstrap.dart` (return forms map; AppScope gains forms)
- Modify: `app/lib/app_scope.dart` (add `Map<String, FormDefinition>? forms`)
- Modify: `app/lib/screens/session_screen.dart` (formRef routing)
- Create: `app/test/ritual_flow_test.dart`

**Interfaces:**
- Consumes: ContentRuntime, AppScope, FormScreen (M3-3), Drift FormSubmissions (M4-1).
- Produces: `ContentRuntime.loadForms() -> List<FormDefinition>` (parse `forms/*.json` via FormDefinition.fromJson); SessionScreen: checkpoint with `formRef` shows "Open form" primary action instead of plain Done → pushes FormScreen(form: referenced, onSubmit: save submission to db + complete checkpoint + return); `SessionScreen` gains required `onFormSubmit(String formId, Map answers)` callback (wired in home_screen).

- [ ] **Step 1: Write failing test**

`app/test/ritual_flow_test.dart`:
```dart
// Session with checkpoint {id:'ritual', type:'ritual', formRef:'form:symptom-checklist'}
// pump SessionScreen(session, onFormSubmit: ...) -> 'Open form' button present;
// tap -> FormScreen renders 'Weekly symptom check' title; fill s1..s18? (long) —
// assert form opens and submit path calls onFormSubmit once with the form id.
```

- [ ] **Step 2: Run to verify fail** → FAIL.
- [ ] **Step 3: Implement** — runtime `loadForms()`, bootstrap returns `(engine, forms)`, AppScope carries forms, SessionScreen formRef branch.
- [ ] **Step 4: Run to verify pass** → PASS.
- [ ] **Step 5: Commit** → "feat(app): ritual wiring — formRef checkpoints open forms, submit completes".

---

### Task M4-4: Symptom progress chart

**Files:**
- Create: `app/lib/charts/symptom_chart.dart` (CustomPainter, dependency-free)
- Create: `app/test/symptom_chart_test.dart`

**Interfaces:**
- Consumes: `form_submissions` (M4-1), `ScoreCalculator` (M4-1).
- Produces: `class SymptomChart extends StatelessWidget { final List<int> totals; }` — line chart, x = submission order, y = 0-54; two colors (line primary500, points grey-600); labels: min/max only; `static List<int>? extractTotals(List<FormSubmissionData> rows)` helper (map + ScoreCalculator, drop nulls).

- [ ] **Step 1: Write failing tests**

`app/test/symptom_chart_test.dart`:
```dart
// 1. extractTotals: 3 rows with full 18-field answers -> [18, 27, 9];
//    row missing keys -> dropped, list still ordered.
// 2. widget test: pump SymptomChart(totals: [18, 27, 9]) -> CustomPaint present,
//    no exception; empty list -> shows calm empty message (I1, no red).
```

- [ ] **Step 2: Run to verify fail** → FAIL.
- [ ] **Step 3: Implement** — painter: min/max normalization, polyline + point circles, axis labels (0 / 54).
- [ ] **Step 4: Run to verify pass** → PASS.
- [ ] **Step 5: Commit** → "feat(app): symptom progress chart (custom painter, calm I1)".

---

### Task M4-5: Charts screen + ritual completion + tag

**Files:**
- Create: `app/lib/screens/progress_screen.dart` (weekly symptom chart + last submission date)
- Modify: `app/lib/screens/home_screen.dart` (AppBar action: progress chart icon → ProgressScreen)
- Modify: `app/test/…` (home widget test taps through)

**Interfaces:**
- Consumes: M4-1..M4-4.
- Produces: `ProgressScreen(db)`: reads form_submissions (formId == 'symptom-checklist'), extractTotals → SymptomChart; empty state message; accessible from home.

- [ ] **Step 1: Write failing widget test** (progress screen shows chart after 2 submissions inserted directly via db; empty db shows calm empty message).
- [ ] **Step 2: Run to verify fail** → FAIL.
- [ ] **Step 3: Implement** screen + home action.
- [ ] **Step 4: Full suite + verify**

```bash
cd app && rm -rf build/unit_test_assets
C:/Users/eltun/flutter/bin/flutter.bat test --no-pub
C:/Users/eltun/flutter/bin/flutter.bat analyze --no-pub | tail -1
```
Expected: all green; analyze clean.

- [ ] **Step 5: Commit + tag**

```bash
git add app/
git commit -m "feat(app): M4 complete — ritual forms, thought record, symptom charts"
git tag v0.1.0-m4
```

---

## Self-Review

1. **Spec coverage:**
   - §9 M4 "Thought Record + Symptom Checklist + progress charts" → M4-2, M4-1, M4-4 ✓
   - §9 M4 "Weekly ritual complete" → M4-3 (formRef routing) + M4-5 (progress screen) ✓
   - §12 ritual skeleton (checklist → meds → module review → skill → exercise → homework → anticipate) — all as session checkpoints with formRefs; M4-3 makes each open its form ✓
   - §1 "weekly symptom score charts" → M4-4/M4-5 ✓
   - §4.7 Symptom Checklist + charts component → M4-1/M4-4 ✓
   - §4.6 Thought Record progressive + errors catalog → M4-2 ✓
   - §8 Forms acceptance "persisted draft restore" (M3-3) + submissions now persist (M4-1) ✓
   - §7.6 invariant 6 (no third-party sharing): chart data local-only ✓
2. **Placeholder scan:** no TBD; all steps carry code or exact behaviors. The M4-3 ritual test spec is behavior-level (long checklist fill avoided deliberately).
3. **Type consistency:** `FormSubmissionData` (drift-generated) used in extractTotals signature; `ScoreCalculator.symptomTotal` single source for charts; `ThoughtRecordController` extends FormController (setValue/toJson inherited); SessionScreen callback `onFormSubmit(String, Map)` matches home wiring; AppScope.forms nullable consistent with engine/db.

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-08-15-m4-ritual-charts.md`. Two execution options:

1. **Subagent-Driven (recommended)** — fresh subagent per task, review between tasks; route via `coder` role per constitution.
2. **Inline Execution** — execute in this session, batch with checkpoints.

Given provider instability, **inline execution is the reliable path** (M1-M3 precedent).
