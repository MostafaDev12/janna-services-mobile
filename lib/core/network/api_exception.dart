/// Thrown by [ApiClient] on every non-2xx response or transport failure.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isNotFound => statusCode == 404;
  bool get isServer  => statusCode != null && statusCode! >= 500;
  bool get isNetwork => statusCode == null;

  @override
  String toString() =>
      statusCode == null ? message : 'HTTP $statusCode — $message';
}
