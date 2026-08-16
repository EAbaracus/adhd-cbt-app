import 'dart:convert';

import 'package:flutter/material.dart';

import '../forms/score_calculator.dart';
import '../store/app_database.dart';
import '../theme/app_theme.dart';

/// Calm, dependency-free symptom progress line chart (I1: no flourish).
class SymptomChart extends StatelessWidget {
  final List<int> totals;
  const SymptomChart({super.key, required this.totals});

  /// Submission rows -> symptom totals in submission order; invalid rows
  /// (partial answers) are dropped (ScoreCalculator returns null).
  static List<int> extractTotals(List<FormSubmission> rows) {
    final out = <int>[];
    for (final r in rows) {
      if (r.formId != 'symptom-checklist') continue;
      final answers = (jsonDecode(r.answersJson) as Map).cast<String, dynamic>();
      final t = ScoreCalculator.symptomTotal(answers);
      if (t != null) out.add(t);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    if (totals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Text(
          'Fill in the weekly symptom check to see your progress here.',
          style: AppText.small.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }
    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: _SymptomPainter(totals),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SymptomPainter extends CustomPainter {
  final List<int> totals;
  _SymptomPainter(this.totals);

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppColors.primary500
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final point = Paint()..color = AppColors.textSecondary;

    final maxY = 54.0;
    final stepX = totals.length > 1 ? size.width / (totals.length - 1) : 0.0;
    final points = <Offset>[];
    for (var i = 0; i < totals.length; i++) {
      final x = totals.length > 1 ? i * stepX : size.width / 2;
      final y = size.height - (totals[i] / maxY) * size.height;
      points.add(Offset(x, y));
    }

    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, line);
    }
    for (final p in points) {
      canvas.drawCircle(p, 3, point);
    }
  }

  @override
  bool shouldRepaint(covariant _SymptomPainter old) =>
      old.totals != totals;
}
