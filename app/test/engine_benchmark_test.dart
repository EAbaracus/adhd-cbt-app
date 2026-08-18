import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/engine/models.dart';
import 'package:adhd_cbt_app/engine/program_engine.dart';

void main() {
  test('benchmark lookup', () {
    final sessions = <Session>[];
    for (int i = 0; i < 50; i++) {
      final checkpoints = <Checkpoint>[];
      for (int j = 0; j < 100; j++) {
        checkpoints.add(
          Checkpoint(
            id: 's${i}c$j',
            type: CheckpointType.reading,
            title: 'Title',
            content: ['Content'],
          ),
        );
      }
      sessions.add(
        Session(
          id: 's$i',
          order: i,
          module: 'Module',
          title: 'Session $i',
          checkpoints: checkpoints,
        ),
      );
    }

    final engine = ProgramEngine(sessions);

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      // Look up the last checkpoint of the last session
      // We don't want to modify state actually, we just want to trigger _find.
      // complete() does find and update, let's use it as worst case lookup.
      engine.complete('s49c99');
    }
    stopwatch.stop();

    print('Lookup benchmark completed in: ${stopwatch.elapsedMilliseconds} ms');
  });
}
