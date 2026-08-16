import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:adhd_cbt_app/api/api_client.dart';
import 'package:adhd_cbt_app/store/app_database.dart';
import 'package:adhd_cbt_app/store/session_manager.dart';

void main() {
  test('persistAuth stores token+email; restoreToken sets api.token', () async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('sp_').path}/s.db');
    final api = ApiClient(baseUrl: 'http://fake');
    final sm = SessionManager(db: db, api: api);
    await sm.persistAuth('tok-1', 'a@b.com');
    expect(api.token, 'tok-1');
    expect(await sm.email(), 'a@b.com');
    // fresh manager restores
    final api2 = ApiClient(baseUrl: 'http://fake');
    final sm2 = SessionManager(db: db, api: api2);
    expect(await sm2.restoreToken(), 'tok-1');
    expect(api2.token, 'tok-1');
    await db.close();
  });

  test('clearAuth wipes token+email only', () async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('sp2_').path}/s.db');
    final api = ApiClient(baseUrl: 'http://fake');
    final sm = SessionManager(db: db, api: api);
    await sm.persistAuth('tok-2', 'a@b.com');
    await sm.clearAuth();
    expect(api.token, isNull);
    expect(await sm.restoreToken(), isNull);
    expect(await sm.email(), isNull);
    // progress tables untouched
    await db.into(db.checkpointStates).insert(CheckpointStatesCompanion.insert(
        checkpointId: 'c1', state: 'completed', updatedAt: 't'));
    await sm.clearAuth();
    final rows = await db.select(db.checkpointStates).get();
    expect(rows, hasLength(1));
    await db.close();
  });

  test('deleteAccount calls DELETE /api/auth/me with bearer', () async {
    final api = ApiClient(baseUrl: 'http://fake')
      ..token = 't'
      ..httpClient = MockClient((req) async {
        expect(req.method, 'DELETE');
        expect(req.url.path, '/api/auth/me');
        expect(req.headers['Authorization'], 'Bearer t');
        return http.Response('{}', 200);
      });
    expect(await api.deleteAccount(), isTrue);
  });
}
