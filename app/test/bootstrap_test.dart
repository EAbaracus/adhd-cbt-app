import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/content/content_runtime.dart';
import 'package:adhd_cbt_app/store/app_database.dart';
import 'package:adhd_cbt_app/store/bootstrap.dart';
import 'package:adhd_cbt_app/store/drift_progress_store.dart';

Directory _contentBundle(Directory root) {
  final dir = Directory('${root.path}/content')..createSync(recursive: true);
  final sessions = Directory('${dir.path}/sessions')..createSync();
  final s1 = {
    'id': 's1', 'order': 1, 'module': 'psychoeducation', 'title': {'en': 'S1'},
    'checkpoints': [
      {'id': 's1c0', 'type': 'reading', 'title': {'en': 't'}, 'content': {'en': ['x']}},
      {'id': 's1c1', 'type': 'reading', 'title': {'en': 't'}, 'content': {'en': ['x']}},
    ],
  };
  final s2 = {
    'id': 's2', 'order': 2, 'module': 'organization_planning', 'title': {'en': 'S2'},
    'checkpoints': [
      {'id': 's2c0', 'type': 'reading', 'title': {'en': 't'}, 'content': {'en': ['x']}},
    ],
  };
  sessions.createSync(recursive: true);
  File('${sessions.path}/01.json').writeAsStringSync(jsonEncode(s1));
  File('${sessions.path}/02.json').writeAsStringSync(jsonEncode(s2));
  final files = [
    '{"path":"sessions/01.json","sha256":"${'X' * 64}"}',
    '{"path":"sessions/02.json","sha256":"${'Y' * 64}"}',
  ];
  File('${dir.path}/manifest.json').writeAsStringSync(
      '{"schema_version":"1.0.0","content_version":"0.1.0","files":[$files]}');
  return dir;
}

void main() {
  test('bootstrap builds engine with 2 sessions and restores progress', () async {
    final root = Directory.systemTemp.createTempSync('boot_');
    final contentDir = _contentBundle(root);
    // fix hashes: rehash real files
    final m = File('${contentDir.path}/manifest.json');
    m.writeAsStringSync(
        '{"schema_version":"1.0.0","content_version":"0.1.0","files":['
        '{"path":"sessions/01.json","sha256":"${ContentRuntime.sha256Hex(File('${contentDir.path}/sessions/01.json').readAsStringSync())}"},'
        '{"path":"sessions/02.json","sha256":"${ContentRuntime.sha256Hex(File('${contentDir.path}/sessions/02.json').readAsStringSync())}"}]}');
    final db = AppDatabase.open('${root.path}/app.db');
    final engine = await bootstrapEngine(db, contentDir);
    expect(engine, isNotNull);
    expect(engine!.sessions.length, 2);
    expect(engine.currentSession!.id, 's1');
    expect(engine.currentCheckpoint!.id, 's1c0');
    // persist + reopen
    engine.complete('s1c0');
    await engine.persist(DriftProgressStore(db));
    final engine2 = await bootstrapEngine(db, contentDir);
    expect(engine2!.currentCheckpoint!.id, 's1c1');
    await db.close();
  });

  test('corrupt content dir -> null (no crash)', () async {
    final root = Directory.systemTemp.createTempSync('boot2_');
    final contentDir = Directory('${root.path}/content')..createSync();
    final db = AppDatabase.open('${root.path}/app.db');
    final engine = await bootstrapEngine(db, contentDir);
    expect(engine, isNull);
    await db.close();
  });
}
