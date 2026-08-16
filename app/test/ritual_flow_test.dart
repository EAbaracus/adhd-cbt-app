import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/app_scope.dart';
import 'package:adhd_cbt_app/engine/models.dart';
import 'package:adhd_cbt_app/forms/form_definition.dart';
import 'package:adhd_cbt_app/screens/session_screen.dart';

Session _ritualSession() => Session(
    id: 's1',
    order: 1,
    module: 'psychoeducation',
    title: 'Understanding ADHD',
    checkpoints: [
      Checkpoint(
          id: 'ritual-check',
          type: CheckpointType.ritual,
          title: 'Weekly check-in',
          content: const ['Fill in the symptom check.'],
          formRef: 'form:symptom-checklist'),
      Checkpoint(
          id: 'read',
          type: CheckpointType.reading,
          title: 'What ADHD is',
          content: const ['ADHD is a real condition.']),
    ]);

FormDefinition _checklist() => FormDefinition(
    id: 'symptom-checklist',
    type: 'symptom_checklist',
    title: 'Weekly symptom check',
    fields: [
      FieldDefinition(id: 's1', kind: FieldKind.scale0to3, label: 'Careless'),
      FieldDefinition(id: 's2', kind: FieldKind.scale0to3, label: 'Attention'),
    ]);

void main() {
  testWidgets('formRef checkpoint opens the form and submits', (tester) async {
    final s = _ritualSession();
    String? submittedForm;
    Map<String, dynamic>? submittedAnswers;
    await tester.pumpWidget(AppScope(
      engine: null,
      db: null,
      forms: {'symptom-checklist': _checklist()},
      child: MaterialApp(
        home: SessionScreen(
          session: s,
          onFormSubmit: (formId, answers) async {
            submittedForm = formId;
            submittedAnswers = answers;
          },
        ),
      ),
    ));
    expect(find.text('Open form'), findsOneWidget);
    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();
    expect(find.text('Weekly symptom check'), findsOneWidget);
    await tester.tap(find.byKey(const Key('scale-s1-2')));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(submittedForm, 'symptom-checklist');
    expect(submittedAnswers!['s1'], 2);
    // back on session screen, checkpoint completed, advanced to next
    expect(find.text('What ADHD is'), findsOneWidget);
    expect(s.checkpoints[0].state, CheckpointState.completed);
  });

  testWidgets('unknown formRef falls back to Done', (tester) async {
    final s = Session(
        id: 's1',
        order: 1,
        module: 'psychoeducation',
        title: 'T',
        checkpoints: [
          Checkpoint(
              id: 'c0',
              type: CheckpointType.ritual,
              title: 'Check',
              content: const ['x'],
              formRef: 'form:missing'),
        ]);
    await tester.pumpWidget(AppScope(
      engine: null,
      db: null,
      forms: const {},
      child: MaterialApp(home: SessionScreen(session: s)),
    ));
    expect(find.text('Open form'), findsOneWidget);
    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();
    // unknown ref: no crash, still on session screen with Done available
    expect(find.text('Open form'), findsOneWidget);
  });
}
