import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/common/models/bloc_base.dart';
import 'package:yodel/src/reset_password/index.dart';
import 'package:yodel/src/services/services.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState>
    implements BlocBase {
  final SessionTracker sessionTracker;
  final UserService userService;
  final AuthenticationBloc authenticationBloc;
  final AppService appService;
  ResetPasswordRequestData _data;

  ResetPasswordBloc({
    @required this.authenticationBloc,
    UserService userService,
    SessionTracker sessionTracker,
    AppService appService,
  })  : this.userService = userService ?? sl<UserService>(),
        this.appService = appService ?? sl<AppService>(),
        this.sessionTracker = sessionTracker ?? sl<SessionTracker>(),
        assert(authenticationBloc != null) {
    _getData();
  }
  ResetPasswordRequestData get request => _data;

  void _getData() {
    if (authenticationBloc.state is AuthenticationAppLinkOpened) {
      AuthenticationAppLinkOpened current = authenticationBloc.state;
      _data = _getPasswordResetData(current.linkType, current.parameters);
    } else {
      _data = _getPasswordResetData(AuthenticationAppLinkType.None, {});
    }
  }

  @override
  ResetPasswordState get initialState => ResetPasswordInitial();

  @override
  Stream<ResetPasswordState> mapEventToState(
    ResetPasswordEvent event,
  ) async* {
    if (event is ResetPasswordButtonPressed) {
      yield ResetPasswordLoading();

      if (sessionTracker.isAuthenticated) {
        final result = await userService.patchUserInfo(UserInfoUpdateRequest(
          email: _data.email,
          password: event.password,
          passwordSpecified: true,
          currentPassword: event.currentPassword,
        ));

        if (result.isSuccessful) {
          yield ResetPasswordCompleted();
        } else {
          yield ResetPasswordFailure(
              error: result.error, exception: result.getException());
        }
      } else {
        final result = await userService.resetPassword(ResetPasswordRequest(
          email: _data.email,
          password: event.password,
          token: event.token,
        ));

        if (!result.isSuccessful) {
          yield ResetPasswordFailure(
              error: result.errorMessage, exception: result.getException());
        } else {
          var deviceId = await appService.getDeviceId();
          var r = await userService.login(LoginRequest(
            deviceId: deviceId,
            email: _data.email,
            password: event.password,
          ));

          if (r.isSuccessful) {
            authenticationBloc.add(LoggedIn(
              session: Session.fromUserData(r.result),
              type: event.type,
            ));
            yield ResetPasswordCompleted();
          } else {
            yield ResetPasswordFailure(
                error: result.error, exception: result.getException());
          }
        }
      }
    }
  }

  ResetPasswordRequestData _getPasswordResetData(
      AuthenticationAppLinkType linkType, Map<String, dynamic> parameters) {
    return ResetPasswordRequestData(
      token: parameters["Token"],
      email: parameters["Email"],
      type: linkType,
    );
  }

  @override
  void dispose() {
    this.close();
  }
}
