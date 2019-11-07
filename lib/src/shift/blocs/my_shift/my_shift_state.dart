import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class MyShiftState {}

class InitialMyShiftState extends MyShiftState {}

class MyShiftError extends MyShiftState {
  final Exception exception;
  final String error;

  MyShiftError(
    this.error, {
    this.exception,
  });

  @override
  String toString() =>
      'MyShiftError => error: error, exception: ${exception.toString()}';
}

class MyShiftLoading extends MyShiftState {
  @override
  String toString() => 'MyShiftLoading';
}

class MyShiftActionLoading extends MyShiftState {
  @override
  String toString() => 'MyShiftActionLoading';
}

class MyShiftLoaded extends MyShiftState {
  final MyShift shift;

  MyShiftLoaded({
    this.shift,
  });

  @override
  String toString() => 'MyShiftLoaded';
}
