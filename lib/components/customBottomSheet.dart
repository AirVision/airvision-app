import 'dart:async';
import 'package:air_vision/models/aircraftInfo.dart';
import 'package:air_vision/models/aircraftState.dart';
import 'package:air_vision/models/flightInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './customListTile.dart';

class CustomBottomSheet extends StatefulWidget {
  final AircraftState aircraft;
  final FlightInfo flightInfo;
  final AircraftInfo aircraftInfo;
  const CustomBottomSheet({this.aircraft, this.flightInfo, this.aircraftInfo});

  @override
  _CustomBottomSheetState createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  Timer _timer;
  int _timerValue = 1;
  bool nothingFound = false;
  List<String> speedSystems = ['m/s', 'km/h', 'knots'];
  int indexSpeedSystem = 0;

  @override
  void initState() {
    super.initState();
    getSettings();
    startTimer();
  }

  getSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    indexSpeedSystem = speedSystems.indexOf(prefs.getString('speedSystem'));
    indexSpeedSystem = indexSpeedSystem == -1 ? 0 : indexSpeedSystem;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_timerValue < 1) {
            if (widget.aircraft == null) {
              setState(() {
                nothingFound = true;
              });
            }
            timer.cancel();
          } else {
            _timerValue = _timerValue - 1;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String velocity = '';
    String verticalVelocity = '';
    if (widget.aircraft != null && widget.aircraft.velocity != null) {
      switch (speedSystems[indexSpeedSystem]) {
        case 'm/s':
          velocity = widget.aircraft.velocity.toStringAsFixed(2) + ' m/s';
          if (widget.aircraft.verticalRate != null)
            verticalVelocity =
                widget.aircraft.verticalRate.toStringAsFixed(2) + ' m/s';
          break;
        case 'km/h':
          velocity =
              (widget.aircraft.velocity * 3.6).toStringAsFixed(2) + ' km/h';
          if (widget.aircraft.verticalRate != null)
            verticalVelocity =
                (widget.aircraft.verticalRate * 3.6).toStringAsFixed(2) +
                    ' km/h';
          break;
        case 'knots':
          velocity =
              (widget.aircraft.velocity * 1.94384).toStringAsFixed(2) + ' kt';
          if (widget.aircraft.verticalRate != null)
            verticalVelocity =
                (widget.aircraft.verticalRate * 1.94384).toStringAsFixed(2) +
                    ' kt';
          break;
      }
    }

    return widget.aircraft != null
        ? Column(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    topLeft: Radius.circular(20)),
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "INFORMATION",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Divider(
                            color: Colors.black87,
                            thickness: 2.0,
                            endIndent: 150.0,
                            indent: 150.0,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: ListView(children: <Widget>[
                    CustomListTile(
                      LineIcons.tag,
                      widget.aircraft.icao24,
                      'ICAO24',
                    ),
                    widget.flightInfo != null
                        ? Column(
                            children: <Widget>[
                              CustomListTile(LineIcons.tags,
                                  widget.flightInfo.number, 'Flight number'),
                              CustomListTile(
                                  Icons.flight_takeoff,
                                  widget.flightInfo.departureAirport.name,
                                  'Departure'),
                              CustomListTile(
                                  Icons.flight_land,
                                  widget.flightInfo.arrivalAirport.name,
                                  'Arrival')
                            ],
                          )
                        : SizedBox(),
                    widget.aircraft.position != null &&
                            widget.aircraft.position.length == 3
                        ? CustomListTile(
                            LineIcons.globe,
                            ('lat: ' + widget.aircraft.position[0].toStringAsFixed(2) +
                                '° lng: ' +
                                widget.aircraft.position[1].toStringAsFixed(2) +
                                '° alt: ' +
                                widget.aircraft.position[2].toStringAsFixed(1) +
                                'm'),
                            'Position')
                        : CustomListTile(
                            LineIcons.globe,
                            (widget.aircraft.position[0].toStringAsFixed(3) +
                                ', ' +
                                widget.aircraft.position[1].toStringAsFixed(3)),
                            'Position',
                          ),
                    widget.aircraft.velocity != null
                        ? CustomListTile(
                            LineIcons.space_shuttle, velocity, 'Ground speed')
                        : Container(),
                    widget.aircraft.verticalRate != null &&
                            widget.aircraft.verticalRate != 0
                        ? CustomListTile(LineIcons.angle_double_up,
                            verticalVelocity, 'Vertical speed')
                        : Container(),
                    widget.aircraftInfo != null
                        ? Column(
                            children: <Widget>[
                              Center(
                                  child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                  Text('Additional information'),
                                  Divider(
                                    color: Colors.black,
                                    indent: 100.0,
                                    endIndent: 100.0,
                                    thickness: 1,
                                  ),
                                ],
                              )),
                              CustomListTile(Icons.airplanemode_active,
                                  widget.aircraftInfo.model, 'Model'),
                              CustomListTile(LineIcons.fighter_jet,
                                  widget.aircraftInfo.type, 'Type'),
                              CustomListTile(
                                  LineIcons.tachometer,
                                  widget.aircraftInfo.engines.count.toString() +
                                      ' x ' +
                                      widget.aircraftInfo.engines.type +
                                      ' engines',
                                  'Engines'),
                              CustomListTile(FontAwesomeIcons.addressCard,
                                  widget.aircraftInfo.owner, 'Airline'),
                              CustomListTile(
                                  LineIcons.industry,
                                  widget.aircraftInfo.manufacturer.name,
                                  'Manufacturer'),
                            ],
                          )
                        : SizedBox(),
                    SizedBox(
                      height: 20.0,
                    ),
                  ]),
                ),
              ),
            ],
          )
        : Center(
            child: !nothingFound
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SpinKitThreeBounce(
                        color: Theme.of(context).primaryColor,
                        size: 50.0,
                      )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Image(
                          width: 250.0,
                          image: AssetImage('assets/nothingFound.png'),
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              "Sorry!",
                              style: TextStyle(fontSize: 16.0),
                            ),
                            Text("We couldn't find anything...",
                                style: TextStyle(fontSize: 14.0))
                          ],
                        )
                      ]),
          );
  }
}
