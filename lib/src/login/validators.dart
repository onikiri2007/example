import 'dart:async';

import 'package:yodel/src/authentication/index.dart';

abstract class AuthValidator {
  StreamTransformer<String, String> get validateEmail;
  StreamTransformer<String, String> get validatePassword;
}

class AuthValidatorImpl implements AuthValidator {
  final _validateEmail =
      StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    if (email == null) {
      sink.addError("Email field is required.");
    } else if (!EmailValidator.validate(email)) {
      sink.addError("Please enter correct email address");
    } else {
      sink.add(email);
    }
  });

  final _validatePassword = StreamTransformer<String, String>.fromHandlers(
      handleData: (password, sink) {
    if (password == null || password.isEmpty || password.trim().isEmpty) {
      sink.addError("Password field is required.");
    } else {
      sink.add(password);
    }
  });

  @override
  StreamTransformer<String, String> get validatePassword => _validatePassword;

  @override
  StreamTransformer<String, String> get validateEmail => _validateEmail;
}

mixin EmailValidatorMixin {
  final _validateEmail =
      StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    if (email == null) {
      sink.addError("Email field is required.");
    } else if (!hasValidEmail(email)) {
      sink.addError("Please enter correct email address");
    } else {
      sink.add(email);
    }
  });

  StreamTransformer<String, String> get validateEmail => _validateEmail;

  static bool hasValidEmail(String email) =>
      email != null && EmailValidator.validate(email);
}

mixin PasswordValidatorMixin {
  final _validatePassword = StreamTransformer<String, String>.fromHandlers(
      handleData: (password, sink) {
    if (!hasPasswordValid(password)) {
      sink.addError("Password field is required.");
    } else {
      sink.add(password);
    }
  });

  StreamTransformer<String, String> get validatePassword => _validatePassword;

  static bool hasPasswordValid(String password) =>
      password != null && password.trim().isNotEmpty;
}
