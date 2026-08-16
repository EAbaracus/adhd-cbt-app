import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/forms/form_definition.dart';
import 'package:adhd_cbt_app/forms/thought_record_controller.dart';
import 'package:adhd_cbt_app/forms/thought_record_screen.dart';

FormDefinition _trForm() => FormDefinition(
    id: 'thought-record',
    type: 'thought_record',
    title: 'Thought record',
    fields: [
      FieldDefinition(
          id: 'situation', kind: FieldKind.textarea, label: 'Situation'),
      FieldDefinition(
          id: 'automatic_thought',
          kind: FieldKind.textarea,
          label: 'Automatic thought'),
      FieldDefinition(
          id: 'thinking_error',
          kind: FieldKind.text,
          label: 'Thinking error',
          options: ['all-or-nothing', 'catastrophizing', 'mind-reading']),
      FieldDefinition(
          id: 'rational_response',
          kind: FieldKind.textarea,
          label: 'Rational response'),
    ]);

void main() {
  test('error catalog read from field options', () {
    final c = ThoughtRecordController(_trForm());
    expect(c.errorOptions, containsAll(['all-or-nothing', 'catastrophizing']));
  });

  testWidgets('progressive steps: situation -> error -> response',
      (tester) async {
    Map<String, dynamic>? submitted;
    await tester.pumpWidget(MaterialApp(
        home: ThoughtRecordScreen(
            form: _trForm(), onSubmit: (a) async => submitted = a)));
    await tester.enterText(
        find.byKey(const Key('tr-situation')), 'missed a deadline');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('catastrophizing'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('tr-rational')), 'I can still fix it');
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(submitted, isNotNull);
    expect(submitted!['situation'], 'missed a deadline');
    expect(submitted!['thinking_error'], 'catastrophizing');
    expect(submitted!['rational_response'], 'I can still fix it');
  });

  testWidgets('back returns to earlier step', (tester) async {
    await tester
        .pumpWidget(MaterialApp(home: ThoughtRecordScreen(form: _trForm())));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Thinking error'), findsOneWidget);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Situation'), findsOneWidget);
  });
}
