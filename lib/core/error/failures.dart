import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.stackTrace]);

  @override
  List<Object?> get props => [message, stackTrace];

  @override
  String toString() => 'Failure: $message';
}

/// Thrown when there's an error communicating with the server
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.stackTrace]);
}

/// Thrown when there's a failure in the cache
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.stackTrace]);
}

/// Thrown when there's a network connectivity issue
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.stackTrace]);
}

/// Thrown when there's an authentication error
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, [super.stackTrace]);
}

/// Thrown when there's a validation error
class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;

  const ValidationFailure(this.errors, [StackTrace? stackTrace])
      : super('Validation failed', stackTrace);

  @override
  List<Object?> get props => [errors, ...super.props];

  @override
  String toString() => 'ValidationFailure: $errors';
}

/// Thrown when there's no internet connection
class NoInternetFailure extends Failure {
  const NoInternetFailure([String message = 'No internet connection'])
      : super(message);
}

/// Thrown when there's an error parsing data
class DataParsingFailure extends Failure {
  const DataParsingFailure([String message = 'Failed to parse data'])
      : super(message);
}

/// Thrown when the request times out
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out', super.stackTrace]);
}

/// Thrown when the server returns an unexpected status code
class ServerErrorFailure extends Failure {
  final int statusCode;

  const ServerErrorFailure(this.statusCode, [String? message, StackTrace? stackTrace])
      : super(message ?? 'Server error: $statusCode', stackTrace);

  @override
  List<Object?> get props => [statusCode, ...super.props];
}

/// Thrown when the requested resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found', super.stackTrace]);
}

/// Thrown when the user is not authorized to perform an action
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized', super.stackTrace]);
}

/// Thrown when the user doesn't have permission to perform an action
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'Forbidden', super.stackTrace]);
}

/// Thrown when there's an application-specific error
class AppFailure extends Failure {
  const AppFailure(super.message, [super.stackTrace]);
}

/// Thrown when the user is not authenticated
class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure([super.message = 'User is not authenticated', super.stackTrace]);
}
