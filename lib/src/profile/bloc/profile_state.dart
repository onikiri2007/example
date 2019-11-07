import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class ProfileState {
  final UserData profile;
  ProfileState(this.profile);
}

class ProfileInitialised extends ProfileState {
  ProfileInitialised(UserData profile) : super(profile);
  toString() => "ProfileInitialise";
}

class ProfileUpdating extends ProfileState {
  ProfileUpdating(UserData profile) : super(profile);
  toString() => "ProfileUpdating";
}

class ProfileConfirmed extends ProfileState {
  ProfileConfirmed(UserData profile) : super(profile);
  toString() => "ProfileConfirmed";
}

class ProfileEdited extends ProfileState {
  ProfileEdited(UserData profile) : super(profile);
  toString() => "ProfileEdited";
}

class ProfileUpdateCompleted extends ProfileState {
  ProfileUpdateCompleted({UserData profile}) : super(profile);
  toString() => "ProfileUpdateCompleted";
}

class ProfileUpdateFailure extends ProfileState {
  final Exception exception;
  final String error;

  ProfileUpdateFailure({
    UserData profile,
    @required this.error,
    this.exception,
  }) : super(profile);

  toString() => "ProfileUpdateFailure";
}

class ProfileLoading extends ProfileState {
  ProfileLoading(UserData profile) : super(profile);
  @override
  String toString() => 'ProfileLoading';
}
