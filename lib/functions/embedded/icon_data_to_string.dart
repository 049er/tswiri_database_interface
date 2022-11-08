import 'package:flutter/cupertino.dart';

List<String> iconDataToString(IconData iconData) {
  return [iconData.codePoint.toString(), iconData.fontFamily.toString()];
}
