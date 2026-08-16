import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/screens/timer_screen.dart';
import 'package:adhd_cbt_app/store/app_database.dart';
import 'package:adhd_cbt_app/timer/timer_controller.dart';

void main() {
  testWidgets('start shows running timer, park list works', (tester) async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('tw_').path}/t.db');
    final controller = TimerController(db);
    await tester.pumpWidget(
        MaterialApp(home: TimerScreen(controller: controller)));
    await tester.tap(find.text('10 min'));
    await tester.pump();
    expect(find.textContaining(':'), findsWidgets); // mm:ss visible
    await tester.enterText(
        find.widgetWithText(TextField, 'Park a distraction'), 'email ping');
    await tester.tap(find.text('Park it'));
    await tester.pump();
    expect(find.text('email ping'), findsOneWidget);
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    // log row persisted
    final rows = await db.select(db.timerLog).get();
    expect(rows, hasLength(1));
    expect(rows.single.minutes, 10);
    expect(rows.single.distractions, 1);
    await db.close();
  });

  testWidgets('recoverLast returns null when no in-progress log', (tester) async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('tw2_').path}/t.db');
    final controller = TimerController(db);
    expect(await controller.recoverLast(), isNull);
    await db.close();
  });
}
