import 'package:air_vision/models/engines.dart';
import 'package:air_vision/models/manufacturer.dart';

class AircraftInfo{
    AircraftInfo(this.icao24,this.model, this.owner, this.type, this.weightCategory, this.manufacturer, this.engines);

  String icao24;
  String model;
  String owner;
  String type;
  String weightCategory;
  Manufacturer manufacturer;
  Engines engines;

  factory AircraftInfo.fromJson(dynamic json) {
    return AircraftInfo(
      json['icao24'] as String,
      json['model'] as String,
      json['owner'] as String,
      json['type'] as String,
      json['weightCategory'] as String,
      Manufacturer.fromJson(json['manufacturer']),
      Engines.fromJson(json['engines']),
    );
  }

}