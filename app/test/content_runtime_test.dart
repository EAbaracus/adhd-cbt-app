import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/content/content_runtime.dart';

Directory _mkBundle() {
  final root = Directory.systemTemp.createTempSync('bundle_test_');
  final dir = Directory('${root.path}/bundle')..createSync(recursive: true);
  File('${dir.path}/manifest.json').writeAsStringSync(
      '{"schema_version":"1.0.0","content_version":"0.1.0","files":['
      '{"path":"sessions/01.json","sha256":"${ContentRuntime.sha256Hex('{}')}"}]}');
  Directory('${dir.path}/sessions').createSync();
  File('${dir.path}/sessions/01.json').writeAsStringSync('{}');
  return dir;
}

void main() {
  test('loads manifest and verifies integrity', () {
    final dir = _mkBundle();
    final rt = ContentRuntime(dir);
    expect(rt.loadManifest()!.contentVersion, '0.1.0');
    expect(rt.verifyIntegrity(), isTrue);
  });

  test('bad hash fails integrity', () {
    final dir = _mkBundle();
    File('${dir.path}/sessions/01.json').writeAsStringSync('{"tampered": true}');
    final rt = ContentRuntime(dir);
    expect(rt.verifyIntegrity(), isFalse);
  });

  test('missing file fails integrity', () {
    final dir = _mkBundle();
    File('${dir.path}/sessions/01.json').deleteSync();
    final rt = ContentRuntime(dir);
    expect(rt.verifyIntegrity(), isFalse);
  });

  test('missing manifest -> null', () {
    final root = Directory.systemTemp.createTempSync('empty_test_');
    final dir = Directory('${root.path}/empty')..createSync();
    final rt = ContentRuntime(dir);
    expect(rt.loadManifest(), isNull);
  });
}
