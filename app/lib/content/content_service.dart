import 'dart:convert';
import 'dart:io';

import '../content/atomic_promote.dart';
import '../content/content_runtime.dart';
import '../api/api_client.dart';

/// Live OTA: manifest diff -> staged download -> atomic activate (M2-5).
/// Any failure: active untouched, next launch retries.
class ContentService {
  final ApiClient api;
  final Directory activeDir;
  final ContentRuntime runtime;
  ContentService(
      {required this.api, required this.activeDir, required this.runtime});

  Future<bool> checkForUpdate() async {
    final remote = await api.fetchRemoteManifest();
    if (remote == null) return false;
    final local = runtime.loadManifest();
    if (local == null) return true; // nothing local: remote is the update
    return remote.contentVersion != local.contentVersion;
  }

  Future<bool> applyUpdate() async {
    final remote = await api.fetchRemoteManifest();
    if (remote == null) return false;
    final stage = Directory('${activeDir.path}.stage');
    if (stage.existsSync()) stage.deleteSync(recursive: true);
    stage.createSync(recursive: true);
    try {
      // stage must carry the manifest itself for integrity verification
      File('${stage.path}/manifest.json').writeAsStringSync(jsonEncode({
        'schema_version': remote.schemaVersion,
        'content_version': remote.contentVersion,
        'files': [
          for (final e in remote.files.entries)
            {'path': e.key, 'sha256': e.value},
        ],
      }));
      for (final path in remote.files.keys) {
        final bytes = await api.fetchContentFile(path);
        if (bytes == null) {
          throw StateError('download failed: $path');
        }
        final dest = File('${stage.path}/$path');
        dest.parent.createSync(recursive: true);
        dest.writeAsBytesSync(bytes);
      }
      await ContentActivator.activate(stage, activeDir);
      return true;
    } catch (_) {
      if (stage.existsSync()) stage.deleteSync(recursive: true);
      return false;
    }
  }
}
