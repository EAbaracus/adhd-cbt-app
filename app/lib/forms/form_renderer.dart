import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'form_controller.dart';
import 'form_definition.dart';

/// Schema-driven form renderer (I1: calm, one primary action).
/// New form = data; this widget is the only renderer.
class FormScreen extends StatefulWidget {
  final FormDefinition form;
  final FormController? initial;
  final Future<void> Function(Map<String, dynamic> answers)? onSubmit;
  const FormScreen({super.key, required this.form, this.initial, this.onSubmit});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  late final FormController _controller;
  late final Map<String, TextEditingController> _textControllers;

  @override
  void initState() {
    super.initState();
    _controller = widget.initial ?? FormController(widget.form);
    _textControllers = {
      for (final f in widget.form.fields)
        if (f.kind == FieldKind.text || f.kind == FieldKind.textarea || f.kind == FieldKind.number)
          f.id: TextEditingController(
              text: _controller.answers[f.id]?.toString() ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    for (final f in widget.form.fields) {
      final tc = _textControllers[f.id];
      if (tc != null) {
        final raw = tc.text.trim();
        if (raw.isNotEmpty) {
          _controller.setValue(f.id, f.kind == FieldKind.number ? int.tryParse(raw) : raw);
        }
      }
    }
    await widget.onSubmit?.call(_controller.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.form.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          children: [
            for (final f in widget.form.fields) ...[
              _field(f),
              const SizedBox(height: AppTheme.spacing24),
            ],
            const SizedBox(height: AppTheme.spacing16),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  Widget _field(FieldDefinition f) {
    switch (f.kind) {
      case FieldKind.scale0to3:
        return _scale(f, 3);
      case FieldKind.scale0to100:
        return _scale(f, 100);
      case FieldKind.bool:
        return SwitchListTile(
          title: Text(f.label, style: AppText.body),
          value: _controller.answers[f.id] == true,
          onChanged: (v) => setState(() => _controller.setValue(f.id, v)),
        );
      case FieldKind.text:
      case FieldKind.textarea:
        return TextField(
          key: Key('textarea-${f.id}'),
          controller: _textControllers[f.id],
          maxLines: f.kind == FieldKind.textarea ? 4 : 1,
          decoration: InputDecoration(labelText: f.label),
          onChanged: (_) => setState(() {}),
        );
      case FieldKind.number:
        return TextField(
          key: Key('number-${f.id}'),
          controller: _textControllers[f.id],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: f.label),
          onChanged: (_) => setState(() {}),
        );
    }
  }

  Widget _scale(FieldDefinition f, int max) {
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
                onTap: () => setState(() => _controller.setValue(f.id, v)),
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
      ],
    );
  }
}
