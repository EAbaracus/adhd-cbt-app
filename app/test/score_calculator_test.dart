import 'package:flutter_test/flutter_test.dart';
import 'package:adhd_cbt_app/forms/score_calculator.dart';

Map<String, dynamic> _full(List<int> values) =>
    {for (var i = 1; i <= 18; i++) 's$i': values[i - 1]};

void main() {
  test('sums 18 symptom items', () {
    expect(ScoreCalculator.symptomTotal(_full(List.filled(18, 1))), 18);
    expect(ScoreCalculator.symptomTotal(_full(List.filled(18, 3))), 54);
    expect(ScoreCalculator.symptomTotal(_full(List.filled(18, 0))), 0);
  });

  test('missing key -> null (never charts partial)', () {
    final a = _full(List.filled(18, 1))..remove('s9');
    expect(ScoreCalculator.symptomTotal(a), isNull);
  });

  test('non-int value -> null', () {
    final a = _full(List.filled(18, 1))..['s3'] = 'high';
    expect(ScoreCalculator.symptomTotal(a), isNull);
  });
}
