import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/store/app_database.dart';
import 'package:adhd_cbt_app/tasks/task_controller.dart';

void main() {
  test('add/list/toggle/delete lifecycle', () async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('t_').path}/t.db');
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
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('t2_').path}/t.db');
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
