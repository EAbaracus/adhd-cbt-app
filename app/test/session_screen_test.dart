import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/engine/models.dart';
import 'package:adhd_cbt_app/screens/session_screen.dart';

Session _mkSession() => Session(
    id: 's1',
    order: 1,
    module: 'psychoeducation',
    title: 'Understanding ADHD',
    checkpoints: [
      Checkpoint(
          id: 'c1',
          type: CheckpointType.reading,
          title: 'What ADHD is',
          content: const ['ADHD is a real condition.']),
      Checkpoint(
          id: 'c2',
          type: CheckpointType.exercise,
          title: 'Map situations',
          content: const ['Write three situations.']),
    ]);

void main() {
  testWidgets('renders reading body and exercise prompt', (tester) async {
    await tester.pumpWidget(
        MaterialApp(home: SessionScreen(session: _mkSession())));
    expect(find.text('What ADHD is'), findsOneWidget);
    expect(find.text('ADHD is a real condition.'), findsOneWidget);
    // sequential flow: exercise prompt comes after Done
    expect(find.text('Map situations'), findsNothing);
  });

  testWidgets('complete button advances and marks state', (tester) async {
    final s = _mkSession();
    await tester.pumpWidget(MaterialApp(home: SessionScreen(session: s)));
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pump();
    expect(s.checkpoints[0].state, CheckpointState.completed);
    expect(find.text('Map situations'), findsOneWidget);
  });

  testWidgets('defer is styled as normal, not red', (tester) async {
    await tester.pumpWidget(
        MaterialApp(home: SessionScreen(session: _mkSession())));
    final skip = find.widgetWithText(TextButton, 'Later');
    expect(skip, findsOneWidget);
    // I1: no red "missed" language — assert the copy standard
    expect(find.textContaining('missed'), findsNothing);
  });
}
