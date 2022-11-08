import 'package:flutter_test/flutter_test.dart';
import 'package:tswiri_database_interface/models/acclerometer/acceleromter_data.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

void main() {
  group('Models: ', () {
    test('AccelerometerData', () async {
      AccelerometerData accelerometerData = AccelerometerData(
        accelerometerEvent: vm.Vector3(1, 2, 3),
        userAccelerometerEvent: vm.Vector3(4, 2, 3),
      );

      double phoneAngle = accelerometerData.calculatePhoneAngle();

      expect(phoneAngle, 1.5707963267948966);
    });
  });
}
