import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

String baseURL = 'https://airvision.seppevolkaerts.be';

class Api {
  Future<dynamic> getVisibleAircraft(
      int time, List position, List rotation, List fov, List aircraftPosition, List aircraftSize) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    String body = '''{
      "time": $time,
      "position": $position,
      "rotation": [
        ${rotation[0]},
        ${rotation[1]},
        ${rotation[2]},
        ${rotation[3]}
      ],
      "fov": $fov,
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

  Future<dynamic> getAll({int time, List bounds}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    String body = '''{
       "bounds": {
        "min": ${bounds[0]},
        "max": ${bounds[1]}
        }
      }
      ''';

    if (time != null) {
      body = '''{
      "time": $time,
      "bounds": {
        "min": ${bounds[0]},
        "max": ${bounds[1]}
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
      return responseData.body;
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
