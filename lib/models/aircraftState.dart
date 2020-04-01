class AircraftState {
  AircraftState(
      {this.time, this.icao24, this.position, this.onGround, this.velocity});

  int time;
  String icao24;
  List position;
  double velocity;
  bool onGround;
}
