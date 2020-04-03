class AircraftState {
  AircraftState(this.time, this.icao24, this.position, this.onGround,
      this.velocity, this.verticalRate, this.heading);

  int time;
  String icao24;
  List position;
  double velocity;
  bool onGround;
  double verticalRate;
  double heading;

  factory AircraftState.fromJson(dynamic json) {
    return AircraftState(
      json['time'] as int,
      json['icao24'] as String,
      json['position'] as List,
      json['on_ground'] as bool,
      json['velocity'] as double,
      json['vertical_rate'] as double,
      json['heading'] as double,
    );
  }
}
