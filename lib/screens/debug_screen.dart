import 'dart:async';
import 'package:air_vision/util/math/euler_angles.dart';
import 'package:air_vision/services/api.dart';
import 'package:air_vision/services/orientation_service.dart';
import 'package:air_vision/services/time_service.dart';
import 'package:air_vision/util/math/quaternion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
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
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 25.0,
                  ),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/debug.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _timeString,
                          style: TextStyle(
                              fontSize: 64.0,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff293A4F),
                              letterSpacing: 2.0),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "DEBUGGING...",
                          style: TextStyle(
                              fontSize: 14.0,
                              letterSpacing: 2.0,
                              color: Color(0xff293A4F)),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffE9E9E9),
                          blurRadius:
                              5.0, // has the effect of softening the shadow
                          spreadRadius:
                              0.0, // has the effect of extending the shadow
                        )
                      ],
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                          child: Row(
                            children: <Widget>[
                              Icon(FontAwesomeIcons.mapPin),
                              SizedBox(
                                width: 20.0,
                              ),
                              Text('Latitude: ${lat.toStringAsFixed(2)}'),
                              SizedBox(
                                width: 20.0,
                              ),
                              Text('Longitude: ${lon.toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
                        Positioned(
                          child: Text(
                            'Location',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          top: 7,
                          right: 10,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffE9E9E9),
                          blurRadius:
                              5.0, // has the effect of softening the shadow
                          spreadRadius:
                              0.0, // has the effect of extending the shadow
                        )
                      ],
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Stack(children: <Widget>[
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                        child: Row(
                          children: <Widget>[
                            Icon(FontAwesomeIcons.compass),
                            SizedBox(
                              width: 20.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                    'Pitch: ${degrees(_rotation.pitch).toStringAsFixed(1)}'),
                                SizedBox(
                                  width: 20.0,
                                ),
                                Text(
                                    'Yaw: ${degrees(_rotation.yaw).toStringAsFixed(1)}'),
                                SizedBox(
                                  width: 20.0,
                                ),
                                Text(
                                    'Roll: ${degrees(_rotation.roll).toStringAsFixed(1)}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        child: Text(
                          'Orientation',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        top: 7,
                        right: 10,
                      )
                    ]),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        loading = true;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xffE9E9E9),
                            blurRadius:
                                5.0, // has the effect of softening the shadow
                            spreadRadius:
                                0.0, // has the effect of extending the shadow
                          )
                        ],
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Stack(children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.network_check),
                              SizedBox(
                                width: 20.0,
                              ),
                              Text('Request server status')
                            ],
                          ),
                        ),
                        Positioned(
                          child: Text(
                            'Status',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          top: 7,
                          right: 10,
                        )
                      ]),
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
      ),
    );
  }
}
