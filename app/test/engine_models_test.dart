import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/engine/models.dart';

Map<String, dynamic> cp(String id,
        {String type = 'reading', List<String> requires = const []}) =>
    {
      'id': id,
      'type': type,
      'title': {'en': 'T'},
      'content': {'en': ['x']},
      if (requires.isNotEmpty) 'requires': requires,
    };

Map<String, dynamic> sessionJson() => {
      'id': 's1',
      'order': 1,
      'module': 'psychoeducation',
      'title': {'en': 'S'},
      'checkpoints': [cp('c1'), cp('c2', requires: ['c1'])],
    };

void main() {
  test('parses session json strictly', () {
    final s = Session.fromJson(sessionJson());
    expect(s.id, 's1');
    expect(s.checkpoints.length, 2);
    expect(s.checkpoints[1].requires, ['c1']);
    expect(s.checkpoints[0].state, CheckpointState.current);
  });

  test('missing required field throws FormatException', () {
    final bad = sessionJson()..remove('id');
    expect(() => Session.fromJson(bad), throwsFormatException);
  });

  test('unknown checkpoint type throws FormatException', () {
    final bad = sessionJson();
    (bad['checkpoints'] as List)[0] = cp('c1', type: 'bogus');
    expect(() => Session.fromJson(bad), throwsFormatException);
  });

  test('localized title falls back gracefully when en missing', () {
    final bad = sessionJson();
    (bad['checkpoints'] as List)[0] = {
      'id': 'c1',
      'type': 'reading',
      'title': {'de': 'x'},
      'content': {'de': ['x']}
    };
    final s = Session.fromJson(bad);
    expect(s.checkpoints[0].title, 'c1');
  });
}
