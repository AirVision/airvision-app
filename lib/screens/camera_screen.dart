import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameras;

class CameraScreen extends StatefulWidget {
  static const String id = 'camera_screen';

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController controller;
  double scale = 1.0;

  void getCameras() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.ultraHigh);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    getCameras();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
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
            body: Transform.scale(
              scale: controller.value.aspectRatio / deviceRatio,
              child: Center(
                child: GestureDetector(
                  onScaleUpdate: (one) {
                    setState(() {
                      if (one.scale > 1.0 && one.scale < 3.0) {
                        scale = one.scale;
                      }
                    });
                  },
                  child: Transform.scale(
                    scale: scale,
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: CameraPreview(controller),
                    ),
                  ),
                ),
              ),
            ),
          )
        : Container();
  }
}
