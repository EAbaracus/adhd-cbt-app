import 'dart:async';

import 'draft_store.dart';

/// A seam that wraps a [DraftStore] with debouncing and race guards.
///
/// Provides:
/// - 400ms debounced saves
/// - Generation counter to prevent stale writes after dispose/submit
/// - Automatic restore on creation
class DraftStoreSeam {
  final DraftStore _store;
  final int _debounceMs;

  Timer? _debounceTimer;
  int _generation = 0;
  bool _disposed = false;
  bool _submitted = false;

  /// Current generation counter. Incremented on dispose/submit.
  int get generation => _generation;

  /// Whether the seam has been disposed or submitted.
  bool get isClosed => _disposed || _submitted;

  DraftStoreSeam(this._store, {this._debounceMs = 400});

  /// Restore the draft for [formId]. Returns the answers map or null if no draft.
  Future<Map<String, dynamic>?> restore(String formId) async {
    if (_disposed) return null;
    return _store.restore(formId);
  }

  /// Schedule a debounced save for [formId] with [answers].
  ///
  /// Uses the current generation to guard against stale writes.
  void saveDebounced(String formId, Map<String, dynamic> answers) {
    if (_disposed || _submitted) return;

    final currentGen = _generation;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: _debounceMs), () async {
      // Race guard: only save if generation hasn't changed
      if (currentGen == _generation && !_disposed && !_submitted) {
        await _store.save(formId, answers);
      }
    });
  }

  /// Immediately save without debouncing (used on explicit submit).
  Future<void> saveNow(String formId, Map<String, dynamic> answers) async {
    if (_disposed || _submitted) return;
    await _store.save(formId, answers);
  }

  /// Delete the draft for [formId].
  Future<void> delete(String formId) async {
    if (_disposed) return;
    await _store.delete(formId);
  }

  /// Mark as submitted - prevents any further saves.
  void markSubmitted() {
    _submitted = true;
    _generation++;
    _debounceTimer?.cancel();
  }

  /// Dispose the seam - prevents any further saves and releases resources.
  Future<void> dispose() async {
    _disposed = true;
    _generation++;
    _debounceTimer?.cancel();
    await _store.dispose();
  }
}