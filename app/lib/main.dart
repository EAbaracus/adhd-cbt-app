import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'content/asset_bootstrap.dart';
import 'engine/program_engine.dart';
import 'routes.dart';
import 'store/app_database.dart';
import 'store/bootstrap.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ProgramEngine? engine;
  AppDatabase? db;
  try {
    final contentDir = await bootstrapContentFromAssets();
    if (contentDir != null) {
      db = AppDatabase.open(
          '${contentDir.parent.path}/app.db');
      engine = await bootstrapEngine(db, contentDir);
    }
  } catch (_) {
    engine = null;
  }
  runApp(AdhdCbtApp(engine: engine, db: db));
}

class AdhdCbtApp extends StatelessWidget {
  final ProgramEngine? engine;
  final AppDatabase? db;
  const AdhdCbtApp({super.key, this.engine, this.db});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      engine: engine,
      db: db,
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
