import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'content/asset_bootstrap.dart';
import 'content/content_runtime.dart';
import 'engine/program_engine.dart';
import 'forms/form_definition.dart';
import 'routes.dart';
import 'store/app_database.dart';
import 'store/bootstrap.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ProgramEngine? engine;
  AppDatabase? db;
  Map<String, FormDefinition>? forms;
  try {
    final contentDir = await bootstrapContentFromAssets();
    if (contentDir != null) {
      db = AppDatabase.open('${contentDir.parent.path}/app.db');
      engine = await bootstrapEngine(db, contentDir);
      forms = {
        for (final f in ContentRuntime(contentDir).loadForms()) f.id: f,
      };
    }
  } catch (_) {
    engine = null;
  }
  runApp(AdhdCbtApp(engine: engine, db: db, forms: forms));
}

class AdhdCbtApp extends StatelessWidget {
  final ProgramEngine? engine;
  final AppDatabase? db;
  final Map<String, FormDefinition>? forms;
  const AdhdCbtApp({super.key, this.engine, this.db, this.forms});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      engine: engine,
      db: db,
      forms: forms,
      child: MaterialApp(
        title: 'ADHD CBT',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        onGenerateRoute: RouteGenerator.generateRoute,
        initialRoute: RouteGenerator.onboarding,
      ),
    );
  }
}
