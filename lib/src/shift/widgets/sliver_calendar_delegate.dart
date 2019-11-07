import 'package:flutter/widgets.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/models/models.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

class SliverCalendarDelegate extends SliverPersistentHeaderDelegate {
  final CalendarWidget _calendar;
  SliverCalendarDelegate(
    this._calendar,
  );

  @override
  double get minExtent => _calendar.preferredSize.height;
  @override
  double get maxExtent => _calendar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: _calendar,
    );
  }

  @override
  bool shouldRebuild(SliverCalendarDelegate oldDelegate) {
    return oldDelegate._calendar.markers != _calendar.markers ||
        oldDelegate._calendar.calendarModel != _calendar.calendarModel;
  }
}

CalendarMarkers getMarkers(
    CalendarModel model, Map<DateTime, List<Shift>> shifts) {
  assert(model != null);
  assert(shifts != null);

  final markers = CalendarMarkers({});
  model.dates.forEach((date) {
    List<Shift> shiftsByDate = shifts.containsKey(date) ? shifts[date] : [];
    final shiftsCount = shiftsByDate.length;
    if (shiftsCount > 0) {
      if (DateTimeHelper.isBefore(date)) {
        markers.setMarker(date, YodelTheme.lightGreyBlue);
      } else {
        final filledShiftsCount = shiftsByDate.where((s) => s.isFilled).length;

        if (filledShiftsCount == shiftsCount) {
          markers.setMarker(date, YodelTheme.tealish);
        } else {
          markers.setMarker(date, YodelTheme.amber);
        }
      }
    }
  });

  return markers;
}
