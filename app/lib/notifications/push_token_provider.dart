/// Provides the device's remote-push token. Default (Noop) returns null —
/// FCM is only active once a Firebase config + provider are supplied (A3/local-first).
abstract class PushTokenProvider {
  Future<String?> token();
  Stream<String?> tokenRefreshes();
}

class NoopPushTokenProvider implements PushTokenProvider {
  @override
  Future<String?> token() async => null;
  @override
  Stream<String?> tokenRefreshes() => const Stream.empty();
}
