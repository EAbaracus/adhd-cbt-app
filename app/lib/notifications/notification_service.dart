/// Notification abstraction. Tests use fakes; production uses the
/// plugin-backed implementation. Timer accuracy never depends on this
/// (spec §6): permission denied => in-app fallback, not silence.
abstract class NotificationService {
  /// Returns true when notifications are allowed after the request.
  Future<bool> ensurePermission();

  Future<void> notifyTimerComplete();

  /// Fired when permission was requested and denied.
  void onPermissionDenied(void Function() cb);
}
