import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class MyShiftsEvent {}

class FetchMyShifts extends MyShiftsEvent {
  final bool autoScroll;

  FetchMyShifts({
    this.autoScroll = false,
  });

  @override
  String toString() => 'FetchMyShifts';
}

class RefreshMyShifts extends MyShiftsEvent {
  RefreshMyShifts();
  @override
  String toString() => 'RefreshMyShifts';
}

class StopAutoRefreshMyShifts extends MyShiftsEvent {
  @override
  String toString() => 'StopAutoRefreshMyShifts';
}

class StartAutoRefresMyShifts extends MyShiftsEvent {
  StartAutoRefresMyShifts();
  @override
  String toString() => 'StartAutoRefresMyShifts';
}

class MyShiftUpdated extends MyShiftsEvent {
  final MyShift shift;
  MyShiftUpdated(this.shift);

  @override
  String toString() => 'MyShiftUpdated';
}
