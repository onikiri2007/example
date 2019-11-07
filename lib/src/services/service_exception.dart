class ServiceException implements Exception {
  final message;
  final Map<String, dynamic> data;

  const ServiceException(
    this.message, {
    this.data,
  });

  String toString() {
    if (message == null) return "ServiceException";
    return "$message";
  }
}
