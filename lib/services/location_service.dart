import 'dart:async';

import 'package:flutter/services.dart';
import 'package:location/location.dart';

class LocationService {
  final Location location = new Location();
  StreamSubscription<LocationData> _locationSubscription;
  LocationData _location;

  Future<LocationData> getLocation() async {
    try {
      var _locationResult = await location.getLocation();
      _location = _locationResult;
      return _location;
    } on PlatformException catch (err) {
      print(err.code);
    }
    return null;
  }

  stopListen() async {
    _locationSubscription.cancel();
  }
}
