import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/retention/retention_service.dart';
import 'package:adhd_cbt_app/store/app_database.dart';

void main() {
  test('record + count', () async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('rt_').path}/r.db');
    final svc = RetentionService(db);
    await svc.record('session_completed');
    await svc.record('session_completed');
    await svc.record('timer_finished');
    expect(await svc.count('session_completed'), 2);
    expect(await svc.count('timer_finished'), 1);
    expect(await svc.count('checkpoint_completed'), 0);
    await db.close();
  });

  test('weeklyCounts buckets across ISO weeks', () async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('rt2_').path}/r.db');
    final svc = RetentionService(db);
    // two events now (current week), one event 10 days ago (previous week)
    await svc.record('session_completed');
    await svc.record('session_completed');
    final past = DateTime.now()
        .toUtc()
        .subtract(const Duration(days: 10));
    await db.into(db.retentionEvents).insert(RetentionEventsCompanion.insert(
          id: 'ev-past',
          event: 'session_completed',
          at: past.toIso8601String(),
        ));
    final counts = await svc.weeklyCounts('session_completed', 3);
    expect(counts.values.reduce((a, b) => a + b), 3);
    expect(counts.length, greaterThanOrEqualTo(2)); // ≥2 distinct weeks
    await db.close();
  });

  test('count respects since filter', () async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('rt3_').path}/r.db');
    final svc = RetentionService(db);
    await svc.record('timer_finished');
    expect(await svc.count('timer_finished',
        since: DateTime.now().add(const Duration(days: 1))), 0);
    await db.close();
  });
}
