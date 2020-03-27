import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './customListTile.dart';

class CustomBottomSheet extends StatelessWidget {
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
            CustomListTile(FontAwesomeIcons.plane),
            CustomListTile(FontAwesomeIcons.tag),
            CustomListTile(FontAwesomeIcons.globeEurope),
            CustomListTile(FontAwesomeIcons.tachometerAlt),
            CustomListTile(FontAwesomeIcons.planeArrival),
            CustomListTile(FontAwesomeIcons.planeDeparture),
            CustomListTile(Icons.info),
            CustomListTile(Icons.info),
            SizedBox(
              height: 10.0,
            ),
          ]),
        ),
      ],
    );
  }
}
