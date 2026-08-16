import 'dart:convert';
import 'dart:io';

import 'progress_store.dart';

class FileProgressStore implements ProgressStore {
  final File file;
  final String deviceId;
  static const schemaVersion = '1.0.0';

  FileProgressStore(this.file, {required this.deviceId});

  @override
  Future<Map<String, String>> load() async {
    if (!file.existsSync()) return {};
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return (json['states'] as Map? ?? {})
        .map((k, v) => MapEntry(k as String, v as String));
  }

  @override
  Future<void> save(Map<String, String> states) async {
    final envelope = {
      'device_id': deviceId,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
      'schema_version': schemaVersion,
      'states': states,
    };
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(jsonEncode(envelope));
  }
}
