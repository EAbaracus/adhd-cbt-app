import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/engine/models.dart';
import 'package:adhd_cbt_app/engine/program_engine.dart';
import 'package:adhd_cbt_app/store/file_progress_store.dart';

Session _mkSession() {
  final cps = <Checkpoint>[
    for (var i = 0; i < 3; i++)
      Checkpoint(
          id: 's1c$i',
          type: CheckpointType.reading,
          title: 't',
          content: const ['x']),
  ];
  return Session(
      id: 's1', order: 1, module: 'psychoeducation', title: 'S', checkpoints: cps);
}

void main() {
  test('roundtrips states', () async {
    final f = File('${Directory.systemTemp.createTempSync('ps_').path}/progress.json');
    final store = FileProgressStore(f, deviceId: 'dev-1');
    await store.save({'s1c0': 'completed'});
    final loaded = await store.load();
    expect(loaded['s1c0'], 'completed');
  });

  test('missing file loads empty', () async {
    final store = FileProgressStore(
        File('${Directory.systemTemp.createTempSync('ps2_').path}/nope.json'),
        deviceId: 'dev-1');
    expect(await store.load(), isEmpty);
  });

  test('envelope carries sync fields', () async {
    final f = File('${Directory.systemTemp.createTempSync('ps3_').path}/progress.json');
    final store = FileProgressStore(f, deviceId: 'dev-1');
    await store.save({'a': 'completed'});
    final raw = f.readAsStringSync();
    expect(raw, contains('device_id'));
    expect(raw, contains('schema_version'));
  });

  test('engine restore + persist roundtrip', () async {
    final store = FileProgressStore(
        File('${Directory.systemTemp.createTempSync('ps4_').path}/p.json'),
        deviceId: 'dev-1');
    final e = ProgramEngine([_mkSession()]);
    e.complete('s1c0');
    await e.persist(store);
    final e2 = ProgramEngine([_mkSession()]);
    await e2.restore(store);
    expect(e2.currentCheckpoint!.id, 's1c1');
  });
}
