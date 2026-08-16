import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:adhd_cbt_app/api/api_client.dart';
import 'package:adhd_cbt_app/billing/receipt_provider.dart';
import 'package:adhd_cbt_app/billing/receipt_service.dart';

class FakeReceiptProvider implements PlatformReceiptProvider {
  final Map<String, String>? receipt;
  FakeReceiptProvider(this.receipt);
  @override
  Future<Map<String, String>?> fetchReceipt() async => receipt;
}

void main() {
  ApiClient _api({int status = 200, List<String>? received}) =>
      ApiClient(baseUrl: 'http://fake')
        ..token = 't'
        ..httpClient = MockClient((req) async {
          received?.add(req.body);
          return http.Response('{}', status);
        });

  test('submit posts platform+receipt_data, 200 -> submitted', () async {
    final received = <String>[];
    final api = _api(received: received);
    final svc = ReceiptService(
        api: api, provider: FakeReceiptProvider({'platform': 'apple', 'receipt_data': 'abc'}));
    expect(await svc.submit(), ReceiptResult.submitted);
    expect(received.single, contains('"apple"'));
    expect(received.single, contains('"abc"'));
  });

  test('400 -> failed', () async {
    final api = _api(status: 400);
    final svc = ReceiptService(
        api: api, provider: FakeReceiptProvider({'platform': 'google', 'receipt_data': 'x'}));
    expect(await svc.submit(), ReceiptResult.failed);
  });

  test('null provider -> failed without crash', () async {
    final api = _api();
    final svc = ReceiptService(api: api);
    expect(await svc.submit(), ReceiptResult.failed);
  });
}
