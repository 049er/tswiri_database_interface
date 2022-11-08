import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tswiri_database_interface/functions/backup/restore_backup.dart';

void main() {
  //TODO:
  //- createBackupFile();
  //- restoreBackupFile();
  //- killIsolate();
  //- openIsarIfClosed();
  //- generateBackupFileName();
  //-

  group('Backup/Restore functions: ', () {
    Directory thumbnailDirectory = Directory('thumbnails');
    File photoFile = File('photos/16089732478234.jpg');
    String photoName = '16089732478234';

    test('Function: getUnZippedDirectoryPath()', () {
      expect(
        getUnzippedDirectory(
          Directory('temporaryDirectory'),
          File('my_file.zip'),
        ).path,
        'temporaryDirectory/my_file',
      );
    });

    test('Function: extractPhotoName()', () {
      expect(extractPhotoName(photoFile), '16089732478234');
    });

    test('Function: constructPhotoThumnailPath()', () {
      expect(
        constructPhotoThumnailPath(thumbnailDirectory, photoName),
        'thumbnails/16089732478234_thumbnail.jpg',
      );
    });
  });
}
