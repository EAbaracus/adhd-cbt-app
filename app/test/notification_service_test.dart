import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/notifications/notification_service.dart';
import 'package:adhd_cbt_app/screens/timer_screen.dart';
import 'package:adhd_cbt_app/timer/timer_controller.dart';
import 'package:adhd_cbt_app/store/app_database.dart';
import 'dart:io';

class FakeNotifications implements NotificationService {
  bool granted = true;
  int notifyCount = 0;
  void Function()? deniedCb;
  @override
  Future<bool> ensurePermission() async {
    if (!granted) deniedCb?.call(); // mirrors real impl
    return granted;
  }
  @override
  Future<void> notifyTimerComplete() async => notifyCount++;
  @override
  void onPermissionDenied(void Function() cb) => deniedCb = cb;
}

void main() {
  testWidgets('timer finish with permission -> notification fired',
      (tester) async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('nt_').path}/t.db');
    final notifications = FakeNotifications()..granted = true;
    await tester.pumpWidget(MaterialApp(
        home: TimerScreen(
            controller: TimerController(db), notifications: notifications)));
    await tester.tap(find.text('10 min'));
    await tester.pump();
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(notifications.notifyCount, 1);
    await db.close();
  });

  testWidgets('permission denied -> calm in-app fallback, no notification',
      (tester) async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('nt2_').path}/t.db');
    final notifications = FakeNotifications()..granted = false;
    await tester.pumpWidget(MaterialApp(
        home: TimerScreen(
            controller: TimerController(db), notifications: notifications)));
    await tester.tap(find.text('10 min'));
    await tester.pump();
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(notifications.notifyCount, 0);
    expect(find.textContaining('notifications'), findsWidgets);
    await db.close();
  });
}
