class ErrorInfo {
  ErrorInfo({
    this.errorMessage,
    this.errors = const [],
  });

  final String errorMessage;
  final List<String> errors;

  String get errorMessages {
    if (errorMessage != null && errorMessage.isNotEmpty) {
      return errorMessage;
    }

    if (errors != null) {
      return errors.reduce((s1, s2) => s1 + ", $s2");
    }

    return "something went wrong";
  }

  static const fromJson = _$ErrorInfoFromJson;

  Map<String, dynamic> toJson() => _$ErrorInfoToJson(this);
}

ErrorInfo _$ErrorInfoFromJson(Map<String, dynamic> json) {
  return ErrorInfo(
      errorMessage: json['errorMessage'] as String,
      errors: (json['errors'] as List)?.map((e) => e as String)?.toList());
}

Map<String, dynamic> _$ErrorInfoToJson(ErrorInfo instance) => <String, dynamic>{
      'errorMessage': instance.errorMessage,
      'errors': instance.errors
    };
