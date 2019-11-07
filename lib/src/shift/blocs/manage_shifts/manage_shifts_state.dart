import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class ManageShiftsState {}

class InitialManageShiftsState extends ManageShiftsState {}

class ManageShiftsLoaded extends ManageShiftsState {
  final List<ManageShift> shifts;
  final bool autoScroll;

  ManageShiftsLoaded({
    this.shifts = const [],
    this.autoScroll = false,
  });

  @override
  String toString() => 'ManageShiftsLoaded';
}

class ManageShiftsLoading extends ManageShiftsState {
  @override
  String toString() => 'ManageShiftsLoading';
}

class ManageShiftsError extends ManageShiftsState {
  final Exception exception;
  final String error;

  ManageShiftsError(
    this.error, {
    this.exception,
  });

  @override
  String toString() =>
      'ManageShiftsError => error: error, exception: ${exception.toString()}';
}
