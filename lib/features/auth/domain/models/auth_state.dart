import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Represents the current authentication state of the user
class AuthState extends Equatable {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  /// Creates an authenticated state with the given user
  const AuthState.authenticated(User? user) 
      : this(user: user, isLoading: false, error: null);

  /// Creates an unauthenticated state
  const AuthState.unauthenticated() 
      : this(user: null, isLoading: false, error: null);

  /// Creates a loading state
  const AuthState.loading() 
      : this(user: null, isLoading: true, error: null);

  /// Creates an error state with the given error message
  const AuthState.error(String message) 
      : this(user: null, isLoading: false, error: message);

  bool get isAuthenticated => user != null;
  bool get isNotAuthenticated => !isAuthenticated;
  bool get hasError => error != null;

  @override
  List<Object?> get props => [user, isLoading, error];

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  String toString() => 'AuthState(user: $user, isLoading: $isLoading, error: $error)';
}
