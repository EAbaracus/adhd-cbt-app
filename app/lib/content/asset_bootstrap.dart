import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'content_runtime.dart';

/// Copies the bundled content (assets) into the app documents dir so the
/// content runtime + OTA path have a single directory source of truth.
/// Returns null on failure (corrupt bundle / platform error).
Future<Directory?> bootstrapContentFromAssets() async {
  final docs = await getApplicationDocumentsDirectory();
  final contentDir = Directory('${docs.path}/content');
  final manifestData = await rootBundle.loadString('assets/content/manifest.json');
  final manifest = jsonDecode(manifestData) as Map<String, dynamic>;
  final files = (manifest['files'] as List? ?? []).cast<Map>();

  // stage into tmp, then atomic rename (spec §7.2 spirit)
  final tmp = Directory('${contentDir.path}.tmp');
  if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  tmp.createSync(recursive: true);
  try {
    for (final f in files) {
      final path = f['path'] as String;
      final data = await rootBundle.load('assets/content/$path');
      final dest = File('${tmp.path}/$path');
      dest.parent.createSync(recursive: true);
      dest.writeAsBytesSync(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    }
    // Stage must carry the manifest — verifyIntegrity reads it via loadManifest()
    // (same lesson as M5-1 OTA: "no manifest in staged bundle").
    File('${tmp.path}/manifest.json').writeAsStringSync(manifestData);
    final rt = ContentRuntime(tmp);
    if (!rt.verifyIntegrity()) throw StateError('bundled content failed integrity');
    if (contentDir.existsSync()) contentDir.deleteSync(recursive: true);
    tmp.renameSync(contentDir.path);
    return contentDir;
  } catch (e, st) {
    // In debug, log the asset path that failed. In profile/release, rethrow so
    // bootstrap failures surface instead of silently leaving the UI broken.
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      // ignore: avoid_print
      print('ADHD-BOOT-FAIL: $e');
    } else {
      Error.throwWithStackTrace(e, st);
    }
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
    return null;
  }
}
