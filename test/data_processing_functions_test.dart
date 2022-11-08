import 'package:flutter_test/flutter_test.dart';
import 'package:tswiri_database_interface/functions/data/data_processing.dart';

void main() {
  group('Data Processing Functions: ', () {
    test('Function: calculateDistanceFromCamera()', () async {
      double distanceFromCamera = calculateDistanceFromCamera(
        barcodeOnImageDiagonalLength: 100,
        barcodeProperties: [],
        barcodeUID: '',
        defaultBarcodeSize: 50,
        focalLength: 1,
      );

      expect(distanceFromCamera, 0.7071067811865476);
    });

    test('Function: calculateBarcodeCenter()', () async {
      Offset barcodeCenter = calculateBarcodeCenter([
        const Offset(0, 0),
        const Offset(100, 0),
        const Offset(100, -100),
        const Offset(0, -100),
      ]);

      expect(barcodeCenter, const Offset(50, -50));
    });

    test('Function: rotateOffset()', () async {
      Offset rotatedOffset = rotateOffset(
        angleRadians: 0.5,
        offset: const Offset(10, 10),
      );

      expect(rotatedOffset.dx, 3.9815702328616975);
      expect(rotatedOffset.dy, 13.570081004945758);
    });
  });
}
