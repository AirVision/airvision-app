import 'package:air_vision/screens/camera/camera_screen.dart';
import 'package:air_vision/screens/debug_screen.dart';
import 'package:air_vision/services/api.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart';
import 'package:air_vision/components/customBottomSheet.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 20;
const double CAMERA_BEARING = 0;
const LatLng SOURCE_LOCATION = LatLng(42.747932, -71.167889);
const LatLng DEST_LOCATION = LatLng(37.335685, -122.0605916);

class MapScreen extends StatefulWidget {
  static const String id = 'map_screen';

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  String _mapStyle;
  LocationData currentLocation;
  Location location;
  GoogleMapController controller;
  Api _api = Api();

  @override
  void initState() {
    super.initState();
    location = new Location();
    location.onLocationChanged().listen((LocationData cLoc) {
      currentLocation = cLoc;
      updatePinOnMap();
    });
    rootBundle.loadString('assets/mapStyle.txt').then((string) {
      _mapStyle = string;
    });
    setInitialLocation();
  }

  void updatePinOnMap() async {
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
  }

  void setInitialLocation() async {
    currentLocation = await location.getLocation();
  }

  void updateAircrafts() async {
    controller.getVisibleRegion().then((LatLngBounds res) async {
      var bounds = [
        [res.northeast.latitude, res.northeast.longitude],
        [res.southwest.latitude, res.southwest.longitude]
      ];

      _api.getAll(bounds: bounds).then((aircrafts){
        print(aircrafts);
      });
      var pinLocationIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/plane.png');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: SOURCE_LOCATION);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING);
    }

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
                  // Navigator.pushNamed(context, SettingsScreen.id);
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
                  Navigator.pushNamed(context, DebugScreen.id);
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
            onPressed: () {
              Navigator.pushNamed(context, CameraScreen.id);
            },
            child: Icon(Icons.photo_camera),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Stack(
        children: <Widget>[
          GoogleMap(
              onCameraMove: (CameraPosition cameraPosition) {
                // cameraPosition will have zoom, tilt, target(LatLng) and bearing
                updateAircrafts();
              },
              buildingsEnabled: true,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              tiltGesturesEnabled: false,
              zoomGesturesEnabled: true,
              mapType: MapType.normal,
              initialCameraPosition: initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                controller.setMapStyle(_mapStyle);
                _controller.complete(controller);
              })
        ],
      ),
    );
  }
}
