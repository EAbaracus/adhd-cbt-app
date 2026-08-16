/// Atomic content activation (spec §7.2): stage -> verify -> swap.
/// Any failure: temp deleted, active untouched.
library;

import 'dart:io';

import 'content_runtime.dart';

class ContentActivator {
  static const _expectedSchema = '1.0.0';

  static Future<void> activate(Directory sourceDir, Directory activeDir) async {
    final tmp = Directory('${activeDir.path}.tmp');
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
    tmp.createSync();

    try {
      // 1. stage
      _copyRecursive(sourceDir, tmp);
      // 2. verify integrity + schema compatibility
      final rt = ContentRuntime(tmp);
      final manifest = rt.loadManifest();
      if (manifest == null) throw StateError('no manifest in staged bundle');
      if (manifest.schemaVersion != _expectedSchema) {
        throw StateError('incompatible schema ${manifest.schemaVersion}');
      }
      if (!rt.verifyIntegrity()) throw StateError('integrity check failed');
      // 3. atomic swap (Windows: delete-then-rename with backup)
      final backup = Directory('${activeDir.path}.bak');
      if (backup.existsSync()) backup.deleteSync(recursive: true);
      if (activeDir.existsSync()) activeDir.renameSync(backup.path);
      try {
        tmp.renameSync(activeDir.path);
        if (backup.existsSync()) backup.deleteSync(recursive: true);
      } catch (_) {
        // swap failed: restore backup
        if (activeDir.existsSync()) activeDir.deleteSync(recursive: true);
        if (backup.existsSync()) backup.renameSync(activeDir.path);
        rethrow;
      }
    } catch (_) {
      if (tmp.existsSync()) tmp.deleteSync(recursive: true);
      rethrow;
    }
  }

  static void _copyRecursive(Directory from, Directory to) {
    for (final e in from.listSync(recursive: true)) {
      if (e is File) {
        final rel = e.path.substring(from.path.length + 1);
        final dest = File('${to.path}/$rel');
        dest.parent.createSync(recursive: true);
        e.copySync(dest.path);
      }
    }
  }
}
