import 'progress_store.dart';
import 'app_database.dart';

/// Drift-backed ProgressStore (replaces the M2 JSON file impl in production;
/// the file impl stays for lightweight tests).
class DriftProgressStore implements ProgressStore {
  final AppDatabase db;
  DriftProgressStore(this.db);

  @override
  Future<Map<String, String>> load() async {
    final rows = await db.select(db.checkpointStates).get();
    return {for (final r in rows) r.checkpointId: r.state};
  }

  @override
  Future<void> save(Map<String, String> states) async {
    await db.transaction(() async {
      for (final e in states.entries) {
        await db.into(db.checkpointStates).insertOnConflictUpdate(
            CheckpointStatesCompanion.insert(
                checkpointId: e.key,
                state: e.value,
                updatedAt: DateTime.now().toUtc().toIso8601String()));
      }
    });
  }
}
