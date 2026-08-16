import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:adhd_cbt_app/api/api_client.dart';
import 'package:adhd_cbt_app/billing/entitlement_service.dart';
import 'package:adhd_cbt_app/screens/locked_screen.dart';
import 'package:adhd_cbt_app/store/app_database.dart';

ApiClient apiFor(String status) => ApiClient(baseUrl: 'http://fake')
  ..token = 't'
  ..httpClient = MockClient((req) async {
    if (req.url.path == '/api/billing/entitlement') {
      return http.Response('{"status":"$status"}', 200);
    }
    return http.Response('nf', 404);
  });

void main() {
  test('refresh caches active; cachedAsync reads it back', () async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('ent_').path}/e.db');
    final svc = EntitlementService(api: apiFor('active'), db: db);
    expect(await svc.refresh(), EntitlementState.active);
    expect(await svc.cachedAsync(), EntitlementState.active);
    await db.close();
  });

  test('expired state cached', () async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('ent2_').path}/e.db');
    final svc = EntitlementService(api: apiFor('expired'), db: db);
    expect(await svc.refresh(), EntitlementState.expired);
    expect(await svc.cachedAsync(), EntitlementState.expired);
    await db.close();
  });

  test('network failure -> unknown, no crash, sessions still gated off',
      () async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('ent3_').path}/e.db');
    final api = ApiClient(baseUrl: 'http://fake')..token = 't';
    final svc = EntitlementService(api: api, db: db);
    expect(await svc.refresh(), EntitlementState.unknown);
    await db.close();
  });

  testWidgets('expired -> LockedScreen shown', (tester) async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('ent4_').path}/e.db');
    final svc = EntitlementService(api: apiFor('expired'), db: db);
    await svc.refresh();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: FutureBuilder(
                future: svc.cachedAsync(),
                builder: (ctx, snap) => snap.data == EntitlementState.expired
                    ? const LockedScreen()
                    : const SizedBox()))));
    await tester.pumpAndSettle();
    expect(find.text('Your subscription has ended'), findsOneWidget);
    await db.close();
  });
}
