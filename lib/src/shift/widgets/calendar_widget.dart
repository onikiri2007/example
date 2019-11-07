import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yodel/src/common/models/models.dart';
import 'package:yodel/src/theme/themes.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

const double kCalendarHeight = 140;
const double kCalendarDaySize = 76;

typedef DateSelectedCallback = void Function(DateTime date);

class CalendarDateController extends ValueNotifier<DateTime> {
  bool _disableAutoScroll = false;
  bool _isAutoScrolling = false;

  CalendarDateController({
    DateTime date,
  }) : super(date ?? DateTimeHelper.getToday());

  DateTime get date => value;
  set date(DateTime newDate) => value = newDate;

  // ignore: unnecessary_getters_setters
  bool get isAutoScrolling => _isAutoScrolling;
  // ignore: unnecessary_getters_setters
  set isAutoScrolling(bool autoscrolling) => _isAutoScrolling = autoscrolling;

  // ignore: unnecessary_getters_setters
  bool get disableAutoScrolling => _disableAutoScroll;
  // ignore: unnecessary_getters_setters
  set disableAutoScrolling(bool disable) => _disableAutoScroll = disable;
}

class CalendarWidget extends StatefulWidget implements PreferredSizeWidget {
  final Color selectedColor;
  final DateSelectedCallback onDateSelected;
  final CalendarDateController controller;
  final CalendarModel calendarModel;
  final EdgeInsets contentPadding;
  final Color backgroundColor;
  final CalendarMarkers markers;

  CalendarWidget({
    Key key,
    this.calendarModel,
    CalendarDateController controller,
    Color selectedColor,
    this.onDateSelected,
    EdgeInsets contentPadding,
    Color backgroundColor,
    CalendarMarkers markers,
  })  : this.controller = controller ?? CalendarDateController(),
        this.selectedColor = selectedColor ?? YodelTheme.amber,
        this.contentPadding = contentPadding ?? const EdgeInsets.all(16),
        this.backgroundColor = backgroundColor ?? YodelTheme.lightPaleGrey,
        this.markers = markers ?? CalendarMarkers({}),
        super(key: key);

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();

  @override
  Size get preferredSize => Size.fromHeight(kCalendarHeight);
}

class _CalendarWidgetState extends State<CalendarWidget> {
  AutoScrollController _controller;
  DateTime _selected;
  final DateFormat dayOfWeekFormat = DateFormat("E");
  final DateFormat dayFormat = DateFormat("d");
  final DateFormat monthFormat = DateFormat("MMMM yyyy");
  DateTime _currentMonth;

  CalendarDateController get _dateController => widget.controller;

  CalendarModel get _model => widget.calendarModel;

  @override
  void initState() {
    _selected = _dateController.date;
    _currentMonth = _dateController.date;
    final index = _model.dates.indexOf(_selected);
    _controller = AutoScrollController(
        initialScrollOffset: index * kCalendarDaySize,
        axis: Axis.horizontal,
        suggestedRowHeight: kCalendarDaySize,
        viewportBoundaryGetter: _getViewPortBoundary);

    _controller.addListener(_onDayScrolled);
    _dateController.addListener(_onDateChanged);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_onDayScrolled);
    _dateController.removeListener(
      _onDateChanged,
    );
    _controller.dispose();
    super.dispose();
  }

  bool _isSelected(DateTime date) => date == _selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kCalendarHeight,
      color: widget.backgroundColor,
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: () {
                final date = DateTimeHelper.getToday();
                _setDate(date);
                _scrollTo(date,
                    preferPosition: AutoScrollPosition.begin,
                    duration: Duration(milliseconds: 150));
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(monthFormat.format(_currentMonth),
                      style: YodelTheme.bodyStrong),
                  Container(
                    alignment: Alignment.center,
                    height: 25,
                    child: Text(
                      "Go to today",
                      style: YodelTheme.metaRegularActive.copyWith(
                        color: YodelTheme.iris,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          _buildCalendar(),
        ],
      ),
    );
  }

  Expanded _buildCalendar() {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        controller: _controller,
        itemExtent: kCalendarDaySize,
        scrollDirection: Axis.horizontal,
        itemCount: _model.dates.length,
        itemBuilder: (context, index) {
          final date = _model.dates[index];
          return AutoScrollTag(
            key: ValueKey(index),
            controller: _controller,
            index: index,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              margin: index == 0 ? EdgeInsets.zero : EdgeInsets.only(left: 8),
              decoration: _isSelected(date)
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: widget.selectedColor)
                  : BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: YodelTheme.lightIris,
                    ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    height: 8,
                    width: 8,
                    right: 4,
                    top: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.markers.findMarker(date),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  FlatButton(
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      _setDate(date);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            dayOfWeekFormat.format(date),
                            style: _isSelected(date)
                                ? YodelTheme.metaWhite
                                : DateTimeHelper.isBefore(date)
                                    ? YodelTheme.metaDefaultInactive
                                    : YodelTheme.metaDefault,
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Text(
                            dayFormat.format(date),
                            style: _isSelected(date)
                                ? YodelTheme.bodyWhite
                                : DateTimeHelper.isBefore(date)
                                    ? YodelTheme.bodyInactive
                                    : YodelTheme.bodyDefault,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _setDate(DateTime date) {
    _dateController.disableAutoScrolling = true;
    _dateController?.date = date;
    setState(() {
      _selected = date;
    });

    if (widget.onDateSelected != null) {
      widget.onDateSelected(date);
    }
  }

  Future<void> _scrollTo(DateTime date,
      {Duration duration, AutoScrollPosition preferPosition}) {
    final index = _model.indexOf(date);
    return _controller.scrollToIndex(index,
        duration: duration, preferPosition: preferPosition);
  }

  void _onDayScrolled() {
    final int currentIndex =
        (_controller.offset / kCalendarDaySize).abs().floor().toInt();
    if (currentIndex < _model.dates.length) {
      final date = _model.dates[currentIndex];
      final prev = DateTime(_currentMonth.year, _currentMonth.month, 1);
      final current = DateTime(date.year, date.month, 1);

      if (prev != current) {
        setState(() {
          _currentMonth = current;
        });
      }
    }
  }

  void _onDateChanged() {
    if (!_dateController.isAutoScrolling) {
      _scrollTo(_dateController.date, duration: Duration(microseconds: 1))
          .then((_) {
        if (mounted) {
          setState(() {
            _selected = _dateController.date;
          });
        }
      });
    }
  }

  Rect _getViewPortBoundary() {
    return Rect.fromLTWH(
        widget.contentPadding.left, widget.contentPadding.top, 0, 0);
  }
}

@immutable
class CalendarModel extends Equatable {
  final DateTime minTime;
  final DateTime maxTime;
  final DateTime currentTime;
  final List<DateTime> _dateList = [];

  CalendarModel({
    DateTime currentTime,
    DateTime minTime,
    DateTime maxTime,
    Map<DateTime, Color> markers,
  })  : this.currentTime = currentTime ?? DateTimeHelper.getToday(),
        this.minTime = minTime ?? DateTime(1900),
        this.maxTime = maxTime ?? DateTime(3000),
        super() {
    _generateCalendarDateList();
  }

  void _generateCalendarDateList() {
    DateTime startDate = DateTime(minTime.year, minTime.month, minTime.day);
    final endDate = DateTime(maxTime.year, maxTime.month, maxTime.day);
    _dateList.add(DateTimeHelper.toDateOnly(startDate));
    while (startDate.isBefore(endDate)) {
      startDate = startDate.add(Duration(days: 1));
      _dateList.add(DateTimeHelper.toDateOnly(startDate));
    }
  }

  List<DateTime> get dates => _dateList;

  int indexOf(DateTime date) => _dateList.indexOf(date);

  @override
  // TODO: implement props
  List<Object> get props => [
        currentTime,
        minTime,
        maxTime,
      ];
}

class CalendarMarkers extends Equatable {
  CalendarMarkers(this.markers) : assert(markers != null);

  final Map<DateTime, Color> markers;

  Color findMarker(DateTime date) =>
      markers.containsKey(date) ? markers[date] : Colors.transparent;

  void setMarker(
    DateTime date,
    Color color,
  ) =>
      markers.update(date, (c) => color, ifAbsent: () => color);

  @override
  // TODO: implement props
  List<Object> get props => [markers];
}
