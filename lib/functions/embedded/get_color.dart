import 'package:flutter/cupertino.dart';

Color getColor(String data) {
  return Color(int.parse(data)).withOpacity(1);
}

String fromColor(Color color) {
  return color.value.toString();
}
