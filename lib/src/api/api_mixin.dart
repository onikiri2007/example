import 'package:dio/dio.dart';

mixin ResponseMixin {
  Response<T> createResponse<T>(T data, Response response) {
    return Response<T>(
        data: data,
        headers: response.headers,
        request: response.request,
        redirects: response.redirects,
        statusCode: response.statusCode,
        extra: response.extra);
  }
}

Map<String, dynamic> removeNulls(Map<String, dynamic> source) {
  source.removeWhere((key, value) => value == null);
  return source;
}
