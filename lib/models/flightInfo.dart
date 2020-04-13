import 'package:air_vision/models/airport.dart';
import 'package:air_vision/models/waypoint.dart';

class FlightInfo {
  FlightInfo(this.number, this.icao24, this.departureAirport,
      this.arrivalAirport, this.estimatedArrivalTime, [this.waypoints]);

  String number;
  String icao24;
  Airport departureAirport;
  Airport arrivalAirport;
  int estimatedArrivalTime;
  List<Waypoint> waypoints;

  factory FlightInfo.fromJson(dynamic json) {
    if (json['waypoints'] != null) {
      var tagObjsJson = json['waypoints'] as List;
      List<Waypoint> _waypoints =
          tagObjsJson.map((tagJson) => Waypoint.fromJson(tagJson)).toList();

      return FlightInfo(
        json['number'] as String,
        json['icao24'] as String,
        Airport.fromJson(json['departure_airport']),
        Airport.fromJson(json['arrival_airport']),
        json['estimated_arrival_time'] as int,
        _waypoints,
      );
    } else {
      return FlightInfo(
        json['number'] as String,
        json['icao24'] as String,
        Airport.fromJson(json['departure_airport']),
        Airport.fromJson(json['arrival_airport']),
        json['estimated_arrival_time'] as int,
      );
    }
  }
}
