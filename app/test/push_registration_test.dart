import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:adhd_cbt_app/api/api_client.dart';
import 'package:adhd_cbt_app/notifications/push_registration.dart';
import 'package:adhd_cbt_app/notifications/push_token_provider.dart';

class FakeProvider implements PushTokenProvider {
  String? value;
  FakeProvider([this.value]);
  @override
  Future<String?> token() async => value;
  @override
  Stream<String?> tokenRefreshes() async* {}
}

void main() {
  test('register posts token to backend', () async {
    final calls = <String>[];
    final api = ApiClient(
        baseUrl: 'http://t',
        httpClient: MockClient((req) async {
          calls.add('${req.method} ${req.url.path}');
          return http.Response('{"registered": 1}', 200);
        }));
    api.token = 'auth';
    final reg = PushRegistration(api, provider: FakeProvider('tok1'));
    await reg.register();
    expect(calls, ['POST /api/push/token']);
  });

  test('register no-ops when no token (FCM unconfigured)', () async {
    final api = ApiClient(
        baseUrl: 'http://t', httpClient: MockClient((req) async {
          return http.Response('{}', 500);
        }));
    final reg = PushRegistration(api, provider: FakeProvider(null));
    // should not throw and not hit network
    await reg.register();
  });

  test('register no-ops when token unchanged', () async {
    var calls = 0;
    final api = ApiClient(
        baseUrl: 'http://t',
        httpClient: MockClient((req) async {
          calls++;
          return http.Response('{"registered": 1}', 200);
        }));
    final reg = PushRegistration(api, provider: FakeProvider('tok1'));
    await reg.register();
    await reg.register(); // same token -> no second call
    expect(calls, 1);
  });

  test('unregister deletes token', () async {
    final calls = <String>[];
    final api = ApiClient(
        baseUrl: 'http://t',
        httpClient: MockClient((req) async {
          calls.add('${req.method} ${req.url.path}');
          return http.Response('{"removed": 1}', 200);
        }));
    api.token = 'auth';
    final reg = PushRegistration(api, provider: FakeProvider('tokX'));
    await reg.register();
    await reg.unregister();
    expect(calls, ['POST /api/push/token', 'DELETE /api/push/token/tokX']);
  });
}
