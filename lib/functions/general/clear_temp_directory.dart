import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<void> clearTemporaryDirectory() async {
  Directory tempDir = await getTemporaryDirectory();
  tempDir.deleteSync(recursive: true);
  tempDir.create();
}
