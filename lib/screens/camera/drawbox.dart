import 'package:flutter/material.dart';
import 'dart:math' as math;

//This service draws the rectangles around the detected aircrafts.

class DrawBox extends StatelessWidget {
  final List<dynamic> results;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;

  DrawBox(
      this.results, this.previewH, this.previewW, this.screenH, this.screenW);

  @override
  Widget build(BuildContext context) {
    List<Widget> _renderBoxes() {
      return results.map((re) {
        if ((re["confidenceInClass"] * 100) > 30 && re["detectedClass"] == "aircraft") {
          var _x = re["rect"]["x"];
          var _w = re["rect"]["w"];
          var _y = re["rect"]["y"];
          var _h = re["rect"]["h"];
          var scaleW, scaleH, x, y, w, h;

          if (screenH / screenW > previewH / previewW) {
            scaleW = screenH / previewH * previewW;
            scaleH = screenH;
            var difW = (scaleW - screenW) / scaleW;
            x = (_x - difW / 2) * scaleW;
            w = _w * scaleW;
            if (_x < difW / 2) w -= (difW / 2 - _x) * scaleW;
            y = _y * scaleH;
            h = _h * scaleH;
          } else {
            scaleH = screenW / previewW * previewH;
            scaleW = screenW;
            var difH = (scaleH - screenH) / scaleH;
            x = _x * scaleW;
            w = _w * scaleW;
            y = (_y - difH / 2) * scaleH;
            h = _h * scaleH;
            if (_y < difH / 2) h -= (difH / 2 - _y) * scaleH;
          }

          return Positioned(
            left: math.max(0, x),
            top: math.max(0, y),
            width: w,
            height: h,
            child: Container(
              padding: EdgeInsets.only(top: 5.0, left: 5.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xff5995EE),
                  width: 3.0,
                ),
              ),
              child: Text(
                "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  color: Color(0xff5995EE),
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      }).toList();
    }

    return Stack(
      children: _renderBoxes(),
    );
  }
}
