import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../content/content_runtime.dart';

class AuthResult {
  final String token;
  final Map<String, dynamic> user;
  AuthResult({required this.token, required this.user});
}

class ApiClient {
  final String baseUrl;
  http.Client httpClient;
  ApiClient({String? baseUrl, http.Client? httpClient})
      : baseUrl = baseUrl ?? 'http://127.0.0.1:8000',
        httpClient = httpClient ?? http.Client();

  Future<AuthResult> _post(String path, Map<String, dynamic> body) async {
    final resp = await httpClient
        .post(
          Uri.parse('$baseUrl$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 200) {
      throw ApiException(
          resp.statusCode, data['detail']?.toString() ?? 'request failed');
    }
    if (path == '/api/auth/login') {
      return AuthResult(
          token: data['token'] as String,
          user: data['user'] as Map<String, dynamic>);
    }
    return AuthResult(token: '', user: data);
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    required String ageCountry,
    required int ageMin,
  }) =>
      _post('/api/auth/register', {
        'email': email,
        'password': password,
        'age_country': ageCountry,
        'age_min': ageMin,
        'privacy_consent': true,
      });

  Future<AuthResult> login(
          {required String email, required String password}) =>
      _post('/api/auth/login', {'email': email, 'password': password});

  String? token;

  Future<ContentBundle?> fetchRemoteManifest() async {
    if (token == null) return null;
    try {
      final resp = await httpClient
          .get(Uri.parse('$baseUrl/api/content/manifest'),
              headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return null;
      return ContentBundle.fromManifestJson(
          jsonDecode(resp.body) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List?> fetchContentFile(String path) async {
    if (token == null) return null;
    try {
      final resp = await httpClient
          .get(Uri.parse('$baseUrl/api/content/file/$path'),
              headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 30));
      if (resp.statusCode != 200) return null;
      return resp.bodyBytes;
    } catch (_) {
      return null;
    }
  }

  Future<String?> fetchEntitlement() async {
    if (token == null) return null;
    try {
      final resp = await httpClient
          .get(Uri.parse('$baseUrl/api/billing/entitlement'),
              headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['status'] as String?; // 'active' | 'expired'
    } catch (_) {
      return null;
    }
  }

  Future<bool> submitReceipt(
      {required String platform, required String receiptData}) async {
    if (token == null) return false;
    try {
      final resp = await httpClient
          .post(Uri.parse('$baseUrl/api/billing/receipt'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(
                  {'platform': platform, 'receipt_data': receiptData}))
          .timeout(const Duration(seconds: 10));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    if (token == null) return false;
    try {
      final resp = await httpClient
          .delete(Uri.parse('$baseUrl/api/auth/me'),
              headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}
