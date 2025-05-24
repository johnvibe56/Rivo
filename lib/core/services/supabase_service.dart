import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Exception thrown when a Supabase operation fails
class SupabaseServiceException implements Exception {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  SupabaseServiceException({
    required this.message,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() => 'SupabaseServiceException: $message';
}

/// Exception thrown when Supabase fails to initialize
class SupabaseInitializationException implements Exception {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  SupabaseInitializationException({
    required this.message,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() => 'SupabaseInitializationException: $message';
}

/// A service class that handles all Supabase-related functionality.
/// This includes initialization, authentication, and database operations.
class SupabaseService {
  static bool _isInitialized = false;
  static final Completer<void> _initializationCompleter = Completer<void>();
  static late final SupabaseClient _supabaseClient;

  /// Private constructor for singleton
  SupabaseService._internal();

  /// Singleton instance
  static final SupabaseService _instance = SupabaseService._internal();

  /// Factory constructor to return the singleton instance
  factory SupabaseService() => _instance;

  /// Returns the current Supabase client instance
  SupabaseClient get client {
    _ensureInitialized();
    return _supabaseClient;
  }

  /// Get the current user if authenticated
  User? get currentUser => _supabaseClient.auth.currentUser;

  /// Check if a user is currently logged in
  bool get isLoggedIn => currentUser != null;

  /// Getter for the Supabase auth instance
  GoTrueClient get auth => _supabaseClient.auth;

  /// Getter for the Supabase storage instance
  SupabaseStorageClient get storage => _supabaseClient.storage;

  /// Getter for the Supabase realtime instance
  RealtimeClient get realtime => _supabaseClient.realtime;

  /// Returns the current session if available
  Session? get currentSession => _supabaseClient.auth.currentSession;

  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    if (_isInitialized) {
      return _initializationCompleter.future;
    }

    try {
      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw const FormatException('Supabase URL and anon key cannot be empty');
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _supabaseClient = Supabase.instance.client;
      _isInitialized = true;
      _initializationCompleter.complete();
    } catch (e, stackTrace) {
      final exception = SupabaseInitializationException(
        message: 'Failed to initialize Supabase',
        error: e,
        stackTrace: stackTrace,
      );
      _initializationCompleter.completeError(exception);
      rethrow;
    }
  }

  /// Ensures Supabase is initialized before use
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'Supabase has not been initialized. '
        'Call SupabaseService.initialize() first.',
      );
    }
  }

  /// Signs in a user with email and password
  /// 
  /// Returns the signed in user on success
  /// Throws [SupabaseServiceException] on failure
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e, stackTrace) {
      throw SupabaseServiceException(
        message: 'Failed to sign in: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Signs up a new user with email and password
  /// 
  /// Returns the newly created user on success
  /// Throws [SupabaseServiceException] on failure
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? userMetadata,
    String? redirectTo,
    Map<String, dynamic>? data,
  }) async {
    try {
      return await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: data ?? userMetadata,
        emailRedirectTo: redirectTo,
      );
    } catch (e, stackTrace) {
      throw SupabaseServiceException(
        message: 'Failed to sign up: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Signs out the current user
  /// 
  /// Throws [SupabaseServiceException] on failure
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e, stackTrace) {
      throw SupabaseServiceException(
        message: 'Failed to sign out: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Sends a password reset email to the specified email address
  /// 
  /// Throws [SupabaseServiceException] on failure
  Future<void> resetPasswordForEmail(
    String email, {
    String? redirectTo,
  }) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );
    } catch (e, stackTrace) {
      throw SupabaseServiceException(
        message: 'Failed to send password reset email: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates the current user's password
  /// 
  /// Throws [SupabaseServiceException] on failure
  Future<void> updateUserPassword(String newPassword) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e, stackTrace) {
      throw SupabaseServiceException(
        message: 'Failed to update password: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Helper method to access Supabase tables
  /// 
  /// Throws [StateError] if Supabase is not initialized
  SupabaseQueryBuilder from(String table) {
    _ensureInitialized();
    return _supabaseClient.from(table);
  }

  /// Returns a stream of the current user's profile
  /// 
  /// The stream will emit a new value whenever the user's profile changes
  Stream<Map<String, dynamic>?> streamUserProfile(String userId) {
    _ensureInitialized();
    return _supabaseClient
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) => data.isNotEmpty ? data[0] : null);
  }

  /// Updates the current user's profile
  /// 
  /// Returns the updated profile on success
  /// Throws [SupabaseServiceException] on failure
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _supabaseClient
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();
      
      return response;
    } catch (e, stackTrace) {
      throw SupabaseServiceException(
        message: 'Failed to update profile: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
