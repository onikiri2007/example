import 'package:yodel/src/services/services.dart';

class ServiceResult<T> {
  final T result;
  final Exception ex;
  final String errorMessage;
  final bool hasError;
  final int statusCode;

  const ServiceResult._(
      {this.result,
      this.ex,
      this.hasError = false,
      this.statusCode,
      this.errorMessage});

  factory ServiceResult.successWithNoData() {
    return ServiceResult._(
      statusCode: 200,
      hasError: false,
    );
  }

  factory ServiceResult.success(T result) {
    return ServiceResult._(
      result: result,
      statusCode: 200,
      hasError: false,
    );
  }

  factory ServiceResult.failure({
    Exception ex,
    String errorMessage,
    int statusCode = 400,
  }) {
    return ServiceResult._(
      ex: ex,
      errorMessage: errorMessage,
      statusCode: statusCode,
      hasError: true,
    );
  }

  bool get isSuccessful => !hasError;

  String get error => errorMessage != null
      ? errorMessage
      : ex?.toString() ?? "Fatal error occured. Please try again later.";

  Exception getException() {
    if (hasError) {
      if (errorMessage != null) {
        return ServiceException(errorMessage);
      }

      return ex;
    }

    return null;
  }
}
