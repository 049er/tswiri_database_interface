import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;

import 'package:tswiri_database/export.dart';
import 'package:tswiri_database_interface/functions/embedded/get_bounding_box.dart';

class MLTextPainter extends CustomPainter {
  MLTextPainter(this.mlTextElement, this.image, this.photoSize);

  ui.Image image;
  MLTextElement mlTextElement;
  Size photoSize;
  @override
  void paint(Canvas canvas, Size size) {
    double photoAspectRatio = photoSize.height / photoSize.width;
    Rect boundingBox = getBoundingBox(mlTextElement.cornerPoints.data!);
    double boundingBoxWidth = boundingBox.width;
    double boundingBoxHeight = boundingBox.height;

    if (boundingBoxWidth >= boundingBoxHeight) {
      boundingBoxHeight = boundingBoxHeight * photoAspectRatio;
    } else {
      boundingBoxWidth = boundingBoxWidth * photoAspectRatio;
    }

    final dst = Offset.zero & size;
    final src = getBoundingBox(mlTextElement.cornerPoints.data!);
    canvas.drawImageRect(image, src, dst, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

//TODO: image cropping :D.