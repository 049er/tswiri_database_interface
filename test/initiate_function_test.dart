import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tswiri_database_interface/functions/isar/isar_functions.dart';

void main() {
  group('Initiate Functions: ', () {
    test('Function: initiateSpaceDirectory()', () async {
      Directory spaceDirectory = await initiateSpaceDirectory();
      expect(spaceDirectory.path,
          '${(await getApplicationSupportDirectory()).path}/main_space');
    });

    test('Function: initiatePhotoStorage()', () async {
      Directory photoDirectory = await initiatePhotoStorage();
      expect(photoDirectory.path,
          '${(await getApplicationSupportDirectory()).path}/main_space/photos');
    });

    test('Function: initiateThumnailStorage()', () async {
      Directory thumbnailDirectory = await initiateThumnailStorage();
      expect(thumbnailDirectory.path,
          '${(await getApplicationSupportDirectory()).path}/main_space/thumbnails');
    });
  });
}
