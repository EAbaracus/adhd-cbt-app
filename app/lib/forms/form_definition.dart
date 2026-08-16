/// Schema-driven form model (pure Dart, G1). New form = data, not code.
library;

enum FieldKind { scale0to3, scale0to100, text, textarea, bool, number }

const _kindMap = {
  'scale_0_3': FieldKind.scale0to3,
  'scale_0_100': FieldKind.scale0to100,
  'text': FieldKind.text,
  'textarea': FieldKind.textarea,
  'bool': FieldKind.bool,
  'number': FieldKind.number,
};

FieldKind _kind(String raw) =>
    _kindMap[raw] ?? (throw FormatException('unknown field kind: $raw'));

class FieldDefinition {
  final String id;
  final FieldKind kind;
  final String label;
  final List<String> options;
  final Map<String, String> labels;
  FieldDefinition(
      {required this.id,
      required this.kind,
      required this.label,
      this.labels = const {},
      this.options = const []});

  /// Locale-aware label; falls back to en, then id (G3: never empty).
  String labelFor(String code) => labels[code] ?? labels['en'] ?? label;

  factory FieldDefinition.fromJson(Map<String, dynamic> json) =>
      FieldDefinition(
        id: json['id'] as String,
        kind: _kind(json['kind'] as String),
        label: (json['label'] as Map?)?['en'] as String? ?? json['id'] as String,
        labels: ((json['label'] as Map?) ?? {})
            .map((k, v) => MapEntry(k as String, v as String)),
        options: (json['options'] as List?)?.cast<String>() ?? const [],
      );
}

class FormDefinition {
  final String id;
  final String type;
  final String title;
  final List<FieldDefinition> fields;
  final Map<String, String> titles;
  FormDefinition(
      {required this.id,
      required this.type,
      required this.title,
      this.titles = const {},
      required this.fields});

  /// Locale-aware title; falls back to en, then id.
  String titleFor(String code) => titles[code] ?? titles['en'] ?? title;

  factory FormDefinition.fromJson(Map<String, dynamic> json) =>
      FormDefinition(
        id: json['id'] as String,
        type: json['type'] as String,
        title: (json['title'] as Map?)?['en'] as String? ?? json['id'] as String,
        titles: ((json['title'] as Map?) ?? {})
            .map((k, v) => MapEntry(k as String, v as String)),
        fields: (json['fields'] as List? ?? [])
            .map((f) => FieldDefinition.fromJson(f as Map<String, dynamic>))
            .toList(),
      );
}
