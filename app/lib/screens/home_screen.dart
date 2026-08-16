import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:math';

import '../engine/models.dart';
import '../engine/program_engine.dart';
import '../store/app_database.dart';
import '../store/drift_progress_store.dart';
import '../retention/retention_service.dart';
import '../l10n/app_locale.dart';
import '../l10n/app_strings.dart';
import '../tasks/task_controller.dart';
import '../theme/app_theme.dart';
import '../timer/timer_controller.dart';
import 'session_screen.dart';
import 'progress_screen.dart';
import 'task_list_screen.dart';
import 'timer_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final ProgramEngine engine;
  final AppDatabase db;
  const HomeScreen({super.key, required this.engine, required this.db});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.of(context)?.code ?? AppLocaleCode.en;
    String s(String key) => AppStrings.tr(locale, key);
    return Scaffold(
      appBar: AppBar(
        title: Text(s('home_title')),
        actions: [
          IconButton(
            tooltip: s('nav_tasks'),
            icon: const Icon(Icons.checklist),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    TaskListScreen(controller: TaskController(widget.db)))),
          ),
          IconButton(
            tooltip: s('nav_timer'),
            icon: const Icon(Icons.timer_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    TimerScreen(controller: TimerController(widget.db)))),
          ),
          IconButton(
            tooltip: s('nav_progress'),
            icon: const Icon(Icons.show_chart),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ProgressScreen(db: widget.db))),
          ),
          IconButton(
            tooltip: s('nav_settings'),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        children: [
          for (final s in widget.engine.availableSessions) _sessionCard(s),
        ],
      ),
    );
  }

  Widget _sessionCard(Session s) {
    final locale = AppLocale.of(context)?.code ?? AppLocaleCode.en;
    String tr(String key) => AppStrings.tr(locale, key);
    final state = widget.engine.sessionState(s);
    final (label, color) = switch (state) {
      SessionState.completed => (tr('session_completed'), AppColors.green900),
      SessionState.inProgress => (tr('session_in_progress'), AppColors.primary700),
      _ => (tr('session_available'), AppColors.textSecondary),
    };
    final isInProgress = state == SessionState.inProgress;
    return Card(
      key: Key('session-card-${s.id}'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius12),
        side: BorderSide(
          color: isInProgress ? AppColors.primary500 : AppColors.border,
          width: isInProgress ? 4 : 1,
        ),
      ),
      child: ListTile(
        title: Text('${tr('session_label')} ${s.order} — ${s.titleFor(locale.name)}',
            style: AppText.subtitle),
        subtitle: Text(label,
            style: AppText.small.copyWith(color: color)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => SessionScreen(
                    session: s,
                    onProgress: (session) async {
                      await widget.engine.persist(
                          DriftProgressStore(widget.db));
                      await RetentionService(widget.db)
                          .record('session_completed');
                      if (context.mounted) setState(() {});
                    },
                    onFormSubmit: (formId, answers) async {
                      final now =
                          DateTime.now().toUtc().toIso8601String();
                      await widget.db.into(widget.db.formSubmissions).insert(
                          FormSubmissionsCompanion.insert(
                              id: 'sub-${Random().nextInt(1 << 32).toRadixString(16)}',
                              formId: formId,
                              answersJson: jsonEncode(answers),
                              submittedAt: now,
                              updatedAt: now));
                      await RetentionService(widget.db)
                          .record('form_submitted');
                    },
                  )));
          if (context.mounted) setState(() {});
        },
      ),
    );
  }
}
