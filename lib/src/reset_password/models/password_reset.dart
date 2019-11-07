import 'package:yodel/src/authentication/index.dart';

class ResetPasswordRequestData {
  final String email;
  final AuthenticationAppLinkType type;
  final String token;
  ResetPasswordRequestData({this.email, this.token, this.type});
}
