import 'dart:ui';

Size getSize(List<double> data) {
  return Size(data[0], data[1]);
}

List<double> photoSizeFromSize(Size size) {
  return [size.width, size.height];
}
