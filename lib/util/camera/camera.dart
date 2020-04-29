import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart';

const _platform = const MethodChannel('airvision/camera');

extension CameraDescriptionExtensions on CameraDescription {

  /// Gets the Field of View (FoV) of the camera. In degrees.
  Future<Vector2> getFov() async {
    List<double> fov = await _platform.invokeMethod('getFov', name);
    return Vector2(fov[0], fov[1]);
  }
}