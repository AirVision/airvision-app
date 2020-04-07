import 'package:air_vision/models/aircraftState.dart';
import 'package:air_vision/models/flightInfo.dart';
import 'package:air_vision/services/api.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import './customListTile.dart';

class CustomBottomSheet extends StatefulWidget {
  final AircraftState aircraft;

  const CustomBottomSheet(this.aircraft);

  @override
  _CustomBottomSheetState createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  Api _api = Api();
  FlightInfo info;

  @override
  void initState() {
    super.initState();
    _api.getSpecificFlightInfo(widget.aircraft.icao24).then((res) {
      if (mounted) {
        setState(() {
          info = res;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double knots = widget.aircraft.velocity * 1.94384;
    double vKnots = widget.aircraft.verticalRate * 1.94384;

    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20.0), topLeft: Radius.circular(20)),
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
                  info != null && info.number != null ?  Text(
                    info.number,
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400),
                  ): SizedBox(),
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
              CustomListTile(
                  LineIcons.globe,
                  (widget.aircraft.position[0].toStringAsFixed(3) +
                      ', ' +
                      widget.aircraft.position[1].toStringAsFixed(3) +
                      ', ' +
                      widget.aircraft.position[2].toStringAsFixed(1) +
                      'm')),
              widget.aircraft.velocity != null
                  ? CustomListTile(
                      LineIcons.space_shuttle,
                      widget.aircraft.velocity.toStringAsFixed(2) +
                          ' m/s, ' +
                          knots.toStringAsFixed(2) +
                          ' kt')
                  : Container(),
              widget.aircraft.verticalRate != null && widget.aircraft.verticalRate != 0
                  ? CustomListTile(
                      LineIcons.angle_double_up,
                      widget.aircraft.verticalRate.toStringAsFixed(2) +
                          ' m/s, ' +
                          vKnots.toStringAsFixed(2) +
                          ' kt')
                  : Container(),
              info != null
                  ? Column(
                      children: <Widget>[
                        CustomListTile(
                            Icons.flight_takeoff, info.departureAirport.name),
                        CustomListTile(
                            Icons.flight_land, info.arrivalAirport.name),
                          SizedBox(height: 20.0,)
                      ],
                    )
                  : CustomListTile(
                      LineIcons.info_circle, 'No additional information found'),
            ]),
          ),
        ),
      ],
    );
  }
}
