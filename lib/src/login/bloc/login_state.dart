import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class LoginState extends Equatable {}

class LoginInitial extends LoginState {
  toString() => "InitialLoginState";

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class LoginLoading extends LoginState {
  toString() => "LoginLoading";
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class LoginFailure extends LoginState {
  final Exception exception;
  final String error;

  LoginFailure({@required this.error, this.exception});

  toString() => "LoginFailed";
  @override
  // TODO: implement props
  List<Object> get props => [error];
}

class LoginCompleted extends LoginState {
  toString() => "LoginCompleted";
  @override
  // TODO: implement props
  List<Object> get props => [];
}
