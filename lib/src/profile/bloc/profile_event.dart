import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class ProfileEvent {}

class ProfileInitialise extends ProfileEvent {
  final UserData profile;
  ProfileInitialise({this.profile});

  @override
  String toString() => "ProfileInitialized - $profile";
}

class ConfirmProfileDetails extends ProfileEvent {
  final UserData profile;
  ConfirmProfileDetails({this.profile});

  @override
  String toString() => "ConfirmProfile - $profile";
}

class EditProfileDetails extends ProfileEvent {
  final UserData profile;
  EditProfileDetails({this.profile});

  @override
  String toString() => "ConfirmProfile - $profile";
}

class UpdateProfile extends ProfileEvent {
  final UserData profile;
  final String profileImagePath;
  UpdateProfile({
    this.profile,
    this.profileImagePath,
  });

  @override
  String toString() => "CompleteProfile - $profile";
}

class SyncProfile extends ProfileEvent {
  @override
  String toString() => 'SyncProfile';
}
