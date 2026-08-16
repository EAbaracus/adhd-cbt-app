import 'package:flutter/material.dart';

import '../l10n/app_locale.dart';
import '../l10n/app_strings.dart';
import '../tasks/task_controller.dart';
import '../theme/app_theme.dart';

class TaskListScreen extends StatefulWidget {
  final TaskController controller;
  const TaskListScreen({super.key, required this.controller});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _title = TextEditingController();
  String _priority = 'B';
  List<Task> _tasks = [];
  bool _loading = true;
  final _stepInputs = <String, TextEditingController>{};

  Function(String) tr = (key) => key;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _title.dispose();
    for (final c in _stepInputs.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _reload() async {
    final tasks = await widget.controller.list();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  Future<void> _add() async {
    final t = _title.text.trim();
    if (t.isEmpty) return;
    await widget.controller.add(t, _priority);
    _title.clear();
    await _reload();
  }

  Color _chipColor(String p) {
    switch (p) {
      case 'A':
        return AppColors.green500;
      case 'B':
        return AppColors.amber500;
      default:
        return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.of(context)?.code ?? AppLocaleCode.en;
    tr = (key) => AppStrings.tr(locale, key);
    return Scaffold(
      appBar: AppBar(title: Text(tr('task_list_title'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _title,
                          decoration: InputDecoration(
                              hintText: tr('task_list_add_hint')),
                          onSubmitted: (_) => _add(),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'A', label: Text('A')),
                          ButtonSegment(value: 'B', label: Text('B')),
                          ButtonSegment(value: 'C', label: Text('C')),
                        ],
                        selected: {_priority},
                        onSelectionChanged: (s) =>
                            setState(() => _priority = s.first),
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      IconButton(
                        onPressed: _add,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _tasks.isEmpty
                      ? Center(
                          child: Text(tr('task_list_empty'),
                              style: AppText.small
                                  .copyWith(color: AppColors.textTertiary)))
                      : ListView.builder(
                          itemCount: _tasks.length,
                          itemBuilder: (ctx, i) => _taskCard(_tasks[i]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _taskCard(Task t) {
    final stepCtl = _stepInputs.putIfAbsent(t.id, TextEditingController.new);
    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16, vertical: AppTheme.spacing4),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: t.done,
                  onChanged: (_) async {
                    await widget.controller.toggleDone(t.id);
                    await _reload();
                  },
                ),
                Expanded(
                  child: Text(
                    t.title,
                    style: t.done
                        ? AppText.body.copyWith(
                            color: AppColors.textTertiary,
                            decoration: TextDecoration.lineThrough)
                        : AppText.body,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing8,
                      vertical: AppTheme.spacing4),
                  decoration: BoxDecoration(
                    color: _chipColor(t.priority).withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppTheme.radius12),
                  ),
                  child: Text(t.priority,
                      style: AppText.caption.copyWith(
                          color: t.priority == 'A'
                              ? AppColors.green900
                              : t.priority == 'B'
                                  ? AppColors.amber900
                                  : AppColors.textSecondary,
                          fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await widget.controller.delete(t.id);
                    await _reload();
                  },
                ),
              ],
            ),
            if (t.steps.isNotEmpty)
              for (final s in t.steps)
                CheckboxListTile(
                  dense: true,
                  value: s.done,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(s.title,
                      style: AppText.small.copyWith(
                          color: s.done
                              ? AppColors.textTertiary
                              : AppColors.textSecondary)),
                  onChanged: (_) async {
                    await widget.controller.toggleStep(s.id);
                    await _reload();
                  },
                ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: stepCtl,
                    decoration:
                        InputDecoration(hintText: tr('task_list_step_hint')),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () async {
                    final s = stepCtl.text.trim();
                    if (s.isEmpty) return;
                    stepCtl.clear();
                    await widget.controller.addStep(t.id, s);
                    await _reload();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
