import 'dart:async';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/services/services.dart';

const kUserProfileCreated = "UserProfileCreated";
const kPushToken = "PushToken";

abstract class UserService {
  Future<ServiceResult<UserData>> register(RegistrationInfo info);
  Future<ServiceResult<UserData>> patchUserInfo(UserInfoUpdateRequest req);
  Future<ServiceResult<UserData>> updateUserInfo(UserInfoUpdateRequest req,
      {String profilePhotoPath});
  Future<ServiceResult> registerPushToken(PushTokenInfo info);
  Future<ServiceResult> requestResetPasswordToken(
      ResetPasswordTokenRequest req);
  Future<ServiceResult<UserData>> resetPassword(ResetPasswordRequest req);
  Future<ServiceResult<UserData>> login(LoginRequest req);
  Future<ServiceResult> logout();
  Future<ServiceResult<UserData>> refreshUserSession();
  Future<ServiceResult<UserData>> getCurrentUserProfile();
  Future<bool> hasPushToken();
  Future<String> getPushToken();
  Future<void> removePushToken();
  Future<ServiceResult<UserData>> getContact(int id);
  Future<ServiceResult<List<Contact>>> getContacts();
}

class UserServiceImpl with ServiceMixin implements UserService {
  final UserApi api;
  final Future<SharedPreferences> sharedPreferences;
  final SessionService _sessionService;

  UserServiceImpl({
    UserApi api,
    Future<SharedPreferences> sharedPreferences,
    SessionService sessionService,
  })  : this.api = api ?? sl<UserApi>(),
        this.sharedPreferences =
            sharedPreferences ?? sl<Future<SharedPreferences>>(),
        this._sessionService = sessionService ?? sl<SessionService>();

  @override
  Future<ServiceResult<UserData>> login(LoginRequest req) async {
    try {
      var response = await api.login(req.toJson());

      if (response.data.isAdmin || response.data.isCompanyAdmin) {
        return onApiError<UserData>(
          DioError(
              response: Response(
            data: ErrorInfo(
                    errorMessage: "Unable to login with supplied credentials")
                .toJson(),
            extra: response.extra,
            headers: response.headers,
            redirects: response.redirects,
            request: response.request,
            statusCode: 401,
            statusMessage: response.statusMessage,
          )),
        );
      }

      final token = response.data.userKey;
      await _sessionService.saveUserKey(token);
      return ServiceResult.success(response.data);
    } on DioError catch (error) {
      return onApiError<UserData>(error);
    } catch (error, stacktrace) {
      return onApiException<UserData>(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult> logout() async {
    try {
      await api.logout();
      await removePushToken();
      return ServiceResult.successWithNoData();
    } on DioError catch (error) {
      return onApiError(error);
    } catch (error, stacktrace) {
      return onApiException(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult<UserData>> register(RegistrationInfo info) async {
    try {
      var response = await api.registerUser(info.toJson());
      return ServiceResult.success(response.data);
    } on DioError catch (error) {
      return onApiError<UserData>(error);
    } catch (error, stacktrace) {
      return onApiException<UserData>(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult> registerPushToken(PushTokenInfo info) async {
    try {
      await api.registerPushToken(info.toJson());
      await _savePushToken(info.token);
      return ServiceResult.successWithNoData();
    } on DioError catch (error) {
      return onApiError<void>(error);
    } catch (error, stacktrace) {
      return onApiException<void>(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult> requestResetPasswordToken(
      ResetPasswordTokenRequest req) async {
    try {
      await api.requestResetPasswordToken(req.toJson());
      return ServiceResult.successWithNoData();
    } on DioError catch (error) {
      return onApiError<UserData>(error);
    } catch (error, stacktrace) {
      return onApiException<UserData>(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult<UserData>> resetPassword(
      ResetPasswordRequest req) async {
    try {
      var response = await api.resetPassword(req.token, req.toJson());
      return ServiceResult.success(response.data);
    } on DioError catch (error) {
      return onApiError<UserData>(error);
    } catch (error, stacktrace) {
      return onApiException<UserData>(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult<UserData>> updateUserInfo(UserInfoUpdateRequest req,
      {String profilePhotoPath}) async {
    try {
      var response = await api.updateUserInfo(req.toJson(),
          profilePhotoPath: profilePhotoPath);
      return ServiceResult.success(response.data);
    } on DioError catch (error) {
      return onApiError<UserData>(error);
    } catch (error, stacktrace) {
      return onApiException<UserData>(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult<UserData>> refreshUserSession() async {
    try {
      var response = await api.currentSession();
      return ServiceResult.success(response.data);
    } on DioError catch (error) {
      return onApiError<UserData>(error);
    } catch (error, stacktrace) {
      return onApiException<UserData>(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult<UserData>> getCurrentUserProfile() async {
    try {
      var response = await api.getCurrentUserProfile();
      return ServiceResult.success(response.data);
    } on DioError catch (error) {
      return onApiError<UserData>(error);
    } catch (error, stacktrace) {
      return onApiException<UserData>(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult<UserData>> patchUserInfo(
      UserInfoUpdateRequest req) async {
    try {
      var response = await api.patchUserInfo(req.toJson());
      return ServiceResult.success(response.data);
    } on DioError catch (error) {
      return onApiError<UserData>(error);
    } catch (error, stacktrace) {
      return onApiException<UserData>(error, stacktrace);
    }
  }

  @override
  Future<bool> hasPushToken() async {
    final token = await getPushToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String> getPushToken() async {
    final pref = await sharedPreferences;
    return pref.getString(kPushToken);
  }

  Future _savePushToken(String token) async {
    final pref = await sharedPreferences;
    await pref.setString(kPushToken, token);
  }

  @override
  Future<void> removePushToken() async {
    final pref = await sharedPreferences;
    await pref.remove(kPushToken);
  }

  @override
  Future<ServiceResult<UserData>> getContact(int id) async {
    try {
      var response = await api.getUser(id);
      return ServiceResult.success(response.data);
    } on DioError catch (error) {
      return onApiError<UserData>(error);
    } catch (error, stacktrace) {
      return onApiException<UserData>(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult<List<Contact>>> getContacts() async {
    try {
      var response = await api.getContacts();
      return ServiceResult.success(response.data);
    } on DioError catch (error) {
      return onApiError<List<Contact>>(error);
    } catch (error, stacktrace) {
      return onApiException<List<Contact>>(error, stacktrace);
    }
  }
}
