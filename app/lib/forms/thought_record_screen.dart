import 'package:flutter/material.dart';

import '../l10n/app_locale.dart';
import '../l10n/app_strings.dart';
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
    final locale = AppLocale.of(context)?.code ?? AppLocaleCode.en;
    String tr(String key) => AppStrings.tr(locale, key);
    return Scaffold(
      appBar: AppBar(title: Text(widget.form.titleFor(locale.name))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('thought_record_step').replaceAll('%1', (_step + 1).toString()).replaceAll('%2', '3'),
                style: AppText.caption.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppTheme.spacing24),
              Expanded(child: _stepWidget(tr, locale)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _step > 0
                        ? () => setState(() => _step--)
                        : null,
                    child: Text(tr('session_back')),
                  ),
                  _step < 2
                      ? FilledButton(
                          onPressed: _next, child: Text(tr('thought_record_next')))
                      : FilledButton(
                          onPressed: _finish, child: Text(tr('thought_record_finish'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepWidget(Function(String) tr, AppLocaleCode locale) {
    switch (_step) {
      case 0:
        return Column(
          children: [
            Text(tr('thought_record_situation_title'), style: AppText.h2),
            const SizedBox(height: AppTheme.spacing12),
            TextField(
              key: const Key('tr-situation'),
              controller: _situation,
              maxLines: 3,
              decoration: InputDecoration(hintText: tr('thought_record_situation_hint')),
            ),
            const SizedBox(height: AppTheme.spacing24),
            Text(tr('thought_record_thought_title'), style: AppText.h2),
            const SizedBox(height: AppTheme.spacing12),
            TextField(
              key: const Key('tr-automatic'),
              controller: _thought,
              maxLines: 3,
              decoration: InputDecoration(hintText: tr('thought_record_thought_hint')),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('thought_record_error_title'), style: AppText.h2),
            const SizedBox(height: AppTheme.spacing8),
            Text(tr('thought_record_error_hint'),
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
            Text(tr('thought_record_rational_title'), style: AppText.h2),
            const SizedBox(height: AppTheme.spacing12),
            TextField(
              key: const Key('tr-rational'),
              controller: _rational,
              maxLines: 4,
              decoration: InputDecoration(hintText: tr('thought_record_rational_hint')),
            ),
          ],
        );
    }
  }
}
