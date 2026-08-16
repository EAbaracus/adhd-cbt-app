import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:adhd_cbt_app/api/api_client.dart';
import 'package:adhd_cbt_app/app_scope.dart';
import 'package:adhd_cbt_app/l10n/app_locale.dart';
import 'package:adhd_cbt_app/screens/onboarding_screen.dart';
import 'package:adhd_cbt_app/screens/settings_screen.dart';
import 'package:adhd_cbt_app/store/app_database.dart';
import 'package:adhd_cbt_app/store/session_manager.dart';

void main() {
  testWidgets('settings shows crisis banner and email', (tester) async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('st_').path}/s.db');
    final api = ApiClient(baseUrl: 'http://fake');
    final sm = SessionManager(db: db, api: api);
    await sm.persistAuth('t', 'a@b.com');
    await tester.pumpWidget(AppLocale(
      code: AppLocaleCode.en,
      db: db,
      onChanged: (_) {},
      child: AppScope(
        engine: null,
        db: db,
        forms: null,
        api: api,
        sessionManager: sm,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('If you are in crisis'), findsOneWidget);
    expect(find.text('a@b.com'), findsOneWidget);
    await db.close();
  });

  testWidgets('language switch persists tr', (tester) async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('st2_').path}/s.db');
    await tester.pumpWidget(AppLocale(
      code: AppLocaleCode.en,
      db: db,
      onChanged: (_) {},
      child: AppScope(
        engine: null,
        db: db,
        forms: null,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    ));
    await tester.tap(find.text('Türkçe'));
    await tester.pumpAndSettle();
    // persisted
    final rows = await (db.select(db.userSettings)
          ..where((u) => u.key.equals('locale')))
        .get();
    expect(rows.single.value, 'tr');
    await db.close();
  });

  testWidgets('delete requires typing delete, calls api, navigates home',
      (tester) async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('st3_').path}/s.db');
    var deleted = false;
    final api = ApiClient(baseUrl: 'http://fake')
      ..token = 't'
      ..httpClient = MockClient((req) async {
        deleted = true;
        return http.Response('{}', 200);
      });
    final sm = SessionManager(db: db, api: api);
    await sm.persistAuth('t', 'a@b.com');
    await tester.pumpWidget(AppLocale(
      code: AppLocaleCode.en,
      db: db,
      onChanged: (_) {},
      child: AppScope(
        engine: null,
        db: db,
        forms: null,
        api: api,
        sessionManager: sm,
        child: MaterialApp(
          home: SettingsScreen(),
          onGenerateRoute: (settings) => settings.name == '/onboarding'
              ? MaterialPageRoute(builder: (_) => const OnboardingScreen())
              : null,
        ),
      ),
    ));
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    // confirm disabled until typed
    final confirm = find.widgetWithText(FilledButton, 'Delete');
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'delete');
    await tester.pump();
    expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(deleted, isTrue);
    // wiped auth + navigated to onboarding
    expect(await sm.restoreToken(), isNull);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    await db.close();
  });
}
