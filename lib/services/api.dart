import 'dart:convert';
import 'dart:developer';
import 'package:air_vision/models/aircraftInfo.dart';
import 'package:air_vision/models/flightInfo.dart';
import 'package:air_vision/models/aircraftState.dart';
import 'package:air_vision/util/math/geodetic_bounds.dart';
import 'package:air_vision/util/math/geodetic_position.dart';
import 'package:http/http.dart' as http;
import 'package:vector_math/vector_math.dart';

String baseURL = 'https://airvision.seppevolkaerts.be';

class Api {
  Future<List<AircraftState>> getVisibleAircraft(
      int time,
      GeodeticPosition position,
      Quaternion rotation,
      double rotationAccuracy,
      Vector2 fov,
      List aircraftPosition,
      List aircraftSize) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    // Send null if it's unsupported
    var sensorAccuracy = rotationAccuracy == -1 ? null : rotationAccuracy;

    String body = '''{
      "time": $time,
      "position": $position,
      "rotation": [
        ${rotation.x},
        ${rotation.y},
        ${rotation.z},
        ${rotation.w}
      ],
      "rotation_accuracy": $sensorAccuracy,
      "fov": [
        ${fov.x},
        ${fov.y}
      ],
      "aircrafts": [{
        "position": $aircraftPosition, 
        "size": $aircraftSize
      }]
    }''';

    http.Response responseData = await http.post(
      baseURL + '/api/v1/aircraft/state/visible',
      body: body,
      headers: headers,
    );

    if (responseData.statusCode == 200) {

      var tagObjsJson = jsonDecode(responseData.body)['data']['states'] as List;
      List<AircraftState> aircrafts = tagObjsJson
          .map((tagJson) => AircraftState.fromJson(tagJson))
          .toList();
      return aircrafts;
    } else {
      return Future.error(jsonDecode(responseData.body)['error']['message']);
    }
  }

  Future<List<AircraftState>> getAll({int time, GeodeticBounds bounds}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    String body = '''{
       "bounds": {
        "min": ${bounds.min},
        "max": ${bounds.max}
        }
      }
      ''';

    if (time != null) {
      body = '''{
      "time": $time,
      "bounds": {
        "min": ${bounds.min},
        "max": ${bounds.max}
        }
      }
      ''';
    }

    http.Response responseData = await http.post(
      baseURL + '/api/v1/aircraft/state/all',
      body: body,
      headers: headers,
    );

    if (responseData.statusCode == 200) {
      var tagObjsJson = jsonDecode(responseData.body)['data'] as List;
      List<AircraftState> aircrafts = tagObjsJson
          .map((tagJson) => AircraftState.fromJson(tagJson))
          .toList();

      return aircrafts;
    } else {
      return Future.error(jsonDecode(responseData.body)['error']['message']);
    }
  }

  Future<AircraftState> getPositionalData(String icao24) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    String body = '''{
      "icao24": "$icao24"
    }''';

    http.Response responseData = await http.post(
      baseURL + '/api/v1/aircraft/state/get',
      body: body,
      headers: headers,
    );

    if (responseData.statusCode == 200) {
      var tagObjsJson = jsonDecode(responseData.body)["data"];
      AircraftState aircrafts = AircraftState.fromJson(tagObjsJson);
      return aircrafts;
    } else {
      return Future.error(jsonDecode(responseData.body)['error']['message']);
    }
  }

  Future<AircraftInfo> getSpecificAircraftInfo(String icao24) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    String body = '''{
      "icao24": "$icao24"
    }''';

    http.Response responseData = await http.post(
      baseURL + '/api/v1/aircraft/info',
      body: body,
      headers: headers,
    );

    if (responseData.statusCode == 200) {
      var tagObjsJson = jsonDecode(responseData.body)["data"];
      AircraftInfo flight = AircraftInfo.fromJson(tagObjsJson);
      return flight;
    } else {
      return jsonDecode(responseData.body)['error']['message'];
    }
  }

  Future<FlightInfo> getSpecificFlightInfo(String icao24) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    String body = '''{
      "icao24": "$icao24"
    }''';

    http.Response responseData = await http.post(
      baseURL + '/api/v1/aircraft/flight',
      body: body,
      headers: headers,
    );

    if (responseData.statusCode == 200) {
      var tagObjsJson = await jsonDecode(responseData.body)["data"];
      FlightInfo flight = FlightInfo.fromJson(tagObjsJson);
      return flight;
    } else {
      return jsonDecode(responseData.body)['error']['message'];
    }
  }

  Future<bool> testConnection() async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    String body = '''{
       "bounds": {
        "min": [0,0],
        "max": [1,1]
        }
      }
      ''';

    http.Response responseData = await http.post(
      baseURL + '/api/v1/aircraft/state/all',
      body: body,
      headers: headers,
    );

    if (responseData.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
