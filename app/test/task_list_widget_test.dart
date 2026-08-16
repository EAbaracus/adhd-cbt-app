import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/screens/task_list_screen.dart';
import 'package:adhd_cbt_app/store/app_database.dart';
import 'package:adhd_cbt_app/tasks/task_controller.dart';

void main() {
  testWidgets('add task appears; checkbox completes', (tester) async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('tw_').path}/t.db');
    final controller = TaskController(db);
    await tester.pumpWidget(
        MaterialApp(home: TaskListScreen(controller: controller)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Do taxes');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Do taxes'), findsOneWidget);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    // done task text gets line-through style; still visible
    expect(find.text('Do taxes'), findsOneWidget);
    await db.close();
  });

  testWidgets('add step under a task', (tester) async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('tw2_').path}/t.db');
    final controller = TaskController(db);
    await controller.add('Task', 'B');
    await tester.pumpWidget(
        MaterialApp(home: TaskListScreen(controller: controller)));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Break it into a step'), 'Find form');
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();
    expect(find.text('Find form'), findsOneWidget);
    await db.close();
  });
}
