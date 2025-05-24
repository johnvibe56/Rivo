import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class for managing Supabase initialization and authentication
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  static SupabaseClient? _supabaseClient;
  static bool _isInitialized = false;

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  /// Initialize Supabase with the given credentials
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    if (!_isInitialized) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _supabaseClient = Supabase.instance.client;
      _isInitialized = true;
    }
  }

  /// Get the Supabase client instance
  static SupabaseClient get client {
    if (_supabaseClient == null) {
      throw Exception('Supabase has not been initialized. Call initialize() first.');
    }
    return _supabaseClient!;
  }

  /// Get the current user session
  static Session? get currentSession => _supabaseClient?.auth.currentSession;

  /// Get the current user
  static User? get currentUser => _supabaseClient?.auth.currentUser;

  /// Check if user is logged in
  static bool get isLoggedIn => currentUser != null;

  /// Sign out the current user
  static Future<void> signOut() async {
    await _supabaseClient?.auth.signOut();
  }
  
  /// Check if Supabase is initialized
  static bool get isInitialized => _isInitialized;
}

/// Provider for Supabase client
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return SupabaseService.client;
});

/// Provider for Supabase auth state changes
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});
