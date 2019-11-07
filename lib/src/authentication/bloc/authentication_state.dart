import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/authentication/index.dart';

enum PasswordActionType {
  None,
  ResetPassword,
  CreatePassoword,
}

@immutable
abstract class AuthenticationState extends Equatable {}

class AuthenticationUninitialized extends AuthenticationState {
  @override
  String toString() => "AuthenticationUnintialized";

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class AuthenticationAuthenticated extends AuthenticationState {
  @override
  String toString() => "AuthenticationAuthenticated";

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class AuthenticationAuthenticatedSynced extends AuthenticationState {
  @override
  String toString() => "AuthenticationAuthenticatedSynced";

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class AuthenticationUnauthenticated extends AuthenticationState {
  @override
  String toString() => "AuthenticationUnauthenticated";

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class AuthenticationLoading extends AuthenticationState {
  @override
  String toString() => "AuthenticationLoading";

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class AuthenticationAppLinkOpened extends AuthenticationState {
  final Map<String, dynamic> parameters;
  final AuthenticationAppLinkType linkType;

  AuthenticationAppLinkOpened({
    this.parameters,
    this.linkType,
  });

  @override
  String toString() => "AuthenticationAppLinkOpened -> $parameters $linkType";

  @override
  // TODO: implement props
  List<Object> get props => [linkType];
}

class AuthenticationAuthenticatedFromAppLink extends AuthenticationState {
  @override
  String toString() => "AuthenticationAuthenticatedFromAppLink";

  @override
  // TODO: implement props
  List<Object> get props => [];
}
