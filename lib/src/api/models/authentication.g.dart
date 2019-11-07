// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authentication.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) {
  return LoginRequest(
    email: json['email'] as String,
    password: json['password'] as String,
    deviceId: json['deviceId'] as String,
  );
}

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'deviceId': instance.deviceId,
    };

RegistrationInfo _$RegistrationInfoFromJson(Map<String, dynamic> json) {
  return RegistrationInfo(
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    email: json['email'] as String,
    password: json['password'] as String,
    deviceId: json['deviceId'] as String,
    acceptTermsConditions: json['acceptTermsConditions'] as bool,
    isAnonymous: json['isAnonymous'] as bool,
    anonymousUserId: json['anonymousUserId'] as String,
  );
}

Map<String, dynamic> _$RegistrationInfoToJson(RegistrationInfo instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'password': instance.password,
      'deviceId': instance.deviceId,
      'acceptTermsConditions': instance.acceptTermsConditions,
      'isAnonymous': instance.isAnonymous,
      'anonymousUserId': instance.anonymousUserId,
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) {
  return UserData(
    userId: json['userId'] as int,
    userKey: json['userKey'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    statusRaw: json['status'] as String,
    roles: (json['roles'] as List)?.map((e) => e as String)?.toList(),
    profilePhoto: json['profilePhotoPath'] as String,
    anonymous: json['anonymous'] as bool,
    phone: json['phone'] as String,
    dateOfBirth: json['dateOfBirth'] as String,
    skillIds: (json['skillIds'] as List)?.map((e) => e as int)?.toList(),
    siteIds: (json['siteIds'] as List)?.map((e) => e as int)?.toList(),
    isProfileConfirmed: json['isProfileConfirmed'] as bool,
    rate: (json['rate'] as num)?.toDouble(),
    sites: (json['sites'] as List)
        ?.map(
            (e) => e == null ? null : Site.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    skills: (json['skills'] as List)
        ?.map(
            (e) => e == null ? null : Skill.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    hasPushToken: json['hasPushToken'] as bool,
  );
}

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
      'userId': instance.userId,
      'userKey': instance.userKey,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'fullName': instance.fullName,
      'email': instance.email,
      'status': instance.statusRaw,
      'roles': instance.roles,
      'profilePhotoPath': instance.profilePhoto,
      'anonymous': instance.anonymous,
      'phone': instance.phone,
      'dateOfBirth': instance.dateOfBirth,
      'skillIds': instance.skillIds,
      'siteIds': instance.siteIds,
      'isProfileConfirmed': instance.isProfileConfirmed,
      'rate': instance.rate,
      'sites': instance.sites,
      'skills': instance.skills,
      'hasPushToken': instance.hasPushToken,
    };

UserInfoUpdateRequest _$UserInfoUpdateRequestFromJson(
    Map<String, dynamic> json) {
  return UserInfoUpdateRequest(
    currentPassword: json['currentPassword'] as String,
    email: json['email'] as String,
    emailSpecified: json['emailSpecified'] as bool,
    password: json['password'] as String,
    passwordSpecified: json['passwordSpecified'] as bool,
    firstname: json['firstname'] as String,
    lastname: json['lastname'] as String,
    status: json['status'] as String,
    nameSpecified: json['nameSpecified'] as bool,
    dateOfBirth: json['dateOfBirth'] as String,
    phone: json['phone'] as String,
    isProfileConfirmed: json['isProfileConfirmed'] as bool,
  );
}

Map<String, dynamic> _$UserInfoUpdateRequestToJson(
        UserInfoUpdateRequest instance) =>
    <String, dynamic>{
      'currentPassword': instance.currentPassword,
      'email': instance.email,
      'emailSpecified': instance.emailSpecified,
      'password': instance.password,
      'passwordSpecified': instance.passwordSpecified,
      'status': instance.status,
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'nameSpecified': instance.nameSpecified,
      'dateOfBirth': instance.dateOfBirth,
      'phone': instance.phone,
      'isProfileConfirmed': instance.isProfileConfirmed,
    };

PushTokenInfo _$PushTokenInfoFromJson(Map<String, dynamic> json) {
  return PushTokenInfo(
    deviceId: json['deviceId'] as String,
    token: json['token'] as String,
    provider:
        _$enumDecodeNullable(_$PushTokenProviderEnumMap, json['provider']),
  );
}

Map<String, dynamic> _$PushTokenInfoToJson(PushTokenInfo instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'token': instance.token,
      'provider': _$PushTokenProviderEnumMap[instance.provider],
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$PushTokenProviderEnumMap = <PushTokenProvider, dynamic>{
  PushTokenProvider.Apple: 'Apple',
  PushTokenProvider.Google: 'Google'
};

ResetPasswordTokenRequest _$ResetPasswordTokenRequestFromJson(
    Map<String, dynamic> json) {
  return ResetPasswordTokenRequest(
    email: json['email'] as String,
    type: json['type'] as String,
  );
}

Map<String, dynamic> _$ResetPasswordTokenRequestToJson(
        ResetPasswordTokenRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'type': instance.type,
    };

ResetPasswordRequest _$ResetPasswordRequestFromJson(Map<String, dynamic> json) {
  return ResetPasswordRequest(
    email: json['email'] as String,
    firstname: json['firstname'] as String,
    lastname: json['lastname'] as String,
    password: json['password'] as String,
    token: json['token'] as String,
  );
}

Map<String, dynamic> _$ResetPasswordRequestToJson(
        ResetPasswordRequest instance) =>
    <String, dynamic>{
      'firstname': instance.firstname,
      'lastname': instance.lastname,
      'password': instance.password,
      'email': instance.email,
      'token': instance.token,
    };

Contact _$ContactFromJson(Map<String, dynamic> json) {
  return Contact(
    id: json['id'] as int,
    fullName: json['fullName'] as String,
    phone: json['phone'] as String,
    profilePhoto: json['profilePhotoPath'] as String,
    skillIds: (json['skillIds'] as List)?.map((e) => e as int)?.toList(),
    siteIds: (json['siteIds'] as List)?.map((e) => e as int)?.toList(),
    sites: (json['sites'] as List)
        ?.map(
            (e) => e == null ? null : Site.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    skills: (json['skills'] as List)
        ?.map(
            (e) => e == null ? null : Skill.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    isManager: json['isManager'] as bool,
  );
}

Map<String, dynamic> _$ContactToJson(Contact instance) => <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'profilePhotoPath': instance.profilePhoto,
      'phone': instance.phone,
      'skillIds': instance.skillIds,
      'siteIds': instance.siteIds,
      'sites': instance.sites,
      'skills': instance.skills,
      'isManager': instance.isManager,
    };
