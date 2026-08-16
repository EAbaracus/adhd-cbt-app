import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'form_definition.dart';
import 'thought_record_controller.dart';

/// Progressive Thought Record (spec Ch10-12): situation+thought -> error
/// catalog -> rational response. Back always available; no forced completion.
class ThoughtRecordScreen extends StatefulWidget {
  final FormDefinition form;
  final Future<void> Function(Map<String, dynamic> answers)? onSubmit;
  const ThoughtRecordScreen({super.key, required this.form, this.onSubmit});

  @override
  State<ThoughtRecordScreen> createState() => _ThoughtRecordScreenState();
}

class _ThoughtRecordScreenState extends State<ThoughtRecordScreen> {
  late final ThoughtRecordController _controller;
  int _step = 0;
  final _situation = TextEditingController();
  final _thought = TextEditingController();
  final _rational = TextEditingController();
  String? _selectedError;

  @override
  void initState() {
    super.initState();
    _controller = ThoughtRecordController(widget.form);
  }

  @override
  void dispose() {
    _situation.dispose();
    _thought.dispose();
    _rational.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 0) {
      _controller.setValue('situation', _situation.text.trim());
      _controller.setValue('automatic_thought', _thought.text.trim());
    }
    setState(() => _step++);
  }

  void _finish() {
    _controller.setValue('rational_response', _rational.text.trim());
    if (_selectedError != null) {
      _controller.setValue('thinking_error', _selectedError);
    }
    widget.onSubmit?.call(_controller.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.form.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step ${_step + 1} of 3',
                style: AppText.caption.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppTheme.spacing24),
              Expanded(child: _stepWidget()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _step > 0
                        ? () => setState(() => _step--)
                        : null,
                    child: const Text('Back'),
                  ),
                  _step < 2
                      ? FilledButton(
                          onPressed: _next, child: const Text('Next'))
                      : FilledButton(
                          onPressed: _finish, child: const Text('Finish')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepWidget() {
    switch (_step) {
      case 0:
        return Column(
          children: [
            Text('Situation', style: AppText.h2),
            const SizedBox(height: AppTheme.spacing12),
            TextField(
              key: const Key('tr-situation'),
              controller: _situation,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'What happened?'),
            ),
            const SizedBox(height: AppTheme.spacing24),
            Text('Automatic thought', style: AppText.h2),
            const SizedBox(height: AppTheme.spacing12),
            TextField(
              key: const Key('tr-automatic'),
              controller: _thought,
              maxLines: 3,
              decoration:
                  const InputDecoration(hintText: 'What went through your mind?'),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thinking error', style: AppText.h2),
            const SizedBox(height: AppTheme.spacing8),
            Text('Which pattern fits best?',
                style: AppText.body.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppTheme.spacing16),
            Wrap(
              spacing: AppTheme.spacing8,
              runSpacing: AppTheme.spacing8,
              children: [
                for (final o in _controller.errorOptions)
                  ChoiceChip(
                    key: Key('tr-error-$o'),
                    label: Text(o),
                    selected: _selectedError == o,
                    onSelected: (_) => setState(() => _selectedError = o),
                  ),
              ],
            ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rational response', style: AppText.h2),
            const SizedBox(height: AppTheme.spacing12),
            TextField(
              key: const Key('tr-rational'),
              controller: _rational,
              maxLines: 4,
              decoration: const InputDecoration(
                  hintText: 'The most accurate, useful thought available'),
            ),
          ],
        );
    }
  }
}
