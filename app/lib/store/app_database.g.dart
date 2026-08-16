// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSetting extends DataClass implements Insertable<UserSetting> {
  final String key;
  final String value;
  const UserSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory UserSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  UserSetting copyWith({String? key, String? value}) =>
      UserSetting(key: key ?? this.key, value: value ?? this.value);
  UserSetting copyWithCompanion(UserSettingsCompanion data) {
    return UserSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<UserSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return UserSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CheckpointStatesTable extends CheckpointStates
    with TableInfo<$CheckpointStatesTable, CheckpointState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckpointStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _checkpointIdMeta = const VerificationMeta(
    'checkpointId',
  );
  @override
  late final GeneratedColumn<String> checkpointId = GeneratedColumn<String>(
    'checkpoint_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [checkpointId, state, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checkpoint_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<CheckpointState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('checkpoint_id')) {
      context.handle(
        _checkpointIdMeta,
        checkpointId.isAcceptableOrUnknown(
          data['checkpoint_id']!,
          _checkpointIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkpointIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {checkpointId};
  @override
  CheckpointState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CheckpointState(
      checkpointId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checkpoint_id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CheckpointStatesTable createAlias(String alias) {
    return $CheckpointStatesTable(attachedDatabase, alias);
  }
}

class CheckpointState extends DataClass implements Insertable<CheckpointState> {
  final String checkpointId;
  final String state;
  final String updatedAt;
  const CheckpointState({
    required this.checkpointId,
    required this.state,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['checkpoint_id'] = Variable<String>(checkpointId);
    map['state'] = Variable<String>(state);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  CheckpointStatesCompanion toCompanion(bool nullToAbsent) {
    return CheckpointStatesCompanion(
      checkpointId: Value(checkpointId),
      state: Value(state),
      updatedAt: Value(updatedAt),
    );
  }

  factory CheckpointState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CheckpointState(
      checkpointId: serializer.fromJson<String>(json['checkpointId']),
      state: serializer.fromJson<String>(json['state']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'checkpointId': serializer.toJson<String>(checkpointId),
      'state': serializer.toJson<String>(state),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  CheckpointState copyWith({
    String? checkpointId,
    String? state,
    String? updatedAt,
  }) => CheckpointState(
    checkpointId: checkpointId ?? this.checkpointId,
    state: state ?? this.state,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CheckpointState copyWithCompanion(CheckpointStatesCompanion data) {
    return CheckpointState(
      checkpointId: data.checkpointId.present
          ? data.checkpointId.value
          : this.checkpointId,
      state: data.state.present ? data.state.value : this.state,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CheckpointState(')
          ..write('checkpointId: $checkpointId, ')
          ..write('state: $state, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(checkpointId, state, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CheckpointState &&
          other.checkpointId == this.checkpointId &&
          other.state == this.state &&
          other.updatedAt == this.updatedAt);
}

class CheckpointStatesCompanion extends UpdateCompanion<CheckpointState> {
  final Value<String> checkpointId;
  final Value<String> state;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const CheckpointStatesCompanion({
    this.checkpointId = const Value.absent(),
    this.state = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CheckpointStatesCompanion.insert({
    required String checkpointId,
    required String state,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : checkpointId = Value(checkpointId),
       state = Value(state),
       updatedAt = Value(updatedAt);
  static Insertable<CheckpointState> custom({
    Expression<String>? checkpointId,
    Expression<String>? state,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (checkpointId != null) 'checkpoint_id': checkpointId,
      if (state != null) 'state': state,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CheckpointStatesCompanion copyWith({
    Value<String>? checkpointId,
    Value<String>? state,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return CheckpointStatesCompanion(
      checkpointId: checkpointId ?? this.checkpointId,
      state: state ?? this.state,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (checkpointId.present) {
      map['checkpoint_id'] = Variable<String>(checkpointId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CheckpointStatesCompanion(')
          ..write('checkpointId: $checkpointId, ')
          ..write('state: $state, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    priority,
    done,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String title;
  final String priority;
  final bool done;
  final String createdAt;
  final String updatedAt;
  const Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.done,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['priority'] = Variable<String>(priority);
    map['done'] = Variable<bool>(done);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      priority: Value(priority),
      done: Value(done),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      priority: serializer.fromJson<String>(json['priority']),
      done: serializer.fromJson<bool>(json['done']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'priority': serializer.toJson<String>(priority),
      'done': serializer.toJson<bool>(done),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? priority,
    bool? done,
    String? createdAt,
    String? updatedAt,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    priority: priority ?? this.priority,
    done: done ?? this.done,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      priority: data.priority.present ? data.priority.value : this.priority,
      done: data.done.present ? data.done.value : this.done,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('priority: $priority, ')
          ..write('done: $done, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, priority, done, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.priority == this.priority &&
          other.done == this.done &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> priority;
  final Value<bool> done;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.priority = const Value.absent(),
    this.done = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String title,
    required String priority,
    this.done = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       priority = Value(priority),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? priority,
    Expression<bool>? done,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (priority != null) 'priority': priority,
      if (done != null) 'done': done,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? priority,
    Value<bool>? done,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('priority: $priority, ')
          ..write('done: $done, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskStepsTable extends TaskSteps
    with TableInfo<$TaskStepsTable, TaskStep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, taskId, title, done, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskStep> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskStep map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskStep(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $TaskStepsTable createAlias(String alias) {
    return $TaskStepsTable(attachedDatabase, alias);
  }
}

class TaskStep extends DataClass implements Insertable<TaskStep> {
  final String id;
  final String taskId;
  final String title;
  final bool done;
  final int position;
  const TaskStep({
    required this.id,
    required this.taskId,
    required this.title,
    required this.done,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['title'] = Variable<String>(title);
    map['done'] = Variable<bool>(done);
    map['position'] = Variable<int>(position);
    return map;
  }

  TaskStepsCompanion toCompanion(bool nullToAbsent) {
    return TaskStepsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      title: Value(title),
      done: Value(done),
      position: Value(position),
    );
  }

  factory TaskStep.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskStep(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      title: serializer.fromJson<String>(json['title']),
      done: serializer.fromJson<bool>(json['done']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'title': serializer.toJson<String>(title),
      'done': serializer.toJson<bool>(done),
      'position': serializer.toJson<int>(position),
    };
  }

  TaskStep copyWith({
    String? id,
    String? taskId,
    String? title,
    bool? done,
    int? position,
  }) => TaskStep(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    title: title ?? this.title,
    done: done ?? this.done,
    position: position ?? this.position,
  );
  TaskStep copyWithCompanion(TaskStepsCompanion data) {
    return TaskStep(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      title: data.title.present ? data.title.value : this.title,
      done: data.done.present ? data.done.value : this.done,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskStep(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('done: $done, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, title, done, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskStep &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.title == this.title &&
          other.done == this.done &&
          other.position == this.position);
}

class TaskStepsCompanion extends UpdateCompanion<TaskStep> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> title;
  final Value<bool> done;
  final Value<int> position;
  final Value<int> rowid;
  const TaskStepsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.title = const Value.absent(),
    this.done = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskStepsCompanion.insert({
    required String id,
    required String taskId,
    required String title,
    this.done = const Value.absent(),
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       title = Value(title),
       position = Value(position);
  static Insertable<TaskStep> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? title,
    Expression<bool>? done,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (title != null) 'title': title,
      if (done != null) 'done': done,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskStepsCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String>? title,
    Value<bool>? done,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return TaskStepsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      done: done ?? this.done,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskStepsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('done: $done, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FormDraftsTable extends FormDrafts
    with TableInfo<$FormDraftsTable, FormDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FormDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _formIdMeta = const VerificationMeta('formId');
  @override
  late final GeneratedColumn<String> formId = GeneratedColumn<String>(
    'form_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answersJsonMeta = const VerificationMeta(
    'answersJson',
  );
  @override
  late final GeneratedColumn<String> answersJson = GeneratedColumn<String>(
    'answers_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [formId, answersJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'form_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<FormDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('form_id')) {
      context.handle(
        _formIdMeta,
        formId.isAcceptableOrUnknown(data['form_id']!, _formIdMeta),
      );
    } else if (isInserting) {
      context.missing(_formIdMeta);
    }
    if (data.containsKey('answers_json')) {
      context.handle(
        _answersJsonMeta,
        answersJson.isAcceptableOrUnknown(
          data['answers_json']!,
          _answersJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_answersJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {formId};
  @override
  FormDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FormDraft(
      formId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form_id'],
      )!,
      answersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answers_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FormDraftsTable createAlias(String alias) {
    return $FormDraftsTable(attachedDatabase, alias);
  }
}

class FormDraft extends DataClass implements Insertable<FormDraft> {
  final String formId;
  final String answersJson;
  final String updatedAt;
  const FormDraft({
    required this.formId,
    required this.answersJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['form_id'] = Variable<String>(formId);
    map['answers_json'] = Variable<String>(answersJson);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  FormDraftsCompanion toCompanion(bool nullToAbsent) {
    return FormDraftsCompanion(
      formId: Value(formId),
      answersJson: Value(answersJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory FormDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FormDraft(
      formId: serializer.fromJson<String>(json['formId']),
      answersJson: serializer.fromJson<String>(json['answersJson']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'formId': serializer.toJson<String>(formId),
      'answersJson': serializer.toJson<String>(answersJson),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  FormDraft copyWith({
    String? formId,
    String? answersJson,
    String? updatedAt,
  }) => FormDraft(
    formId: formId ?? this.formId,
    answersJson: answersJson ?? this.answersJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FormDraft copyWithCompanion(FormDraftsCompanion data) {
    return FormDraft(
      formId: data.formId.present ? data.formId.value : this.formId,
      answersJson: data.answersJson.present
          ? data.answersJson.value
          : this.answersJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FormDraft(')
          ..write('formId: $formId, ')
          ..write('answersJson: $answersJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(formId, answersJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FormDraft &&
          other.formId == this.formId &&
          other.answersJson == this.answersJson &&
          other.updatedAt == this.updatedAt);
}

class FormDraftsCompanion extends UpdateCompanion<FormDraft> {
  final Value<String> formId;
  final Value<String> answersJson;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const FormDraftsCompanion({
    this.formId = const Value.absent(),
    this.answersJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FormDraftsCompanion.insert({
    required String formId,
    required String answersJson,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : formId = Value(formId),
       answersJson = Value(answersJson),
       updatedAt = Value(updatedAt);
  static Insertable<FormDraft> custom({
    Expression<String>? formId,
    Expression<String>? answersJson,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (formId != null) 'form_id': formId,
      if (answersJson != null) 'answers_json': answersJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FormDraftsCompanion copyWith({
    Value<String>? formId,
    Value<String>? answersJson,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return FormDraftsCompanion(
      formId: formId ?? this.formId,
      answersJson: answersJson ?? this.answersJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (formId.present) {
      map['form_id'] = Variable<String>(formId.value);
    }
    if (answersJson.present) {
      map['answers_json'] = Variable<String>(answersJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FormDraftsCompanion(')
          ..write('formId: $formId, ')
          ..write('answersJson: $answersJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimerLogTable extends TimerLog
    with TableInfo<$TimerLogTable, TimerLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimerLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskMeta = const VerificationMeta('task');
  @override
  late final GeneratedColumn<String> task = GeneratedColumn<String>(
    'task',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minutesMeta = const VerificationMeta(
    'minutes',
  );
  @override
  late final GeneratedColumn<int> minutes = GeneratedColumn<int>(
    'minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distractionsMeta = const VerificationMeta(
    'distractions',
  );
  @override
  late final GeneratedColumn<int> distractions = GeneratedColumn<int>(
    'distractions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<String> startedAt = GeneratedColumn<String>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<String> endedAt = GeneratedColumn<String>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    task,
    minutes,
    distractions,
    startedAt,
    endedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timer_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimerLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task')) {
      context.handle(
        _taskMeta,
        task.isAcceptableOrUnknown(data['task']!, _taskMeta),
      );
    } else if (isInserting) {
      context.missing(_taskMeta);
    }
    if (data.containsKey('minutes')) {
      context.handle(
        _minutesMeta,
        minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta),
      );
    } else if (isInserting) {
      context.missing(_minutesMeta);
    }
    if (data.containsKey('distractions')) {
      context.handle(
        _distractionsMeta,
        distractions.isAcceptableOrUnknown(
          data['distractions']!,
          _distractionsMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimerLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimerLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      task: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task'],
      )!,
      minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes'],
      )!,
      distractions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distractions'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ended_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TimerLogTable createAlias(String alias) {
    return $TimerLogTable(attachedDatabase, alias);
  }
}

class TimerLogData extends DataClass implements Insertable<TimerLogData> {
  final String id;
  final String task;
  final int minutes;
  final int distractions;
  final String startedAt;
  final String? endedAt;
  final String updatedAt;
  const TimerLogData({
    required this.id,
    required this.task,
    required this.minutes,
    required this.distractions,
    required this.startedAt,
    this.endedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task'] = Variable<String>(task);
    map['minutes'] = Variable<int>(minutes);
    map['distractions'] = Variable<int>(distractions);
    map['started_at'] = Variable<String>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<String>(endedAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  TimerLogCompanion toCompanion(bool nullToAbsent) {
    return TimerLogCompanion(
      id: Value(id),
      task: Value(task),
      minutes: Value(minutes),
      distractions: Value(distractions),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TimerLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimerLogData(
      id: serializer.fromJson<String>(json['id']),
      task: serializer.fromJson<String>(json['task']),
      minutes: serializer.fromJson<int>(json['minutes']),
      distractions: serializer.fromJson<int>(json['distractions']),
      startedAt: serializer.fromJson<String>(json['startedAt']),
      endedAt: serializer.fromJson<String?>(json['endedAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'task': serializer.toJson<String>(task),
      'minutes': serializer.toJson<int>(minutes),
      'distractions': serializer.toJson<int>(distractions),
      'startedAt': serializer.toJson<String>(startedAt),
      'endedAt': serializer.toJson<String?>(endedAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  TimerLogData copyWith({
    String? id,
    String? task,
    int? minutes,
    int? distractions,
    String? startedAt,
    Value<String?> endedAt = const Value.absent(),
    String? updatedAt,
  }) => TimerLogData(
    id: id ?? this.id,
    task: task ?? this.task,
    minutes: minutes ?? this.minutes,
    distractions: distractions ?? this.distractions,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TimerLogData copyWithCompanion(TimerLogCompanion data) {
    return TimerLogData(
      id: data.id.present ? data.id.value : this.id,
      task: data.task.present ? data.task.value : this.task,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
      distractions: data.distractions.present
          ? data.distractions.value
          : this.distractions,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimerLogData(')
          ..write('id: $id, ')
          ..write('task: $task, ')
          ..write('minutes: $minutes, ')
          ..write('distractions: $distractions, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    task,
    minutes,
    distractions,
    startedAt,
    endedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerLogData &&
          other.id == this.id &&
          other.task == this.task &&
          other.minutes == this.minutes &&
          other.distractions == this.distractions &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.updatedAt == this.updatedAt);
}

class TimerLogCompanion extends UpdateCompanion<TimerLogData> {
  final Value<String> id;
  final Value<String> task;
  final Value<int> minutes;
  final Value<int> distractions;
  final Value<String> startedAt;
  final Value<String?> endedAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const TimerLogCompanion({
    this.id = const Value.absent(),
    this.task = const Value.absent(),
    this.minutes = const Value.absent(),
    this.distractions = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimerLogCompanion.insert({
    required String id,
    required String task,
    required int minutes,
    this.distractions = const Value.absent(),
    required String startedAt,
    this.endedAt = const Value.absent(),
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       task = Value(task),
       minutes = Value(minutes),
       startedAt = Value(startedAt),
       updatedAt = Value(updatedAt);
  static Insertable<TimerLogData> custom({
    Expression<String>? id,
    Expression<String>? task,
    Expression<int>? minutes,
    Expression<int>? distractions,
    Expression<String>? startedAt,
    Expression<String>? endedAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (task != null) 'task': task,
      if (minutes != null) 'minutes': minutes,
      if (distractions != null) 'distractions': distractions,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimerLogCompanion copyWith({
    Value<String>? id,
    Value<String>? task,
    Value<int>? minutes,
    Value<int>? distractions,
    Value<String>? startedAt,
    Value<String?>? endedAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return TimerLogCompanion(
      id: id ?? this.id,
      task: task ?? this.task,
      minutes: minutes ?? this.minutes,
      distractions: distractions ?? this.distractions,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (task.present) {
      map['task'] = Variable<String>(task.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<int>(minutes.value);
    }
    if (distractions.present) {
      map['distractions'] = Variable<int>(distractions.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<String>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<String>(endedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimerLogCompanion(')
          ..write('id: $id, ')
          ..write('task: $task, ')
          ..write('minutes: $minutes, ')
          ..write('distractions: $distractions, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $CheckpointStatesTable checkpointStates = $CheckpointStatesTable(
    this,
  );
  late final $TasksTable tasks = $TasksTable(this);
  late final $TaskStepsTable taskSteps = $TaskStepsTable(this);
  late final $FormDraftsTable formDrafts = $FormDraftsTable(this);
  late final $TimerLogTable timerLog = $TimerLogTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userSettings,
    checkpointStates,
    tasks,
    taskSteps,
    formDrafts,
    timerLog,
  ];
}

typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$UserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTable,
          UserSetting,
          $$UserSettingsTableFilterComposer,
          $$UserSettingsTableOrderingComposer,
          $$UserSettingsTableAnnotationComposer,
          $$UserSettingsTableCreateCompanionBuilder,
          $$UserSettingsTableUpdateCompanionBuilder,
          (
            UserSetting,
            BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>,
          ),
          UserSetting,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTable,
      UserSetting,
      $$UserSettingsTableFilterComposer,
      $$UserSettingsTableOrderingComposer,
      $$UserSettingsTableAnnotationComposer,
      $$UserSettingsTableCreateCompanionBuilder,
      $$UserSettingsTableUpdateCompanionBuilder,
      (
        UserSetting,
        BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>,
      ),
      UserSetting,
      PrefetchHooks Function()
    >;
typedef $$CheckpointStatesTableCreateCompanionBuilder =
    CheckpointStatesCompanion Function({
      required String checkpointId,
      required String state,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$CheckpointStatesTableUpdateCompanionBuilder =
    CheckpointStatesCompanion Function({
      Value<String> checkpointId,
      Value<String> state,
      Value<String> updatedAt,
      Value<int> rowid,
    });

class $$CheckpointStatesTableFilterComposer
    extends Composer<_$AppDatabase, $CheckpointStatesTable> {
  $$CheckpointStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get checkpointId => $composableBuilder(
    column: $table.checkpointId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CheckpointStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $CheckpointStatesTable> {
  $$CheckpointStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get checkpointId => $composableBuilder(
    column: $table.checkpointId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CheckpointStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CheckpointStatesTable> {
  $$CheckpointStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get checkpointId => $composableBuilder(
    column: $table.checkpointId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CheckpointStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CheckpointStatesTable,
          CheckpointState,
          $$CheckpointStatesTableFilterComposer,
          $$CheckpointStatesTableOrderingComposer,
          $$CheckpointStatesTableAnnotationComposer,
          $$CheckpointStatesTableCreateCompanionBuilder,
          $$CheckpointStatesTableUpdateCompanionBuilder,
          (
            CheckpointState,
            BaseReferences<
              _$AppDatabase,
              $CheckpointStatesTable,
              CheckpointState
            >,
          ),
          CheckpointState,
          PrefetchHooks Function()
        > {
  $$CheckpointStatesTableTableManager(
    _$AppDatabase db,
    $CheckpointStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CheckpointStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CheckpointStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CheckpointStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> checkpointId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CheckpointStatesCompanion(
                checkpointId: checkpointId,
                state: state,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String checkpointId,
                required String state,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CheckpointStatesCompanion.insert(
                checkpointId: checkpointId,
                state: state,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CheckpointStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CheckpointStatesTable,
      CheckpointState,
      $$CheckpointStatesTableFilterComposer,
      $$CheckpointStatesTableOrderingComposer,
      $$CheckpointStatesTableAnnotationComposer,
      $$CheckpointStatesTableCreateCompanionBuilder,
      $$CheckpointStatesTableUpdateCompanionBuilder,
      (
        CheckpointState,
        BaseReferences<_$AppDatabase, $CheckpointStatesTable, CheckpointState>,
      ),
      CheckpointState,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      required String id,
      required String title,
      required String priority,
      Value<bool> done,
      required String createdAt,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> priority,
      Value<bool> done,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<int> rowid,
    });

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TaskStepsTable, List<TaskStep>>
  _taskStepsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.taskSteps,
    aliasName: 'tasks__id__task_steps__task_id',
  );

  $$TaskStepsTableProcessedTableManager get taskStepsRefs {
    final manager = $$TaskStepsTableTableManager(
      $_db,
      $_db.taskSteps,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskStepsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> taskStepsRefs(
    Expression<bool> Function($$TaskStepsTableFilterComposer f) f,
  ) {
    final $$TaskStepsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskSteps,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskStepsTableFilterComposer(
            $db: $db,
            $table: $db.taskSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> taskStepsRefs<T extends Object>(
    Expression<T> Function($$TaskStepsTableAnnotationComposer a) f,
  ) {
    final $$TaskStepsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskSteps,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskStepsTableAnnotationComposer(
            $db: $db,
            $table: $db.taskSteps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({bool taskStepsRefs})
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                priority: priority,
                done: done,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String priority,
                Value<bool> done = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                priority: priority,
                done: done,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TasksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({taskStepsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (taskStepsRefs) db.taskSteps],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (taskStepsRefs)
                    await $_getPrefetchedData<Task, $TasksTable, TaskStep>(
                      currentTable: table,
                      referencedTable: $$TasksTableReferences
                          ._taskStepsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TasksTableReferences(db, table, p0).taskStepsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.taskId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({bool taskStepsRefs})
    >;
typedef $$TaskStepsTableCreateCompanionBuilder =
    TaskStepsCompanion Function({
      required String id,
      required String taskId,
      required String title,
      Value<bool> done,
      required int position,
      Value<int> rowid,
    });
typedef $$TaskStepsTableUpdateCompanionBuilder =
    TaskStepsCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<String> title,
      Value<bool> done,
      Value<int> position,
      Value<int> rowid,
    });

final class $$TaskStepsTableReferences
    extends BaseReferences<_$AppDatabase, $TaskStepsTable, TaskStep> {
  $$TaskStepsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('task_steps__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<String>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TaskStepsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskStepsTable> {
  $$TaskStepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskStepsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskStepsTable> {
  $$TaskStepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskStepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskStepsTable> {
  $$TaskStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskStepsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskStepsTable,
          TaskStep,
          $$TaskStepsTableFilterComposer,
          $$TaskStepsTableOrderingComposer,
          $$TaskStepsTableAnnotationComposer,
          $$TaskStepsTableCreateCompanionBuilder,
          $$TaskStepsTableUpdateCompanionBuilder,
          (TaskStep, $$TaskStepsTableReferences),
          TaskStep,
          PrefetchHooks Function({bool taskId})
        > {
  $$TaskStepsTableTableManager(_$AppDatabase db, $TaskStepsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskStepsCompanion(
                id: id,
                taskId: taskId,
                title: title,
                done: done,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required String title,
                Value<bool> done = const Value.absent(),
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => TaskStepsCompanion.insert(
                id: id,
                taskId: taskId,
                title: title,
                done: done,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TaskStepsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable: $$TaskStepsTableReferences
                                    ._taskIdTable(db),
                                referencedColumn: $$TaskStepsTableReferences
                                    ._taskIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TaskStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskStepsTable,
      TaskStep,
      $$TaskStepsTableFilterComposer,
      $$TaskStepsTableOrderingComposer,
      $$TaskStepsTableAnnotationComposer,
      $$TaskStepsTableCreateCompanionBuilder,
      $$TaskStepsTableUpdateCompanionBuilder,
      (TaskStep, $$TaskStepsTableReferences),
      TaskStep,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$FormDraftsTableCreateCompanionBuilder =
    FormDraftsCompanion Function({
      required String formId,
      required String answersJson,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$FormDraftsTableUpdateCompanionBuilder =
    FormDraftsCompanion Function({
      Value<String> formId,
      Value<String> answersJson,
      Value<String> updatedAt,
      Value<int> rowid,
    });

class $$FormDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $FormDraftsTable> {
  $$FormDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get formId => $composableBuilder(
    column: $table.formId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answersJson => $composableBuilder(
    column: $table.answersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FormDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $FormDraftsTable> {
  $$FormDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get formId => $composableBuilder(
    column: $table.formId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answersJson => $composableBuilder(
    column: $table.answersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FormDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FormDraftsTable> {
  $$FormDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get formId =>
      $composableBuilder(column: $table.formId, builder: (column) => column);

  GeneratedColumn<String> get answersJson => $composableBuilder(
    column: $table.answersJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FormDraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FormDraftsTable,
          FormDraft,
          $$FormDraftsTableFilterComposer,
          $$FormDraftsTableOrderingComposer,
          $$FormDraftsTableAnnotationComposer,
          $$FormDraftsTableCreateCompanionBuilder,
          $$FormDraftsTableUpdateCompanionBuilder,
          (
            FormDraft,
            BaseReferences<_$AppDatabase, $FormDraftsTable, FormDraft>,
          ),
          FormDraft,
          PrefetchHooks Function()
        > {
  $$FormDraftsTableTableManager(_$AppDatabase db, $FormDraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FormDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FormDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FormDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> formId = const Value.absent(),
                Value<String> answersJson = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FormDraftsCompanion(
                formId: formId,
                answersJson: answersJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String formId,
                required String answersJson,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FormDraftsCompanion.insert(
                formId: formId,
                answersJson: answersJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FormDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FormDraftsTable,
      FormDraft,
      $$FormDraftsTableFilterComposer,
      $$FormDraftsTableOrderingComposer,
      $$FormDraftsTableAnnotationComposer,
      $$FormDraftsTableCreateCompanionBuilder,
      $$FormDraftsTableUpdateCompanionBuilder,
      (FormDraft, BaseReferences<_$AppDatabase, $FormDraftsTable, FormDraft>),
      FormDraft,
      PrefetchHooks Function()
    >;
typedef $$TimerLogTableCreateCompanionBuilder =
    TimerLogCompanion Function({
      required String id,
      required String task,
      required int minutes,
      Value<int> distractions,
      required String startedAt,
      Value<String?> endedAt,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$TimerLogTableUpdateCompanionBuilder =
    TimerLogCompanion Function({
      Value<String> id,
      Value<String> task,
      Value<int> minutes,
      Value<int> distractions,
      Value<String> startedAt,
      Value<String?> endedAt,
      Value<String> updatedAt,
      Value<int> rowid,
    });

class $$TimerLogTableFilterComposer
    extends Composer<_$AppDatabase, $TimerLogTable> {
  $$TimerLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get task => $composableBuilder(
    column: $table.task,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distractions => $composableBuilder(
    column: $table.distractions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimerLogTableOrderingComposer
    extends Composer<_$AppDatabase, $TimerLogTable> {
  $$TimerLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get task => $composableBuilder(
    column: $table.task,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distractions => $composableBuilder(
    column: $table.distractions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimerLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimerLogTable> {
  $$TimerLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get task =>
      $composableBuilder(column: $table.task, builder: (column) => column);

  GeneratedColumn<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);

  GeneratedColumn<int> get distractions => $composableBuilder(
    column: $table.distractions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TimerLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimerLogTable,
          TimerLogData,
          $$TimerLogTableFilterComposer,
          $$TimerLogTableOrderingComposer,
          $$TimerLogTableAnnotationComposer,
          $$TimerLogTableCreateCompanionBuilder,
          $$TimerLogTableUpdateCompanionBuilder,
          (
            TimerLogData,
            BaseReferences<_$AppDatabase, $TimerLogTable, TimerLogData>,
          ),
          TimerLogData,
          PrefetchHooks Function()
        > {
  $$TimerLogTableTableManager(_$AppDatabase db, $TimerLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimerLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimerLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimerLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> task = const Value.absent(),
                Value<int> minutes = const Value.absent(),
                Value<int> distractions = const Value.absent(),
                Value<String> startedAt = const Value.absent(),
                Value<String?> endedAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimerLogCompanion(
                id: id,
                task: task,
                minutes: minutes,
                distractions: distractions,
                startedAt: startedAt,
                endedAt: endedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String task,
                required int minutes,
                Value<int> distractions = const Value.absent(),
                required String startedAt,
                Value<String?> endedAt = const Value.absent(),
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TimerLogCompanion.insert(
                id: id,
                task: task,
                minutes: minutes,
                distractions: distractions,
                startedAt: startedAt,
                endedAt: endedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimerLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimerLogTable,
      TimerLogData,
      $$TimerLogTableFilterComposer,
      $$TimerLogTableOrderingComposer,
      $$TimerLogTableAnnotationComposer,
      $$TimerLogTableCreateCompanionBuilder,
      $$TimerLogTableUpdateCompanionBuilder,
      (
        TimerLogData,
        BaseReferences<_$AppDatabase, $TimerLogTable, TimerLogData>,
      ),
      TimerLogData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$CheckpointStatesTableTableManager get checkpointStates =>
      $$CheckpointStatesTableTableManager(_db, _db.checkpointStates);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$TaskStepsTableTableManager get taskSteps =>
      $$TaskStepsTableTableManager(_db, _db.taskSteps);
  $$FormDraftsTableTableManager get formDrafts =>
      $$FormDraftsTableTableManager(_db, _db.formDrafts);
  $$TimerLogTableTableManager get timerLog =>
      $$TimerLogTableTableManager(_db, _db.timerLog);
}
