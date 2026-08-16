import '../api/api_client.dart';
import 'receipt_provider.dart';

enum ReceiptResult { submitted, failed }

class ReceiptService {
  final ApiClient api;
  final PlatformReceiptProvider? provider;
  ReceiptService({required this.api, this.provider});

  Future<ReceiptResult> submit() async {
    final provider = this.provider;
    if (provider == null) return ReceiptResult.failed;
    final receipt = await provider.fetchReceipt();
    if (receipt == null) return ReceiptResult.failed;
    final platform = receipt['platform'];
    final data = receipt['receipt_data'];
    if (platform == null || data == null) return ReceiptResult.failed;
    final ok = await api.submitReceipt(platform: platform, receiptData: data);
    return ok ? ReceiptResult.submitted : ReceiptResult.failed;
  }
}
