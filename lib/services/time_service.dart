class TimeService {
  String getCurrentTime() {
    var now = new DateTime.now();
    return "${now.hour}:${now.minute < 10? '0' + now.minute.toString() : now.minute}:${now.second < 10? '0' + now.second.toString() : now.second }";
  }
}
