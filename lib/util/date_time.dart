extension DateTimeExtensions on DateTime {

  int get secondsSinceEpoch => (millisecondsSinceEpoch / 1000).floor();
}