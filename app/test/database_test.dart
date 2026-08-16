import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/store/app_database.dart';

void main() {
  test('schema v1 creates all tables', () async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('db_').path}/app.db');
    final tables = db.allTables;
    expect(
        tables.map((t) => t.actualTableName),
        containsAll([
          'user_settings',
          'checkpoint_states',
          'tasks',
          'task_steps',
          'form_drafts',
          'timer_log'
        ]));
    await db.close();
  });

  test('migration v1 -> v2 preserves data', () async {
    final dir = Directory.systemTemp.createTempSync('mig_');
    final db1 = AppDatabase.open('${dir.path}/app.db', schemaVersion: 1);
    await db1.into(db1.userSettings).insert(
        UserSettingsCompanion.insert(key: 'a', value: 'b'));
    await db1.close();
    final db2 = AppDatabase.open('${dir.path}/app.db', schemaVersion: 2);
    final rows = await db2.select(db2.userSettings).get();
    expect(rows.single.value, 'b');
    await db2.close();
  });

  test('checkpoint states roundtrip', () async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('db2_').path}/app.db');
    await db.into(db.checkpointStates).insert(CheckpointStatesCompanion.insert(
        checkpointId: 's1c0', state: 'completed', updatedAt: 't'));
    final rows = await db.select(db.checkpointStates).get();
    expect(rows.single.state, 'completed');
    await db.close();
  });
}
