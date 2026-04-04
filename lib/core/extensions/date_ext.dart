import 'package:intl/intl.dart';

extension DateFormatting on DateTime {
  String get dateKey => DateFormat('yyyy-MM-dd').format(this);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool isSameMonth(DateTime other) => year == other.year && month == other.month;

  bool isSameYear(DateTime other) => year == other.year;

  String get friendlyTime => DateFormat('h:mm a', 'en_IN').format(this);
}