import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ForgotPasswordEvent extends Equatable {}

class RequestForgotPassword extends ForgotPasswordEvent {
  final String email;

  RequestForgotPassword({
    @required this.email,
  });

  @override
  String toString() => 'RequestForgotPassword { email;: $email, }';

  @override
  // TODO: implement props
  List<Object> get props => [email];
}
