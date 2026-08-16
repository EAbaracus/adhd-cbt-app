import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/charts/symptom_chart.dart';
import 'package:adhd_cbt_app/store/app_database.dart';

Map<String, dynamic> _full(int v) =>
    {for (var i = 1; i <= 18; i++) 's$i': v};

Future<AppDatabase> _dbWithRows(List<Map<String, dynamic>?> answers) async {
  final db = AppDatabase.open(
      '${Directory.systemTemp.createTempSync('chart_').path}/c.db');
  for (final a in answers) {
    final now = DateTime.now().toUtc().toIso8601String();
    await db.into(db.formSubmissions).insert(FormSubmissionsCompanion.insert(
        id: 'r-${now.hashCode}',
        formId: 'symptom-checklist',
        answersJson: jsonEncode(a ?? {}),
        submittedAt: now,
        updatedAt: now));
  }
  return db;
}

void main() {
  test('extractTotals maps totals and drops invalid rows', () async {
    final db = await _dbWithRows([
      _full(1), // -> 18
      _full(3), // -> 54
      ({for (var i = 1; i <= 18; i++) 's$i': 1}..remove('s9')), // invalid
      _full(0), // -> 0
    ]);
    final rows = await db.select(db.formSubmissions).get();
    final totals = SymptomChart.extractTotals(rows);
    expect(totals, [18, 54, 0]);
    await db.close();
  });

  testWidgets('chart renders points without exception', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SymptomChart(totals: [18, 27, 9]))));
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('empty totals shows calm empty state, no red', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SymptomChart(totals: []))));
    expect(find.textContaining('weekly symptom check'), findsOneWidget);
    expect(find.textContaining('missed'), findsNothing);
  });
}
