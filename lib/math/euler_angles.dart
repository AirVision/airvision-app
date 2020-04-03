class EulerAngles {

  final double pitch;
  final double yaw;
  final double roll;

  EulerAngles(this.pitch, this.roll, this.yaw);

  factory EulerAngles.zero() => new EulerAngles(0, 0, 0);
}