import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/screens/home_screen.dart';
import 'package:adhd_cbt_app/engine/models.dart';
import 'package:adhd_cbt_app/engine/program_engine.dart';
import 'package:adhd_cbt_app/store/app_database.dart';
import 'package:adhd_cbt_app/store/drift_progress_store.dart';
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
    // Complete first session to make second one in-progress
    engine.complete('s1c0');
    engine.complete('s1c1');

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

    // Available session should have normal border
    final availableCard = find.byKey(const Key('session-card-s1'));
    // s1 is completed, not available - but let's check completed
    final completedCard = find.byKey(const Key('session-card-s1'));
    expect(completedCard, findsOneWidget);
    final completedCardWidget = tester.widget<Card>(completedCard);
    final completedShape = completedCardWidget.shape! as RoundedRectangleBorder;
    expect(completedShape.side.width, 1); // normal border
    expect(completedShape.side.color, equals(const Color(0xFFE2E6EB))); // AppColors.border

    await db.close();
  });

  testWidgets('session card has Key for all sessions', (tester) async {
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

    // Both sessions should have keys
    expect(find.byKey(const Key('session-card-s1')), findsOneWidget);
    expect(find.byKey(const Key('session-card-s2')), findsOneWidget);

    await db.close();
  });
}