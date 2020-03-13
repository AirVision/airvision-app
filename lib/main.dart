import 'package:air_vision/screens/camera_screen.dart';
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
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MapScreen(),
        '/camera': (context) => CameraScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
