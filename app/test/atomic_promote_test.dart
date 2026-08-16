import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/content/atomic_promote.dart';
import 'package:adhd_cbt_app/content/content_runtime.dart';

Directory _bundle({bool tamper = false, bool missing = false}) {
  final root = Directory.systemTemp.createTempSync('promote_test_');
  final dir = Directory('${root.path}/src')..createSync(recursive: true);
  File('${dir.path}/manifest.json').writeAsStringSync(
      '{"schema_version":"1.0.0","content_version":"0.2.0","files":['
      '{"path":"sessions/01.json","sha256":"${ContentRuntime.sha256Hex('{}')}"}]}');
  Directory('${dir.path}/sessions').createSync();
  File('${dir.path}/sessions/01.json').writeAsStringSync(tamper ? '{"x":1}' : '{}');
  if (missing) File('${dir.path}/sessions/01.json').deleteSync();
  return dir;
}

Directory _activeOld() {
  final root = Directory.systemTemp.createTempSync('active_test_');
  final active = Directory('${root.path}/active')..createSync();
  File('${active.path}/manifest.json')
      .writeAsStringSync('{"schema_version":"1.0.0","content_version":"0.1.0","files":[]}');
  return active;
}

void main() {
  test('promote swaps active dir', () async {
    final src = _bundle();
    final active = _activeOld();
    await ContentActivator.activate(src, active);
    final rt = ContentRuntime(active);
    expect(rt.loadManifest()!.contentVersion, '0.2.0');
  });

  test('activation failure (bad hash) leaves active unchanged', () async {
    final src = _bundle(tamper: true);
    final active = _activeOld();
    await expectLater(ContentActivator.activate(src, active), throwsStateError);
    final rt = ContentRuntime(active);
    expect(rt.loadManifest()!.contentVersion, '0.1.0'); // previous active intact
    final root = active.parent;
    expect(Directory('${root.path}/active.tmp').existsSync(), isFalse); // temp cleaned
  });

  test('corrupt manifest rejected, active unchanged', () async {
    final root = Directory.systemTemp.createTempSync('corrupt_test_');
    final src = Directory('${root.path}/src')..createSync();
    File('${src.path}/manifest.json').writeAsStringSync('{not json');
    final active = _activeOld();
    await expectLater(ContentActivator.activate(src, active), throwsStateError);
    expect(ContentRuntime(active).loadManifest()!.contentVersion, '0.1.0');
  });

  test('incompatible schema version rejected, active unchanged', () async {
    final root = Directory.systemTemp.createTempSync('schema_test_');
    final src = Directory('${root.path}/src')..createSync();
    File('${src.path}/manifest.json').writeAsStringSync(
        '{"schema_version":"9.9.9","content_version":"0.2.0","files":[]}');
    final active = _activeOld();
    await expectLater(ContentActivator.activate(src, active), throwsStateError);
    expect(ContentRuntime(active).loadManifest()!.contentVersion, '0.1.0');
  });

  test('missing file rejected, active unchanged, previous content renderable', () async {
    final src = _bundle(missing: true);
    final active = _activeOld();
    File('${active.path}/manifest.json').writeAsStringSync(
        '{"schema_version":"1.0.0","content_version":"0.1.0","files":['
        '{"path":"sessions/01.json","sha256":"${ContentRuntime.sha256Hex('{}')}"}]}');
    Directory('${active.path}/sessions').createSync();
    File('${active.path}/sessions/01.json').writeAsStringSync('{}');
    await expectLater(ContentActivator.activate(src, active), throwsStateError);
    // previous active still renders
    expect(ContentRuntime(active).verifyIntegrity(), isTrue);
  });
}
