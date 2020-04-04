import 'package:air_vision/util/math/euler_angles.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:math' as math;

extension QuaternionExtensions on Quaternion {

  EulerAngles toEulerAngles() {
    double yaw;
    double pitch;
    double roll;

    double test = w * x - y * z;
    if (test.abs() < 0.4999) {
      yaw = math.atan2(2 * (w * z + x * y), 1 - 2 * (x * x + z * z));
      pitch = math.asin(2 * test);
      roll = math.atan2(2 * (w * y + z * x), 1 - 2 * (x * x + y * y));
    } else {
      int sign = (test < 0) ? -1 : 1;
      yaw = 0;
      pitch = sign * math.pi / 2;
      roll = -sign * 2 * math.atan2(z, w);
    }

    // https://www.sentiance.com/wp-content/uploads/2020/02/samsung-sensors.jpg
    return EulerAngles(pitch, roll, yaw);
  }
}