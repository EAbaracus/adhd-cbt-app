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
  FormSubmissions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.open(String path, {int schemaVersion = 2})
      : super(NativeDatabase(File(path), setup: (db) {
          db.execute('PRAGMA foreign_keys = ON');
        })) {
    _schemaVersion = schemaVersion;
  }

  int _schemaVersion = 2;
  @override
  int get schemaVersion => _schemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(formSubmissions);
          }
        },
      );
}
