import 'package:flutter/material.dart';

class TimeService {
  String getCurrentTime() {
    var now = new DateTime.now();
    var berlinWallFell = new DateTime.utc(1989, 11, 9);
    var moonLanding = DateTime.parse("1969-07-20 20:18:04Z");
    return "${now.hour}:${now.minute < 10? '0' + now.minute.toString() : now.minute}:${now.second < 10? '0' + now.second.toString() : now.second }";
  }
}
