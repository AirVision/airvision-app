import 'dart:async';

import 'package:air_vision/services/location_service.dart';
import 'package:air_vision/services/time_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:sensors/sensors.dart';

class DebugScreen extends StatefulWidget {
  static const String id = 'leaderboard_screen';

  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  double lat = -0;
  double lon = -0;
  double x;
  double y;
  double z;
  String _timeString;
  LocationData _location;
  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  final Location location = Location();

  final TimeService _timeService = TimeService();

  StreamSubscription<LocationData> _locationSubscription;
  LocationService _locationService = LocationService();

  _listenLocation() async {
    _locationSubscription = location.onLocationChanged().handleError((err) {
      setState(() {});
      _locationSubscription.cancel();
    }).listen((LocationData currentLocation) {
      setState(() {
        _location = currentLocation;
        lat = _location.latitude;
        lon = _location.longitude;
      });
    });
  }

  @override
  void initState() {
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
    _listenLocation();
    _timeString =
        "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";
    Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
    super.initState();
  }

  void _updateTime() {
    setState(() {
      _timeString = _timeService.getCurrentTime();
    });
  }

  @override
  void dispose() {
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _locationService.stopListen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Debug',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.access_time),
                    SizedBox(
                      width: 20.0,
                    ),
                    Text(_timeString),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.location_on),
                    SizedBox(
                      width: 20.0,
                    ),
                    Text('Lat: ${lat.toStringAsFixed(2)}'),
                    SizedBox(
                      width: 20.0,
                    ),
                    Text('Lon: ${lon.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                child: Row(
                  children: <Widget>[
                    Icon(FontAwesomeIcons.draftingCompass),
                    SizedBox(
                      width: 20.0,
                    ),
                    Text('x: ${gyroscope[0]}'),
                    SizedBox(
                      width: 20.0,
                    ),
                    Text('y: ${gyroscope[1]}'),
                    SizedBox(
                      width: 20.0,
                    ),
                    Text('z: ${gyroscope[2]}'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
