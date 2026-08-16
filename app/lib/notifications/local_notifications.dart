import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_service.dart';

/// Plugin-backed implementation. Platform channels only work on device;
/// widget tests inject a fake.
class LocalNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  void Function()? _deniedCb;

  LocalNotificationService() {
    _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  @override
  Future<bool> ensurePermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      if (granted == false) _deniedCb?.call();
      return granted ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(alert: true, badge: true, sound: true);
      if (granted == false) _deniedCb?.call();
      return granted ?? false;
    }
    return true; // desktop/test fallback: nothing to ask
  }

  @override
  Future<void> notifyTimerComplete() async {
    await _plugin.show(
      id: 1,
      title: 'Focus session done',
      body: 'Take a planned break.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails('focus', 'Focus timer',
            channelDescription: 'Focus timer completions',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  @override
  void onPermissionDenied(void Function() cb) => _deniedCb = cb;
}
