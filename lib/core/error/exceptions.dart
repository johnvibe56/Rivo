/// Base class for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);

  @override
  String toString() => 'AppException: $message';
}

/// Thrown when there's an error communicating with the server
class ServerException extends AppException {
  const ServerException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Thrown when there's a failure in the cache
class CacheException extends AppException {
  const CacheException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Thrown when there's a network connectivity issue
class NetworkException extends AppException {
  const NetworkException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Thrown when there's an authentication error
class AuthenticationException extends AppException {
  const AuthenticationException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Thrown when there's a validation error
class ValidationException extends AppException {
  final Map<String, List<String>> errors;

  const ValidationException(this.errors, [StackTrace? stackTrace])
      : super('Validation failed', stackTrace);

  @override
  String toString() => 'ValidationException: $errors';
}
