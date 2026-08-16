import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  UserSettings,
  CheckpointStates,
  Tasks,
  TaskSteps,
  FormDrafts,
  TimerLog,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.open(String path, {int schemaVersion = 1})
      : super(NativeDatabase(File(path), setup: (db) {
          db.execute('PRAGMA foreign_keys = ON');
        })) {
    _schemaVersion = schemaVersion;
  }

  int _schemaVersion = 1;
  @override
  int get schemaVersion => _schemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // v1 -> v2: additive migration fixture (no-op keeps data).
          // Any future destructive step must be its own tested migration.
        },
      );
}
