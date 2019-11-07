import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/models/models.dart';
import 'package:yodel/src/theme/themes.dart';

class ShiftDateWidget extends StatelessWidget {
  ShiftDateWidget({
    Key key,
    @required this.shift,
    @required this.color,
    this.child,
    this.hasBorder = false,
  }) : super(key: key);

  final Shift shift;
  final Color color;
  final DateFormat dayOfWeekFormat = DateFormat("E");
  final DateFormat dayFormat = DateFormat("d");
  final DateFormat monthFormat = DateFormat("MMMM yyyy");
  final DateFormat timeFormat = DateFormat("h:mm a");
  final double _kCalendarDayHeight = 68;
  final Widget child;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    final date = DateTimeHelper.toDateOnly(shift.startOn);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: YodelTheme.darkGreyBlue,
        border: hasBorder
            ? Border(
                bottom: BorderSide(
                  color: YodelTheme.lightPaleGrey,
                  width: 1,
                ),
              )
            : null,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: _kCalendarDayHeight,
            height: _kCalendarDayHeight,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: color,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(dayOfWeekFormat.format(date), style: YodelTheme.metaWhite),
                SizedBox(
                  height: 3,
                ),
                Text(dayFormat.format(date), style: YodelTheme.bodyWhite),
              ],
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      "Time:",
                      style: YodelTheme.metaRegularActiveWhite,
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      "${timeFormat.format(shift.startOn).toLowerCase()} - ${timeFormat.format(shift.finishOn).toLowerCase()}",
                      style: YodelTheme.metaRegularActiveWhite.copyWith(
                        color: color,
                      ),
                    )
                  ],
                ),
                if (child != null)
                  SizedBox(
                    height: 8,
                  ),
                if (child != null) child,
              ],
            ),
          )
        ],
      ),
    );
  }
}
