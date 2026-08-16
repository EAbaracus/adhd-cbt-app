import 'dart:math';

import 'package:drift/drift.dart';

import '../store/app_database.dart';

/// §9 M5 retention instrumentation: append-only local events, ISO-UTC
/// timestamps, weekly buckets for the retention metric.
class RetentionService {
  final AppDatabase db;
  final Random _rng = Random();
  RetentionService(this.db);

  Future<void> record(String event) async {
    final now = DateTime.now().toUtc();
    await db.into(db.retentionEvents).insert(RetentionEventsCompanion.insert(
          id: 'ev-${now.microsecondsSinceEpoch}-${_rng.nextInt(1 << 16)}',
          event: event,
          at: now.toIso8601String(),
        ));
  }

  Future<int> count(String event, {DateTime? since}) async {
    final q = db.select(db.retentionEvents)
      ..where((e) => e.event.equals(event));
    if (since != null) {
      q.where((e) => e.at.isBiggerOrEqualValue(since.toUtc().toIso8601String()));
    }
    return q.get().then((rows) => rows.length);
  }

  /// [weeks] buckets: key = ISO week "YYYY-Www" (UTC), value = count.
  Future<Map<String, int>> weeklyCounts(String event, int weeks) async {
    final since = DateTime.now()
        .toUtc()
        .subtract(Duration(days: 7 * weeks));
    final rows = await (db.select(db.retentionEvents)
          ..where((e) =>
              e.event.equals(event) &
              e.at.isBiggerOrEqualValue(since.toUtc().toIso8601String())))
        .get();
    final out = <String, int>{};
    for (final r in rows) {
      final dt = DateTime.tryParse(r.at);
      if (dt == null) continue;
      final week = _isoWeek(dt);
      out[week] = (out[week] ?? 0) + 1;
    }
    return out;
  }

  static String _isoWeek(DateTime dt) {
    // ISO week number (UTC)
    final d = DateTime.utc(dt.year, dt.month, dt.day);
    final thursday = d.add(Duration(days: 3 - ((d.weekday + 6) % 7)));
    final jan1 = DateTime.utc(thursday.year, 1, 1);
    final week = ((thursday.difference(jan1).inDays + jan1.weekday + 6) ~/ 7)
        .clamp(1, 53);
    return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
  }
}
