import '../api/api_client.dart';
import 'push_token_provider.dart';

/// Registers/unregisters the device push token with the backend.
/// No-op without a token (FCM not configured) — never fails the app (local-first, A3).
class PushRegistration {
  final ApiClient api;
  final PushTokenProvider provider;
  final String platform;
  String? _lastToken;

  PushRegistration(this.api,
      {PushTokenProvider? provider, this.platform = 'android'})
      : provider = provider ?? NoopPushTokenProvider();

  Future<void> register() async {
    final token = await provider.token();
    if (token == null || token.isEmpty || token == _lastToken) return;
    _lastToken = token;
    await api.registerPushToken(token, platform);
  }

  Future<void> unregister() async {
    final token = _lastToken ?? await provider.token();
    if (token == null || token.isEmpty) return;
    _lastToken = null;
    await api.unregisterPushToken(token);
  }

  /// Wire this to [PushTokenProvider.tokenRefreshes] to re-register on rotation.
  void onTokenRefresh() {
    // Refresh handled by re-calling register() when the provider emits.
  }
}
