import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yodel/src/api/index.dart';

part 'authentication.g.dart';

@JsonSerializable()
class LoginRequest {
  LoginRequest({
    this.email,
    this.password,
    this.deviceId,
  });

  final String email;
  final String password;
  final String deviceId;

  static const fromJson = _$LoginRequestFromJson;

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegistrationInfo {
  RegistrationInfo({
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.deviceId,
    this.acceptTermsConditions = true,
    this.isAnonymous = true,
    this.anonymousUserId,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String deviceId;
  final bool acceptTermsConditions;
  final bool isAnonymous;
  final String anonymousUserId;

  static const fromJson = _$RegistrationInfoFromJson;

  Map<String, dynamic> toJson() => _$RegistrationInfoToJson(this);
}

enum UserStatus { Registered, Activated, Deleted, Invited, Anonymous }

@JsonSerializable()
class UserData {
  UserData(
      {this.userId,
      this.userKey,
      this.firstName,
      this.lastName,
      this.fullName,
      this.email,
      this.statusRaw,
      this.roles = const [],
      this.profilePhoto,
      this.anonymous = false,
      this.phone,
      this.dateOfBirth,
      this.skillIds = const [],
      this.siteIds = const [],
      this.isProfileConfirmed = false,
      this.rate,
      this.sites = const [],
      this.skills = const [],
      this.hasPushToken = false});

  final int userId;
  final String userKey;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  @JsonKey(name: "status")
  final String statusRaw;
  final List<String> roles;
  @JsonKey(name: 'profilePhotoPath')
  final String profilePhoto;
  final bool anonymous;
  final String phone;
  final String dateOfBirth;
  final List<int> skillIds;
  final List<int> siteIds;
  final bool isProfileConfirmed;
  final double rate;
  final List<Site> sites;
  final List<Skill> skills;
  final bool hasPushToken;

  static const fromJson = _$UserDataFromJson;

  UserData copyWith({
    int userId,
    String userKey,
    String firstName,
    String lastName,
    String fullName,
    String email,
    String statusRaw,
    List<String> roles,
    String profilePhoto,
    bool anonymous,
    String phone,
    String dateOfBirth,
    List<int> skillIds,
    List<int> siteIds,
    bool isProfileConfirmed,
    double rate,
    List<Site> sites,
    List<Skill> skills,
    bool hasPushToken,
  }) {
    return UserData(
      userId: userId ?? this.userId,
      userKey: userKey ?? this.userKey,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      statusRaw: statusRaw ?? this.statusRaw,
      roles: roles ?? this.roles,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      anonymous: anonymous ?? this.anonymous,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phone: phone ?? this.phone,
      skillIds: skillIds ?? this.skillIds,
      siteIds: siteIds ?? this.siteIds,
      isProfileConfirmed: isProfileConfirmed ?? this.isProfileConfirmed,
      rate: rate ?? this.rate,
      skills: skills ?? this.skills,
      sites: sites ?? this.sites,
      hasPushToken: hasPushToken ?? this.hasPushToken,
    );
  }

  factory UserData.copyWithoutSensitveData({
    @required UserData userData,
  }) {
    return UserData(
      firstName: userData.firstName,
      lastName: userData.lastName,
      fullName: userData.fullName,
      statusRaw: userData.statusRaw,
      roles: userData.roles,
      profilePhoto: userData.profilePhoto,
      skillIds: userData.skillIds,
      siteIds: userData.siteIds,
      anonymous: userData.anonymous,
      isProfileConfirmed: userData.isProfileConfirmed ?? false,
      rate: userData.rate,
      hasPushToken: userData.hasPushToken,
    );
  }

  factory UserData.copyWithSensitiveData({
    String email,
    int userId,
    String userKey,
    String dateOfBirth,
    String phone,
    UserData userData,
  }) {
    return UserData(
      userId: userId,
      userKey: userKey,
      email: email,
      firstName: userData.firstName,
      lastName: userData.lastName,
      fullName: userData.fullName,
      statusRaw: userData.statusRaw,
      roles: userData.roles,
      profilePhoto: userData.profilePhoto,
      anonymous: userData.anonymous,
      dateOfBirth: dateOfBirth,
      phone: phone,
      skillIds: userData.skillIds,
      siteIds: userData.siteIds,
      isProfileConfirmed: userData.isProfileConfirmed ?? false,
      rate: userData.rate,
      skills: userData.skills,
      sites: userData.sites,
      hasPushToken: userData.hasPushToken,
    );
  }

  Map<String, dynamic> toJson() => _$UserDataToJson(this);

  UserStatus get status {
    return statusRaw != null
        ? UserStatus.values.firstWhere(
            (d) => describeEnum(d).toLowerCase() == statusRaw.toLowerCase(),
            orElse: () => UserStatus.Invited)
        : UserStatus.Invited;
  }

  bool isAnonymous() => status == UserStatus.Anonymous;

  bool get hasProfile =>
      status == UserStatus.Registered || status == UserStatus.Activated;

  bool get isManager => roles?.contains("CompanyManager") ?? false;
  bool get isWorker => roles?.contains("CompanyUser") ?? false;
  bool get isAdmin => roles?.contains("Administrator") ?? false;
  bool get isCompanyAdmin => roles?.contains("CompanyAdmin") ?? false;
  bool get isSiteManager => roles?.contains("CompanySiteManager") ?? false;
  bool get isManagementRole => isManager || isSiteManager;

  String get role {
    if (isManager) return "Manager";
    if (isWorker) return "Employee";
    if (isSiteManager) return "Site manager";
    return "Uknown";
  }

  String get hourlyRate => rate != null ? rate.toStringAsFixed(2) : "";
}

@JsonSerializable()
class UserInfoUpdateRequest {
  UserInfoUpdateRequest({
    this.currentPassword,
    this.email,
    this.emailSpecified = false,
    this.password,
    this.passwordSpecified = false,
    this.firstname,
    this.lastname,
    this.status,
    this.nameSpecified = false,
    this.dateOfBirth,
    this.phone,
    this.isProfileConfirmed = false,
  });

  final String currentPassword;
  final String email;
  final bool emailSpecified;
  final String password;
  final bool passwordSpecified;
  final String status;
  final String firstname;
  final String lastname;
  final bool nameSpecified;
  final String dateOfBirth;
  final String phone;
  final bool isProfileConfirmed;

  static const fromJson = _$UserInfoUpdateRequestFromJson;

  Map<String, dynamic> toJson() => _$UserInfoUpdateRequestToJson(this);
}

enum PushTokenProvider { Apple, Google }

@JsonSerializable()
class PushTokenInfo {
  PushTokenInfo({
    this.deviceId,
    this.token,
    this.provider = PushTokenProvider.Apple,
  });

  final String deviceId;
  final String token;
  final PushTokenProvider provider;

  static const fromJson = _$PushTokenInfoFromJson;

  Map<String, dynamic> toJson() => _$PushTokenInfoToJson(this);
}

@JsonSerializable()
class ResetPasswordTokenRequest {
  ResetPasswordTokenRequest({
    this.email,
    this.type = "Password",
  });

  final String email;
  final String type;

  static const fromJson = _$ResetPasswordTokenRequestFromJson;

  Map<String, dynamic> toJson() => _$ResetPasswordTokenRequestToJson(this);
}

@JsonSerializable()
class ResetPasswordRequest {
  ResetPasswordRequest({
    this.email,
    this.firstname,
    this.lastname,
    this.password,
    this.token,
  });

  final String firstname;
  final String lastname;
  final String password;
  final String email;
  final String token;

  static const fromJson = _$ResetPasswordRequestFromJson;

  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}

@JsonSerializable()
class Contact {
  Contact({
    this.id,
    this.fullName,
    this.phone,
    this.profilePhoto,
    this.skillIds = const [],
    this.siteIds = const [],
    this.sites = const [],
    this.skills = const [],
    this.isManager = false,
  });

  final int id;
  final String fullName;
  @JsonKey(name: 'profilePhotoPath')
  final String profilePhoto;
  final String phone;
  final List<int> skillIds;
  final List<int> siteIds;
  final List<Site> sites;
  final List<Skill> skills;
  final bool isManager;

  Contact copyWith({
    int id,
    String fullName,
    String profilePhoto,
    String phone,
    List<int> skillIds,
    List<int> siteIds,
    List<Site> sites,
    List<Skill> skills,
    bool isManager,
  }) {
    return Contact(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      phone: phone ?? this.phone,
      skillIds: skillIds ?? this.skillIds,
      siteIds: siteIds ?? this.siteIds,
      skills: skills ?? this.skills,
      sites: sites ?? this.sites,
      isManager: isManager ?? this.isManager,
    );
  }

  Map<String, dynamic> toJson() => _$ContactToJson(this);
  static const fromJson = _$ContactFromJson;
}
