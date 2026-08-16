import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/forms/form_controller.dart';
import 'package:adhd_cbt_app/forms/form_definition.dart';

FormDefinition _f() => FormDefinition(
    id: 'f1',
    type: 'module_review',
    title: 'T',
    fields: [
      FieldDefinition(id: 'n', kind: FieldKind.number, label: 'Doses'),
      FieldDefinition(id: 's', kind: FieldKind.scale0to3, label: 'Impact'),
      FieldDefinition(id: 'ok', kind: FieldKind.bool, label: 'Consent'),
    ]);

void main() {
  test('invalid scale rejected', () {
    final c = FormController(_f());
    expect(c.setValue('s', 5), isFalse); // scale_0_3 max 3
    expect(c.answers['s'], isNull);
    expect(c.setValue('s', 2), isTrue);
  });

  test('number parse + range', () {
    final c = FormController(_f());
    expect(c.setValue('n', -1), isFalse);
    expect(c.setValue('n', 4), isTrue);
    expect(c.answers['n'], 4);
  });

  test('bool only true/false', () {
    final c = FormController(_f());
    expect(c.setValue('ok', 'yes'), isFalse);
    expect(c.setValue('ok', true), isTrue);
  });

  test('json roundtrip preserves answers', () {
    final c = FormController(_f())
      ..setValue('n', 2)
      ..setValue('s', 1);
    final c2 = FormController.fromJson(_f(), c.toJson());
    expect(c2.answers['n'], 2);
    expect(c2.answers['s'], 1);
  });

  test('unknown field id ignored', () {
    final c = FormController(_f());
    expect(c.setValue('ghost', 1), isFalse);
  });
}
