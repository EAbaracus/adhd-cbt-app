import 'package:flutter/widgets.dart';

import 'api/api_client.dart';
import 'engine/program_engine.dart';
import 'forms/form_definition.dart';
import 'store/app_database.dart';
import 'store/session_manager.dart';

/// App-wide scope: bootstrapped engine/db/forms + shared ApiClient and
/// SessionManager (all nullable — bootstrap failure degrades to onboarding).
class AppScope extends InheritedWidget {
  final ProgramEngine? engine;
  final AppDatabase? db;
  final Map<String, FormDefinition>? forms;
  final ApiClient? api;
  final SessionManager? sessionManager;
  const AppScope(
      {super.key,
      required this.engine,
      required this.db,
      required this.forms,
      required this.api,
      required this.sessionManager,
      required super.child});

  static AppScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>();

  @override
  bool updateShouldNotify(AppScope old) =>
      engine != old.engine ||
      db != old.db ||
      forms != old.forms ||
      api != old.api ||
      sessionManager != old.sessionManager;
}
