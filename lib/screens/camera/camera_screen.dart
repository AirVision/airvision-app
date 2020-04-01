import 'dart:async';

import 'package:air_vision/services/api.dart';
import 'package:air_vision/screens/Camera/bndbox.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import '../../util/models.dart';

class CameraScreen extends StatefulWidget {
  static const String id = 'camera_screen';
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  static const platform = const MethodChannel('airvision/orientation');

  List<CameraDescription> cameras;
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = yolo;

  StreamSubscription<LocationData> _locationSubscription;
  LocationData _location;
  final Location location = Location();
  double lat = -0;
  double lon = -0;

  Api _api = Api();

  CameraController controller;
  double scale = 1.0;
  bool isDetecting = false;
  bool modalIsOpen = false;
  bool detectedAircraft = false;
  String infoText = "Find Aircraft";

  _listenLocation() async {
    _locationSubscription = location.onLocationChanged().handleError((err) {
      setState(() {});
      _locationSubscription.cancel();
    }).listen((LocationData currentLocation) {
      setState(() {
        _location = currentLocation;
        lat = _location.latitude;
        lon = _location.longitude;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/yolov2_tiny.tflite",
        labels: "assets/yolov2_tiny.txt",
        numThreads: 1);
  }

  void getCameras() async {
    print('Start');
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.ultraHigh);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      controller.startImageStream((CameraImage img) {
        if (!isDetecting) {
          isDetecting = true;
          Tflite.detectObjectOnFrame(
            bytesList: img.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            model: _model,
            imageHeight: img.height,
            imageWidth: img.width,
            imageMean: _model == yolo ? 0 : 127.5,
            imageStd: _model == yolo ? 255.0 : 127.5,
            numResultsPerClass: 1,
            threshold: _model == yolo ? 0.2 : 0.4,
          ).then((recognitions) {
            // int endTime = new DateTime.now().millisecondsSinceEpoch;
            // print("Detection took ${endTime - startTime}");
            updateRecognitions(recognitions, img.height, img.width);
            isDetecting = false;
          });
        }
      });
    });
  }

  scanAirplane(previewH, previewW, screenH, screenW) async {
    if (!modalIsOpen) {
      var aircrafts = [];
      var time = DateTime.now().millisecondsSinceEpoch;
      var position = [lat, lon];
      var fov = [80, 80];
      final List<double> rotation =
          await platform.invokeMethod('getDeviceOrientation');

      _recognitions.map((re) {
        var _x = re["rect"]["x"];
        var _w = re["rect"]["w"];
        var _y = re["rect"]["y"];
        var _h = re["rect"]["h"];
        var aircraft = [
          [_x + (_w / 2), _y + (_h / 2)],
          [_w, _h]
        ];
        aircrafts.add(aircraft);
      });

      _api
          .getVisibleAircraft(time, position, rotation, fov, aircrafts)
          .then((res) {
        modalIsOpen = true;

        showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20.0),
                      topLeft: Radius.circular(20)),
                ),
                builder: (context) {
                  // return CustomBottomSheet();
                })
            .whenComplete(() {});
      });
    }
  }

  updateRecognitions(List recognitions, h, w) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = h;
      _imageWidth = w;
      if (recognitions.length > 0 &&
          recognitions[0]["detectedClass"] == "aircraft") {
        infoText = "Scan aircraft";
        detectedAircraft = true;
      } else {
        infoText = "Find Aircraft";
        detectedAircraft = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    platform.invokeMethod('startListeningDeviceOrientation');
    loadModel();
    getCameras();
    _listenLocation();
  }

  @override
  void dispose() {
    super.dispose();
    platform.invokeMethod('stopListeningDeviceOrientation');
    controller?.dispose();
    _locationSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    if (controller != null) {
      tmp = controller.value.previewSize;
    }
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;
    return controller != null
        ? Scaffold(
            appBar: AppBar(
              title: Text(
                'Find aircraft',
                style: TextStyle(color: Colors.black),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(15),
                ),
              ),
              iconTheme: IconThemeData(color: Colors.black),
            ),
            body: Stack(
              children: [
                OverflowBox(
                  maxHeight: screenRatio > previewRatio
                      ? screenH
                      : screenW / previewW * previewH,
                  maxWidth: screenRatio > previewRatio
                      ? screenH / previewH * previewW
                      : screenW,
                  child: CameraPreview(controller),
                ),
                BndBox(
                    _recognitions == null ? [] : _recognitions,
                    math.max(_imageHeight, _imageWidth),
                    math.min(_imageHeight, _imageWidth),
                    screen.height,
                    screen.width),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Opacity(
                      opacity: detectedAircraft ? 1.0 : 0.8,
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
                          width: 180.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                              color: Color(0xff3496F7),
                              borderRadius: BorderRadius.circular(20.0)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.info_outline,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text(
                                infoText,
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }
}
