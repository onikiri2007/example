import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/authentication/index.dart';

@immutable
abstract class AuthenticationEvent extends Equatable {}

class AppStarted extends AuthenticationEvent {
  @override
  String toString() => "AppStarted";

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class AppLinkOpen extends AuthenticationEvent {
  final Map<String, dynamic> parameters;
  final AuthenticationAppLinkType linkType;

  AppLinkOpen({
    this.parameters,
    this.linkType,
  });

  @override
  String toString() => "AppLinkHandled -> $parameters $linkType";

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class LoggedIn extends AuthenticationEvent {
  final Session session;
  final AuthenticationAppLinkType type;

  LoggedIn({
    this.session,
    this.type = AuthenticationAppLinkType.None,
  });

  @override
  String toString() => "LoggedIn with session";

  @override
  List<Object> get props => [session];
}

class Loggedout extends AuthenticationEvent {
  @override
  String toString() => "LoggedOut";

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class Expired extends AuthenticationEvent {
  @override
  String toString() => "Expired";

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class WelcomeUser extends AuthenticationEvent {
  @override
  String toString() => 'WelcomeUser';

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class SyncSession extends AuthenticationEvent {
  @override
  String toString() => 'SyncSession';

  @override
  // TODO: implement props
  List<Object> get props => [];
}
