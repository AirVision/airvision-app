import 'package:air_vision/models/airport.dart';

class FlightInfo {
  FlightInfo(this.number, this.icao24, this.departureAirport, this.arrivalAirport,
      this.estimatedArrivalTime, this.waypoints);

  String number;
  String icao24;
  Airport departureAirport;
  Airport arrivalAirport;
  int estimatedArrivalTime;
  List waypoints;

  factory FlightInfo.fromJson(dynamic json) {
    return FlightInfo(
      json['number'] as String,
      json['icao24'] as String,
      Airport.fromJson(json['departure_airport']),
      Airport.fromJson(json['arrival_airport']),
      json['estimated_arrival_time'] as int,
      json['waypoints'] as List,
    );
  }
}
