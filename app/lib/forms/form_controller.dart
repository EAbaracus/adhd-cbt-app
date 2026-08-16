import 'form_definition.dart';

class FormController {
  final FormDefinition form;
  final Map<String, dynamic> answers;
  FormController(this.form, [Map<String, dynamic>? initial])
      : answers = {...?initial};

  FieldDefinition? _find(String id) {
    for (final f in form.fields) {
      if (f.id == id) return f;
    }
    return null;
  }

  bool setValue(String id, dynamic value) {
    final f = _find(id);
    if (f == null) return false;
    if (f.kind == FieldKind.scale0to3) {
      if (value is! int || value < 0 || value > 3) return false;
    } else if (f.kind == FieldKind.scale0to100) {
      if (value is! int || value < 0 || value > 100) return false;
    } else if (f.kind == FieldKind.number) {
      if (value is! num || value < 0) return false;
    } else if (f.kind == FieldKind.bool) {
      if (value is! bool) return false;
    } else {
      if (value is! String) return false;
    }
    answers[f.id] = value;
    return true;
  }

  Map<String, dynamic> toJson() => Map.of(answers);

  static FormController fromJson(FormDefinition form, Map<String, dynamic> json) =>
      FormController(form, json);
}
