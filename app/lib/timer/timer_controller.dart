import 'dart:math';

import 'package:drift/drift.dart';

import '../store/app_database.dart';
import 'chunk_timer.dart';

class TimerController {
  final AppDatabase db;
  final Random _rng = Random();
  TimerController(this.db);

  Future<void> saveLog(ChunkTimer timer, {int distractions = 0, String task = ''}) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await db.into(db.timerLog).insert(TimerLogCompanion.insert(
          id: 'log-${_rng.nextInt(1 << 32).toRadixString(16)}',
          task: task,
          minutes: timer.chunkMinutes,
          distractions: Value(distractions),
          startedAt: timer.startedAt?.toUtc().toIso8601String() ?? now,
          endedAt: Value<String?>(now),
          updatedAt: now,
        ));
  }

  /// Crash recovery (spec §6.4): last in-progress timer, reconstructed.
  Future<ChunkTimer?> recoverLast() async {
    final rows = await (db.select(db.timerLog)
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(1))
        .get();
    if (rows.isEmpty) return null;
    final r = rows.first;
    if (r.endedAt != null) return null;
    final t = ChunkTimer(r.minutes);
    t.state = ChunkTimerState.running;
    t.startedAt = DateTime.tryParse(r.startedAt) ?? DateTime.now();
    final elapsed = DateTime.now().difference(t.startedAt!).inSeconds;
    t.tick(elapsed.clamp(0, t.chunkSeconds));
    return t;
  }
}
