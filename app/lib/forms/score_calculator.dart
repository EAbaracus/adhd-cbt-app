/// Pure Dart. Symptom checklist total = s1..s18 (0-3 each). Null = invalid.
class ScoreCalculator {
  static int? symptomTotal(Map<String, dynamic> answers) {
    var total = 0;
    for (var i = 1; i <= 18; i++) {
      final v = answers['s$i'];
      if (v is! int || v < 0 || v > 3) return null;
      total += v;
    }
    return total;
  }
}
