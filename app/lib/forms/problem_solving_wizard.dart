import 'package:flutter/material.dart';

import '../l10n/app_locale.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import 'form_controller.dart';
import 'form_definition.dart';

/// 6-step Problem-Solving wizard (spec Ch6): linear steps, one field each.
/// Reuses FormController validation; final submit collects all answers.
class ProblemSolvingWizard extends StatefulWidget {
  final FormDefinition form;
  final Future<void> Function(Map<String, dynamic> answers)? onSubmit;
  const ProblemSolvingWizard({super.key, required this.form, this.onSubmit});

  @override
  State<ProblemSolvingWizard> createState() => _ProblemSolvingWizardState();
}

class _ProblemSolvingWizardState extends State<ProblemSolvingWizard> {
  late final FormController _controller;
  late final List<TextEditingController> _texts;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _controller = FormController(widget.form);
    _texts = [
      for (final f in widget.form.fields)
        TextEditingController(text: _controller.answers[f.id]?.toString() ?? ''),
    ];
  }

  @override
  void dispose() {
    for (final c in _texts) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() {
    final f = widget.form.fields[_step];
    _controller.setValue(f.id, _texts[_step].text.trim());
    setState(() => _step++);
  }

  Future<void> _finish() async {
    for (var i = 0; i < widget.form.fields.length; i++) {
      _controller.setValue(widget.form.fields[i].id, _texts[i].text.trim());
    }
    await widget.onSubmit?.call(_controller.toJson());
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.form.fields[_step];
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
                tr('problem_solving_step')
                    .replaceAll('%1', (_step + 1).toString())
                    .replaceAll('%2', widget.form.fields.length.toString()),
                style: AppText.caption.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(field.labelFor(locale.name), style: AppText.h2),
              const SizedBox(height: AppTheme.spacing24),
              TextField(
                controller: _texts[_step],
                maxLines: 5,
                decoration: InputDecoration(hintText: tr('problem_solving_hint')),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed:
                        _step > 0 ? () => setState(() => _step--) : null,
                    child: Text(tr('session_back')),
                  ),
                  _step < widget.form.fields.length - 1
                      ? FilledButton(
                          onPressed: _next, child: Text(tr('problem_solving_next')))
                      : FilledButton(
                          onPressed: _finish, child: Text(tr('problem_solving_finish'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
