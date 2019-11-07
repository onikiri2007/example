import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class LoginEvent extends Equatable {}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;

  LoginButtonPressed({
    @required this.username,
    @required this.password,
  });

  @override
  String toString() =>
      'LoginButtonPressed { username: $username, password: ....... }';

  @override
  // TODO: implement props
  List<Object> get props => [username, password];
}
