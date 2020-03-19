import 'package:air_vision/screens/camera_screen.dart';
import 'package:air_vision/screens/debug_screen.dart';
import 'package:air_vision/screens/map_screen.dart';
import 'package:air_vision/screens/settings_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(AirVision());

class AirVision extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Air Vision',
      theme: ThemeData(
        primaryColor: Color(0xFF3496F7),
        accentColor: Color(0xFF3496F7)
      ),
      initialRoute: MapScreen.id,
      routes: {
        MapScreen.id: (context) => MapScreen(),
        CameraScreen.id: (context) => CameraScreen(),
        SettingsScreen.id: (context) => SettingsScreen(),
        DebugScreen.id: (context) => DebugScreen()
      },
    );
  }
}
