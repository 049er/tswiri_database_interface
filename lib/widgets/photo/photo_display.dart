import 'dart:io';
import 'package:flutter/material.dart';

//TODO: move to widgets package.

///The default way to display a photo.
class PhotoDisplay extends StatelessWidget {
  const PhotoDisplay({
    Key? key,
    required this.photoPath,
    this.height,
    this.width,
  }) : super(key: key);

  ///File path of the photo.
  final String photoPath;

  ///The width of the displayed photo.
  final double? width;

  ///The height of the displayed photo.
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(photoPath),
      fit: BoxFit.scaleDown,
      height: height,
      width: width,
    );
  }
}
