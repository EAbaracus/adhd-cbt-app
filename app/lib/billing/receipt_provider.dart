/// Real StoreKit2 / Play Billing implementations require store credentials
/// (M1 verifier-registry precedent — G7). The contract is here; the app
/// degrades to `null` (submit fails, no crash) until credentials exist.
abstract class PlatformReceiptProvider {
  Future<Map<String, String>?> fetchReceipt();
}
