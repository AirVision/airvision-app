import 'package:air_vision/services/bndbox.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import '../util/models.dart';

// typedef void Callback(List<dynamic> list, int h, int w);

class CameraScreen extends StatefulWidget {
  static const String id = 'camera_screen';
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription> cameras;
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = yolo;

  CameraController controller;
  double scale = 1.0;
  bool isDetecting = false;
  bool modalIsOpen = false;
  bool detectedAirplane = false;
  String text = "";

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

  scanAirplane(h, w, sh, sw) {
    if (!modalIsOpen) {
      modalIsOpen = true;
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.airplanemode_active),
                  title: Text("Airbus A220"),
                ),
                ListTile(
                  leading: Icon(Icons.airplanemode_active),
                  title: Text("Airbus A220"),
                ),
                ListTile(
                  leading: Icon(Icons.airplanemode_active),
                  title: Text("Airbus A220"),
                ),
                ListTile(
                  leading: Icon(Icons.airplanemode_active),
                  title: Text("Airbus A220"),
                ),
                ListTile(
                  leading: Icon(Icons.airplanemode_active),
                  title: Text("Airbus A220"),
                ),
              ],
            );
          }).whenComplete(() {
        modalIsOpen = false;
      });
    }
  }

  updateRecognitions(List recognitions, h, w) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = h;
      _imageWidth = w;
      if (recognitions != null && recognitions.length > 0)
        text = recognitions[0]["detectedClass"];
      else {
        text = "Find Aircraft";
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadModel();
    getCameras();
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
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
                      opacity: text == "aircraft" ? 1.0 : 0.8,
                      child: GestureDetector(
                        onTap: () {
                          if(text == "aircraft")
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
                                text,
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        : Container();
  }
}
