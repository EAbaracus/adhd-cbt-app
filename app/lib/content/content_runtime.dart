/// Content bundle runtime: manifest + sha256 integrity + typed load.
/// Pure Dart (dart:io). No Flutter imports (G1).
library;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import '../forms/form_definition.dart';

class ContentBundle {
  final String schemaVersion;
  final String contentVersion;
  final Map<String, String> files; // path -> sha256

  ContentBundle(
      {required this.schemaVersion,
      required this.contentVersion,
      required this.files});

  factory ContentBundle.fromManifestJson(Map<String, dynamic> json) {
    final files = <String, String>{
      for (final f in (json['files'] as List? ?? []))
        (f as Map)['path'] as String: (f)['sha256'] as String,
    };
    return ContentBundle(
      schemaVersion: json['schema_version'] as String,
      contentVersion: json['content_version'] as String,
      files: files,
    );
  }
}

class ContentRuntime {
  final Directory root;
  ContentRuntime(this.root);

  static String sha256Hex(String input) =>
      sha256.convert(utf8.encode(input)).toString();

  ContentBundle? loadManifest() {
    final f = File('${root.path}/manifest.json');
    if (!f.existsSync()) return null;
    final json = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    return ContentBundle.fromManifestJson(json);
  }

  bool verifyIntegrity() {
    final m = loadManifest();
    if (m == null) return false;
    for (final entry in m.files.entries) {
      final f = File('${root.path}/${entry.key}');
      if (!f.existsSync()) return false;
      if (sha256Hex(f.readAsStringSync()) != entry.value) return false;
    }
    return true;
  }

  List<FormDefinition> loadForms() {
    final dir = Directory('${root.path}/forms');
    if (!dir.existsSync()) return [];
    final out = <FormDefinition>[];
    for (final f in dir.listSync().whereType<File>().toList()
      ..sort((a, b) => a.path.compareTo(b.path))) {
      out.add(FormDefinition.fromJson(
          jsonDecode(f.readAsStringSync()) as Map<String, dynamic>));
    }
    return out;
  }
}
