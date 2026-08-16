import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/store/draft_store.dart';
import 'package:adhd_cbt_app/store/draft_store_seam.dart';

void main() {
  group('DraftStoreSeam', () {
    late FakeDraftStore fakeStore;
    late DraftStoreSeam seam;

    setUp(() {
      fakeStore = FakeDraftStore();
      seam = DraftStoreSeam(fakeStore, debounceMs: 100);
    });

    tearDown(() async {
      await seam.dispose();
    });

    test('restore returns null for non-existent draft', () async {
      final result = await seam.restore('form1');
      expect(result, isNull);
    });

    test('saveDebounced persists after debounce', () async {
      seam.saveDebounced('form1', {'field1': 'value1'});

      // Before debounce
      expect(fakeStore.savedDrafts.containsKey('form1'), isFalse);

      // After debounce
      await Future.delayed(const Duration(milliseconds: 150));
      expect(fakeStore.savedDrafts['form1'], {'field1': 'value1'});
    });

    test('saveDebounced is race-guarded by generation', () async {
      seam.saveDebounced('form1', {'field1': 'value1'});
      
      // Dispose before debounce fires
      await seam.dispose();
      
      await Future.delayed(const Duration(milliseconds: 150));
      // Should not have saved because disposed
      expect(fakeStore.savedDrafts.containsKey('form1'), isFalse);
    });

    test('markSubmitted prevents further saves', () async {
      seam.saveDebounced('form1', {'field1': 'value1'});
      seam.markSubmitted();
      await Future.delayed(const Duration(milliseconds: 150));
      
      expect(fakeStore.savedDrafts.containsKey('form1'), isFalse);
    });

    test('saveNow bypasses debounce', () async {
      await seam.saveNow('form1', {'field1': 'now'});
      expect(fakeStore.savedDrafts['form1'], {'field1': 'now'});
    });

    test('delete removes draft', () async {
      fakeStore.savedDrafts['form1'] = {'field1': 'value1'};
      await seam.delete('form1');
      expect(fakeStore.deletedDrafts.contains('form1'), isTrue);
    });

    test('dispose cancels pending debounced save', () async {
      seam.saveDebounced('form1', {'field1': 'value1'});
      await seam.dispose();
      await Future.delayed(const Duration(milliseconds: 150));
      expect(fakeStore.savedDrafts.containsKey('form1'), isFalse);
    });

    test('multiple rapid saves - only last wins', () async {
      seam.saveDebounced('form1', {'v': 1});
      await Future.delayed(const Duration(milliseconds: 50));
      seam.saveDebounced('form1', {'v': 2});
      await Future.delayed(const Duration(milliseconds: 50));
      seam.saveDebounced('form1', {'v': 3});
      await Future.delayed(const Duration(milliseconds: 150));
      expect(fakeStore.savedDrafts['form1'], {'v': 3});
    });

    test('chain: save, dispose, new seam restores', () async {
      seam.saveDebounced('form1', {'field1': 'value1'});
      await Future.delayed(const Duration(milliseconds: 150));
      expect(fakeStore.savedDrafts['form1'], {'field1': 'value1'});

      await seam.dispose();

      // New seam with same store
      final seam2 = DraftStoreSeam(fakeStore, debounceMs: 100);
      final restored = await seam2.restore('form1');
      expect(restored, {'field1': 'value1'});
      await seam2.dispose();
    });
  });
}

class FakeDraftStore implements DraftStore {
  final Map<String, Map<String, dynamic>> savedDrafts = {};
  final List<String> deletedDrafts = [];
  bool disposed = false;

  @override
  Future<Map<String, dynamic>?> restore(String formId) async {
    return savedDrafts[formId];
  }

  @override
  Future<void> save(String formId, Map<String, dynamic> answers) async {
    if (disposed) return;
    savedDrafts[formId] = Map.of(answers);
  }

  @override
  Future<void> delete(String formId) async {
    deletedDrafts.add(formId);
    savedDrafts.remove(formId);
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}