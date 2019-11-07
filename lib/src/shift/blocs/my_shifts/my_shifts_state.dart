import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class MyShiftsState {}

class InitialMyShiftsState extends MyShiftsState {}

class MyShiftsLoaded extends MyShiftsState {
  final List<MyShift> shifts;
  final bool autoScroll;

  MyShiftsLoaded({
    this.shifts = const [],
    this.autoScroll = false,
  });

  @override
  String toString() => 'MyShiftsLoaded';
}

class MyShiftsLoading extends MyShiftsState {
  @override
  String toString() => 'MyShiftsLoading';
}

class MyShiftsError extends MyShiftsState {
  final Exception exception;
  final String error;

  MyShiftsError(
    this.error, {
    this.exception,
  });

  @override
  String toString() =>
      'MyShiftsError => error: error, exception: ${exception.toString()}';
}
