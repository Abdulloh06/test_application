import 'package:intl/intl.dart';

class DateFormatUtils {

  static String weekDay(DateTime date) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];

    return weekdays[date.weekday - 1];
  }

  static String formatDate() {
    final DateFormat formatter = DateFormat('d MMMM yyyy');
    return formatter.format(DateTime.now());
  }

  static String monthFormat(DateTime date) {
    final DateFormat formatter = DateFormat('MMMM');
    return formatter.format(date);
  }

  static DateTime parseString(String date) {
    return DateFormat('dd.MM.yyyy').parse(date);
  }

  static String formatDefault(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

}