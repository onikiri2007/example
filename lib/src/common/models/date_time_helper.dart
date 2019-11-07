import 'package:flutter/material.dart';

class DateTimeHelper {
  static DateTime getToday() =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  static bool isYesterday(DateTime date) =>
      (getToday().add(Duration(days: -1))) == date;
  static bool isToday(DateTime date) => getToday() == date;
  static bool isTomorrow(DateTime date) =>
      (getToday().add(Duration(days: 1))) == date;

  static DateTime toDateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day, 0, 0, 0, 0, 0);

  static TimeOfDay toTimeOfDay(DateTime date) =>
      TimeOfDay(hour: date.hour, minute: date.minute);

  static DateTime toDate(DateTime date, TimeOfDay timeOfDay) => DateTime(
      date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);

  static bool isBefore(DateTime date) => date.isBefore(getToday());

  static List<int> splitTimeToInterval({int interval = 1}) {
    final intervalSplit = 60 ~/ interval;
    return List.generate(intervalSplit, (index) => interval * index);
  }

  static int getTimeToIntervalLength({int interval = 1}) {
    return 60 ~/ interval;
  }

  static int getNearestIntervalTime(int time, int interval) {
    final intervalSplit = (time / interval).ceil().toInt();
    return intervalSplit > 3 ? 0 : intervalSplit;
  }

  static DateTime convertToIntervalMinutesDateTime(
      DateTime source, int interval) {
    final intervalSplit = (source.minute / interval).ceil().toInt();
    if (intervalSplit > 3) {
      DateTime target;
      final time = TimeOfDay.fromDateTime(source);
      if (time.hourOfPeriod == 11 && time.period == DayPeriod.pm) {
        target = source.add(Duration(days: 1));
        return DateTime(target.year, target.month, target.day, 0, 0);
      }

      target = source.add(Duration(hours: 1));
      return DateTime(target.year, target.month, target.day, target.hour, 0);
    } else {
      final length = getNearestIntervalTime(source.minute, interval);
      return DateTime(
        source.year,
        source.month,
        source.day,
        source.hour,
        length * interval,
      );
    }
  }
}
