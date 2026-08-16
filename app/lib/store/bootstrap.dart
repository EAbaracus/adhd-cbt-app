import 'dart:convert';
import 'dart:io';

import '../content/content_runtime.dart';
import '../engine/models.dart';
import '../engine/program_engine.dart';
import 'app_database.dart';
import 'drift_progress_store.dart';

/// Bootstraps the ProgramEngine from a validated content directory + Drift.
/// Returns null on any failure (app falls back to plain onboarding).
Future<ProgramEngine?> bootstrapEngine(
    AppDatabase db, Directory contentDir) async {
  final runtime = ContentRuntime(contentDir);
  if (!runtime.verifyIntegrity()) return null;
  final sessions = <Session>[];
  final dir = Directory('${contentDir.path}/sessions');
  if (!dir.existsSync()) return null;
  for (final f in dir.listSync().whereType<File>().toList()
    ..sort((a, b) => a.path.compareTo(b.path))) {
    sessions.add(Session.fromJson(
        jsonDecode(f.readAsStringSync()) as Map<String, dynamic>));
  }
  if (sessions.isEmpty) return null;
  final engine = ProgramEngine(sessions);
  await engine.restore(DriftProgressStore(db));
  return engine;
}
