import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/screens/home_screen.dart';
import 'package:adhd_cbt_app/engine/models.dart';
import 'package:adhd_cbt_app/engine/program_engine.dart';
import 'package:adhd_cbt_app/store/app_database.dart';
import 'dart:io';

Session _mkSession(int order, String id, {bool optional = false}) {
  return Session(
    id: id,
    order: order,
    module: 'psychoeducation',
    title: 'Session $order',
    optional: optional,
    checkpoints: [
      Checkpoint(
        id: '${id}c0',
        type: CheckpointType.ritual,
        title: 'Ritual',
        content: ['Welcome'],
      ),
      Checkpoint(
        id: '${id}c1',
        type: CheckpointType.reading,
        title: 'Reading',
        content: ['Content'],
      ),
    ],
  );
}

void main() {
  testWidgets('session card has correct Key and accent bar for in-progress', (tester) async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('hs_').path}/t.db');
    final engine = ProgramEngine([
      _mkSession(1, 's1'),
      _mkSession(2, 's2'),
    ]);
    // Complete first session to unlock second, then complete one checkpoint of second to make it in-progress
    engine.complete('s1c0');
    engine.complete('s1c1');
    engine.complete('s2c0'); // complete first checkpoint of s2 to make it in-progress

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(engine: engine, db: db),
      ),
    );
    await tester.pumpAndSettle();

    // Find the in-progress session card (session 2)
    final inProgressCard = find.byKey(const Key('session-card-s2'));
    expect(inProgressCard, findsOneWidget);

    // Verify it has the accent bar (4px left border in primary500)
    final card = tester.widget<Card>(inProgressCard);
    expect(card.shape, isA<RoundedRectangleBorder>());
    final shape = card.shape! as RoundedRectangleBorder;
    expect(shape.side.width, 4);
    expect(shape.side.color, equals(const Color(0xFF2F5FD0))); // AppColors.primary500

    // Completed session should have normal border
    final completedCard = find.byKey(const Key('session-card-s1'));
    expect(completedCard, findsOneWidget);
    final completedCardWidget = tester.widget<Card>(completedCard);
    final completedShape = completedCardWidget.shape! as RoundedRectangleBorder;
    expect(completedShape.side.width, 1); // normal border
    expect(completedShape.side.color, equals(const Color(0xFFE2E6EB))); // AppColors.border

    await db.close();
  });

  testWidgets('session card has Key for all available sessions', (tester) async {
    final db = AppDatabase.open(
        '${Directory.systemTemp.createTempSync('hs2_').path}/t.db');
    final engine = ProgramEngine([
      _mkSession(1, 's1'),
      _mkSession(2, 's2'),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(engine: engine, db: db),
      ),
    );
    await tester.pumpAndSettle();

    // Only s1 is available (s2 is locked because no earlier session started)
    expect(find.byKey(const Key('session-card-s1')), findsOneWidget);
    // s2 is locked, so not in availableSessions
    expect(find.byKey(const Key('session-card-s2')), findsNothing);

    await db.close();
  });
}