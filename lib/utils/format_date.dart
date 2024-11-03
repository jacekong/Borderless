import 'package:intl/intl.dart';

class DateFormatted {
   String formatTimestamp(String timestampString) {
    try {
      DateTime timestamp = DateTime.parse(timestampString);

      DateTime now = DateTime.now();
      DateTime yesterday = DateTime(now.year, now.month, now.day - 1);

      if (isSameDay(timestamp, now)) {
        // If the timestamp is from today
        return DateFormat.Hm().format(timestamp.toLocal()); // Format "Today + time"
      } else if (isSameDay(timestamp, yesterday)) {
        // If the timestamp is from yesterday
        return '昨天 ${DateFormat.Hm().format(timestamp.toLocal())}'; // Format "Yesterday + time"
      } else {
        // For all other dates
        return DateFormat.MMMd().add_Hm().format(timestamp.toLocal()); // Format "date + time"
      }
    } catch (e) {
      return ''; // Return empty string if there's an error parsing the timestamp
    }
  }
  
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
