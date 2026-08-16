import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/engine/models.dart';
import 'package:adhd_cbt_app/screens/session_screen.dart';

Session _mkSession({int checkpointCount = 2}) => Session(
    id: 's1',
    order: 1,
    module: 'psychoeducation',
    title: 'Understanding ADHD',
    checkpoints: [
      for (var i = 0; i < checkpointCount; i++)
        Checkpoint(
            id: 'c$i',
            type: CheckpointType.reading,
            title: 'Checkpoint title $i',
            content: ['Body text $i']),
    ]);

void main() {
  testWidgets('renders reading body and exercise prompt', (tester) async {
    await tester.pumpWidget(
        MaterialApp(home: SessionScreen(session: _mkSession())));
    expect(find.text('Checkpoint title 0'), findsOneWidget);
    expect(find.text('Body text 0'), findsOneWidget);
    // sequential flow: next checkpoint comes after Done
    expect(find.text('Checkpoint title 1'), findsNothing);
  });

  testWidgets('complete button advances and marks state', (tester) async {
    final s = _mkSession();
    await tester.pumpWidget(MaterialApp(home: SessionScreen(session: s)));
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pump();
    expect(s.checkpoints[0].state, CheckpointState.completed);
    expect(find.text('Checkpoint title 1'), findsOneWidget);
  });

  testWidgets('defer is styled as normal, not red', (tester) async {
    await tester.pumpWidget(
        MaterialApp(home: SessionScreen(session: _mkSession())));
    expect(find.widgetWithText(TextButton, 'Later'), findsOneWidget);
    // I1: no red "missed" language — assert the copy standard
    expect(find.textContaining('missed'), findsNothing);
  });

  testWidgets('back returns to previous checkpoint, state snapshot unchanged (R0)',
      (tester) async {
    final s = _mkSession(checkpointCount: 3);
    await tester.pumpWidget(MaterialApp(home: SessionScreen(session: s)));
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pump();
    // on checkpoint 3 (index 2); snapshot: [completed, completed, current]
    final before = s.checkpoints.map((c) => c.state).toList();
    await tester.tap(find.widgetWithText(TextButton, 'Back'));
    await tester.pump();
    expect(find.text('Checkpoint title 1'), findsOneWidget); // cp2 visible
    expect(s.checkpoints.map((c) => c.state).toList(), before); // SNAPSHOT UNCHANGED
  });

  testWidgets('back is disabled on first checkpoint', (tester) async {
    final s = _mkSession();
    await tester.pumpWidget(MaterialApp(home: SessionScreen(session: s)));
    final back =
        tester.widget<TextButton>(find.widgetWithText(TextButton, 'Back'));
    expect(back.onPressed, isNull);
  });

  testWidgets('completed checkpoint data preserved when revisited (R0)',
      (tester) async {
    final s = _mkSession(checkpointCount: 3);
    await tester.pumpWidget(MaterialApp(home: SessionScreen(session: s)));
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Back'));
    await tester.pump();
    expect(s.checkpoints[0].state, CheckpointState.completed); // preserved
    expect(s.checkpoints[1].state, CheckpointState.completed); // preserved
  });

  testWidgets('caption shows checkpoint position (R5)', (tester) async {
    final s = _mkSession(checkpointCount: 2);
    await tester.pumpWidget(MaterialApp(home: SessionScreen(session: s)));
    expect(find.textContaining('Checkpoint 1/2'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await tester.pump();
    expect(find.textContaining('Checkpoint 2/2'), findsOneWidget);
  });
}
