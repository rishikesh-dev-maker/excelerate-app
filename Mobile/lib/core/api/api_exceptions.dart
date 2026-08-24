class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException([
    String message = 'Network error. Please check your connection.',
  ]) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Invalid email or password'])
    : super(message, 401);
}

class NotFoundException extends ApiException {
  NotFoundException([String message = 'Requested resource not found'])
    : super(message, 404);
}

class ValidationException extends ApiException {
  ValidationException([String message = 'Validation failed'])
    : super(message, 400);
}
