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
  TextColumn get endedAt => text().nullable()();
  TextColumn get updatedAt => text()();
  @override
  Set<Column> get primaryKey => {id};
}
