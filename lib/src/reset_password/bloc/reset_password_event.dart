import 'package:meta/meta.dart';
import 'package:yodel/src/authentication/index.dart';

@immutable
abstract class ResetPasswordEvent {}

class ResetPasswordButtonPressed extends ResetPasswordEvent {
  final String email;
  final String password;
  final String token;
  final String currentPassword;
  final AuthenticationAppLinkType type;

  ResetPasswordButtonPressed({
    @required this.email,
    @required this.password,
    @required this.token,
    this.currentPassword,
    this.type,
  });
}
