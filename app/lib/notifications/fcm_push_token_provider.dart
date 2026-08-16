import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'push_token_provider.dart';

/// Real FCM-backed provider. Firebase is only initialized lazily and only when
/// this provider is actually used (the A3 opt-in point) — the app never
/// collects or sends a token before the user consents. Any failure degrades to
/// `null` (local-first: remote push is optional, the app is fully functional
/// without it).
class FcmPushTokenProvider implements PushTokenProvider {
  @override
  Future<String?> token() async {
    try {
      await Firebase.initializeApp();
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<String?> tokenRefreshes() {
    try {
      return FirebaseMessaging.instance.onTokenRefresh;
    } catch (e) {
      return const Stream.empty();
    }
  }
}
