import 'dart:convert';
import 'package:air_vision/models/aircraftState.dart';
import 'package:http/http.dart' as http;
import 'package:vector_math/vector_math.dart';

String baseURL = 'https://airvision.seppevolkaerts.be';

class Api {
  Future<dynamic> getVisibleAircraft(
      int time,
      List position,
      Quaternion rotation,
      Vector2 fov,
      List aircraftPosition,
      List aircraftSize) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    String body = '''{
      "time": $time,
      "position": $position,
      "rotation": [
        ${rotation.x},
        ${rotation.y},
        ${rotation.z},
        ${rotation.w}
      ],
      "fov": [
        ${fov.x},
        ${fov.y}
      ],
      "aircrafts": [{
        "position": $aircraftPosition, 
        "size": $aircraftSize
      }]
    }''';

    print(body);

    http.Response responseData = await http.post(
      baseURL + '/api/v1/aircraft/state/visible',
      body: body,
      headers: headers,
    );

    if (responseData.statusCode == 200) {
      return responseData.body;
    } else {
      return jsonDecode(responseData.body)['error']['message'];
    }
  }

  Future<List<AircraftState>> getAll({int time, List bounds}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    String body = '''{
       "bounds": {
        "min": ${bounds[1]},
        "max": ${bounds[0]}
        }
      }
      ''';

    if (time != null) {
      body = '''{
      "time": $time,
      "bounds": {
        "min": ${bounds[1]},
        "max": ${bounds[0]}
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
      return jsonDecode(responseData.body)['error']['message'];
    }
  }

  Future<dynamic> getPositionalData(String icao24) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    String body = '''{
      "icao24": $icao24,
    }''';

    http.Response responseData = await http.post(
      baseURL + '/api/v1/aircraft/state/get',
      body: body,
      headers: headers,
    );

    if (responseData.statusCode == 200) {
      return responseData.body;
    } else {
      return jsonDecode(responseData.body)['error']['message'];
    }
  }

  Future<dynamic> getSpecificAircraftInfo(String icao24) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    String body = '''{
      "icao24": $icao24,
    }''';

    http.Response responseData = await http.post(
      baseURL + '/api/v1/aircraft/info',
      body: body,
      headers: headers,
    );

    if (responseData.statusCode == 200) {
      return responseData.body;
    } else {
      return jsonDecode(responseData.body)['error']['message'];
    }
  }

  Future<dynamic> getSpecificFlightInfo(String icao24) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    String body = '''{
      "icao24": $icao24,
    }''';

    http.Response responseData = await http.post(
      baseURL + '/api/v1/aircraft/flight',
      body: body,
      headers: headers,
    );

    if (responseData.statusCode == 200) {
      return responseData.body;
    } else {
      return jsonDecode(responseData.body)['error']['message'];
    }
  }
}
