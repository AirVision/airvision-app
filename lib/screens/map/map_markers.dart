import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
      .buffer
      .asUint8List();
}

Future<Uint8List> getAirportIcon() async {
  return await getBytesFromAsset('assets/airport.png', 100);
}

Future<List<List<Uint8List>>> getNormalMarkerIcon(
    int normalsize, int selectedSize) async {
  //UltraLight
  var ultraLightIcon =
      await getBytesFromAsset('assets/ultraLight.png', normalsize - 15);
  var ultraLightSelected =
      await getBytesFromAsset('assets/ultraLightSelected.png', selectedSize);

  //Light
  var lightIcon = await getBytesFromAsset('assets/light.png', normalsize - 15);
  var lightSelected =
      await getBytesFromAsset('assets/lightSelected.png', selectedSize);

  //Normal
  var normalIcon =
      await getBytesFromAsset('assets/normal.png', normalsize - 10);
  var normalSelected =
      await getBytesFromAsset('assets/normalSelected.png', selectedSize);

  //Heavy
  var heavyIcon = await getBytesFromAsset('assets/heavy.png', normalsize);
  var heavySelected =
      await getBytesFromAsset('assets/heavySelected.png', selectedSize);

  //VeryHeavy
  var veryHeavyIcon =
      await getBytesFromAsset('assets/veryHeavy.png', normalsize);
  var veryHeavySelected =
      await getBytesFromAsset('assets/veryHeavySelected.png', selectedSize);

  //Final list
  List<List<Uint8List>> list = [
    [ultraLightIcon, ultraLightSelected],
    [lightIcon, lightSelected],
    [normalIcon, normalSelected],
    [heavyIcon, heavySelected],
    [veryHeavyIcon, veryHeavySelected],
  ];
  return list;
}
