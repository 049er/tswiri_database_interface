import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tswiri_database_interface/functions/barcodes/barcode_pdf_generator.dart';

void main() {
  group('Barcode Functions: ', () {
    test('Function: barcodePdfGenerator()', () async {
      Uint8List pdf =
          await barcodePdfGenerator(barcodeUIDs: ['1_1', '1_2'], size: 50);

      expect(pdf.length.toString(), 1876);
      pdf =
          await barcodePdfGenerator(barcodeUIDs: ['1_1_1', '1_2_1'], size: 80);

      expect(pdf.length, 1903);
    });
  });
}
