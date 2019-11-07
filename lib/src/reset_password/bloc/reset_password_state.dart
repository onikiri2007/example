import 'package:meta/meta.dart';

@immutable
abstract class ResetPasswordState {}

class ResetPasswordInitial extends ResetPasswordState {
  toString() => "ResetPasswordInitial";
}

class ResetPasswordLoading extends ResetPasswordState {
  toString() => "ResetPasswordLoading";
}

class ResetPasswordCompleted extends ResetPasswordState {
  toString() => "ResetPasswordCompleted";
}

class ResetPasswordFailure extends ResetPasswordState {
  final Exception exception;
  final String error;

  ResetPasswordFailure({
    @required this.error,
    this.exception,
  });

  toString() => "ResetPasswordState";
}
