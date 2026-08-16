/// Pure Dart content models. No Flutter imports (G1).
library;

enum CheckpointState { completed, inProgress, deferred, current }

enum CheckpointType { ritual, reading, exercise, homework, reflection }

CheckpointType _cpType(String raw) => CheckpointType.values.firstWhere(
    (t) => t.name == raw,
    orElse: () => throw FormatException('unknown checkpoint type: $raw'));

class Checkpoint {
  final String id;
  final CheckpointType type;
  final String title;
  final List<String> content;
  final String? formRef;
  final List<String> requires;
  CheckpointState state;

  Checkpoint({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.formRef,
    this.requires = const [],
    this.state = CheckpointState.current,
  });

  factory Checkpoint.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] as Map?)?['en'] as String? ?? json['id'] as String;
    final content =
        ((json['content'] as Map?)?['en'] as List?)?.cast<String>() ?? <String>[];
    return Checkpoint(
      id: json['id'] as String,
      type: _cpType(json['type'] as String),
      title: title,
      content: content,
      formRef: json['formRef'] as String?,
      requires: (json['requires'] as List?)?.cast<String>() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': {'en': title},
        'content': {'en': content},
        if (formRef != null) 'formRef': formRef,
        'state': state.name,
      };
}

enum SessionState { completed, inProgress, available, locked }

class Session {
  final String id;
  final int order;
  final String module;
  final String title;
  final bool optional;
  final List<Checkpoint> checkpoints;

  Session({
    required this.id,
    required this.order,
    required this.module,
    required this.title,
    this.optional = false,
    required this.checkpoints,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final order = json['order'];
    final module = json['module'];
    final title = (json['title'] as Map?)?['en'] as String?;
    final cps = json['checkpoints'];
    if (id is! String || order is! int || module is! String || title == null || cps is! List) {
      throw const FormatException('session missing required fields');
    }
    return Session(
      id: id,
      order: order,
      module: module,
      title: title,
      optional: json['optional'] == true,
      checkpoints: cps
          .map((c) => Checkpoint.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order': order,
        'module': module,
        'title': {'en': title},
        if (optional) 'optional': true,
        'checkpoints': checkpoints.map((c) => c.toJson()).toList(),
      };
}
