import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/screens/progress_screen.dart';
import 'package:adhd_cbt_app/store/app_database.dart';

Map<String, dynamic> _full(int v) =>
    {for (var i = 1; i <= 18; i++) 's$i': v};

void main() {
  testWidgets('shows chart after two submissions', (tester) async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('ps_').path}/p.db');
    for (final v in [2, 1]) {
      final now = DateTime.now().toUtc().toIso8601String();
      await db.into(db.formSubmissions).insert(FormSubmissionsCompanion.insert(
          id: 's-${now.hashCode}',
          formId: 'symptom-checklist',
          answersJson: jsonEncode(_full(v)),
          submittedAt: now,
          updatedAt: now));
    }
    await tester.pumpWidget(MaterialApp(home: ProgressScreen(db: db)));
    await tester.pumpAndSettle();
    expect(find.text('Weekly symptom score'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    await db.close();
  });

  testWidgets('empty db shows calm empty state', (tester) async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('ps2_').path}/p.db');
    await tester.pumpWidget(MaterialApp(home: ProgressScreen(db: db)));
    await tester.pumpAndSettle();
    expect(find.textContaining('weekly symptom check'), findsOneWidget);
    await db.close();
  });
}
