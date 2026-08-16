import 'package:flutter/material.dart';

import '../charts/symptom_chart.dart';
import '../store/app_database.dart';
import '../theme/app_theme.dart';

/// Weekly ritual progress: symptom scores over submissions.
class ProgressScreen extends StatefulWidget {
  final AppDatabase db;
  const ProgressScreen({super.key, required this.db});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<int>? _totals;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await widget.db.select(widget.db.formSubmissions).get();
    if (!mounted) return;
    setState(() => _totals = SymptomChart.extractTotals(rows));
  }

  @override
  Widget build(BuildContext context) {
    final totals = _totals;
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: totals == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              children: [
                Text('Weekly symptom score', style: AppText.h2),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'Lower is better. Each point is one weekly check-in.',
                  style: AppText.small.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppTheme.spacing16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: SymptomChart(totals: totals),
                  ),
                ),
              ],
            ),
    );
  }
}
