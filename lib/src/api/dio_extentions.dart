import 'package:dio/dio.dart';
import 'index.dart';

ErrorInfo getErrorInfoFromError(DioError error) {
  if (hasErrorInfo(error)) {
    return ErrorInfo.fromJson(error.response.data);
  }

  return null;
}

bool hasErrorInfo(DioError error) {
  return error.response != null &&
      error.response.data != null &&
      error.response.data is Map<String, dynamic>;
}
