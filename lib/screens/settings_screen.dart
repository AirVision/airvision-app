import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool locationGranted = false;
  bool cameraGranted = false;
  List<String> speedSystems = ['M/s', 'Km/h', 'Knots'];
  int selectedSpeedSystem;

  @override
  void initState() {
    getPermissions();
    getSelectedValues();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getPermissions() async {
    var statusCamera = await Permission.camera.status;
    var statusLocation = await Permission.location.status;

    if (mounted) {
      if (statusCamera.isGranted) {
        setState(() {
          cameraGranted = true;
        });
      } else {
        setState(() {
          cameraGranted = false;
        });
      }
    }

    if (statusLocation.isGranted) {
      setState(() {
        locationGranted = true;
      });
    } else {
      setState(() {
        locationGranted = false;
      });
    }
  }

  getSelectedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var indexSpeedSystem = speedSystems.indexOf(prefs.getString('speedSystem'));
    indexSpeedSystem = indexSpeedSystem == -1 ? 0 : indexSpeedSystem;
    setState(() {
      selectedSpeedSystem = indexSpeedSystem;
    });
  }

  updateSpeedSystem(index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('speedSystem', speedSystems[index]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: selectedSpeedSystem != null
            ? Container(
                padding: EdgeInsets.all(26.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Displayed data',
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      'Change how the app displays values',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    Text(
                      'Preffered measurement of velocity',
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 6.0,
                    ),
                    ToggleSwitch(
                      
                      initialLabelIndex: selectedSpeedSystem,
                      activeBgColor: Theme.of(context).primaryColor,
                      activeTextColor: Colors.white,
                      inactiveBgColor: Colors.grey[400],
                      inactiveTextColor: Colors.black,
                      labels: speedSystems,
                      onToggle: (index) {
                        updateSpeedSystem(index);
                      },
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    Text(
                      'Permissions',
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      'Easy way to edit permissions given to the app. To change permissions tap on \'Manage permissions\'.',
                      style: TextStyle(fontSize: 14.0),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      'Location',
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    GestureDetector(
                      onTap: () {
                          AppSettings.openLocationSettings();
                      },
                                          child: Container(
                        height: 50.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                          color: locationGranted ? Colors.green : Colors.red,
                        ),
                        child: Center(
                          child: Text(
                            locationGranted
                                ? "Permission granted"
                                : "Permission not granted",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      'Camera',
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Container(
                      height: 50.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        color: cameraGranted ? Colors.green : Colors.red,
                      ),
                      child: Center(
                        child: Text(
                          cameraGranted
                              ? "Permission granted"
                              : "Permission not granted",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 45.0,
                                          child: RaisedButton(onPressed: (){
                      AppSettings.openAppSettings();
                      }, child: Text("Manage permissions", style: TextStyle(color: Colors.white),), color: Theme.of(context).primaryColor, shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),),
                    )
                  ],
                ),
              )
            : SpinKitChasingDots(
                color: Theme.of(context).primaryColor,
                size: 64.0,
              ),
      ),
    );
  }
}
