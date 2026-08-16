import 'dart:async';

import 'package:flutter/material.dart';

import 'api/api_client.dart';
import 'app_scope.dart';
import 'content/asset_bootstrap.dart';
import 'content/content_runtime.dart';
import 'engine/models.dart';
import 'engine/program_engine.dart';
import 'forms/form_definition.dart';
import 'l10n/app_locale.dart';
import 'routes.dart';
import 'store/app_database.dart';
import 'store/bootstrap.dart';
import 'store/session_manager.dart';
import 'theme/app_theme.dart';

/// Result of the background content/db bootstrap. `null` members mean the
/// bootstrapped resource is not available (local-first: the app shell still
/// renders — onboarding works without an engine; home upgrades in place).
class BootState {
  final ProgramEngine? engine;
  final AppDatabase? db;
  final Map<String, FormDefinition>? forms;
  final List<SourceInfo>? sources;
  final Map<String, SourceInfo>? sourceLookup;
  final ContentRuntime? contentRuntime;
  final ApiClient? api;
  final SessionManager? sessionManager;
  final AppLocaleCode locale;

  const BootState({
    this.engine,
    this.db,
    this.forms,
    this.sources,
    this.sourceLookup,
    this.contentRuntime,
    this.api,
    this.sessionManager,
    this.locale = AppLocaleCode.en,
  });

  static const empty = BootState();
}

Future<BootState> _bootstrap() async {
  final contentDir = await bootstrapContentFromAssets();
  if (contentDir == null) return const BootState();
  final runtime = ContentRuntime(contentDir);
  final db = AppDatabase.open('${contentDir.parent.path}/app.db');
  final engine = await bootstrapEngine(db, contentDir);
  final forms = {
    for (final f in runtime.loadForms()) f.id: f,
  };
  final allSources = runtime.loadSources();
  final sourceLookup = {
    for (final s in allSources) s.id: s,
  };
  final api = ApiClient();
  final sessionManager = SessionManager(db: db, api: api);
  await sessionManager.restoreToken();
  final locale = await AppLocale.load(db);
  return BootState(
      engine: engine,
      db: db,
      forms: forms,
      sources: allSources,
      sourceLookup: sourceLookup,
      contentRuntime: runtime,
      api: api,
      sessionManager: sessionManager,
      locale: locale);
}

/// First frame renders IMMEDIATELY (onboarding needs no engine); the heavy
/// content/db bootstrap runs in the background and upgrades the scope in
/// place when ready. No white screen on cold start.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final boot = ValueNotifier<BootState>(const BootState());
  unawaited(() async {
    try {
      boot.value = await _bootstrap();
    } catch (_) {
      boot.value = const BootState();
    }
  }());
  runApp(AdhdCbtApp(boot: boot));
}

class AdhdCbtApp extends StatelessWidget {
  final ValueNotifier<BootState> boot;
  AdhdCbtApp({super.key, ValueNotifier<BootState>? boot})
      : boot = boot ?? ValueNotifier(const BootState());

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<BootState>(
      valueListenable: boot,
      builder: (context, state, _) {
        final localeNotifier = ValueNotifier<AppLocaleCode>(state.locale);
        return ValueListenableBuilder<AppLocaleCode>(
          valueListenable: localeNotifier,
          builder: (context, code, _) => AppLocale(
            code: code,
            db: state.db,
            onChanged: (c) => localeNotifier.value = c,
            child: AppScope(
              engine: state.engine,
              db: state.db,
              forms: state.forms,
              sources: state.sources,
              sourceLookup: state.sourceLookup,
              contentRuntime: state.contentRuntime,
              api: state.api,
              sessionManager: state.sessionManager,
              child: MaterialApp(
                title: 'ADHD CBT',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                onGenerateRoute: RouteGenerator.generateRoute,
                initialRoute: RouteGenerator.onboarding,
              ),
            ),
          ),
        );
      },
    );
  }
}
