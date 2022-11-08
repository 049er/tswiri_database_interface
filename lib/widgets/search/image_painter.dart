import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:tswiri_database/export.dart';

import 'dart:ui' as ui;

class ImagePainter extends CustomPainter {
  ImagePainter(
    this.mlObject,
    this.image,
    this.photoSize,
  );

  ui.Image image;
  MLObject mlObject;
  Size photoSize;

  @override
  void paint(Canvas canvas, Size size) {
    double photoAspectRatio = photoSize.height / photoSize.width;
    Rect boundingBox = Rect.fromLTRB(
        mlObject.boundingBox[0],
        mlObject.boundingBox[1],
        mlObject.boundingBox[2],
        mlObject.boundingBox[3]);
    double boundingBoxWidth = boundingBox.width;
    double boundingBoxHeight = boundingBox.height;

    if (boundingBoxWidth > boundingBoxHeight) {
      //Width bigger
      boundingBoxHeight = boundingBoxHeight * photoAspectRatio;
    } else {
      //Height Bigger
      boundingBoxWidth = boundingBoxWidth * photoAspectRatio;
    }

    log('width: $boundingBoxWidth');
    log('height: $boundingBoxHeight');

    final dst = Offset.zero & size;
    final src = Rect.fromCenter(
      center: boundingBox.center,
      width: boundingBoxWidth,
      height: boundingBoxHeight,
    );

    canvas.drawImageRect(image, src, dst, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
