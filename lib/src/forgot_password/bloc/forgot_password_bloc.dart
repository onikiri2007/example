import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/common/models/bloc_base.dart';
import 'package:yodel/src/forgot_password/index.dart';
import 'package:yodel/src/services/services.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState>
    implements BlocBase {
  final UserService userService;

  ForgotPasswordBloc({
    UserService userService,
  }) : this.userService = userService ?? sl<UserService>();

  @override
  ForgotPasswordState get initialState => ForgotPasswordInitial();

  @override
  Stream<ForgotPasswordState> mapEventToState(
    ForgotPasswordEvent event,
  ) async* {
    if (event is RequestForgotPassword) {
      yield ForgotPasswordLoading();

      final result = await userService.requestResetPasswordToken(
          ResetPasswordTokenRequest(email: event.email));

      if (result.isSuccessful) {
        yield ForgotPasswordRequestSent();
      } else {
        yield ForgotPasswordFailed(
            error: result.error, exception: result.getException());
      }
    }
  }

  @override
  void dispose() {}
}
