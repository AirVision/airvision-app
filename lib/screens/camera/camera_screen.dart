import 'dart:async';
import 'package:air_vision/util/camera/camera.dart';
import 'package:air_vision/components/customBottomSheet.dart';
import 'package:air_vision/models/aircraftState.dart';
import 'package:air_vision/models/flightInfo.dart';
import 'package:air_vision/services/api.dart';
import 'package:air_vision/screens/Camera/drawbox.dart';
import 'package:air_vision/services/orientation_service.dart';
import 'package:air_vision/util/date_time.dart';
import 'package:air_vision/util/math/geodetic_position.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

class CameraScreen extends StatefulWidget {
  static const String id = 'camera_screen';
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final Location location = Location();
  GeodeticPosition _position = GeodeticPosition.zero();

  OrientationService _orientationService = OrientationService();
  List<dynamic> _recognitions;
  StreamSubscription<LocationData> _locationSubscription;

  Api _api = Api();
  List<CameraDescription> cameras;
  CameraController controller;
  double previewH = 0.0;
  double previewW = 0.0;
  double screenRatio = 0.0;
  double previewRatio = 0.0;
  int _imageHeight = 0;
  int _imageWidth = 0;
  Size screen;
  double screenH = 0.0;
  double screenW = 0.0;
  double scale = 1.0;
  bool isDetecting = false;
  bool modalIsOpen = false;
  bool detectedAircraft = false;
  String infoText = "Searching...";
  bool gotCameraPermission = false;

  List<AircraftState> scannedAircrafts = [];
  FlightInfo scannedFlightInfo;

  @override
  void initState() {
    super.initState();
    checkCameraPermission();
    _orientationService.start();
    loadModel();
    getCameras();
    _listenLocation();
  }

  @override
  void dispose() {
    _orientationService.stop();
    controller?.dispose();
    _locationSubscription.cancel();
    super.dispose();
  }

  _listenLocation() async {
    _locationSubscription = location.onLocationChanged().handleError((err) {
      setState(() {});
    }).listen((LocationData locationData) {
      setState(() {
        _position = GeodeticPosition(
            latitude: locationData.latitude,
            longitude: locationData.longitude,
            altitude: locationData.altitude);
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/yolov2_tiny.tflite",
        labels: "assets/yolov2_tiny.txt",
        numThreads: 2);
  }

  void getCameras() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.ultraHigh,
        enableAudio: false);

    controller.initialize().then((_) {
      if (!mounted && !gotCameraPermission) {
        return;
      }
      screen = MediaQuery.of(context).size;
      var tmp = MediaQuery.of(context).size;
      screenH = math.max(tmp.height, tmp.width);
      screenW = math.min(tmp.height, tmp.width);

      tmp = controller.value.previewSize;
      previewH = math.max(tmp.height, tmp.width);
      previewW = math.min(tmp.height, tmp.width);
      screenRatio = screenH / screenW;
      previewRatio = previewH / previewW;

      setState(() {});

      if (mounted) {
        controller.startImageStream((CameraImage img) async{
          if (!isDetecting) {
            isDetecting = true;
            Tflite.detectObjectOnFrame(
              bytesList: img.planes.map((plane) {
                return plane.bytes;
              }).toList(),
              model: 'Tiny YOLOv2',
              imageHeight: img.height,
              imageWidth: img.width,
              imageMean: 0,
              imageStd: 255.0,
              numResultsPerClass: 1,
              threshold: 0.2,
            ).then((recognitions) {
              updateRecognitions(recognitions, img.height, img.width);
              isDetecting = false;
            });
          }
        });
      }
    });
  }

  Future<void> getScannedAircrafts(
      time, _position, rotation, fov, aircraftPosition, aircraftSize) async {
    scannedAircrafts = await _api.getVisibleAircraft(
        time, _position, rotation, fov, aircraftPosition, aircraftSize);
  }

  Future<void> getFlightInformation() async {
    scannedFlightInfo =
        await _api.getSpecificFlightInfo(scannedAircrafts.first.icao24);
  }

  scanAirplane(previewH, previewW, screenH, screenW) async {
    if (!modalIsOpen) {
      var time = DateTime.now().secondsSinceEpoch;
      var fov = await cameras[0].getFov();
      var rotation = await _orientationService.getQuaternion();

      var _x = _recognitions[0]["rect"]["x"];
      var _w = _recognitions[0]["rect"]["w"];
      var _y = _recognitions[0]["rect"]["y"];
      var _h = _recognitions[0]["rect"]["h"];

      var aircraftPosition = [_x + (_w / 2), _y + (_h / 2)];
      var aircraftSize = [_w, _h];

      await getScannedAircrafts(
              time, _position, rotation, fov, aircraftPosition, aircraftSize)
          .catchError((e) {});

      if (scannedAircrafts.length > 0)
        await getFlightInformation().catchError((e) {});
      modalIsOpen = true;
      showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.0), topLeft: Radius.circular(20)),
          ),
          builder: (context) {
            return CustomBottomSheet(
                aircraft: scannedAircrafts.length > 0? scannedAircrafts.first : null , flightInfo: scannedFlightInfo);
          }).whenComplete(() {
        modalIsOpen = false;
      });
    }
  }

  updateRecognitions(List recognitions, h, w) {
    if (mounted) {
      setState(() {
        _recognitions = recognitions;
        _imageHeight = h;
        _imageWidth = w;
        if (recognitions.length > 0 &&
            recognitions[0]["detectedClass"] == "aircraft") {
          infoText = "Press To Scan";
          detectedAircraft = true;
        } else {
          infoText = "Searching...";
          detectedAircraft = false;
        }
      });
    }
  }

  Future<void> checkCameraPermission() async {
    var status = await Permission.camera.status;

    if (mounted) {
      if (status.isUndetermined || status.isDenied) {
        setState(() {
          gotCameraPermission = false;
        });
      }
      if (status.isGranted) {
        setState(() {
          gotCameraPermission = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    checkCameraPermission();

    if (controller != null) {}

    return controller != null && controller.value.isInitialized
        ? Scaffold(
            body: gotCameraPermission
                ? Stack(
                    children: [
                      CameraPreview(controller),
                      DrawBox(
                          _recognitions == null ? [] : _recognitions,
                          math.max(_imageHeight, _imageWidth),
                          math.min(_imageHeight, _imageWidth),
                          screen.height,
                          screen.width),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onTap: () {
                              if (detectedAircraft)
                                scanAirplane(
                                    math.max(_imageHeight, _imageWidth),
                                    math.min(_imageHeight, _imageWidth),
                                    screen.height,
                                    screen.width);
                            },
                            child: Container(
                              width: 160.0,
                              height: 50.0,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius:
                                          5.0, // has the effect of softening the shadow
                                      spreadRadius:
                                          0.0, // has the effect of extending the shadow
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.search,
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Text(
                                    infoText,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
          )
        : Container();
  }
}
