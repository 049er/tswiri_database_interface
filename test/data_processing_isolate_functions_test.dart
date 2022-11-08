import 'dart:developer';

import 'package:flutter_test/flutter_test.dart';
import 'package:tswiri_database/collections/cataloged_coordinate/cataloged_coordinate.dart';
import 'package:tswiri_database/embedded/embedded_vector_3/embedded_vector_3.dart';
import 'package:tswiri_database_interface/functions/data/data_processing_isolates.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

void main() {
  group('Data Processing Isolate Functions: ', () {
    test('Function: hasMoved()', () async {
      CatalogedCoordinate storedCoordinate = CatalogedCoordinate()
        ..barcodeUID = 'test'
        ..coordinate = EmbeddedVector3.fromVector(vm.Vector3(0, 0, 0))
        ..gridUID = 1
        ..id = 1
        ..rotation = EmbeddedVector3.fromVector(vm.Vector3(0, 0, 0))
        ..timestamp = 123;

      CatalogedCoordinate newCoordinate = CatalogedCoordinate()
        ..barcodeUID = 'test'
        ..coordinate = EmbeddedVector3.fromVector(vm.Vector3(0, 0, 0))
        ..gridUID = 1
        ..id = 1
        ..rotation = EmbeddedVector3.fromVector(vm.Vector3(0, 0, 0))
        ..timestamp = 123;

      bool moved = hasMoved(newCoordinate, storedCoordinate, 5);

      expect(moved, false);

      newCoordinate = CatalogedCoordinate()
        ..barcodeUID = 'test'
        ..coordinate = EmbeddedVector3.fromVector(vm.Vector3(10, 0, 0))
        ..gridUID = 1
        ..id = 1
        ..rotation = EmbeddedVector3.fromVector(vm.Vector3(0, 20, 0))
        ..timestamp = 123;

      moved = hasMoved(newCoordinate, storedCoordinate, 5);

      expect(moved, true);
    });
  });
}
