import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthResult {
  final String token;
  final Map<String, dynamic> user;
  AuthResult({required this.token, required this.user});
}

class ApiClient {
  final String baseUrl;
  final http.Client httpClient;
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
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}
