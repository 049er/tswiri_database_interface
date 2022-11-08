import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

///Generates a pdf document containing barcodes.
///
/// - List<String> barcodeUIDs
/// - double Size of the barcodes in mm
Future<Uint8List> barcodePdfGenerator({
  required List<String> barcodeUIDs,
  required double size,
}) async {
  final pdf = pw.Document();

  double convertionWidth = PdfPageFormat.a4.width / 210;
  double convertionHeight = PdfPageFormat.a4.height / 297;

  double realWidth = ((size) * convertionWidth);
  double realHeight = ((size) * convertionHeight);

  double totalWidth = realWidth + (12 * convertionWidth);
  double totalHeight = realHeight + (12 * convertionHeight);

  int crossAxisCount = (PdfPageFormat.a4.width ~/ totalWidth);
  int mainAxisCount = (PdfPageFormat.a4.height ~/ totalHeight);

  int numberPerPage = crossAxisCount * mainAxisCount;
  int numberOfPages = (barcodeUIDs.length ~/ numberPerPage);
  int remainder = barcodeUIDs.length % numberPerPage;

  for (var i = 0; i <= numberOfPages; i++) {
    if (i < numberOfPages) {
      pdf.addPage(
        pw.Page(
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            return pw.GridView(
              direction: pw.Axis.vertical,
              crossAxisCount: crossAxisCount,
              children: generatePageBarcodes(
                6,
                barcodeUIDs
                    .getRange(
                        i * numberPerPage, i * numberPerPage + numberPerPage)
                    .toList(),
                realWidth,
                convertionWidth,
                convertionHeight,
              ),
            );
          },
        ),
      );
    } else if (remainder > 0) {
      pdf.addPage(
        pw.Page(
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            return pw.GridView(
              direction: pw.Axis.vertical,
              crossAxisCount: crossAxisCount,
              children: generatePageBarcodes(
                remainder,
                barcodeUIDs
                    .getRange(i * numberPerPage, i * numberPerPage + remainder)
                    .toList(),
                realWidth,
                convertionWidth,
                convertionHeight,
              ),
            );
          },
        ),
      );
    }
  }

  return await pdf.save();
}

//Generates a page worth of barcodes.
List<pw.Widget> generatePageBarcodes(
  int numberOfBarcodes,
  List<String> barcodeUIDs,
  double size,
  double conversionWidth,
  double conversionHeight,
) {
  List<pw.Widget> barcodes = [];
  for (String barcodeUID in barcodeUIDs) {
    barcodes.add(
      pw.Container(
        width: size,
        height: size,
        padding: pw.EdgeInsets.only(
          left: (5 * conversionWidth),
          right: (5 * conversionWidth),
          bottom: (5 * conversionHeight),
          top: (3 * conversionHeight),
        ),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(
              style: pw.BorderStyle(
                pattern: [2, 6],
              ),
            ),
            top: pw.BorderSide(
              style: pw.BorderStyle(
                pattern: [2, 6],
              ),
            ),
            left: pw.BorderSide(
              style: pw.BorderStyle(
                pattern: [2, 6],
              ),
            ),
            right: pw.BorderSide(
              style: pw.BorderStyle(
                pattern: [2, 6],
              ),
            ),
          ),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              barcodeUID,
              style: pw.TextStyle(
                fontSize: ((2) * conversionHeight),
              ),
            ),
            pw.BarcodeWidget(
              height: size,
              width: size,
              color: PdfColor.fromHex("#000000"),
              barcode: pw.Barcode.qrCode(
                errorCorrectLevel: pw.BarcodeQRCorrectionLevel.high,
              ),
              data: barcodeUID,
            ),
          ],
        ),
      ),
    );
  }

  return barcodes;
}
