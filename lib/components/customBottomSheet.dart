import 'package:air_vision/models/aircraftState.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './customListTile.dart';

class CustomBottomSheet extends StatefulWidget {
  // final AircraftState state;

  // const CustomBottomSheet({this.state});

  final dynamic res;

  const CustomBottomSheet(this.res);


  @override
  _CustomBottomSheetState createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20.0), topLeft: Radius.circular(20)),
          child: Container(
            color: Colors.blue,
            height: 70.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    child: Divider(
                      color: Colors.white,
                      thickness: 3.0,
                      endIndent: 130.0,
                      indent: 130.0,
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "FLIGHT: LX856",
                    style: TextStyle(color: Colors.white, letterSpacing: 4),
                  )
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            Text(widget.res),
            // CustomListTile(FontAwesomeIcons.plane, widget.state.icao24),
            SizedBox(
              height: 10.0,
            ),
          ]),
        ),
      ],
    );
  }
}
