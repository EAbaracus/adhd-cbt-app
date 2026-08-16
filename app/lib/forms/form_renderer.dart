import 'package:flutter/material.dart';

import '../l10n/app_locale.dart';
import '../l10n/app_strings.dart';
import '../store/app_database.dart';
import '../store/draft_store_seam.dart';
import '../store/draft_store.dart';
import '../theme/app_theme.dart';
import 'form_controller.dart';
import 'form_definition.dart';

/// Schema-driven form renderer (I1: calm, one primary action).
/// New form = data; this widget is the only renderer.
class FormScreen extends StatefulWidget {
  final FormDefinition form;
  final FormController? initial;
  final Future<void> Function(Map<String, dynamic> answers)? onSubmit;
  final DraftStoreSeam? draftSeam;
  const FormScreen({
    super.key,
    required this.form,
    this.initial,
    this.onSubmit,
    this.draftSeam,
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  late final FormController _controller;
  late final Map<String, TextEditingController> _textControllers;
  late final DraftStoreSeam _draftSeam;
  final Map<String, String> _fieldErrors = {};
  bool _draftRestored = false;
  bool _submitted = false;

  static AppDatabase _getDefaultDatabase() {
    // Use a temporary path for the default database
    // In production, this should be provided via widget.draftSeam
    return AppDatabase.open(':memory:');
  }

  @override
  void initState() {
    super.initState();
    _draftSeam = widget.draftSeam ?? DraftStoreSeam(DriftDraftStore(_FormScreenState._getDefaultDatabase()));
    _controller = widget.initial ?? FormController(widget.form);
    _textControllers = {
      for (final f in widget.form.fields)
        if (f.kind == FieldKind.text || f.kind == FieldKind.textarea || f.kind == FieldKind.number)
          f.id: TextEditingController(
              text: _controller.answers[f.id]?.toString() ?? ''),
    };
    _restoreDraft();
  }

  Future<void> _restoreDraft() async {
    if (_draftRestored) return;
    _draftRestored = true;
    if (widget.draftSeam != null) {
      final draft = await widget.draftSeam!.restore(widget.form.id);
      if (draft != null && draft.isNotEmpty && mounted) {
        _controller = FormController.fromJson(widget.form, draft);
        // Update text controllers
        for (final f in widget.form.fields) {
          final tc = _textControllers[f.id];
          if (tc != null) {
            final value = _controller.answers[f.id];
            if (value != null) {
              tc.text = value.toString();
            }
          }
        }
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    _draftSeam.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final locale = AppLocale.of(context)?.code ?? AppLocaleCode.en;
    bool hasErrors = false;

    for (final f in widget.form.fields) {
      final tc = _textControllers[f.id];
      if (tc != null) {
        final raw = tc.text.trim();
        if (raw.isNotEmpty) {
          final value = f.kind == FieldKind.number ? int.tryParse(raw) : raw;
          final ok = _controller.setValue(f.id, value);
          if (ok) {
            _fieldErrors.remove(f.id);
          } else {
            _fieldErrors[f.id] = AppStrings.tr(locale, 'form_invalid_value');
            hasErrors = true;
          }
        } else {
          // Empty field - remove any existing error and don't set value
          _fieldErrors.remove(f.id);
        }
      }
    }

    // Also check non-text fields that might have been set via UI (scale, bool)
    // They use setValue directly in onChanged, so we need to validate those too
    for (final f in widget.form.fields) {
      if (_textControllers[f.id] == null) {
        final ans = _controller.answers[f.id];
        if (ans != null) {
          // Validate existing answer
          final ok = _controller.setValue(f.id, ans);
          if (!ok) {
            _fieldErrors[f.id] = AppStrings.tr(locale, 'form_invalid_value');
            hasErrors = true;
          }
        }
      }
    }

    if (hasErrors) {
      setState(() {});
      return;
    }

    _submitted = true;
    _draftSeam.markSubmitted();
    await widget.onSubmit?.call(_controller.toJson());
  }

  void _onAnswerChanged() {
    if (widget.draftSeam != null && !_submitted) {
      widget.draftSeam!.saveDebounced(widget.form.id, _controller.toJson());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.of(context)?.code ?? AppLocaleCode.en;
    return Scaffold(
      appBar: AppBar(title: Text(widget.form.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          children: [
            for (final f in widget.form.fields) ...[
              _field(f, locale),
              const SizedBox(height: AppTheme.spacing24),
            ],
            const SizedBox(height: AppTheme.spacing16),
            FilledButton(
              onPressed: _save,
              child: Text(AppStrings.tr(locale, 'form_save')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(FieldDefinition f, AppLocaleCode locale) {
    final error = _fieldErrors[f.id];
    final showError = error != null && error.isNotEmpty;

    Widget field;
    switch (f.kind) {
      case FieldKind.scale0to3:
        field = _scale(f, 3);
        break;
      case FieldKind.scale0to100:
        field = _scale(f, 100);
        break;
      case FieldKind.bool:
        field = SwitchListTile(
          title: Text(f.label, style: AppText.body),
          value: _controller.answers[f.id] == true,
          onChanged: (v) {
            _controller.setValue(f.id, v);
            _onAnswerChanged();
          },
        );
        break;
      case FieldKind.text:
      case FieldKind.textarea:
        field = TextField(
          key: Key('textarea-${f.id}'),
          controller: _textControllers[f.id],
          maxLines: f.kind == FieldKind.textarea ? 4 : 1,
          decoration: InputDecoration(
            labelText: f.label,
            errorText: showError ? error : null,
          ),
          onChanged: (_) => _onAnswerChanged(),
        );
        break;
      case FieldKind.number:
        field = TextField(
          key: Key('number-${f.id}'),
          controller: _textControllers[f.id],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: f.label,
            errorText: showError ? error : null,
          ),
          onChanged: (_) => _onAnswerChanged(),
        );
        break;
    }

    return field;
  }

  Widget _scale(FieldDefinition f, int max) {
    final error = _fieldErrors[f.id];
    final showError = error != null && error.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(f.label, style: AppText.body),
        const SizedBox(height: AppTheme.spacing12),
        Row(
          children: [
            for (var v = 0; v <= max; v += (max > 3 ? 10 : 1)) ...[
              InkWell(
                key: Key('scale-${f.id}-$v'),
                onTap: () {
                  _controller.setValue(f.id, v);
                  _onAnswerChanged();
                },
                borderRadius: BorderRadius.circular(AppTheme.radius12),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _controller.answers[f.id] == v
                        ? AppColors.primary500
                        : AppColors.panel,
                  ),
                  child: Text(
                    '$v',
                    style: AppText.body.copyWith(
                      color: _controller.answers[f.id] == v
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (v < max) const SizedBox(width: AppTheme.spacing8),
            ],
          ],
        ),
        if (showError) ...[
          const SizedBox(height: AppTheme.spacing8),
          Text(
            error,
            style: AppText.caption.copyWith(color: AppColors.red500),
          ),
        ],
      ],
    );
  }
}