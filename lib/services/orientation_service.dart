import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart';

class OrientationService {

  static const _platform = const MethodChannel('airvision/orientation');

  Future<bool> start() async {
    return _platform.invokeMethod('start');
  }

  Future<bool> stop() async {
    return _platform.invokeMethod('stop');
  }

  Future<Quaternion> getQuaternion() async {
    List<double> values = await _platform.invokeMethod('getQuaternion');
    return Quaternion(values[0], values[1], values[2], values[3]);
  }
}
