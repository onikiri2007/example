import "dart:async";
import 'dart:io';
import "package:dio/dio.dart";
import 'package:yodel/src/api/index.dart';

abstract class UserApi {
  Future<Response> registerPushToken(Map<String, dynamic> tokenInfo,
      {CancelToken cancelToken});
  Future<Response<UserData>> registerUser(Map<String, dynamic> registrationInfo,
      {CancelToken cancelToken});
  Future<Response<UserData>> login(Map<String, dynamic> loginInfo,
      {CancelToken cancelToken});
  Future<Response<UserData>> loginByMobileNumber(Map<String, dynamic> loginInfo,
      {CancelToken cancelToken});
  Future<Response<UserData>> loginByPin(Map<String, dynamic> loginInfo,
      {CancelToken cancelToken});
  Future<Response<UserData>> requestVerificationCode(Map<String, dynamic> req,
      {CancelToken cancelToken});
  Future<Response> logout({CancelToken cancelToken});
  Future<Response<UserData>> currentSession({CancelToken cancelToken});
  Future<Response<UserData>> patchUserInfo(Map<String, dynamic> userInfo,
      {CancelToken cancelToken});
  Future<Response<UserData>> updateUserInfo(Map<String, dynamic> userInfo,
      {String profilePhotoPath, CancelToken cancelToken});
  Future<Response> requestResetPasswordToken(Map<String, dynamic> tokenInfo,
      {CancelToken cancelToken});
  Future<Response> resetPassword(String tokenId, Map<String, dynamic> tokenInfo,
      {CancelToken cancelToken});

  Future<Response<UserData>> getCurrentUserProfile({CancelToken cancelToken});

  Future<Response<UserData>> getUser(int id, {CancelToken cancelToken});

  Future<Response<List<Contact>>> getContacts({CancelToken cancelToken});
}

class UserApiImpl with ResponseMixin implements UserApi {
  final Dio httpClient;

  UserApiImpl(this.httpClient) : assert(httpClient != null);

  Future<Response> registerPushToken(Map<String, dynamic> tokenInfo,
      {CancelToken cancelToken}) {
    return httpClient.post("/devicepushtokens",
        data: removeNulls(tokenInfo), cancelToken: cancelToken);
  }

  Future<Response<UserData>> registerUser(Map<String, dynamic> registrationInfo,
      {CancelToken cancelToken}) async {
    var res = await httpClient.post("/users/byemail",
        data: removeNulls(registrationInfo), cancelToken: cancelToken);
    return createResponse<UserData>(UserData.fromJson(res.data), res);
  }

  Future<Response<UserData>> login(Map<String, dynamic> loginInfo,
      {CancelToken cancelToken}) async {
    var res = await httpClient.post("/usersessions/byemail",
        data: removeNulls(loginInfo), cancelToken: cancelToken);
    return createResponse<UserData>(UserData.fromJson(res.data), res);
  }

  Future<Response<UserData>> loginByMobileNumber(Map<String, dynamic> loginInfo,
      {CancelToken cancelToken}) async {
    var res = await httpClient.post("/usersessions/byphone",
        data: removeNulls(loginInfo), cancelToken: cancelToken);
    return createResponse<UserData>(UserData.fromJson(res.data), res);
  }

  Future<Response<UserData>> loginByPin(Map<String, dynamic> loginInfo,
      {CancelToken cancelToken}) async {
    var res = await httpClient.post("/usersessions/byphone",
        data: removeNulls(loginInfo), cancelToken: cancelToken);
    return createResponse<UserData>(UserData.fromJson(res.data), res);
  }

  Future<Response<UserData>> requestVerificationCode(Map<String, dynamic> req,
      {CancelToken cancelToken}) async {
    var res = await httpClient.post("/usersessions/byphone/coderequest",
        data: removeNulls(req), cancelToken: cancelToken);
    return createResponse<UserData>(UserData.fromJson(res.data), res);
  }

  Future<Response> logout({CancelToken cancelToken}) {
    return httpClient.delete("/usersessions/current", cancelToken: cancelToken);
  }

  Future<Response<UserData>> currentSession({CancelToken cancelToken}) async {
    var res =
        await httpClient.get("/usersessions/current", cancelToken: cancelToken);
    return createResponse<UserData>(UserData.fromJson(res.data), res);
  }

  Future<Response<UserData>> patchUserInfo(Map<String, dynamic> userInfo,
      {CancelToken cancelToken}) async {
    var res = await httpClient.patch("/users/current",
        data: removeNulls(userInfo), cancelToken: cancelToken);
    return createResponse<UserData>(UserData.fromJson(res.data), res);
  }

  Future<Response<UserData>> updateUserInfo(Map<String, dynamic> userInfo,
      {String profilePhotoPath, CancelToken cancelToken}) async {
    if (profilePhotoPath != null && profilePhotoPath.isNotEmpty) {
      final photoFile = File(profilePhotoPath);
      final exists = await photoFile.exists();
      if (exists) {
        userInfo.putIfAbsent(
            "profilePhotoFile",
            () => UploadFileInfo(
                  photoFile,
                  photoFile.uri.pathSegments.last,
                ));
      }
    }

    final data = FormData.from(removeNulls(userInfo));
    var res = await httpClient.put("/users/current",
        data: data,
        cancelToken: cancelToken,
        options: Options(headers: {"Accept": "*/*"}));
    return createResponse<UserData>(UserData.fromJson(res.data), res);
  }

  Future<Response> requestResetPasswordToken(Map<String, dynamic> tokenInfo,
      {CancelToken cancelToken}) {
    return httpClient.post("/users/tokens",
        data: removeNulls(tokenInfo), cancelToken: cancelToken);
  }

  Future<Response<UserData>> resetPassword(
      String tokenId, Map<String, dynamic> tokenInfo,
      {CancelToken cancelToken}) async {
    var res = await httpClient.patch("/users/bytoken/$tokenId",
        data: removeNulls(tokenInfo), cancelToken: cancelToken);

    return createResponse<UserData>(UserData.fromJson(res.data), res);
  }

  @override
  Future<Response<UserData>> getCurrentUserProfile(
      {CancelToken cancelToken}) async {
    var res = await httpClient.get("/users/current", cancelToken: cancelToken);
    return createResponse<UserData>(UserData.fromJson(res.data), res);
  }

  @override
  Future<Response<UserData>> getUser(int id, {CancelToken cancelToken}) async {
    var res = await httpClient.get("/users/$id", cancelToken: cancelToken);
    return createResponse<UserData>(UserData.fromJson(res.data), res);
  }

  @override
  Future<Response<List<Contact>>> getContacts({CancelToken cancelToken}) async {
    var res = await httpClient.get("/users", cancelToken: cancelToken);

    List<dynamic> data = res.data ?? [];
    final List<Contact> users =
        data.isNotEmpty ? data.map((s) => Contact.fromJson(s)).toList() : [];

    return createResponse<List<Contact>>(users, res);
  }
}
