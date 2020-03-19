import 'package:air_vision/screens/camera_screen.dart';
import 'package:air_vision/screens/leaderboard_screen.dart';
import 'package:air_vision/screens/settings_screen.dart';
import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  static const String id = 'map_screen';

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        notchMargin: 5.0,
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 70.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.settings),
                    Text(
                      'Settings',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.pushNamed(context, SettingsScreen.id);
                },
              ),
              SizedBox(),
              FlatButton(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.bug_report),
                    Text(
                      'Debug',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.pushNamed(context, LeaderBoardScreen.id);
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        height: 70.0,
        width: 70.0,
        child: FittedBox(
          child: FloatingActionButton(
            elevation: 0,
            hoverElevation: 0,
            focusElevation: 0,
            highlightElevation: 0,
            onPressed: () {Navigator.pushNamed(context, CameraScreen.id);},
            child: Icon(Icons.photo_camera),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Image(
              fit: BoxFit.fitHeight,
              image: AssetImage('assets/googlemap.jpg'),
            ),
          ),
        ],
      ),
    );
  }
}
