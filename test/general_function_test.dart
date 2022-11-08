import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tswiri_database_interface/functions/general/calculate_directory_size.dart';
import 'package:tswiri_database_interface/functions/general/capitalize_first_character.dart';
import 'package:tswiri_database_interface/functions/general/coordinate_translator.dart';
import 'package:tswiri_database_interface/functions/general/distinct_by.dart';
import 'package:tswiri_database_interface/functions/general/recreate_directory.dart';

void main() {
  group('General Functions: ', () {
    test('Function: capitalizeFirstCharacter()', () async {
      String string = 'test';
      expect(string.capitalizeFirstCharacter(), 'Test');
    });

    test('Function: translateX()', () async {
      double x = translateX(1, InputImageRotation.rotation0deg,
          const Size(720, 1024), const Size(1440, 2048));
      expect(x, 0.5);
    });

    test('Function: translateY()', () async {
      double y = translateY(1, InputImageRotation.rotation0deg,
          const Size(720, 1024), const Size(1440, 2048));
      expect(y, 0.5);
    });

    test('Function: recreateDirectory()', () async {
      Directory testDirectory = Directory(
          '${(await getApplicationSupportDirectory()).path}/new_directory');

      recreateDirectory(testDirectory);

      expect(testDirectory.existsSync(), true);

      testDirectory.deleteSync();
    });

    test('Function: distinctBy()', () async {
      List<String> testList = [
        'test',
        'test',
        'test_1',
        'test_2',
        'test_1',
      ];

      List<String> distinctList = testList.distinctBy((x) => x).toList();

      expect(distinctList, ['test', 'test_1', 'test_2']);
    });

    test('Function: calculateDirectorySize()', () async {
      double directorySize = await calculateDirectorySize(
          Directory((await getApplicationSupportDirectory()).path));

      expect(directorySize, 0.0);
    });
  });
}
