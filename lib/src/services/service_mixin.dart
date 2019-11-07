import 'package:dio/dio.dart';
import 'package:raygun/raygun.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/services/services.dart';

const String no_network = "Internet connection appears to be offline";
const String cancelled = "Request has been cancelled";
const int no_network_code = 4008;
const int cancelled_request = 4009;

mixin ServiceMixin {
  ServiceResult<T> onApiError<T>(DioError error) {
    if (hasErrorInfo(error)) {
      try {
        var errorInfo = getErrorInfoFromError(error);
        return ServiceResult<T>.failure(
            errorMessage: errorInfo.errorMessages,
            statusCode: error.response.statusCode);
      } catch (ex, stacktrace) {
        return onApiException<T>(ex, stacktrace);
      }
    }

    if (error.type == DioErrorType.CONNECT_TIMEOUT ||
        error.type == DioErrorType.RECEIVE_TIMEOUT ||
        error.type == DioErrorType.SEND_TIMEOUT) {
      return ServiceResult<T>.failure(
          errorMessage: no_network, statusCode: no_network_code);
    }

    if (error.type == DioErrorType.CANCEL) {
      return ServiceResult<T>.failure(
          errorMessage: cancelled, statusCode: cancelled_request);
    }

    return ServiceResult<T>.failure(
        errorMessage: error.message,
        statusCode: error.response?.statusCode ?? 400);
  }

  ServiceResult<T> onApiException<T>(dynamic ex, StackTrace stracktrace) {
    FlutterRaygun().logException(ex, stracktrace);
    return ServiceResult<T>.failure(
      ex: ex != null && ex is Exception ? ex : null,
      statusCode: 500,
      errorMessage: ex != null && ex is! Exception ? ex?.toString() : null,
    );
  }
}
