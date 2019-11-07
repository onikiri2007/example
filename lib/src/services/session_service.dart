import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/services/services.dart';

const kUserKey = "UserKey";
const kUserId = "UserId";
const kUserEmail = "UserEmail";
const kUserData = "UserData";
const kUserDateOfBirth = "UserDateOfBirth";
const kUserPhoneNumber = "UserPhoneNumber";

abstract class SessionService {
  Future<ServiceResult<Session>> loadSession();
  Future<void> saveSession(Session session);
  Future<void> removeSession();
  Future<String> getToken();
  Future<String> getUserEmail();
  Future<bool> hasToken();
  Future<void> saveUserKey(String userKey);
}

class SessionServiceImpl with ServiceMixin implements SessionService {
  final Future<SharedPreferences> preferences;
  final FlutterSecureStorage secureStorage;

  SessionServiceImpl({
    Future<SharedPreferences> preferences,
    FlutterSecureStorage secureStorage,
  })  : this.preferences = preferences ?? sl<Future<SharedPreferences>>(),
        this.secureStorage = secureStorage ?? sl<FlutterSecureStorage>();

  @override
  Future<ServiceResult<Session>> loadSession() async {
    try {
      var prefs = await preferences;
      var userDataString = prefs.getString(kUserData);
      if (userDataString != null && userDataString.isNotEmpty) {
        final email = await secureStorage.read(key: kUserEmail);
        final userKey = await secureStorage.read(key: kUserKey);
        final userPhone = await secureStorage.read(key: kUserPhoneNumber);
        final userBirthDate = await secureStorage.read(key: kUserDateOfBirth);
        final userId = await secureStorage.read(key: kUserId);
        final data = UserData.fromJson(json.decode(userDataString));
        final userData = UserData.copyWithSensitiveData(
          email: email,
          userKey: userKey,
          dateOfBirth: userBirthDate,
          phone: userPhone,
          userId: userId != null ? int.tryParse(userId) : 0,
          userData: data,
        );
        return ServiceResult.success(Session.fromUserData(
          userData,
        ));
      }
      return ServiceResult.success(null);
    } catch (error, stacktrace) {
      return onApiException<Session>(error, stacktrace);
    }
  }

  @override
  Future<void> removeSession() async {
    var prefs = await preferences;
    await prefs.remove(kUserData);
    await secureStorage.delete(key: kUserEmail);
    await secureStorage.delete(key: kUserKey);
    await secureStorage.delete(key: kUserId);
    await secureStorage.delete(key: kUserDateOfBirth);
    await secureStorage.delete(key: kUserPhoneNumber);
  }

  @override
  Future<void> saveSession(Session session) async {
    var prefs = await preferences;
    if (session != null) {
      var userData =
          UserData.copyWithoutSensitveData(userData: session.userData);
      await prefs.setString(kUserData, json.encode(userData.toJson()));

      await secureStorage.write(key: kUserKey, value: session.userKey);
      await secureStorage.write(
          key: kUserId, value: "${session.userData.userId}");

      await secureStorage.write(key: kUserEmail, value: session.userData.email);

      if (session.userData?.dateOfBirth != null) {
        await secureStorage.write(
            key: kUserDateOfBirth, value: session.userData.dateOfBirth);
      }

      if (session.userData?.phone != null) {
        await secureStorage.write(
            key: kUserPhoneNumber, value: session.userData.phone);
      }
    }
  }

  @override
  Future<String> getUserEmail() {
    return secureStorage.read(key: kUserEmail);
  }

  @override
  Future<String> getToken() {
    return secureStorage.read(key: kUserKey);
  }

  @override
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> saveUserKey(String userKey) async {
    if (userKey != null && userKey.isNotEmpty) {
      await secureStorage.write(key: kUserKey, value: userKey);
    }
  }
}
