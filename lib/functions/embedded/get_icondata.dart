import 'package:flutter/cupertino.dart';

IconData getIconData(List<String> data) {
  return IconData(
    int.parse(data[0]),
    fontFamily: data[1],
  );
}
