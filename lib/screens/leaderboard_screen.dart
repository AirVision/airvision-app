import 'package:air_vision/services/location.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';

class LeaderBoardScreen extends StatefulWidget {
  static const String id = 'leaderboard_screen';

  @override
  _LeaderBoardScreenState createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends State<LeaderBoardScreen> {
  double lat = -0;
  double lon = -0;

  double x;
  double y;
  double z;

  LocationService locationService = LocationService();

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  void getLocation() async {
    LocationData location = await locationService.getLocation();
    // print(location);
    setState(() {
      lat = location.latitude;
      lon = location.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    var now = new DateTime.now();
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
                    Text(now.toString()),
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
                    Text('x: ${lat.toStringAsFixed(2)}'),
                    SizedBox(
                      width: 20.0,
                    ),
                    Text('y: ${lon.toStringAsFixed(2)}'),
                    SizedBox(
                      width: 20.0,
                    ),
                    Text('z: ${lon.toStringAsFixed(2)}'),
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
