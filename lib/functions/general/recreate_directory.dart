import 'dart:io';

///Create a directory if it does not exsit or deletes it and recreates it.
void recreateDirectory(Directory directory) {
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  } else {
    directory.deleteSync(recursive: true);
    directory.createSync(recursive: true);
  }
}
