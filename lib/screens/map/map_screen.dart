import 'dart:typed_data';
import 'package:air_vision/models/aircraftState.dart';
import 'package:air_vision/models/flightInfo.dart';
import 'package:air_vision/screens/map/map_markers.dart';
import 'package:air_vision/util/math/geodetic_bounds.dart';
import 'package:air_vision/util/math/geodetic_position.dart';
import 'package:air_vision/services/api.dart';
import 'package:flutter/material.dart';
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
  int makeRequestTime = 250;
  bool modalIsOpen = false;
  bool _timerisActive = false;

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
    double _timerValue = 500;
    const oneMiliSec = const Duration(milliseconds: 100);
    _timer = new Timer.periodic(
      oneMiliSec,
      (Timer timer) => setState(
        () {
          print("TIMER");
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
    if (zoom > 10) {
      markerIcon = await getCustomMarkerIcon(125);
      selectedMarkerIcon = await getCustomSelectedMarkerIcon(125);
    }
    if (zoom < 10 && zoom > 8) {
      markerIcon = await getCustomMarkerIcon(100);
      selectedMarkerIcon = await getCustomSelectedMarkerIcon(100);
    }
    if (zoom < 8 && zoom > 6) {
      markerIcon = await getCustomMarkerIcon(75);
      selectedMarkerIcon = await getCustomSelectedMarkerIcon(75);
    }
    if (zoom < 6 && zoom > 5) {
      markerIcon = await getCustomMarkerIcon(50);
      selectedMarkerIcon = await getCustomSelectedMarkerIcon(50);
    }
    if (zoom < 5) {
      markerIcon = await getCustomMarkerIcon(25);
      selectedMarkerIcon = await getCustomSelectedMarkerIcon(25);
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
      points: waypoints,
      color: Theme.of(context).primaryColor,
    ));
  }

  // Gets specifc flight information
  Future<void> getFlightInformation() async {
    selectedFlightInfo = await _api.getSpecificFlightInfo(selectedMarker.value);
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
            return CustomBottomSheet(selectedAircraft,
                info: selectedFlightInfo);
          }).whenComplete(() {
        modalIsOpen = false;
      });
    }
  }

  Future<void> updateAircrafts() async {
    // Gets visible region of the mapcamera
    controller.getVisibleRegion().then((LatLngBounds res) {
      // set min and max bounds
      var bounds = GeodeticBounds(
          min: GeodeticPosition(
              latitude: res.southwest.latitude,
              longitude: res.southwest.longitude),
          max: GeodeticPosition(
              latitude: res.northeast.latitude,
              longitude: res.northeast.longitude));

      // Clear markers to prevent duplicates
      markers.clear();

      // Get all aircrafts currently within the latlng bounds of the mapcamera
      _api.getAll(bounds: bounds).then((aircrafts) {
        aircrafts.forEach((aircraft) {
          if (aircraft.position != null) {
            final markerId = MarkerId(aircraft.icao24);

            // Determine if current marker is selected to change icon
            Uint8List icon =
                markerId == selectedMarker ? selectedMarkerIcon : markerIcon;

            // Create markers
            final marker = Marker(
                markerId: markerId,
                position: LatLng(aircraft.position[0], aircraft.position[1]),
                icon: BitmapDescriptor.fromBytes(icon),
                anchor: Offset(0, 0),
                rotation: aircraft.heading != null ? (aircraft.heading) : null,
                onTap: () async {
                  selectedAircraft = null;
                  selectedFlightInfo = null;
                  if (selectedMarker != markerId) _polyline.clear();
                  selectedMarker = markerId;

                  await updateAircrafts();
                  await getAircraftState().catchError((e) {});
                  await getFlightInformation().catchError((e) {});
                  // if (selectedFlightInfo != null) updateWaypoints();
                  openInformationModal();
                });
            setState(() {
              markers[marker.markerId] = marker;
            });
          }
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
