import 'dart:io';

String getDirectoryName(Directory directory) {
  return directory.path.split('/').last;
}
