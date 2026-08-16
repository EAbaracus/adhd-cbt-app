import 'package:flutter/widgets.dart';

import 'api/api_client.dart';
import 'content/content_runtime.dart';
import 'engine/models.dart';
import 'engine/program_engine.dart';
import 'forms/form_definition.dart';
import 'store/app_database.dart';
import 'store/session_manager.dart';

/// App-wide scope: bootstrapped engine/db/forms/sources + shared ApiClient
/// and SessionManager (all nullable — bootstrap failure degrades to onboarding).
class AppScope extends InheritedWidget {
  final ProgramEngine? engine;
  final AppDatabase? db;
  final Map<String, FormDefinition>? forms;
  final List<SourceInfo>? sources;
  final Map<String, SourceInfo>? sourceLookup;
  final ContentRuntime? contentRuntime;
  final ApiClient? api;
  final SessionManager? sessionManager;
  const AppScope(
      {super.key,
      this.engine,
      this.db,
      this.forms,
      this.sources,
      this.sourceLookup,
      this.contentRuntime,
      this.api,
      this.sessionManager,
      required super.child});

  static AppScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>();

  SourceInfo? lookupSource(String id) {
    if (sourceLookup != null) return sourceLookup![id];
    if (sources != null) {
      for (final s in sources!) {
        if (s.id == id) return s;
      }
    }
    if (contentRuntime != null) return contentRuntime!.lookupSource(id);
    return null;
  }

  @override
  bool updateShouldNotify(AppScope old) =>
      engine != old.engine ||
      db != old.db ||
      forms != old.forms ||
      sources != old.sources ||
      sourceLookup != old.sourceLookup ||
      contentRuntime != old.contentRuntime ||
      api != old.api ||
      sessionManager != old.sessionManager;
}
