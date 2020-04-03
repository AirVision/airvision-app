import 'dart:async';
import 'dart:convert';

import 'package:air_vision/math/euler_angles.dart';
import 'package:air_vision/services/api.dart';
import 'package:air_vision/services/orientation_service.dart';
import 'package:air_vision/services/time_service.dart';
import 'package:air_vision/math/quaternion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:sensors/sensors.dart';
import 'package:vector_math/vector_math.dart' show Quaternion, degrees;

class DebugScreen extends StatefulWidget {
  static const String id = 'leaderboard_screen';

  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {

  final OrientationService _orientationService = OrientationService();

  double lat = -0;
  double lon = -0;
  Timer _timer;
  String _timeString;
  Api _api = Api();

  LocationData _location;
  final Location location = Location();
  final TimeService _timeService = TimeService();

  StreamSubscription<LocationData> _locationSubscription;

  bool loading = false;

  EulerAngles _rotation = EulerAngles.zero();

  Future<void> _updateDeviceOrientation() async {
    try {
      final Quaternion rotation = await _orientationService.getQuaternion();
      setState(() {
        _rotation = rotation.toEulerAngles();
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }

  _listenLocation() async {
    _locationSubscription = location.onLocationChanged().handleError((err) {
      setState(() {});
      _locationSubscription.cancel();
    }).listen((LocationData currentLocation) {
      if (mounted) {
        setState(() {
          _location = currentLocation;
          lat = _location.latitude;
          lon = _location.longitude;
        });
      }
    });
  }

  @override
  void initState() {
    _orientationService.start();
    _timeString = _timeService.getCurrentTime();
    if (mounted) {
      _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _update());
      _listenLocation();
    }
    super.initState();
  }

  void _update() async {
    _updateTime();
    await _updateDeviceOrientation();
  }

  void _updateTime() {
    setState(() {
      _timeString = _timeService.getCurrentTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _locationSubscription.cancel();
    _orientationService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Debug',
          style: TextStyle(color: Colors.black87),
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
      body: Stack(
        children: <Widget>[
          Padding(
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
                        Icon(Icons.rotate_right),
                        SizedBox(
                          width: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('Pitch: ${degrees(_rotation.pitch).toStringAsFixed(1)}'),
                            SizedBox(
                              width: 20.0,
                            ),
                            Text('Yaw: ${degrees(_rotation.yaw).toStringAsFixed(1)}'),
                            SizedBox(
                              width: 20.0,
                            ),
                            Text('Roll: ${degrees(_rotation.roll).toStringAsFixed(1)}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                    child: Row(
                      children: <Widget>[
                        Icon(FontAwesomeIcons.server),
                        SizedBox(
                          width: 20.0,
                        ),
                        FlatButton(
                            onPressed: () {
                              setState(() {
                                loading = true;
                              });
                              _api.getAll().then((res) {
                                setState(() {
                                  loading = false;
                                });
                                var data = res.length;
                                Fluttertoast.showToast(
                                    msg:
                                        "Request succesfull first record ICAO is: $data",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              });
                            },
                            child: Text('Request /all'))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: loading ? true : false,
            child: SpinKitRing(
              color: Theme.of(context).primaryColor,
              size: 50.0,
            ),
          )
        ],
      ),
    );
  }
}
