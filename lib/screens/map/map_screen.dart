import 'dart:typed_data';
import 'package:air_vision/models/aircraftState.dart';
import 'package:air_vision/models/flightInfo.dart';
import 'package:air_vision/screens/map/map_markers.dart';
import 'package:air_vision/util/math/geodetic_bounds.dart';
import 'package:air_vision/util/math/geodetic_position.dart';
import 'package:air_vision/services/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart';
import 'package:air_vision/components/customBottomSheet.dart';

//Map constansts
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
  // Used to control custom google maps behaviour
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController controller;
  LocationData currentLocation;
  Location location;
  String _mapStyle;
  CameraPosition initialCameraPosition;
  Set<Polyline> _polyline = {};
  double currentZoomlevel = 10;

  // Used to place to markers and get which marker has been clicked on
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  BitmapDescriptor pinLocationIcon;
  List<List<Uint8List>> planeMarkers = [];
  Uint8List airportIcon;
  MarkerId selectedMarker;

  // Used for the requests to the api
  // Timer is currently being used to prevent a lot of requests per second, which can lead to the app crashing.
  Api _api = Api();
  Timer _timer;
  int makeRequestTime = 250;
  bool modalIsOpen = false;
  bool _timerisActive = false;
  bool loading = false;

  //Modal information
  FlightInfo selectedFlightInfo;
  AircraftState selectedAircraft;

  @override
  void initState() {
    super.initState();
    setUserLocation();
    rootBundle.loadString('assets/mapStyle2.txt').then((string) {
      _mapStyle = string;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    _timerisActive = true;
    double _timerValue = 300;
    const oneMiliSec = const Duration(milliseconds: 100);
    _timer = new Timer.periodic(
      oneMiliSec,
      (Timer timer) => setState(
        () {
          if (_timerValue < 100) {
            updateAircrafts();
            _timerisActive = false;
            timer.cancel();
          } else {
            _timerValue = _timerValue - 100;
          }
        },
      ),
    );
  }

  void updateMakerSize(zoom) async {
    airportIcon = await getAirportIcon();

    if (zoom > 10) {
      planeMarkers = await getNormalMarkerIcon(125, 125);
    }
    if (zoom < 10 && zoom > 8) {
      planeMarkers = await getNormalMarkerIcon(100, 100);
    }
    if (zoom < 8 && zoom > 6) {
      planeMarkers = await getNormalMarkerIcon(75, 75);
    }
    if (zoom < 6 && zoom > 5) {
      planeMarkers = await getNormalMarkerIcon(50, 75);
    }
    if (zoom < 5) {
      planeMarkers = await getNormalMarkerIcon(30, 75);
    }

    if (currentZoomlevel - zoom >= 1 || currentZoomlevel - zoom >= 1) {
      markers.clear();
      currentZoomlevel = zoom;
    }
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

  void updateWaypoints() {
    List<LatLng> waypoints = [];

    if (selectedFlightInfo.waypoints != null) {
      selectedFlightInfo.waypoints.forEach((w) {
        waypoints.add(LatLng(w.pos[0], w.pos[1]));
      });
    }

    _polyline.add(Polyline(
      polylineId: PolylineId(currentLocation.toString()),
      visible: true,
      width: 3,
      patterns: <PatternItem>[PatternItem.dash(20), PatternItem.gap(15)],
      points: waypoints,
      color: Theme.of(context).primaryColor,
    ));
  }

  // Gets specifc flight information
  Future<void> getFlightInformation() async {
    selectedFlightInfo = await _api.getSpecificFlightInfo(selectedMarker.value);

    if (selectedFlightInfo.departureAirport != null) {
      List pos = selectedFlightInfo.departureAirport.position;
      print(pos);
      final marker = Marker(
          markerId: MarkerId("airport"),
          position: LatLng(pos[0], pos[1]),
          icon: BitmapDescriptor.fromBytes(airportIcon),
          // anchor: Offset(0, .5),
          infoWindow: InfoWindow(
            title: selectedFlightInfo.departureAirport.name,
          ));
      setState(() {
        markers[marker.markerId] = marker;
      });
    }
  }

  // Gets aircarft state information
  Future<void> getAircraftState() async {
    selectedAircraft = await _api.getPositionalData(selectedMarker.value);
  }

  void openInformationModal() {
    if (!modalIsOpen) {
      modalIsOpen = true;
      showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.0), topLeft: Radius.circular(20)),
          ),
          builder: (context) {
            return CustomBottomSheet(
                aircraft: selectedAircraft, info: selectedFlightInfo);
          }).whenComplete(() {
        modalIsOpen = false;
      });
    }
  }

  Future<void> updateAircrafts() async {
    loading = true;

    // Gets visible region of the mapcamera
    controller.getVisibleRegion().then((LatLngBounds boundary) {
      // Clear markers to prevent duplicates
      markers.removeWhere((id, marker) =>
          boundary.contains(marker.position) == false &&
          selectedMarker != id &&
          id != MarkerId("airport"));

      // set min and max bounds
      var bounds = GeodeticBounds(
          min: GeodeticPosition(
              latitude: boundary.southwest.latitude,
              longitude: boundary.southwest.longitude),
          max: GeodeticPosition(
              latitude: boundary.northeast.latitude,
              longitude: boundary.northeast.longitude));

      // Get all aircrafts currently within the latlng bounds of the mapcamera
      _api.getAll(bounds: bounds).then((aircrafts) {
        aircrafts.forEach((aircraft) {
          if (aircraft.position != null) {
            final markerId = MarkerId(aircraft.icao24);

            // Change icon according to size and currently selected
            Uint8List icon;
            if (aircraft.weightCategory != null) {
              switch (aircraft.weightCategory) {
                case "Ultralight":
                  icon = markerId == selectedMarker
                      ? planeMarkers[0][1]
                      : planeMarkers[0][0];
                  break;
                case "Light":
                  icon = markerId == selectedMarker
                      ? planeMarkers[1][1]
                      : planeMarkers[1][0];
                  break;
                case "Normal":
                  icon = markerId == selectedMarker
                      ? planeMarkers[2][1]
                      : planeMarkers[2][0];
                  break;
                case "Heavy":
                  icon = markerId == selectedMarker
                      ? planeMarkers[3][1]
                      : planeMarkers[3][0];
                  break;
                case "VeryHeavy":
                  icon = markerId == selectedMarker
                      ? planeMarkers[4][1]
                      : planeMarkers[4][0];
                  break;
              }
            } else {
              icon = markerId == selectedMarker
                  ? planeMarkers[2][1]
                  : planeMarkers[2][0];
            }

            // Create markers
            final marker = Marker(
                markerId: markerId,
                position: LatLng(aircraft.position[0], aircraft.position[1]),
                icon: BitmapDescriptor.fromBytes(icon),
                anchor: Offset(0, .5),
                rotation:
                    aircraft.heading != null ? (aircraft.heading - 90) : null,
                onTap: () async {
                    markers.removeWhere((id, marker) => id.value == "airport");
                  selectedAircraft = null;
                  selectedFlightInfo = null;
                  if (selectedMarker != markerId) _polyline.clear();
                  selectedMarker = markerId;

                  await updateAircrafts().catchError((e) {});
                  await getAircraftState().catchError((e) {});
                  await getFlightInformation().catchError((e) {});
                  if (selectedFlightInfo != null) updateWaypoints();
                  openInformationModal();
                });
            setState(() {
              markers[marker.markerId] = marker;
            });
          }
        });
        setState(() {
          loading = false;
        });
      });
    });
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
              if (_timerisActive) {
                _timer.cancel();
                startTimer();
              } else {
                startTimer();
              }

              updateMakerSize(cameraPosition.zoom);
              currentZoomlevel = cameraPosition.zoom;
            },
            markers: Set<Marker>.of(markers.values),
            buildingsEnabled: true,
            myLocationEnabled: true,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            tiltGesturesEnabled: false,
            zoomGesturesEnabled: true,
            rotateGesturesEnabled: false,
            polylines: _polyline,
            mapType: MapType.normal,
            initialCameraPosition: initialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              controller.setMapStyle(_mapStyle);
              _controller.complete(controller);
            },
          ),
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: loading
                        ? Row(
                            children: <Widget>[
                              Container(
                                height: 50,
                                width: 50,
                                color: Colors.transparent,
                                child: SpinKitFadingCube(
                                  color: Theme.of(context).primaryColor,
                                  size: 25.0,
                                ),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text(
                                "Loading...",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                ),
                Padding(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
