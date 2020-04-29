class Waypoint {
  int time;
  List pos;

  Waypoint(this.time, this.pos);

  factory Waypoint.fromJson(dynamic json) {
    return Waypoint(json['time'] as int, json['pos'] as List);
  }
}
