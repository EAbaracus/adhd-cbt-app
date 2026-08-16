import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/forms/form_definition.dart';
import 'package:adhd_cbt_app/forms/problem_solving_wizard.dart';

FormDefinition _psForm() => FormDefinition(
    id: 'problem-solving',
    type: 'problem_solving',
    title: 'Problem solving',
    fields: [
      FieldDefinition(id: 'problem', kind: FieldKind.textarea, label: 'Problem'),
      FieldDefinition(id: 'solutions', kind: FieldKind.textarea, label: 'Solutions'),
      FieldDefinition(id: 'pros', kind: FieldKind.textarea, label: 'Pros'),
      FieldDefinition(id: 'cons', kind: FieldKind.textarea, label: 'Cons'),
      FieldDefinition(id: 'action_plan', kind: FieldKind.textarea, label: 'Action plan'),
      FieldDefinition(id: 'review', kind: FieldKind.textarea, label: 'Review'),
    ]);

void main() {
  testWidgets('walks 6 steps and collects answers', (tester) async {
    Map<String, dynamic>? submitted;
    await tester.pumpWidget(MaterialApp(
      home: ProblemSolvingWizard(form: _psForm(), onSubmit: (a) async => submitted = a),
    ));
    expect(find.text('Problem'), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      await tester.enterText(find.byType(TextField).last, 'answer-$i');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    await tester.enterText(find.byType(TextField).last, 'answer-5');
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(submitted, isNotNull);
    expect(submitted!.length, 6);
    expect(submitted!['problem'], 'answer-0');
    expect(submitted!['review'], 'answer-5');
  });
}
