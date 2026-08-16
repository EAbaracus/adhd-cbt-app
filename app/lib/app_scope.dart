import 'package:flutter/widgets.dart';

import 'engine/program_engine.dart';
import 'store/app_database.dart';

/// App-wide scope: the bootstrapped engine + database (nullable when the
/// bootstrap failed — onboarding still runs, engine rebuilt next launch).
class AppScope extends InheritedWidget {
  final ProgramEngine? engine;
  final AppDatabase? db;
  const AppScope({super.key, required this.engine, required this.db, required super.child});

  static AppScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>();

  @override
  bool updateShouldNotify(AppScope old) =>
      engine != old.engine || db != old.db;
}
