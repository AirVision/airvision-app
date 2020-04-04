import 'dart:typed_data';

import 'package:air_vision/util/math/geodetic_bounds.dart';
import 'package:air_vision/util/math/geodetic_position.dart';
import 'package:air_vision/screens/camera/camera_screen.dart';
import 'package:air_vision/screens/debug_screen.dart';
import 'package:air_vision/services/api.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart';
import 'package:air_vision/components/customBottomSheet.dart';
import 'dart:ui' as ui;

const double CAMERA_ZOOM = 10;
const double CAMERA_TILT = 20;
const double CAMERA_BEARING = 0;
const LatLng CAMERA_LOCATION = LatLng(0, 0);

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
  bool canMakeRequest = true;
  Timer _timer;

  CameraPosition initialCameraPosition;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  BitmapDescriptor pinLocationIcon;
  Uint8List markerIcon;

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  getCustomMarker(int size) async {
    markerIcon = await getBytesFromAsset('assets/plane.png', size);
  }

  @override
  void initState() {
    super.initState();
    getCustomMarker(250);

    _timer = Timer.periodic(
        Duration(seconds: 1), (Timer t) => canMakeRequest = true);
    location = new Location();
    rootBundle.loadString('assets/mapStyle.txt').then((string) {
      _mapStyle = string;
    });
    setInitialLocation().then((data) {
      setUserLocation();
    });
  }

  void setUserLocation() async {
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
  }

  Future<void> setInitialLocation() async {
    currentLocation = await location.getLocation();
  }

  void updateAircrafts() {
    controller.getVisibleRegion().then((LatLngBounds res) {
      var bounds = GeodeticBounds(
          min: GeodeticPosition(
              latitude: res.southwest.latitude,
              longitude: res.southwest.longitude),
          max: GeodeticPosition(
              latitude: res.northeast.latitude,
              longitude: res.northeast.longitude));

      if (canMakeRequest) {
        markers.clear();
        canMakeRequest = false;
        _api.getAll(bounds: bounds).then((aircrafts) {
          aircrafts.forEach((aircraft) {
            if (aircraft.position != null && aircraft.onGround == false) {
              final markerId = MarkerId(aircraft.icao24);
              final marker = Marker(
                  markerId: markerId,
                  position: LatLng(aircraft.position[0], aircraft.position[1]),
                  icon: BitmapDescriptor.fromBytes(markerIcon),
                  rotation:
                      aircraft.heading != null ? (aircraft.heading - 90) : null,
                  onTap: () {
                    _api.getPositionalData(markerId.value).then((aircraft) {
                      if (aircraft != null) {
                        showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20.0),
                                  topLeft: Radius.circular(20)),
                            ),
                            builder: (context) {
                              return CustomBottomSheet(aircraft);
                            }).whenComplete(() {});
                      }
                    });
                  });
              setState(() {
                markers[marker.markerId] = marker;
              });
            }
          });
        });
      }
    });
  }

  void onMarkerTap(MarkerId id) {
    print(id.value);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: CAMERA_LOCATION);

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
              if (cameraPosition.zoom > 10) {
                getCustomMarker(150);
              }
              if (cameraPosition.zoom < 10 && cameraPosition.zoom > 6) {
                getCustomMarker(100);
              }
              if (cameraPosition.zoom < 6) {
                getCustomMarker(50);
              }
            },
            markers: Set<Marker>.of(markers.values),
            buildingsEnabled: true,
            myLocationEnabled: true,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            tiltGesturesEnabled: false,
            zoomGesturesEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              controller.setMapStyle(_mapStyle);
              _controller.complete(controller);
            },
          ),
          Positioned(
            right: 10,
            top: 35.0,
            child: Container(
              height: 50,
              width: 50,
              color: Colors.white,
              child: IconButton(
                onPressed: () {
                  setUserLocation();
                },
                icon: Icon(Icons.my_location),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
