import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:http/http.dart' as http;

String baseURL = 'https://airvision.seppevolkaerts.be';

class Api {
  Future<dynamic> getVisibleAircraft(
      int time, List position, List rotation, List fov, List aircrafts) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    String body = '''{
      'time': $time,
      'position': $position,
      'rotation': $rotation,
      'fov': $fov,
      'aircrafts': $aircrafts
    }''';

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

  Future<dynamic> getAll({int time, List position, List bounds}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    String body = '''{
      "position": $position,
      "bounds": $bounds}
      ''';

    if (time != null) {
      body = '''{
      "position": $position,
      "bounds": $bounds,
      "time": $time
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
