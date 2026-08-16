import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/forms/form_definition.dart';
import 'package:adhd_cbt_app/forms/form_renderer.dart';

FormDefinition _f() => FormDefinition(
    id: 'f1',
    type: 'symptom_checklist',
    title: 'Check',
    fields: [
      FieldDefinition(id: 's1', kind: FieldKind.scale0to3, label: 'Careless mistakes'),
      FieldDefinition(id: 'note', kind: FieldKind.textarea, label: 'Notes'),
    ]);

void main() {
  testWidgets('renders scale and textarea fields', (tester) async {
    await tester.pumpWidget(MaterialApp(home: FormScreen(form: _f())));
    expect(find.text('Careless mistakes'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
  });

  testWidgets('submit collects answers', (tester) async {
    Map<String, dynamic>? submitted;
    await tester.pumpWidget(MaterialApp(
      home: FormScreen(
        form: _f(),
        onSubmit: (a) async => submitted = a,
      ),
    ));
    await tester.tap(find.byKey(const Key('scale-s1-2')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('textarea-note')), 'hello');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(submitted, isNotNull);
    expect(submitted!['s1'], 2);
    expect(submitted!['note'], 'hello');
  });
}
