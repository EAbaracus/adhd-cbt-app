import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:adhd_cbt_app/api/api_client.dart';
import 'package:adhd_cbt_app/notifications/fcm_push_token_provider.dart';
import 'package:adhd_cbt_app/notifications/push_registration.dart';
import 'package:adhd_cbt_app/notifications/push_token_provider.dart';

void main() {
  test('FcmPushTokenProvider degrades to null without a device/Firebase (A3)',
      () async {
    // In the test environment Firebase platform channels are absent -> null.
    final provider = FcmPushTokenProvider();
    expect(await provider.token(), isNull);
    await expectLater(provider.tokenRefreshes(), emitsDone); // empty stream
  });

  test('PushRegistration is a no-op when the provider has no token (A3)',
      () async {
    var calls = 0;
    final api = ApiClient(
        baseUrl: 'http://fake',
        httpClient: MockClient((req) async {
          calls++;
          return http.Response('{}', 200);
        }));
    final reg = PushRegistration(api, provider: NoopPushTokenProvider());
    await reg.register();
    expect(calls, 0); // Noop -> no token -> never calls backend
  });
}
