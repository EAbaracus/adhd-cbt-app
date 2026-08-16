import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:math';

import '../engine/models.dart';
import '../engine/program_engine.dart';
import '../store/app_database.dart';
import '../store/drift_progress_store.dart';
import '../tasks/task_controller.dart';
import '../theme/app_theme.dart';
import '../timer/timer_controller.dart';
import 'session_screen.dart';
import 'task_list_screen.dart';
import 'timer_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program'),
        actions: [
          IconButton(
            tooltip: 'Tasks',
            icon: const Icon(Icons.checklist),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    TaskListScreen(controller: TaskController(widget.db)))),
          ),
          IconButton(
            tooltip: 'Focus timer',
            icon: const Icon(Icons.timer_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    TimerScreen(controller: TimerController(widget.db)))),
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
    final state = widget.engine.sessionState(s);
    final (label, color) = switch (state) {
      SessionState.completed => ('Completed', AppColors.green900),
      SessionState.inProgress => ('In progress', AppColors.primary700),
      _ => ('Available', AppColors.textSecondary),
    };
    return Card(
      child: ListTile(
        title: Text('Session ${s.order} — ${s.title}',
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
                    },
                  )));
          if (context.mounted) setState(() {});
        },
      ),
    );
  }
}
