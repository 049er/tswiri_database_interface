import 'dart:developer';
import 'dart:io';

///Calculate directory size in GB.
Future<double> calculateDirectorySize(Directory directory) async {
  // int fileNum = 0;
  int totalSize = 0;
  try {
    if (directory.existsSync()) {
      directory
          .listSync(recursive: true, followLinks: false)
          .forEach((FileSystemEntity entity) {
        if (entity is File) {
          // fileNum++;
          totalSize += entity.lengthSync();
        }
      });
    }
  } catch (e) {
    log(e.toString());
  }

  return totalSize * 0.000000001;
}
