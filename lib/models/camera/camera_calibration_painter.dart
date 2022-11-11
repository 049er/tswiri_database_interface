import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math' as m;
import 'package:tswiri_database/export.dart';
import 'package:tswiri_database/tswiri_database.dart';
import 'package:tswiri_database_interface/models/settings/app_settings.dart';
import 'package:tswiri_database_interface/models/settings/global_settings.dart';

class CameraCalibrationVisualizerPainter extends CustomPainter {
  CameraCalibrationVisualizerPainter();

  @override
  paint(Canvas canvas, Size size) {
    final Paint equationPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.lightGreenAccent;

    final Paint dataPointPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.red;

    final Paint backgroundPaint = Paint()..color = const Color(0xFF626262);

    //Draw the equation
    List<Offset> equationPoints = [];
    for (var i = 50; i < 2000; i++) {
      double defualtBarcodeDiagonalSize = defaultBarcodeSize * m.sqrt(2);

      double distanceFromCamera =
          focalLength * defualtBarcodeDiagonalSize / i.toDouble();
      Offset dataPoint = Offset(i.toDouble(), distanceFromCamera);

      equationPoints.add(Offset(
          ((dataPoint.dx + size.width / 2) / (size.width / 50)),
          ((dataPoint.dy + size.height / 2) / (size.height / 50))));
    }

    canvas.drawPoints(PointMode.points, equationPoints, equationPaint);

    //Draw the dataPoints
    List<CameraCalibrationEntry> entries = getCameraCalibrationEntries();
    // isar!.cameraCalibrationEntrys.where().findAllSync();

    List<Offset> dataPoints = [];
    for (var element in entries) {
      Offset offsetData =
          Offset(element.diagonalSize, element.distanceFromCamera);

      Offset position = Offset(
        ((offsetData.dx + size.width / 2) / (size.width / 50)),
        ((offsetData.dy + size.height / 2) / (size.height / 50)),
      );
      dataPoints.add(position);

      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
            textAlign: TextAlign.left,
            fontSize: 5,
            textDirection: TextDirection.ltr),
      );
      builder.pushStyle(ui.TextStyle(
          color: Colors.lightGreenAccent,
          background: backgroundPaint,
          fontSize: 5));
      builder.addText(
          '(${element.distanceFromCamera.toStringAsFixed(2)}, ${element.diagonalSize.toStringAsFixed(2)})');
      builder.pop();

      canvas.drawParagraph(
        builder.build()..layout(const ParagraphConstraints(width: 100)),
        position,
      );
    }

    canvas.drawPoints(PointMode.points, dataPoints, dataPointPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
