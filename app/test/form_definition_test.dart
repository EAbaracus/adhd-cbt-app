import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/forms/form_definition.dart';

Map<String, dynamic> _formJson() => {
      'id': 'symptom-checklist',
      'type': 'symptom_checklist',
      'title': {'en': 'Check'},
      'fields': [
        {'id': 's1', 'kind': 'scale_0_3', 'label': {'en': 'Careless mistakes'}},
        {'id': 'note', 'kind': 'textarea', 'label': {'en': 'Notes'}},
      ],
    };

void main() {
  test('parses form definition', () {
    final f = FormDefinition.fromJson(_formJson());
    expect(f.id, 'symptom-checklist');
    expect(f.fields.length, 2);
    expect(f.fields[0].kind, FieldKind.scale0to3);
    expect(f.fields[1].kind, FieldKind.textarea);
  });

  test('unknown kind rejected', () {
    final bad = _formJson();
    (bad['fields'] as List)[0] = {
      'id': 'x',
      'kind': 'radio_group',
      'label': {'en': 'x'}
    };
    expect(() => FormDefinition.fromJson(bad), throwsFormatException);
  });

  test('options parsed for select-like fields', () {
    final j = _formJson();
    (j['fields'] as List)[0] = {
      'id': 'm',
      'kind': 'text',
      'label': {'en': 'M'},
      'options': ['a', 'b']
    };
    expect(FormDefinition.fromJson(j).fields[0].options, ['a', 'b']);
  });
}
