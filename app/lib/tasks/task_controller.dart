import 'dart:math';

import 'package:drift/drift.dart';

import '../store/app_database.dart';

class TaskStep {
  final String id;
  final String title;
  final bool done;
  TaskStep({required this.id, required this.title, required this.done});
}

class Task {
  final String id;
  final String title;
  final String priority; // A | B | C
  final bool done;
  final List<TaskStep> steps;
  Task({required this.id, required this.title, required this.priority,
      required this.done, this.steps = const []});
}

const _priorityOrder = {'A': 0, 'B': 1, 'C': 2};

class TaskController {
  final AppDatabase db;
  final Random _rng = Random();

  TaskController(this.db);

  String _newId() => 'task-${_rng.nextInt(1 << 32).toRadixString(16)}';

  Future<List<Task>> list() async {
    final tasks = await (db.select(db.tasks)
          ..orderBy([
            (t) => OrderingTerm.asc(t.priority),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .get();
    final steps = await (db.select(db.taskSteps)
          ..orderBy([(s) => OrderingTerm.asc(s.position)]))
        .get();
    final byTask = <String, List<TaskStep>>{};
    for (final s in steps) {
      byTask.putIfAbsent(s.taskId, () => []).add(TaskStep(
          id: s.id, title: s.title, done: s.done));
    }
    final out = [
      for (final t in tasks)
        Task(
            id: t.id,
            title: t.title,
            priority: t.priority,
            done: t.done,
            steps: byTask[t.id] ?? []),
    ];
    // A/B/C, then not-done first within priority
    out.sort((a, b) {
      final pa = _priorityOrder[a.priority] ?? 9;
      final pb = _priorityOrder[b.priority] ?? 9;
      if (pa != pb) return pa.compareTo(pb);
      if (a.done != b.done) return a.done ? 1 : -1;
      return 0;
    });
    return out;
  }

  Future<void> add(String title, String priority) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await db.into(db.tasks).insert(TasksCompanion.insert(
        id: _newId(), title: title, priority: priority,
        createdAt: now, updatedAt: now));
  }

  Future<void> addStep(String taskId, String stepTitle) async {
    final existing = await (db.select(db.taskSteps)
          ..where((s) => s.taskId.equals(taskId)))
        .get();
    await db.into(db.taskSteps).insert(TaskStepsCompanion.insert(
        id: _newId(),
        taskId: taskId,
        title: stepTitle,
        position: existing.length));
  }

  Future<void> toggleDone(String taskId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final row = await (db.select(db.tasks)
          ..where((t) => t.id.equals(taskId)))
        .getSingleOrNull();
    if (row == null) return;
    await (db.update(db.tasks)..where((t) => t.id.equals(taskId)))
        .write(TasksCompanion(
            done: Value(!row.done), updatedAt: Value(now)));
  }

  Future<void> toggleStep(String stepId) async {
    final row = await (db.select(db.taskSteps)
          ..where((s) => s.id.equals(stepId)))
        .getSingleOrNull();
    if (row == null) return;
    await (db.update(db.taskSteps)..where((s) => s.id.equals(stepId)))
        .write(TaskStepsCompanion(done: Value(!row.done)));
  }

  Future<void> delete(String taskId) async {
    await (db.delete(db.taskSteps)..where((s) => s.taskId.equals(taskId))).go();
    await (db.delete(db.tasks)..where((t) => t.id.equals(taskId))).go();
  }
}
