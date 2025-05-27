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
  const ServerException(super.message, [super.stackTrace]);
}

/// Thrown when there's a failure in the cache
class CacheException extends AppException {
  const CacheException(super.message, [super.stackTrace]);
}

/// Thrown when there's a network connectivity issue
class NetworkException extends AppException {
  const NetworkException(super.message, [super.stackTrace]);
}

/// Thrown when there's an authentication error
class AuthenticationException extends AppException {
  const AuthenticationException(super.message, [super.stackTrace]);
}

/// Thrown when there's a validation error
class ValidationException extends AppException {
  final Map<String, List<String>> errors;

  const ValidationException(this.errors, [StackTrace? stackTrace])
      : super('Validation failed', stackTrace);

  @override
  String toString() => 'ValidationException: $errors';
}

/// Thrown when a requested resource is not found
class NotFoundException extends AppException {
  const NotFoundException(
    super.message, [
    super.stackTrace,
  ]);

  @override
  String toString() => 'NotFoundException: $message';
}
