import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:adhd_cbt_app/api/api_client.dart';
import 'package:adhd_cbt_app/content/content_runtime.dart';
import 'package:adhd_cbt_app/content/content_service.dart';

void main() {
  Directory _active({String version = '0.1.0', String body = '{}'}) {
    final root = Directory.systemTemp.createTempSync('ota_');
    final dir = Directory('${root.path}/active')..createSync();
    File('${dir.path}/manifest.json').writeAsStringSync(
        '{"schema_version":"1.0.0","content_version":"$version","files":[]}');
    return dir;
  }

  test('checkForUpdate true when remote newer', () async {
    final active = _active(version: '0.1.0');
    final api = ApiClient(baseUrl: 'http://fake')
      ..token = 't'
      ..httpClient = MockClient((req) async {
        if (req.url.path == '/api/content/manifest') {
          return http.Response(
              '{"schema_version":"1.0.0","content_version":"0.2.0","files":[]}',
              200);
        }
        return http.Response('not found', 404);
      });
    final svc = ContentService(
        api: api, activeDir: active, runtime: ContentRuntime(active));
    expect(await svc.checkForUpdate(), isTrue);
  });

  test('checkForUpdate false when versions equal or auth missing', () async {
    final active = _active(version: '0.1.0');
    final api = ApiClient(baseUrl: 'http://fake')
      ..httpClient = MockClient((req) async => http.Response(
          '{"schema_version":"1.0.0","content_version":"0.1.0","files":[]}',
          200));
    final svc = ContentService(
        api: api, activeDir: active, runtime: ContentRuntime(active));
    expect(await svc.checkForUpdate(), isFalse); // equal
    api.token = null;
    expect(await svc.checkForUpdate(), isFalse); // no token
  });

  test('applyUpdate downloads, verifies, activates atomically', () async {
    final active = _active(version: '0.1.0');
    final remoteManifest = jsonEncode({
      'schema_version': '1.0.0',
      'content_version': '0.2.0',
      'files': [
        {
          'path': 'sessions/01.json',
          'sha256': ContentRuntime.sha256Hex('{"v":2}')
        }
      ]
    });
    final api = ApiClient(baseUrl: 'http://fake')
      ..token = 't'
      ..httpClient = MockClient((req) async {
        if (req.url.path == '/api/content/manifest') {
          return http.Response(remoteManifest, 200);
        }
        if (req.url.path == '/api/content/file/sessions/01.json') {
          return http.Response('{"v":2}', 200);
        }
        return http.Response('nf', 404);
      });
    final svc = ContentService(
        api: api, activeDir: active, runtime: ContentRuntime(active));
    expect(await svc.applyUpdate(), isTrue);
    final rt = ContentRuntime(active);
    expect(rt.loadManifest()!.contentVersion, '0.2.0');
    expect(rt.verifyIntegrity(), isTrue);
    expect(await svc.checkForUpdate(), isFalse); // now current
  });

  test('applyUpdate download failure leaves active untouched', () async {
    final active = _active(version: '0.1.0');
    final api = ApiClient(baseUrl: 'http://fake')
      ..token = 't'
      ..httpClient = MockClient((req) async {
        if (req.url.path == '/api/content/manifest') {
          return http.Response(
              '{"schema_version":"1.0.0","content_version":"0.2.0","files":['
              '{"path":"sessions/01.json","sha256":"${'a' * 64}"}]}',
              200);
        }
        return http.Response('gone', 500); // file download fails
      });
    final svc = ContentService(
        api: api, activeDir: active, runtime: ContentRuntime(active));
    expect(await svc.applyUpdate(), isFalse);
    expect(ContentRuntime(active).loadManifest()!.contentVersion, '0.1.0');
    expect(Directory('${active.path}.stage').existsSync(), isFalse);
  });
}
