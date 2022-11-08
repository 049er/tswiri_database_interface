import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as img;

Size getPhotoSize(String photoPath) {
  File imageFile = File(photoPath);
  img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;
  return Size(image.width.toDouble(), image.height.toDouble());
}
