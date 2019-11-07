import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/common/models/bloc_base.dart';
import 'package:yodel/src/login/index.dart';
import 'package:yodel/src/services/services.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> implements BlocBase {
  final AuthenticationBloc authenticationBloc;
  final UserService userService;
  final AppService appService;

  LoginBloc({
    @required this.authenticationBloc,
    UserService userService,
    AppService appService,
  })  : this.userService = userService ?? sl<UserService>(),
        this.appService = appService ?? sl<AppService>(),
        assert(authenticationBloc != null);

  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is LoginButtonPressed) {
      yield LoginLoading();
      await Future.delayed(Duration(seconds: 4));
      final deviceId = await appService.getDeviceId();
      final result = await userService.login(LoginRequest(
          deviceId: deviceId, email: event.username, password: event.password));
      if (result.isSuccessful) {
        authenticationBloc
            .add(LoggedIn(session: Session.fromUserData(result.result)));
        yield LoginCompleted();
      } else {
        yield LoginFailure(
            error: result.error, exception: result.getException());
      }
    }
  }

  @override
  void dispose() {}
}
