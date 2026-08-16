import 'package:flutter/material.dart';

import '../charts/symptom_chart.dart';
import '../l10n/app_locale.dart';
import '../l10n/app_strings.dart';
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
    final locale = AppLocale.of(context)?.code ?? AppLocaleCode.en;
    String tr(String key) => AppStrings.tr(locale, key);
    final totals = _totals;
    return Scaffold(
      appBar: AppBar(title: Text(tr('progress_title'))),
      body: totals == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              children: [
                Text(tr('progress_weekly_score'), style: AppText.h2),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  tr('progress_subtitle'),
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
