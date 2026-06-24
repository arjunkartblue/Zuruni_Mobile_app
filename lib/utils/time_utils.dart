class TimeUtils {
  /// Adds 30 minutes to the start time string (e.g. "10:00 AM" -> "10:30 AM")
  static String getEndTimeSlot(String start) {
    try {
      final parts = start.split(" ");
      final timeParts = parts[0].split(":");
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      
      minute += 30;
      if (minute >= 60) {
        minute -= 60;
        hour += 1;
      }
      
      String period = parts[1];
      if (hour >= 12) {
        if (hour > 12) {
          hour -= 12;
        }
        if (timeParts[0] != "12") {
          period = period == "AM" ? "PM" : "AM";
        }
      }
      
      final paddedHour = hour.toString();
      final paddedMinute = minute.toString().padLeft(2, '0');
      return "$paddedHour:$paddedMinute $period";
    } catch (_) {
      return "10:00 AM";
    }
  }
}
