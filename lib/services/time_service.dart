class TimeService{
  String getCurrentTime(){
    return "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";
  }
}