class GeodeticPosition {

  final double latitude;
  final double longitude;
  final double altitude;

  GeodeticPosition({this.latitude, this.longitude, this.altitude: 0});

  @override
  String toString() {
    if (altitude == 0) {
      return "[$latitude, $longitude]";
    }
    return "[$latitude, $longitude, $altitude]";
  }

  factory GeodeticPosition.zero() => GeodeticPosition(latitude: 0.0, longitude: 0.0);
}