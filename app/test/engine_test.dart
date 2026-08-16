import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/engine/models.dart';
import 'package:adhd_cbt_app/engine/program_engine.dart';

Session _mk(int order, String sid, List<List<String>> cpSpecs) {
  final cps = <Checkpoint>[
    for (var i = 0; i < cpSpecs.length; i++)
      Checkpoint(
          id: '${sid}c$i',
          type: CheckpointType.reading,
          title: 't',
          content: const ['x'],
          requires: cpSpecs[i]),
  ];
  return Session(
      id: sid,
      order: order,
      module: 'psychoeducation',
      title: 'S',
      checkpoints: cps);
}

ProgramEngine _three() => ProgramEngine([
      _mk(1, 's1', [[], [], []]),
      _mk(2, 's2', [[], [], []]),
      _mk(3, 's3', [[], [], []]),
    ]);

void main() {
  test('first session is current initially', () {
    final e = _three();
    expect(e.currentSession!.id, 's1');
    expect(e.currentCheckpoint!.id, 's1c0');
  });

  test('complete advances to next checkpoint', () {
    final e = _three();
    e.complete('s1c0');
    expect(e.currentCheckpoint!.id, 's1c1');
    e.complete('s1c1');
    e.complete('s1c2');
    expect(e.sessionState(e.sessions[0]), SessionState.completed);
    expect(e.currentSession!.id, 's2');
  });

  test('skipped session is normal — next session offered', () {
    final e = _three();
    e.defer('s1c1'); // skip one checkpoint
    e.complete('s1c0');
    e.complete('s1c2');
    expect(e.sessionState(e.sessions[0]), SessionState.completed);
    expect(e.currentSession!.id, 's2'); // no punishment, s2 offered
  });

  test('catch-up: completing later session leaves earlier available', () {
    final e = _three();
    e.complete('s1c0');
    e.complete('s1c1');
    e.complete('s1c2');
    e.complete('s2c0'); // s2 started but not finished
    e.complete('s3c0'); // jump ahead — allowed
    expect(e.sessionState(e.sessions[1]), SessionState.inProgress);
    expect(e.sessionState(e.sessions[0]), SessionState.completed);
    expect(e.availableSessions.map((s) => s.id), containsAll(['s2', 's3']));
  });

  test('prerequisite gating: checkpoint with unmet requires is not current', () {
    final s = _mk(1, 's1', [
      ['s1c2'],
      [],
      []
    ]);
    final e = ProgramEngine([s]);
    expect(e.currentCheckpoint!.id, 's1c1'); // c0 locked (requires c2, unmet)
    e.complete('s1c1');
    expect(e.currentCheckpoint!.id, 's1c2');
    e.complete('s1c2');
    expect(e.currentCheckpoint!.id, 's1c0'); // now c0 unlocks
  });

  test('resume after long absence: next candidate is correct, no dates involved', () {
    final e = _three();
    e.complete('s1c0');
    e.complete('s1c1');
    // simulate returning later: engine has no notion of time
    expect(e.currentCheckpoint!.id, 's1c2');
    expect(e.currentSession!.id, 's1');
  });

  test('no calendar punishment: deferred checkpoints count toward completion', () {
    final s = _mk(1, 's1', [[], [], []]);
    final e = ProgramEngine([s]);
    e.defer('s1c0');
    e.defer('s1c1');
    e.defer('s1c2');
    expect(e.sessionState(s), SessionState.completed);
  });
}
