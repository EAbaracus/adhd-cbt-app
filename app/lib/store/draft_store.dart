import 'dart:convert';

import 'package:drift/drift.dart';

import 'app_database.dart';

/// Interface for persisting and restoring form drafts.
abstract class DraftStore {
  /// Restore a draft for [formId]. Returns null if no draft exists.
  Future<Map<String, dynamic>?> restore(String formId);

  /// Save a draft for [formId] with [answers].
  Future<void> save(String formId, Map<String, dynamic> answers);

  /// Delete a draft for [formId].
  Future<void> delete(String formId);

  /// Dispose the store, releasing any resources.
  Future<void> dispose();
}

/// Drift-backed implementation of [DraftStore] using the form_drafts table.
class DriftDraftStore implements DraftStore {
  final AppDatabase _db;
  bool _disposed = false;

  DriftDraftStore(this._db);

  @override
  Future<Map<String, dynamic>?> restore(String formId) async {
    if (_disposed) return null;
    final row = await (_db.select(_db.formDrafts)
          ..where((t) => t.formId.equals(formId)))
        .getSingleOrNull();
    if (row == null) return null;
    return row.answersJson.isEmpty ? null : _decode(row.answersJson);
  }

  @override
  Future<void> save(String formId, Map<String, dynamic> answers) async {
    if (_disposed) return;
    final json = _encode(answers);
    await _db.into(_db.formDrafts).insertOnConflictUpdate(
          FormDraftsCompanion(
            formId: Value(formId),
            answersJson: Value(json),
            updatedAt: Value(DateTime.now().toIso8601String()),
          ),
        );
  }

  @override
  Future<void> delete(String formId) async {
    if (_disposed) return;
    await (_db.delete(_db.formDrafts)..where((t) => t.formId.equals(formId)))
        .go();
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
  }

  Map<String, dynamic> _decode(String json) {
    return jsonDecode(json) as Map<String, dynamic>;
  }

  String _encode(Map<String, dynamic> map) {
    return jsonEncode(map);
  }
}