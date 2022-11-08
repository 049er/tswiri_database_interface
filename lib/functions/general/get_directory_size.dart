import 'dart:io';

int getDirectorySize(Directory directory) {
  int totalSize = 0;
  var dir = directory;

  if (dir.existsSync()) {
    dir
        .listSync(recursive: true, followLinks: false)
        .forEach((FileSystemEntity entity) {
      if (entity is File) {
        totalSize += entity.lengthSync();
      }
    });
  }

  return totalSize;
}
