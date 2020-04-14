import 'dart:async';

import 'package:air_vision/models/aircraftState.dart';
import 'package:air_vision/models/flightInfo.dart';
import 'package:air_vision/services/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import './customListTile.dart';

class CustomBottomSheet extends StatefulWidget {
  final AircraftState aircraft;
  final FlightInfo info;
  const CustomBottomSheet({this.aircraft, this.info});

  @override
  _CustomBottomSheetState createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  Timer _timer;
  int _timerValue = 1;
  bool nothingFound = false;

  @override
  void initState() {
    super.initState();
    startTimer();
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
    double knots;
    double vKnots;

    if (widget.aircraft != null) {
      knots = widget.aircraft.velocity == null? 0 : widget.aircraft.velocity * 1.94384;
      vKnots = widget.aircraft.verticalRate == null? 0 : widget.aircraft.verticalRate * 1.94384;
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
                          "FLIGHT INFORMATION",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 2.0,
                        ),
                        widget.info != null && widget.info.number != null
                            ? Text(
                                widget.info.number,
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w400),
                              )
                            : SizedBox(),
                        SizedBox(
                          height: 2.0,
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
                    CustomListTile(LineIcons.tag, widget.aircraft.icao24),
                    widget.info != null
                        ? Column(
                            children: <Widget>[
                              CustomListTile(Icons.flight_takeoff,
                                  widget.info.departureAirport.name),
                              CustomListTile(Icons.flight_land,
                                  widget.info.arrivalAirport.name)
                            ],
                          )
                        : SizedBox(),
                    widget.aircraft.position != null &&
                            widget.aircraft.position.length == 3
                        ? CustomListTile(
                            LineIcons.globe,
                            (widget.aircraft.position[0].toStringAsFixed(3) +
                                ', ' +
                                widget.aircraft.position[1].toStringAsFixed(3) +
                                ', ' +
                                widget.aircraft.position[2].toStringAsFixed(1) +
                                'm'))
                        : CustomListTile(
                            LineIcons.globe,
                            (widget.aircraft.position[0].toStringAsFixed(3) +
                                ', ' +
                                widget.aircraft.position[1].toStringAsFixed(3)),
                          ),
                    widget.aircraft.velocity != null
                        ? CustomListTile(
                            LineIcons.space_shuttle,
                            widget.aircraft.velocity.toStringAsFixed(2) +
                                ' m/s, ' +
                                knots.toStringAsFixed(2) +
                                ' kt')
                        : Container(),
                    widget.aircraft.verticalRate != null &&
                            widget.aircraft.verticalRate != 0
                        ? CustomListTile(
                            LineIcons.angle_double_up,
                            widget.aircraft.verticalRate.toStringAsFixed(2) +
                                ' m/s, ' +
                                vKnots.toStringAsFixed(2) +
                                ' kt')
                        : Container(),
                    SizedBox(
                      height: 20.0,
                    )
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
