import 'dart:math';
import 'dart:ui';

Rect getBoundingBox(List<int> cornerPoints) {
  return Rect.fromPoints(
    Offset(cornerPoints[0].toDouble(), cornerPoints[1].toDouble()),
    Offset(cornerPoints[4].toDouble(), cornerPoints[5].toDouble()),
  );
}
