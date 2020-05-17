import 'package:flutter/material.dart';

class InfoScreen extends StatefulWidget {
  static const String id = 'leaderboard_screen';

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tutorial",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(26.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'How to use',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 4.0,
            ),
            Text(
              'There are two options when it comes to using the camera to scan an aircraft.',
              style: TextStyle(fontSize: 14.0),
            ),
            SizedBox(
              height: 24.0,
            ),
            Text(
              'Option 1',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
             SizedBox(
              height: 6.0,
            ),
            Text(
              'Look for an aircraft in the sky and let the artifical intelligence help you. When it finds an aircraft, a blue square will appear and you will be able to press the \'Scan aircraft\' button.',
              style: TextStyle(fontSize: 14.0), textAlign: TextAlign.justify,
            ),
            SizedBox(
              height: 16.0,
            ),
             Text(
              'Option 2',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500), textAlign: TextAlign.justify,
            ),
              SizedBox(
              height: 6.0,
            ),
            Text(
              'When the artificial intelligence is having some trouble detecting the aircraft your looking at, you can always just tap the aircraft on the screen and the app will search for an aircraft that matches that position.',
              style: TextStyle(fontSize: 14.0), textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
