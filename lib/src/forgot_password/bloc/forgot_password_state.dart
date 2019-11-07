import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ForgotPasswordState {}

class ForgotPasswordInitial extends ForgotPasswordState {
  toString() => "ForgotPasswordInitial";
}

class ForgotPasswordLoading extends ForgotPasswordState {
  toString() => "ForgotPassowordLoading";
}

class ForgotPasswordRequestSent extends ForgotPasswordState {
  toString() => "ForgotPasswordRequestSent";
}

class ForgotPasswordFailed extends ForgotPasswordState {
  final Exception exception;
  final String error;

  ForgotPasswordFailed({@required this.error, this.exception});

  toString() => "ForgotPasswordFailed";
}
