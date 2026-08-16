import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/engine/models.dart';
import 'package:adhd_cbt_app/forms/form_definition.dart';
import 'package:adhd_cbt_app/l10n/app_locale.dart';
import 'package:adhd_cbt_app/l10n/app_strings.dart';

void main() {
  test('checkpoint contentFor: tr present -> tr, missing -> en fallback',
      () {
    final cp = Checkpoint.fromJson({
      'id': 'c1',
      'type': 'reading',
      'title': {'en': 'What ADHD is', 'tr': 'DEHB nedir'},
      'content': {
        'en': ['ADHD is real.'],
        'tr': ['DEHB gerçektir.'],
      },
    });
    expect(cp.titleFor('tr'), 'DEHB nedir');
    expect(cp.titleFor('en'), 'What ADHD is');
    expect(cp.contentFor('tr'), ['DEHB gerçektir.']);
    expect(cp.contentFor('de'), ['ADHD is real.']); // fallback en
  });

  test('session titleFor falls back to en', () {
    final s = Session.fromJson({
      'id': 's1',
      'order': 1,
      'module': 'psychoeducation',
      'title': {'en': 'Understanding ADHD'},
      'checkpoints': [
        {
          'id': 'c1',
          'type': 'reading',
          'title': {'en': 't'},
          'content': {'en': ['x']},
        }
      ],
    });
    expect(s.titleFor('tr'), 'Understanding ADHD'); // no tr yet
    expect(s.titleFor('en'), 'Understanding ADHD');
  });

  test('appStrings tr fallback', () {
    expect(AppStrings.tr(AppLocaleCode.tr, 'nav_tasks'), 'Görevler');
    expect(AppStrings.tr(AppLocaleCode.tr, 'unknown_key'), 'unknown_key');
    expect(AppStrings.tr(AppLocaleCode.en, 'nav_tasks'), 'Tasks');
  });

  test('form definition labels en-only parse stays valid', () {
    final f = FormDefinition.fromJson({
      'id': 'f1',
      'type': 'module_review',
      'title': {'en': 'Review'},
      'fields': [
        {'id': 'a', 'kind': 'text', 'label': {'en': 'A'}},
      ],
    });
    expect(f.title, 'Review');
    expect(f.fields.single.label, 'A');
  });

  test('form labels are locale-aware with en fallback', () {
    final form = FormDefinition.fromJson({
      'id': 'f1',
      'type': 'symptom_checklist',
      'title': {'en': 'Check', 'tr': 'Kontrol'},
      'fields': [
        {'id': 's1', 'kind': 'scale_0_3', 'label': {'en': 'Careless', 'tr': 'Dikkatsiz'}},
        {'id': 's2', 'kind': 'scale_0_3', 'label': {'en': 'Only en'}},
      ],
    });
    expect(form.titleFor('tr'), 'Kontrol');
    expect(form.titleFor('de'), 'Check'); // fallback en
    expect(form.fields[0].labelFor('tr'), 'Dikkatsiz');
    expect(form.fields[0].labelFor('de'), 'Careless'); // fallback en
    expect(form.fields[1].labelFor('tr'), 'Only en'); // fallback en
  });
}
