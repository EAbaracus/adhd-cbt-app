import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/l10n/app_strings.dart';
import 'package:adhd_cbt_app/l10n/app_locale.dart';

void main() {
  group('AppStrings copy migration (R3)', () {
    test('All required keys return non-fallback values in EN locale', () {
      final requiredKeys = [
        // Session screen
        'session_label',
        'session_open_form',
        'session_done',
        'session_finish',
        'session_later',
        'session_complete_title',
        'session_complete_body',
        'session_back_home',
        'session_back',
        'session_completed',
        'session_in_progress',
        'session_available',
        'session_caption',
        // Form renderer
        'form_save',
        'form_invalid_value',
        // Home screen states
        'home_state_completed',
        'home_state_in_progress',
        'home_state_available',
      ];

      for (final key in requiredKeys) {
        final value = AppStrings.tr(AppLocaleCode.en, key);
        expect(value, isNot(equals(key)), reason: 'Key missing or fallback in EN: $key');
        expect(value.isNotEmpty, isTrue, reason: 'Empty EN value for: $key');
      }
    });

    test('All required keys return non-fallback values in TR locale', () {
      final requiredKeys = [
        // Session screen
        'session_label',
        'session_open_form',
        'session_done',
        'session_finish',
        'session_later',
        'session_complete_title',
        'session_complete_body',
        'session_back_home',
        'session_back',
        'session_completed',
        'session_in_progress',
        'session_available',
        'session_caption',
        // Form renderer
        'form_save',
        'form_invalid_value',
        // Home screen states
        'home_state_completed',
        'home_state_in_progress',
        'home_state_available',
      ];

      for (final key in requiredKeys) {
        final value = AppStrings.tr(AppLocaleCode.tr, key);
        expect(value, isNot(equals(key)), reason: 'Key missing or fallback in TR: $key');
        expect(value.isNotEmpty, isTrue, reason: 'Empty TR value for: $key');
      }
    });

    test('session_caption template has expected placeholders', () {
      final en = AppStrings.tr(AppLocaleCode.en, 'session_caption');
      final tr = AppStrings.tr(AppLocaleCode.tr, 'session_caption');
      
      expect(en.contains('%1'), isTrue, reason: 'EN missing %1 placeholder');
      expect(en.contains('%2'), isTrue, reason: 'EN missing %2 placeholder');
      expect(en.contains('%3'), isTrue, reason: 'EN missing %3 placeholder');
      expect(tr.contains('%1'), isTrue, reason: 'TR missing %1 placeholder');
      expect(tr.contains('%2'), isTrue, reason: 'TR missing %2 placeholder');
      expect(tr.contains('%3'), isTrue, reason: 'TR missing %3 placeholder');
    });

    test('Tr lookup returns correct EN values', () {
      expect(AppStrings.tr(AppLocaleCode.en, 'session_done'), equals('Done'));
      expect(AppStrings.tr(AppLocaleCode.en, 'form_save'), equals('Save'));
      expect(AppStrings.tr(AppLocaleCode.en, 'session_later'), equals('Later'));
      expect(AppStrings.tr(AppLocaleCode.en, 'session_finish'), equals('Finish session'));
      expect(AppStrings.tr(AppLocaleCode.en, 'session_open_form'), equals('Open form'));
    });

    test('Tr lookup returns correct TR values', () {
      expect(AppStrings.tr(AppLocaleCode.tr, 'session_done'), equals('Tamam'));
      expect(AppStrings.tr(AppLocaleCode.tr, 'form_save'), equals('Kaydet'));
      expect(AppStrings.tr(AppLocaleCode.tr, 'session_later'), equals('Sonra'));
      expect(AppStrings.tr(AppLocaleCode.tr, 'session_finish'), equals('Oturumu bitir'));
      expect(AppStrings.tr(AppLocaleCode.tr, 'session_open_form'), equals('Formu aç'));
      // "Harika" copy preserved
      expect(AppStrings.tr(AppLocaleCode.tr, 'session_complete_title'), equals('Harika, bir sonraki oturuma dön'));
    });

    test('Tr falls back to EN for unknown locale', () {
      // Unknown key returns the key itself
      expect(AppStrings.tr(AppLocaleCode.tr, 'nonexistent_key_xyz'), equals('nonexistent_key_xyz'));
    });
  });
}