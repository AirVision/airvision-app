import 'package:air_vision/util/math/geodetic_position.dart';

class GeodeticBounds {

  final GeodeticPosition min;
  final GeodeticPosition max;

  GeodeticBounds({this.min, this.max});
}