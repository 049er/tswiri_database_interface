import 'dart:io';

import 'package:flutter/cupertino.dart';
// ignore: depend_on_referenced_packages
import 'package:image/image.dart' as img;

Size getPhotoSize(String photoPath) {
  File imageFile = File(photoPath);
  img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;
  return Size(image.width.toDouble(), image.height.toDouble());
}
