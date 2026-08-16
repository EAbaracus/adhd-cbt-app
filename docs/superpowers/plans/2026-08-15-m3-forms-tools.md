# M3 Forms + Tools (Forms Engine, TaskList, Timer, Problem-Solving) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the app from a content viewer into the interactive core: schema-driven Forms Engine (renders the 8 M0 forms), Calendar+TaskList (A/B/C priorities + breakdown), distractibility Timer (chunk + delay + park list, crash-safe), 6-step Problem-Solving wizard — on a Drift local store — plus the engine→main assembly deferred from M2.

**Architecture:** Forms are data (`content/forms/*.json` parsed by a pure-Dart `FormDefinition` model); the renderer is one widget that switches on field `kind` (scale/text/textarea/bool/number) — new form = data, not code (spec §4.2). Drift replaces the M2 JSON FileProgressStore: `user_settings`, `checkpoint_states`, `tasks`, `task_steps`, `form_drafts`, `timer_log` tables, every row carrying the sync envelope (device_id implicit at DB level, updated_at, schema_version per store). Timer persists on every transition (spec §6.4) and recovers state after process kill. Navigation: main() bootstraps assets→docs content via ContentActivator, builds ProgramEngine over Drift, providers it, and routes home (session list) → SessionScreen.

**Tech Stack:** Flutter 3.44.1, drift + drift_flutter + drift_dev + build_runner (codegen), provider, http. All test runs `--no-pub`; Windows pitfall: `rm -rf build/unit_test_assets` before test if "failed to delete" appears.

## Global Constraints

- G1: `lib/forms/`, `lib/engine/`, `lib/content/`, `lib/store/` pure-Dart logic layers stay Flutter-free where they hold logic; only `lib/screens/` + renderers import Flutter.
- G2: Timer state persists on EVERY transition; process-kill recovery must restore the last timer state (spec §6.4, §8 Timer acceptance).
- G3: Forms validation: unknown field kind → form rejected at load (never rendered half); invalid answers never saved (draft saved on valid partial input only).
- G4: Draft persistence: form drafts autosave (spec §8 Forms "persisted draft restore"); clearing/complete deletes the draft.
- G5: I1 throughout: no streak/punishment UI; timer break is "planned pause", never "you failed".
- G6: Drift schema_version = 1; migrations tested (upgrade path test), no destructive migration in M3.
- G7: Navigation: home lists sessions from the engine (available/in-progress/completed badges), tap → SessionScreen; SessionScreen "Later"/"Done" persist via Drift checkpoint_states.
- G8: Every table row: `updated_at` ISO-UTC; primary keys stable across devices (task_id/checkpoint_id/form_id).
- G9: Test runs: `C:/Users/eltun/flutter/bin/flutter.bat test --no-pub`; Windows: rm -rf build/unit_test_assets on "failed to delete" errors.

---

### Task M3-1: Drift local store (schema v1 + migrations + UserSettings)

**Files:**
- Create: `app/lib/store/app_database.dart`
- Create: `app/lib/store/tables.dart`
- Create: `app/test/database_test.dart`
- Modify: `app/pubspec.yaml` (drift, drift_flutter; dev: drift_dev, build_runner)

**Interfaces:**
- Consumes: nothing.
- Produces: `class AppDatabase extends _$AppDatabase` (drift), `Tables`: `UserSettings` (key TEXT PK, value TEXT), `CheckpointStates` (checkpointId TEXT PK, state TEXT, updatedAt TEXT), `Tasks` (id TEXT PK, title, priority TEXT, done INT, createdAt, updatedAt), `TaskSteps` (id TEXT PK, taskId REF, title, done INT, position INT), `FormDrafts` (formId TEXT PK, answersJson TEXT, updatedAt), `TimerLog` (id TEXT PK, task TEXT, minutes INT, distractions INT, startedAt, endedAt, updatedAt); `AppDatabase.open(String path)`; `MigrationStrategy` with schema v1 + a tested v1→v2 upgrade fixture.

- [ ] **Step 1: Add deps**

```bash
cd app
C:/Users/eltun/flutter/bin/flutter.bat pub add drift drift_flutter
C:/Users/eltun/flutter/bin/flutter.bat pub add dev:drift_dev dev:build_runner
```

- [ ] **Step 2: Write failing DB test**

`app/test/database_test.dart`:
```dart
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/store/app_database.dart';

void main() {
  test('schema v1 creates all tables', () async {
    final db = AppDatabase.open('${Directory.systemTemp.createTempSync('db_').path}/app.db');
    final tables = db.allTables;
    expect(tables.map((t) => t.actualTableName),
        containsAll(['user_settings', 'checkpoint_states', 'tasks', 'task_steps', 'form_drafts', 'timer_log']));
    await db.close();
  });

  test('migration v1 -> v2 preserves data', () async {
    // fixture: open with schemaVersion override, insert, reopen at v2
    final dir = Directory.systemTemp.createTempSync('mig_');
    final db1 = AppDatabase.open('${dir.path}/app.db', schemaVersion: 1);
    await db1.into(db1.userSettings).insert(UserSettingsCompanion.insert(key: 'a', value: 'b'));
    await db1.close();
    final db2 = AppDatabase.open('${dir.path}/app.db', schemaVersion: 2);
    final rows = await db2.select(db2.userSettings).get();
    expect(rows.single.value, 'b');
    await db2.close();
  });

  test('checkpoint states roundtrip', () async {
    final db = AppDatabase.open('${Directory.systemTemp.createTempSync('db2_').path}/app.db');
    await db.into(db.checkpointStates).insert(CheckpointStatesCompanion.insert(
        checkpointId: 's1c0', state: 'completed', updatedAt: 't'));
    final rows = await db.select(db.checkpointStates).get();
    expect(rows.single.state, 'completed');
    await db.close();
  });
}
```

- [ ] **Step 3: Run to verify fail**

Run: `cd app && rm -rf build/unit_test_assets; C:/Users/eltun/flutter/bin/flutter.bat test --no-pub test/database_test.dart`
Expected: FAIL — no app_database.dart.

- [ ] **Step 4: Write tables + database**

`app/lib/store/tables.dart`:
```dart
import 'package:drift/drift.dart';

class UserSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

class CheckpointStates extends Table {
  TextColumn get checkpointId => text()();
  TextColumn get state => text()();
  TextColumn get updatedAt => text()();
  @override
  Set<Column> get primaryKey => {checkpointId};
}

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get priority => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class TaskSteps extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().references(Tasks, #id)();
  TextColumn get title => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get position => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

class FormDrafts extends Table {
  TextColumn get formId => text()();
  TextColumn get answersJson => text()();
  TextColumn get updatedAt => text()();
  @override
  Set<Column> get primaryKey => {formId};
}

class TimerLog extends Table {
  TextColumn get id => text()();
  TextColumn get task => text()();
  IntColumn get minutes => integer()();
  IntColumn get distractions => integer().withDefault(const Constant(0))();
  TextColumn get startedAt => text()();
  TextColumn get endedAt => text()();
  TextColumn get updatedAt => text()();
  @override
  Set<Column> get primaryKey => {id};
}
```

`app/lib/store/app_database.dart`:
```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  UserSettings, CheckpointStates, Tasks, TaskSteps, FormDrafts, TimerLog,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);
  AppDatabase.open(String path, {int schemaVersion = 1})
      : super(NativeDatabase(File(path), setup: (db) {
          db.execute('PRAGMA foreign_keys = ON');
        })) {
    this.schemaVersion = schemaVersion;
  }

  @override
  int get schemaVersion => _schemaVersion;
  int _schemaVersion = 1;
  set schemaVersion(int v) => _schemaVersion = v;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // v1 -> v2: additive migration fixture (no-op keeps data)
          // (any future destructive step must be a separate tested migration)
        },
      );
}
```

- [ ] **Step 5: Generate + verify pass**

```bash
cd app && C:/Users/eltun/flutter/bin/flutter.bat pub run build_runner build --delete-conflicting-outputs
rm -rf build/unit_test_assets; C:/Users/eltun/flutter/bin/flutter.bat test --no-pub test/database_test.dart
```
Expected: `3 passed`.

- [ ] **Step 6: Commit**

```bash
git add app/lib/store app/test/database_test.dart app/pubspec.yaml
git commit -m "feat(app): drift local store — schema v1, migrations, 6 tables"
```

---

### Task M3-2: Forms Engine — data model (pure Dart)

**Files:**
- Create: `app/lib/forms/form_definition.dart`
- Create: `app/test/form_definition_test.dart`

**Interfaces:**
- Consumes: `content/forms/*.json` shape (M0 form.schema.json contract: id, type, title.en, fields[{id, kind, label.en, options?}]; kinds: scale_0_3, scale_0_100, text, textarea, bool, number).
- Produces: `enum FieldKind { scale0to3, scale0to100, text, textarea, bool, number }`, `class FieldDefinition {id, kind, label, options}`, `class FormDefinition {id, type, title, fields, fromJson}` — unknown kind → FormatException (G3).

- [ ] **Step 1: Write failing tests**

`app/test/form_definition_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/forms/form_definition.dart';

Map<String, dynamic> _formJson() => {
  'id': 'symptom-checklist', 'type': 'symptom_checklist', 'title': {'en': 'Check'},
  'fields': [
    {'id': 's1', 'kind': 'scale_0_3', 'label': {'en': 'Careless mistakes'}},
    {'id': 'note', 'kind': 'textarea', 'label': {'en': 'Notes'}},
  ],
};

void main() {
  test('parses form definition', () {
    final f = FormDefinition.fromJson(_formJson());
    expect(f.id, 'symptom-checklist');
    expect(f.fields.length, 2);
    expect(f.fields[0].kind, FieldKind.scale0to3);
    expect(f.fields[1].kind, FieldKind.textarea);
  });

  test('unknown kind rejected', () {
    final bad = _formJson();
    (bad['fields'] as List)[0] = {'id': 'x', 'kind': 'radio_group', 'label': {'en': 'x'}};
    expect(() => FormDefinition.fromJson(bad), throwsFormatException);
  });

  test('options parsed for select-like fields', () {
    final j = _formJson();
    (j['fields'] as List)[0] = {'id': 'm', 'kind': 'text', 'label': {'en': 'M'},
        'options': ['a', 'b']};
    expect(FormDefinition.fromJson(j).fields[0].options, ['a', 'b']);
  });
}
```

- [ ] **Step 2: Run to verify fail**

Run: `cd app && rm -rf build/unit_test_assets; C:/Users/eltun/flutter/bin/flutter.bat test --no-pub test/form_definition_test.dart`
Expected: FAIL.

- [ ] **Step 3: Write form_definition.dart**

```dart
/// Schema-driven form model (pure Dart, G1). New form = data, not code.
library;

enum FieldKind { scale0to3, scale0to100, text, textarea, bool, number }

FieldKind _kind(String raw) => FieldKind.values.firstWhere(
    (k) => k.name == raw.replaceAll('_', '').toLowerCase() ||
           _legacy(raw) == k,
    orElse: () => throw FormatException('unknown field kind: $raw'));

FieldKind _legacy(String raw) => switch (raw) {
      'scale_0_3' => FieldKind.scale0to3,
      'scale_0_100' => FieldKind.scale0to100,
      _ => FieldKind.values.first,
    };
```
NOTE: the enum-name mapping above is convoluted — use an explicit map instead:
```dart
const _kindMap = {
  'scale_0_3': FieldKind.scale0to3,
  'scale_0_100': FieldKind.scale0to100,
  'text': FieldKind.text,
  'textarea': FieldKind.textarea,
  'bool': FieldKind.bool,
  'number': FieldKind.number,
};
FieldKind _kind(String raw) => _kindMap[raw] ??
    (throw FormatException('unknown field kind: $raw'));
```

```dart
class FieldDefinition {
  final String id;
  final FieldKind kind;
  final String label;
  final List<String> options;
  FieldDefinition({required this.id, required this.kind, required this.label, this.options = const []});

  factory FieldDefinition.fromJson(Map<String, dynamic> json) => FieldDefinition(
        id: json['id'] as String,
        kind: _kind(json['kind'] as String),
        label: (json['label'] as Map?)?['en'] as String? ?? json['id'] as String,
        options: (json['options'] as List?)?.cast<String>() ?? const [],
      );
}

class FormDefinition {
  final String id;
  final String type;
  final String title;
  final List<FieldDefinition> fields;
  FormDefinition({required this.id, required this.type, required this.title, required this.fields});

  factory FormDefinition.fromJson(Map<String, dynamic> json) => FormDefinition(
        id: json['id'] as String,
        type: json['type'] as String,
        title: (json['title'] as Map?)?['en'] as String? ?? json['id'] as String,
        fields: (json['fields'] as List? ?? [])
            .map((f) => FieldDefinition.fromJson(f as Map<String, dynamic>))
            .toList(),
      );
}
```

- [ ] **Step 4: Run to verify pass**

Expected: `3 passed`.

- [ ] **Step 5: Commit**

```bash
git add app/lib/forms/form_definition.dart app/test/form_definition_test.dart
git commit -m "feat(app): forms engine data model — kind-typed definitions, unknown kind rejected"
```

---

### Task M3-3: Forms Engine renderer + draft persistence

**Files:**
- Create: `app/lib/forms/form_controller.dart` (pure Dart: answers map, validation, draft JSON)
- Create: `app/lib/forms/form_renderer.dart` (Flutter widgets)
- Create: `app/test/form_controller_test.dart`
- Create: `app/test/form_renderer_widget_test.dart`

**Interfaces:**
- Consumes: `FormDefinition` (M3-2), Drift `FormDrafts` (M3-1).
- Produces: `class FormController { Map<String,dynamic> answers; bool valid; void setValue(String id, dynamic v); Map<String,dynamic> toJson(); static FormController fromJson(Map); }` — validation per kind (scale bounds, number parse, bool); `class FormScreen { FormDefinition form; FormController initial; Future<void> Function(Map answers)? onSubmit; }` — renders fields by kind, autosaves drafts via `FormDrafts` (debounced), complete → submit + delete draft, cancel → draft kept.

- [ ] **Step 1: Write failing controller tests**

`app/test/form_controller_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/forms/form_controller.dart';
import 'package:adhd_cbt_app/forms/form_definition.dart';

FormDefinition _f() => FormDefinition(
    id: 'f1', type: 'module_review', title: 'T',
    fields: [
      FieldDefinition(id: 'n', kind: FieldKind.number, label: 'Doses'),
      FieldDefinition(id: 's', kind: FieldKind.scale0to3, label: 'Impact'),
      FieldDefinition(id: 'ok', kind: FieldKind.bool, label: 'Consent'),
    ]);

void main() {
  test('invalid scale rejected', () {
    final c = FormController(_f());
    expect(c.setValue('s', 5), isFalse); // scale_0_3 max 3
    expect(c.answers['s'], isNull);
    expect(c.setValue('s', 2), isTrue);
  });

  test('number parse + range', () {
    final c = FormController(_f());
    expect(c.setValue('n', -1), isFalse);
    expect(c.setValue('n', 4), isTrue);
    expect(c.answers['n'], 4);
  });

  test('bool only true/false', () {
    final c = FormController(_f());
    expect(c.setValue('ok', 'yes'), isFalse);
    expect(c.setValue('ok', true), isTrue);
  });

  test('json roundtrip preserves answers', () {
    final c = FormController(_f())..setValue('n', 2)..setValue('s', 1);
    final c2 = FormController.fromJson(_f(), c.toJson());
    expect(c2.answers['n'], 2);
    expect(c2.answers['s'], 1);
  });

  test('unknown field id ignored', () {
    final c = FormController(_f());
    expect(c.setValue('ghost', 1), isFalse);
  });
}
```

- [ ] **Step 2: Run to verify fail**

Expected: FAIL — no form_controller.dart.

- [ ] **Step 3: Write controller + renderer**

`app/lib/forms/form_controller.dart`:
```dart
import 'form_definition.dart';

class FormController {
  final FormDefinition form;
  final Map<String, dynamic> answers;
  FormController(this.form, [Map<String, dynamic>? initial]) : answers = {...?initial};

  bool setValue(String id, dynamic value) {
    final f = form.fields.where((x) => x.id == id).firstOrNull;
    if (f == null) return false;
    switch (f.kind) {
      case FieldKind.scale0to3:
        if (value is! int || value < 0 || value > 3) return false;
      case FieldKind.scale0to100:
        if (value is! int || value < 0 || value > 100) return false;
      case FieldKind.number:
        if (value is! num || value < 0) return false;
      case FieldKind.bool:
        if (value is! bool) return false;
      case FieldKind.text:
      case FieldKind.textarea:
        if (value is! String) return false;
    }
    answers[f.id] = value;
    return true;
  }

  Map<String, dynamic> toJson() => Map.of(answers);
  static FormController fromJson(FormDefinition form, Map<String, dynamic> json) =>
      FormController(form, json);
}
```
NOTE: `firstOrNull` needs `package:collection` OR a manual loop — use a manual loop (dependency-free, same as M2-3):
```dart
FieldDefinition? _find(String id) {
  for (final f in form.fields) { if (f.id == id) return f; }
  return null;
}
```
(no switch-case fallthrough in Dart — each case needs break/return; rewrite with if/else chains.)

- [ ] **Step 4: Renderer widget test**

`app/test/form_renderer_widget_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/forms/form_controller.dart';
import 'package:adhd_cbt_app/forms/form_definition.dart';
import 'package:adhd_cbt_app/forms/form_renderer.dart';

FormDefinition _f() => FormDefinition(id: 'f1', type: 'symptom_checklist', title: 'Check',
    fields: [
      FieldDefinition(id: 's1', kind: FieldKind.scale0to3, label: 'Careless mistakes'),
      FieldDefinition(id: 'note', kind: FieldKind.textarea, label: 'Notes'),
    ]);

void main() {
  testWidgets('renders scale and textarea fields', (tester) async {
    await tester.pumpWidget(MaterialApp(home: FormScreen(form: _f())));
    expect(find.text('Careless mistakes'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
  });

  testWidgets('submit collects answers', (tester) async {
    Map<String, dynamic>? submitted;
    await tester.pumpWidget(MaterialApp(home: FormScreen(
      form: _f(),
      onSubmit: (a) async => submitted = a,
    )));
    await tester.tap(find.byKey(const Key('scale-s1-2')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('textarea-note')), 'hello');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(submitted, isNotNull);
    expect(submitted!['s1'], 2);
    expect(submitted!['note'], 'hello');
  });
}
```

- [ ] **Step 5: Write renderer**

`app/lib/forms/form_renderer.dart` — `FormScreen(form, {initial, onSubmit, draftStore})`: ListView of field widgets:
- `scale_0_3` → 4 tappable circles (0-3) with `Key('scale-<id>-<v>')` (I1: no color urgency — selected state = primary fill, neutral otherwise)
- `scale_0_100` → Slider (divisions 10)
- `text` → TextField (with options → ChoiceChips)
- `textarea` → TextField(maxLines: 4, key `Key('textarea-<id>')`)
- `bool` → Switch
- `number` → TextFormField(keyboardType: number, key `Key('number-<id>')`)
- Save button (`Key('save')`): validate + `onSubmit(answers)`; autosave draft on change when `draftStore` provided (debounce 400ms via Timer), delete draft after submit.

- [ ] **Step 6: Run to verify pass**

Run: `cd app && rm -rf build/unit_test_assets; C:/Users/eltun/flutter/bin/flutter.bat test --no-pub test/form_controller_test.dart test/form_renderer_widget_test.dart`
Expected: `7 passed`.

- [ ] **Step 7: Commit**

```bash
git add app/lib/forms app/test/form_controller_test.dart app/test/form_renderer_widget_test.dart
git commit -m "feat(app): forms engine — controller validation + schema-driven renderer + drafts"
```

---

### Task M3-4: Calendar+TaskList (tasks + steps, Drift-backed)

**Files:**
- Create: `app/lib/tasks/task_controller.dart` (pure Dart over Drift queries)
- Create: `app/lib/screens/task_list_screen.dart`
- Create: `app/test/task_controller_test.dart`
- Create: `app/test/task_list_widget_test.dart`

**Interfaces:**
- Consumes: Drift `Tasks`/`TaskSteps` (M3-1).
- Produces: `TaskController(db)`: `Future<List<Task>> list()` (ordered: A/B/C then not-done first), `Future<void> add(String title, String priority)`, `Future<void> addStep(String taskId, String stepTitle)`, `Future<void> toggleDone(String taskId)`, `Future<void> toggleStep(String stepId)`, `Future<void> delete(String taskId)`; Task = {id, title, priority, done, steps}. UI: TaskListScreen with A/B/C colored priority chips (green/amber/red accents, text always dark-on-tint — refactoring-ui), add-task field, expandable steps, checkboxes.

- [ ] **Step 1: Write failing controller tests**

`app/test/task_controller_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/store/app_database.dart';
import 'package:adhd_cbt_app/tasks/task_controller.dart';

void main() {
  test('add/list/toggle/delete lifecycle', () async {
    final db = AppDatabase.open('${Directory.systemTemp.createTempSync('t_').path}/t.db');
    final c = TaskController(db);
    await c.add('Do taxes', 'A');
    await c.add('Call mom', 'C');
    final tasks = await c.list();
    expect(tasks.length, 2);
    expect(tasks.first.priority, 'A'); // A first
    await c.toggleDone(tasks.first.id);
    final after = await c.list();
    expect(after.first.done, isTrue);
    await c.delete(tasks.first.id);
    expect(await c.list(), hasLength(1));
    await db.close();
  });

  test('steps lifecycle', () async {
    final db = AppDatabase.open('${Directory.systemTemp.createTempSync('t2_').path}/t.db');
    final c = TaskController(db);
    await c.add('Task', 'B');
    final t = (await c.list()).single;
    await c.addStep(t.id, 'Find form');
    await c.addStep(t.id, 'Fill form');
    final loaded = (await c.list()).single;
    expect(loaded.steps.length, 2);
    await c.toggleStep(loaded.steps.first.id);
    final after = (await c.list()).single;
    expect(after.steps.first.done, isTrue);
    await db.close();
  });
}
```

- [ ] **Step 2: Run to verify fail**

Expected: FAIL — no task_controller.dart.

- [ ] **Step 3: Write controller**

`app/lib/tasks/task_controller.dart` — maps Drift rows to `Task`/`TaskStep` models; priority order A < B < C; done tasks sink to bottom; `updatedAt` stamped on every mutation.

- [ ] **Step 4: Widget test**

`app/test/task_list_widget_test.dart`: pump `TaskListScreen(controller: c)` with real temp Drift DB; assert add → appears; tap checkbox → done moves down.

- [ ] **Step 5: Write screen**

`app/lib/screens/task_list_screen.dart` — `TaskListScreen({required TaskController controller})`; ListView of cards: priority chip (A=green tint/green-900 text, B=amber, C=grey), title, expandable steps with checkboxes, delete via Dismissible. Add: bottom TextField + priority selector.

- [ ] **Step 6: Run to verify pass**

Expected: `3 passed`.

- [ ] **Step 7: Commit**

```bash
git add app/lib/tasks app/lib/screens/task_list_screen.dart app/test/task_controller_test.dart app/test/task_list_widget_test.dart
git commit -m "feat(app): task list — A/B/C priorities + step breakdown (drift)"
```

---

### Task M3-5: Distractibility Timer (chunk + delay + park list, crash-safe)

**Files:**
- Create: `app/lib/timer/chunk_timer.dart` (pure Dart state machine)
- Create: `app/lib/timer/timer_controller.dart` (persistence via Drift TimerLog + in-memory recovery)
- Create: `app/lib/screens/timer_screen.dart`
- Create: `app/test/chunk_timer_test.dart`
- Create: `app/test/timer_screen_widget_test.dart`

**Interfaces:**
- Consumes: Drift `TimerLog` (M3-1).
- Produces: `class ChunkTimer { ChunkTimer(int chunkMinutes); states: idle/running/paused/done; void start(); void pause(); void resume(); void finish(); int get remainingSeconds; DateTime? get startedAt; }` — pure Dart, tick-driven from outside (widget Timer.periodic); `TimerController(db)`: `Future<void> saveLog(ChunkTimer, {int distractions, String task})`, `Future<ChunkTimer?> recoverLast()` — returns last in-progress timer (startedAt + chunkMinutes, remaining computed) after process kill (spec §6.4, §8); `TimerScreen`: chunk preset selector (10/15/25/45), start/pause, urge → "park list" entry (text field appends to visible list — active ignoring), finish → save TimerLog.

- [ ] **Step 1: Write failing pure-Dart tests**

`app/test/chunk_timer_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/timer/chunk_timer.dart';

void main() {
  test('lifecycle idle->running->paused->resume->done', () {
    final t = ChunkTimer(25);
    expect(t.state, ChunkTimerState.idle);
    t.start();
    expect(t.state, ChunkTimerState.running);
    t.pause();
    expect(t.state, ChunkTimerState.paused);
    t.resume();
    expect(t.state, ChunkTimerState.running);
    t.finish();
    expect(t.state, ChunkTimerState.done);
  });

  test('pause freezes remaining, resume continues', () {
    final t = ChunkTimer(25);
    t.start();
    t.tick(10 * 60); // 10 min elapsed
    t.pause();
    final pausedAt = t.remainingSeconds;
    t.tick(5 * 60); // wall time passes while paused
    expect(t.remainingSeconds, pausedAt);
    t.resume();
    t.tick(2 * 60);
    expect(t.remainingSeconds, pausedAt - 2 * 60);
  });

  test('finish before zero is explicit, not forced', () {
    final t = ChunkTimer(10);
    t.start();
    t.finish(); // user chose to stop (planned pause, I1)
    expect(t.state, ChunkTimerState.done);
  });
}
```

- [ ] **Step 2: Run to verify fail**

Expected: FAIL.

- [ ] **Step 3: Write chunk_timer.dart**

```dart
enum ChunkTimerState { idle, running, paused, done }

class ChunkTimer {
  final int chunkMinutes;
  int _elapsed = 0;
  int _pausedElapsed = 0;
  DateTime? startedAt;
  ChunkTimerState state = ChunkTimerState.idle;
  ChunkTimer(this.chunkMinutes);

  int get remainingSeconds => (chunkMinutes * 60) - _elapsed;
  int get elapsedSeconds => _elapsed;
  int get chunkSeconds => chunkMinutes * 60;

  void start() {
    if (state != ChunkTimerState.idle) return;
    startedAt = DateTime.now();
    state = ChunkTimerState.running;
  }
  void pause() {
    if (state != ChunkTimerState.running) return;
    _pausedElapsed = _elapsed;
    state = ChunkTimerState.paused;
  }
  void resume() {
    if (state != ChunkTimerState.paused) return;
    state = ChunkTimerState.running;
  }
  void tick(int seconds) {
    if (state != ChunkTimerState.running) return;
    _elapsed = (_elapsed + seconds).clamp(0, chunkSeconds);
    if (_elapsed >= chunkSeconds) state = ChunkTimerState.done;
  }
  void finish() {
    if (state == ChunkTimerState.done) return;
    state = ChunkTimerState.done;
  }
}
```

- [ ] **Step 4: Recovery + widget tests**

`app/test/timer_screen_widget_test.dart`:
```dart
// pump TimerScreen(controller) with temp DB; assert:
// 1. start button → running state visible
// 2. park list: enter urge text, tap 'Park it' → appears in list
// 3. finish → TimerLog row exists in DB (query db.timerLog directly)
```

- [ ] **Step 5: Write timer_controller + screen**

`app/lib/timer/timer_controller.dart`: `saveLog(...)` inserts TimerLog with startedAt/endedAt/updatedAt; `recoverLast()`: query latest TimerLog with `endedAt == null` → reconstruct ChunkTimer(chunkMinutes=minutes, startedAt, state=running, elapsed computed from now - startedAt) — crash recovery (G2).

`app/lib/screens/timer_screen.dart`: chunk presets (ChoiceChips), big remaining time, Start/Pause/Resume/Finish, "park list" (active ignoring — I1: framed as parking, never "you got distracted"): TextField + add → list; Finish → `controller.saveLog` + sync marker.

- [ ] **Step 6: Run to verify pass**

Expected: all timer tests pass.

- [ ] **Step 7: Commit**

```bash
git add app/lib/timer app/lib/screens/timer_screen.dart app/test/chunk_timer_test.dart app/test/timer_screen_widget_test.dart
git commit -m "feat(app): distractibility timer — chunk/delay/park, crash-safe recovery"
```

---

### Task M3-6: Problem-Solving wizard (6-step)

**Files:**
- Create: `app/lib/forms/problem_solving_wizard.dart`
- Create: `app/test/problem_solving_wizard_test.dart`

**Interfaces:**
- Consumes: `FormController` (M3-3) — the `problem-solving` form has 6 fields: problem, solutions, pros, cons, action_plan, review.
- Produces: `ProblemSolvingWizard(form)` — 6-step Stepper (one field per step, I1: linear, no skip pressure), step labels from spec Ch6 (Define, Brainstorm, Pros/cons, Choose, Plan, Review), final submit → answers map. Reuses FormController validation + draft autosave.

- [ ] **Step 1: Write failing widget test**

`app/test/problem_solving_wizard_test.dart`:
```dart
// pump ProblemSolvingWizard with a 6-field problem-solving FormDefinition;
// assert: step 1 visible, next disabled until field filled (or optional);
// walk through all 6 steps via 'Next'; final 'Finish' collects 6 answers.
```

- [ ] **Step 2: Run to verify fail** → FAIL.
- [ ] **Step 3: Write wizard** (Stepper with 6 steps mapping to form fields in order; Next/Back; Finish → onSubmit(answers)).
- [ ] **Step 4: Run to verify pass** → PASS.
- [ ] **Step 5: Commit** → `git add app/lib/forms/problem_solving_wizard.dart app/test/problem_solving_wizard_test.dart` + commit "feat(app): 6-step problem-solving wizard".

---

### Task M3-7: Navigation assembly (main → engine → routes)

**Files:**
- Modify: `app/lib/main.dart` (async bootstrap)
- Modify: `app/lib/routes.dart` (session route with args, taskList, timer routes)
- Modify: `app/lib/screens/home_screen.dart` (session list from engine)
- Modify: `app/lib/engine/program_engine.dart` (Drift-backed ProgressStore adapter)
- Create: `app/lib/store/drift_progress_store.dart`
- Create: `app/test/bootstrap_test.dart`

**Interfaces:**
- Consumes: ContentActivator (M2-5), ContentRuntime (M2-4), ProgramEngine (M2-3), AppDatabase (M3-1).
- Produces: `DriftProgressStore implements ProgressStore` (checkpoint_states table); `Future<ProgramEngine> bootstrapEngine(AppDatabase, Directory contentDir)` (load sessions from content runtime → engine → restore from Drift store); main(): docs dir → ContentActivator.activate(assetsContentDir, docsContentDir) (first-run extract) → AppDatabase.open → engine → `MultiProvider` (engine, db, taskController, apiClient) → home; routes: `/session` (args Session), `/tasks`, `/timer`, `/problem-solving`. Home: session cards (title, state badge — completed/in-progress/available with I1 colors), tap → SessionScreen; SessionScreen onProgress → engine.persist via DriftProgressStore.

- [ ] **Step 1: Write failing bootstrap test**

`app/test/bootstrap_test.dart`:
```dart
// create temp content dir with a 2-session bundle (manifest + sessions)
// -> bootstrapEngine(contentDir, db) returns engine with 2 sessions,
//    currentCheckpoint = s1c0; complete + persist -> reopen -> restored.
```

- [ ] **Step 2: Run to verify fail** → FAIL.
- [ ] **Step 3: Write drift_progress_store + bootstrap**

```dart
class DriftProgressStore implements ProgressStore {
  final AppDatabase db;
  DriftProgressStore(this.db);
  @override
  Future<Map<String, String>> load() async {
    final rows = await db.select(db.checkpointStates).get();
    return {for (final r in rows) r.checkpointId: r.state};
  }
  @override
  Future<void> save(Map<String, String> states) async {
    await db.transaction(() async {
      for (final e in states.entries) {
        await db.into(db.checkpointStates).insertOnConflictUpdate(
            CheckpointStatesCompanion.insert(
                checkpointId: e.key, state: e.value,
                updatedAt: DateTime.now().toUtc().toIso8601String()));
      }
    });
  }
}
```

- [ ] **Step 4: Wire main.dart (guarded bootstrap)**

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final app = await _boot();
  runApp(AdhdCbtApp(bootstrap: app));
}
```
`_boot()`: try { docs dir; activate assets content → docs; db open; engine; store restore } catch { return null } — null → plain onboarding (tests unaffected; real device failure → onboarding still runs, engine rebuilt next launch).

- [ ] **Step 5: Update home screen + routes**

Home: `Consumer<ProgramEngine>` session cards → Navigator.pushNamed('/session', arguments: session). SessionScreen onProgress wiring. Routes: session/tasks/timer/problem-solving with argument passing.

- [ ] **Step 6: Run to verify pass** — all green.
- [ ] **Step 7: Commit**

```bash
git add app/
git commit -m "feat(app): M3 assembly — drift progress store, engine bootstrap, routes"
```

---

### Task M3-8: Full suite + tag

**Files:** none new.

- [ ] **Step 1: Full suite**

```bash
cd app && rm -rf build/unit_test_assets
C:/Users/eltun/flutter/bin/flutter.bat test --no-pub
grep -r "package:flutter" lib/forms lib/engine lib/content lib/timer lib/tasks lib/store || echo "G1 OK"
C:/Users/eltun/flutter/bin/flutter.bat analyze --no-pub | tail -2
```
Expected: all tests pass; G1 OK; analyze clean.

- [ ] **Step 2: Commit + tag**

```bash
git add app/
git commit -m "feat(app): M3 complete — forms, tasks, timer, problem-solving, drift"
git tag v0.1.0-m3
```

---

## Self-Review

1. **Spec coverage:**
   - §4.2 Forms Engine schema-driven → M3-2/M3-3 ✓ (kinds enum, unknown rejected, draft autosave)
   - §4.3 Calendar+TaskList A/B/C + breakdown → M3-4 ✓
   - §4.4 Timer chunk/delay/park + environment checklist (checklist = park list UI) → M3-5 ✓
   - §4.5 Problem-Solving 6-step → M3-6 ✓
   - §3 Drift local store → M3-1 ✓ (deferred from M2, documented)
   - §6.4 timer persist every transition + notification-independent → M3-5 (persist; notification fallback = M5 push)
   - §8 Forms acceptance (invalid schema/unknown field → M3-2 FormatException; migration/schema_version → M3-1; persisted draft restore → M3-3 draftStore) ✓
   - §8 Timer acceptance (fg→bg→fg = state machine pause/resume; process kill → recoverLast; notification denied → N/A until M5) ✓
   - §7.1 local-first: engine/tasks/timer all work offline ✓
   - M2 deferrals closed: Drift (M3-1), engine→main assembly + routes (M3-7) ✓
2. **Placeholder scan:** no TBD; the NOTE blocks give exact replacement code (explicit kind-map, manual firstOrNull, if/else chains). Timer persistence details concrete.
3. **Type consistency:** `ProgressStore` interface shared by FileProgressStore (M2, kept for tests) + DriftProgressStore (M3-7); `ChunkTimer` states match tests; `FormController.setValue` returns bool used identically in renderer + tests; Drift companion names match generated code (`.insertOnConflictUpdate`).

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-08-15-m3-forms-tools.md`. Two execution options:

1. **Subagent-Driven (recommended)** — fresh subagent per task, review between tasks; route via `coder` role per constitution; durable progress on the native Kanban board (board `adhd-cbt-app`).
2. **Inline Execution** — execute in this session, batch with checkpoints.

Given provider instability, **inline execution is the reliable path** (M1/M2 precedent). Drift codegen (`build_runner`) is the main risk — it runs locally, no provider dependency.
