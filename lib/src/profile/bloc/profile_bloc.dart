import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/common/models/bloc_base.dart';
import 'package:yodel/src/services/services.dart';
import './bloc.dart';

const double kProfileImageWidth = 250;
const double kProfileImageHeight = 250;

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> implements BlocBase {
  final UserService userService;
  final SessionService sessionService;
  final SessionTracker sessionTracker;
  final BehaviorSubject<bool> _menuEnabled = BehaviorSubject.seeded(false);
  final AuthenticationBloc authBloc;

  ProfileBloc({
    @required this.authBloc,
    UserService userService,
    SessionService sessionService,
    SessionTracker sessionTracker,
  })  : this.userService = userService ?? sl<UserService>(),
        this.sessionService = sessionService ?? sl<SessionService>(),
        this.sessionTracker = sessionTracker ?? sl<SessionTracker>();

  @override
  void close() {
    _menuEnabled.close();
    super.close();
  }

  @override
  ProfileState get initialState =>
      ProfileInitialised(this.sessionTracker?.session?.value?.userData);

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
    if (event is EditProfileDetails) {
      yield ProfileEdited(state.profile.copyWith(
        dateOfBirth: event.profile.dateOfBirth,
        email: event.profile.email,
        firstName: event.profile.firstName,
        lastName: event.profile.lastName,
        phone: event.profile.phone,
      ));
    }

    if (event is ConfirmProfileDetails) {
      yield ProfileUpdating(event.profile);

      final user = sessionTracker.currentSession?.userData;

      var result = await userService.patchUserInfo(
        UserInfoUpdateRequest(
          dateOfBirth: event.profile.dateOfBirth,
          email: event.profile.email,
          emailSpecified: true,
          firstname: event.profile.firstName,
          lastname: event.profile.lastName,
          nameSpecified: true,
          passwordSpecified: false,
          phone: event.profile.phone,
          isProfileConfirmed: true,
        ),
      );
      if (!result.isSuccessful) {
        yield ProfileUpdateFailure(
            error: result.error,
            exception: result.getException(),
            profile: event.profile);
      } else {
        var userData = result.result.copyWith(
          userKey: sessionTracker.session.value.userKey,
          skills: user?.skills ?? [],
          sites: user?.sites ?? [],
        );
        var session = Session.fromUserData(userData);
        sessionService.saveSession(session);
        sessionTracker.sessionLoaded(session);
        yield ProfileConfirmed(userData);
      }
    }

    if (event is ProfileInitialise) {
      yield ProfileInitialised(state.profile);
    }

    if (event is UpdateProfile) {
      yield ProfileUpdating(state.profile);
      final user = state.profile;
      var result = await userService.updateUserInfo(
        UserInfoUpdateRequest(
          email: event.profile.email,
          emailSpecified: true,
          firstname: event.profile.firstName,
          lastname: event.profile.lastName,
          nameSpecified: true,
        ),
        profilePhotoPath: event.profileImagePath,
      );
      if (!result.isSuccessful) {
        yield ProfileUpdateFailure(
            error: result.error, exception: result.getException());
      } else {
        var userData = result.result.copyWith(
          userKey: sessionTracker.session.value.userKey,
          skills: user?.skills ?? [],
          sites: user?.sites ?? [],
        );

        var session = Session.fromUserData(userData);
        sessionService.saveSession(session);
        sessionTracker.sessionLoaded(session);
        yield ProfileUpdateCompleted(profile: userData);
      }
    }

    if (event is SyncProfile) {
      yield ProfileLoading(state.profile);
      final session = await authBloc.syncSession(sessionTracker.currentSession);
      yield ProfileInitialised(session.userData);
    }
  }

  Stream<bool> get menuEnabled => _menuEnabled.stream;
  void Function(bool) get enableMenu => _menuEnabled.add;
  bool get isMenuEnabled => _menuEnabled.value;

  @override
  void dispose() {
    this.close();
  }
}
