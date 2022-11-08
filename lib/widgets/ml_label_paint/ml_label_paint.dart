import 'package:flutter/material.dart';
import 'package:tswiri_database_interface/models/image_data/image_data.dart';
import 'package:tswiri_database_interface/widgets/ml_label_paint/ml_label_photo_painter.dart';

///Draw a custom paint with all the object and/or text labels.
class MLLabelPaint extends StatelessWidget {
  const MLLabelPaint({
    Key? key,
    required this.imageData,
    required this.showObjects,
    required this.showText,
    this.objectLabelConfidence,
  }) : super(key: key);

  ///The imageData.
  final ImageData imageData;

  ///Show objects and bounding Boxes.
  final bool showObjects;

  ///Show text and bounding Boxes.
  final bool showText;

  ///The confidence required to display the objectLabel.
  final double? objectLabelConfidence;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MLLabePainter(
        imageData: imageData,
        showObjects: showObjects,
        showText: showText,
        objectLabelConfidence: objectLabelConfidence,
      ),
    );
  }
}
