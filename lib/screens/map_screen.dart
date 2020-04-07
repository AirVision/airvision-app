import 'dart:typed_data';
import 'package:air_vision/models/flightInfo.dart';
import 'package:air_vision/util/math/geodetic_bounds.dart';
import 'package:air_vision/util/math/geodetic_position.dart';
import 'package:air_vision/services/api.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  // Used for google maps
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController controller;
  LocationData currentLocation;
  Location location;
  String _mapStyle;
  CameraPosition initialCameraPosition;

  // Used to place to markers and get which marker has been clicked on
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  BitmapDescriptor pinLocationIcon;
  Uint8List markerIcon;
  Uint8List selectedMarkerIcon;
  MarkerId selectedMarker;

  // Used for the requests to the api
  // Timer is currently being used to prevent a lot of requests per second, which can lead to the app crashing.
  Api _api = Api();
  Timer _timer;
  bool canMakeRequest = true;

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
    selectedMarkerIcon =
        await getBytesFromAsset('assets/planeSelected.png', size);
  }

  @override
  void initState() {
    super.initState();
    setUserLocation();
    _timer = Timer.periodic(
        Duration(seconds: 1),
        (Timer t) => {
              canMakeRequest = true,
            });

    rootBundle.loadString('assets/mapStyle2.txt').then((string) {
      _mapStyle = string;
    });
  }

  void setUserLocation() async {
    location = Location();
    currentLocation = await location.getLocation();

    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );

    controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
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
              Uint8List icon;
              icon =
                  markerId == selectedMarker ? selectedMarkerIcon : markerIcon;
              final marker = Marker(
                  markerId: markerId,
                  position: LatLng(aircraft.position[0], aircraft.position[1]),
                  icon: BitmapDescriptor.fromBytes(icon),
                  rotation:
                      aircraft.heading != null ? (aircraft.heading - 90) : null,
                  onTap: () {
                    selectedMarker = markerId;
                    updateAircrafts();
                    _api.getPositionalData(markerId.value).then((aircraft) {
                      if (aircraft != null) {
                        FlightInfo info;
                        _api.getSpecificFlightInfo(markerId.value).then((res) {
                          info = res;
                          showModalBottomSheet(
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20.0),
                                    topLeft: Radius.circular(20)),
                              ),
                              builder: (context) {
                                return CustomBottomSheet(aircraft, info: info);
                              }).whenComplete(() {
                            selectedMarker = MarkerId('1');
                            updateAircrafts();
                          });
                        });
                      }
                    }).catchError((e) {
                      Fluttertoast.showToast(
                          msg: "No information found",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onCameraMove: (CameraPosition cameraPosition) {
              // cameraPosition will have zoom, tilt, target(LatLng) and bearing
              updateAircrafts();
              if (cameraPosition.zoom > 10) {
                getCustomMarker(125);
              }
              if (cameraPosition.zoom < 10 && cameraPosition.zoom > 8) {
                getCustomMarker(100);
              }
              if (cameraPosition.zoom < 8 && cameraPosition.zoom > 6) {
                getCustomMarker(75);
              }
              if (cameraPosition.zoom < 6 && cameraPosition.zoom > 5) {
                getCustomMarker(50);
              }
              if (cameraPosition.zoom < 5) {
                getCustomMarker(25);
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.topRight,
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
            ),
          ),
        ],
      ),
    );
  }
}
