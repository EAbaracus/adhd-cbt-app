import '../api/api_client.dart';
import '../store/app_database.dart';

enum EntitlementState { active, expired, unknown }

/// Entitlement: refresh from backend, cache in UserSettings, degrade to
/// 'unknown' on network failure (G3: never bricks offline content).
class EntitlementService {
  final ApiClient api;
  final AppDatabase db;
  EntitlementService({required this.api, required this.db});

  static const _key = 'entitlement';

  Future<EntitlementState> refresh() async {
    final status = await api.fetchEntitlement();
    final state = switch (status) {
      'active' => EntitlementState.active,
      'expired' => EntitlementState.expired,
      _ => EntitlementState.unknown,
    };
    if (status != null) {
      await db.into(db.userSettings).insertOnConflictUpdate(
          UserSettingsCompanion.insert(key: _key, value: state.name));
    }
    return state;
  }

  Future<EntitlementState> cachedAsync() async {
    final rows = await (db.select(db.userSettings)
          ..where((u) => u.key.equals(_key)))
        .get();
    if (rows.isEmpty) return EntitlementState.unknown;
    return switch (rows.single.value) {
      'active' => EntitlementState.active,
      'expired' => EntitlementState.expired,
      _ => EntitlementState.unknown,
    };
  }
}
