import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class ManageShiftsEvent {}

class FetchManageShifts extends ManageShiftsEvent {
  final bool autoScroll;

  FetchManageShifts({
    this.autoScroll = false,
  });

  @override
  String toString() => 'FetchManageShifts';
}

class RefreshManageShifts extends ManageShiftsEvent {
  RefreshManageShifts();
  @override
  String toString() => 'RefreshManageShifts';
}

class StopAutoRefreshManageShifts extends ManageShiftsEvent {
  @override
  String toString() => 'StopAutoRefreshManageShifts';
}

class StartAutoRefreshManageShifts extends ManageShiftsEvent {
  StartAutoRefreshManageShifts();
  @override
  String toString() => 'StartAutoRefreshManageShifts';
}

class ManageShiftUpdated extends ManageShiftsEvent {
  final ManageShift shift;
  ManageShiftUpdated(this.shift);

  @override
  String toString() => 'ManageShiftUpdated';
}
