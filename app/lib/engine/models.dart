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
  })  : titles = {'en': title},
        contents = {'en': content};

  final Map<String, String> titles;
  final Map<String, List<String>> contents;

  String titleFor(String locale) => titles[locale] ?? titles['en'] ?? title;
  List<String> contentFor(String locale) =>
      contents[locale] ?? contents['en'] ?? content;

  factory Checkpoint.fromJson(Map<String, dynamic> json) {
    final titleJson = (json['title'] as Map?) ?? const {};
    final contentJson = (json['content'] as Map?) ?? const {};
    final cp = Checkpoint(
      id: json['id'] as String,
      type: _cpType(json['type'] as String),
      title: titleJson['en'] as String? ?? json['id'] as String,
      content: (contentJson['en'] as List?)?.cast<String>() ?? <String>[],
      formRef: json['formRef'] as String?,
      requires: (json['requires'] as List?)?.cast<String>() ?? const [],
    );
    cp.titles
      ..clear()
      ..addAll({
        for (final e in titleJson.entries)
          if (e.value is String) e.key: e.value as String,
      });
    cp.contents
      ..clear()
      ..addAll({
        for (final e in contentJson.entries)
          if (e.value is List) e.key: (e.value as List).cast<String>(),
      });
    return cp;
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
  final Map<String, String> titles;

  Session({
    required this.id,
    required this.order,
    required this.module,
    required this.title,
    this.optional = false,
    required this.checkpoints,
  }) : titles = {'en': title};

  String titleFor(String locale) => titles[locale] ?? titles['en'] ?? title;

  factory Session.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final order = json['order'];
    final module = json['module'];
    final titleJson = (json['title'] as Map?) ?? const {};
    final cps = json['checkpoints'];
    if (id is! String ||
        order is! int ||
        module is! String ||
        titleJson.isEmpty ||
        cps is! List) {
      throw const FormatException('session missing required fields');
    }
    final s = Session(
      id: id,
      order: order,
      module: module,
      title: titleJson['en'] as String? ?? id,
      optional: json['optional'] == true,
      checkpoints: cps
          .map((c) => Checkpoint.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
    s.titles
      ..clear()
      ..addAll({
        for (final e in titleJson.entries)
          if (e.value is String) e.key: e.value as String,
      });
    return s;
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
