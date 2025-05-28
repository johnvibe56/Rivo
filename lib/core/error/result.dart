import 'package:equatable/equatable.dart';

/// A class representing either a successful result with a value of type [T]
/// or a failure with a [Failure] object.
abstract class Result<T> {
  const Result();

  /// Returns `true` if this is a successful result.
  bool get isSuccess => this is Success<T>;

  /// Returns `true` if this is a failure result.
  bool get isFailure => this is Failure<T>;

  /// Returns the success value if this is a success, otherwise returns `null`.
  T? get valueOrNull => isSuccess ? (this as Success<T>).value : null;

  /// Returns the failure if this is a failure, otherwise returns `null`.
  Failure<T>? get failureOrNull => isFailure ? (this as Failure<T>) : null;

  /// Handles both success and failure cases.
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure<T> failure) failure,
  }) {
    if (isSuccess) {
      return success((this as Success<T>).value);
    } else {
      return failure(this as Failure<T>);
    }
  }

  /// Maps the success value to a new [Result] using the provided function.
  Result<R> mapSuccess<R>(R Function(T) mapper) {
    if (isSuccess) {
      return Result<R>.success(mapper((this as Success<T>).value));
    } else {
      final failure = this as Failure<T>;
      return Result<R>.failure(
        failure.error,
        failure.stackTrace,
      );
    }
  }

  /// Maps the failure to a new [Result] using the provided function.
  Result<T> mapFailure(Result<T> Function(Failure<T>) mapper) {
    if (isSuccess) {
      return this;
    } else {
      return mapper(this as Failure<T>);
    }
  }

  /// Creates a success result with the given [value].
  factory Result.success(T value) => Success<T>(value);

  /// Creates a failure result with the given [error].
  factory Result.failure(Object error, [StackTrace? stackTrace]) => Failure<T>._(error, stackTrace);
}

/// Represents a successful result containing a value.
class Success<T> extends Result<T> with EquatableMixin {
  final T value;

  const Success(this.value);

  @override
  List<Object?> get props => [value];
}

/// Represents a failed result containing an error.
class Failure<T> extends Result<T> with EquatableMixin {
  final Object error;
  final StackTrace? stackTrace;

  const Failure._(this.error, [this.stackTrace]);
  
  /// Creates a new Failure with the given error and optional stack trace.
  factory Failure(Object error, [StackTrace? stackTrace]) {
    return Failure<T>._(error, stackTrace);
  }

  @override
  List<Object?> get props => [error, stackTrace];
  
  /// Get the error message if the error is an AppFailure, otherwise convert to string
  String get errorMessage => error is AppFailure 
      ? (error as AppFailure).message 
      : error.toString();
  
  /// Creates a new Failure with the same error but a different type parameter.
  Failure<R> withType<R>() => Failure<R>(error, stackTrace);
}

/// Extension methods for [Result].
extension ResultExtensions<T> on Result<T> {
  /// Returns the success value or throws the error if this is a failure.
  T getOrThrow() {
    return when(
      success: (value) => value,
      failure: (failure) => throw failure.error,
    );
  }

  /// Returns the success value or null if this is a failure.
  T? getOrNull() => valueOrNull;

  /// Returns the success value or the result of [orElse] if this is a failure.
  T getOrElse(T Function() orElse) {
    if (isSuccess) {
      return (this as Success<T>).value;
    } else {
      return orElse();
    }
  }

  /// Executes [onSuccess] if this is a success, or [onFailure] if this is a failure.
  void fold({
    required void Function(T value) onSuccess,
    required void Function(Failure<T> failure) onFailure,
  }) {
    when(
      success: onSuccess,
      failure: onFailure,
    );
  }
}

/// A base class for all failures in the application.
/// Extend this class to create specific types of failures.
class AppFailure implements Exception {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const AppFailure({
    required this.message,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() => 'AppFailure: $message';
}

/// A failure that occurs when a requested resource is not found.
class NotFoundFailure extends AppFailure {
  const NotFoundFailure({
    super.message = 'The requested resource was not found',
    super.error,
    super.stackTrace,
  });
}

/// A failure that occurs when there is no internet connection.
class NoInternetFailure extends AppFailure {
  const NoInternetFailure({
    super.message = 'No internet connection',
    super.error,
    super.stackTrace,
  });
}

/// A failure that occurs when a server error occurs.
class ServerFailure extends AppFailure {
  const ServerFailure({
    super.message = 'A server error occurred',
    super.error,
    super.stackTrace,
  });
}

/// A failure that occurs when a request times out.
class TimeoutFailure extends AppFailure {
  const TimeoutFailure({
    super.message = 'The request timed out',
    super.error,
    super.stackTrace,
  });
}

/// A failure that occurs when the user is not authenticated.
class UnauthenticatedFailure extends AppFailure {
  const UnauthenticatedFailure({
    super.message = 'User is not authenticated',
    super.error,
    super.stackTrace,
  });
}

/// A failure that occurs when the user is not authorized to perform an action.
class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure({
    super.message = 'User is not authorized',
    super.error,
    super.stackTrace,
  });
}
