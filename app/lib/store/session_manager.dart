import '../api/api_client.dart';
import 'package:drift/drift.dart';
import '../store/app_database.dart';

/// Single auth touchpoint: persists/restores/clears token + email in
/// user_settings. Progress data is NOT touched (local-first, G4).
class SessionManager {
  final AppDatabase db;
  final ApiClient api;
  SessionManager({required this.db, required this.api});

  static const tokenKey = 'auth_token';
  static const emailKey = 'auth_email';

  Future<void> persistAuth(String token, String email) async {
    api.token = token;
    await db.batch((b) {
      b.insert(db.userSettings,
          UserSettingsCompanion.insert(key: tokenKey, value: token),
          mode: InsertMode.insertOrReplace);
      b.insert(db.userSettings,
          UserSettingsCompanion.insert(key: emailKey, value: email),
          mode: InsertMode.insertOrReplace);
    });
  }

  Future<String?> restoreToken() async {
    final rows = await (db.select(db.userSettings)
          ..where((u) => u.key.equals(tokenKey)))
        .get();
    if (rows.isEmpty) return null;
    final token = rows.single.value;
    api.token = token;
    return token;
  }

  Future<String?> email() async {
    final rows = await (db.select(db.userSettings)
          ..where((u) => u.key.equals(emailKey)))
        .get();
    return rows.isEmpty ? null : rows.single.value;
  }

  Future<void> clearAuth() async {
    api.token = null;
    await (db.delete(db.userSettings)
          ..where((u) => u.key.equals(tokenKey) | u.key.equals(emailKey)))
        .go();
  }
}
