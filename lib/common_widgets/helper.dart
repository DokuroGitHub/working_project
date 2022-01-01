class Helper {
  static String timeToString(DateTime dateTime) {
    String time = '';
    var millisecond = DateTime.now().millisecondsSinceEpoch -
        dateTime.millisecondsSinceEpoch;
    var second = millisecond / (1000);
    var minute = second / (60);
    var hour = minute / (60);
    var day = hour / (24);
    var week = day / (7);
    //TODO: wrong but meh
    var month = day / 30;
    var year = day / (365);
    if (year.toInt() > 0) {
      time = year.toInt().toString() + ' năm trc';
    } else {
      if (month.toInt() > 0) {
        time = month.toInt().toString() + ' tháng trc';
      } else {
        if (week.toInt() > 0) {
          time = week.toInt().toString() + '  tuần trc';
        } else {
          if (day.toInt() > 0) {
            time = day.toInt().toString() + ' ngày trc';
          } else {
            if (hour.toInt() > 0) {
              time = hour.toInt().toString() + ' giờ trc';
            } else {
              if (minute.toInt() > 0) {
                time = minute.toInt().toString() + ' phút trc';
              } else {
                time = second.toInt().toString() + ' giây trc';
              }
            }
          }
        }
      }
    }
    return time;
  }

}
