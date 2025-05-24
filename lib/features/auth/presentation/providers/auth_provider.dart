import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rivo/features/auth/domain/models/auth_state.dart' as app_auth;
import 'package:supabase_flutter/supabase_flutter.dart';

// Alias the AuthState from gotrue to avoid conflicts
typedef GotrueAuthState = AuthState;

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<app_auth.AuthState>>(
  (ref) => AuthNotifier(),
);

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<app_auth.AuthState>> {
  bool _mounted = true;
  
  AuthNotifier() : super(const AsyncValue.loading());
  
  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
  
  @override
  bool get mounted => _mounted;
  
  /// Initialize the auth state
  Future<void> initialize() async {
    try {
      state = const AsyncValue.loading();
      await _checkAuthState();
      
      // Listen to auth state changes
      Supabase.instance.client.auth.onAuthStateChange.listen((event) {
        _handleAuthChange(event.session);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  
  Future<void> _checkAuthState() async {
    try {
      state = const AsyncValue.loading();
      final session = Supabase.instance.client.auth.currentSession;
      if (mounted) {
        _handleAuthChange(session);
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }
  
  void _handleAuthChange(Session? session) {
    if (!mounted) return;
    
    try {
      if (session != null) {
        // User is signed in
        state = AsyncValue.data(app_auth.AuthState.authenticated(session.user));
      } else {
        // User is signed out
        state = const AsyncValue.data(app_auth.AuthState.unauthenticated());
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  void setLoading() {
    state = const AsyncValue.loading();
  }

  void setError(String message) {
    state = AsyncValue.error(message, StackTrace.current);
  }
  
  void setAuthenticated(User? user) {
    if (user != null) {
      state = AsyncValue.data(app_auth.AuthState.authenticated(user));
    } else {
      state = const AsyncValue.data(app_auth.AuthState.unauthenticated());
    }
  }
  
  void setUnauthenticated() {
    state = const AsyncValue.data(app_auth.AuthState.unauthenticated());
  }
}

class AuthController {
  final Ref _ref;
  final _supabase = Supabase.instance.client;

  AuthController(this._ref);

  /// Signs in a user with email and password
  /// 
  /// [email] The user's email address
  /// [password] The user's password
  /// 
  /// Throws an [AuthException] if sign in fails
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final notifier = _ref.read(authStateProvider.notifier);
    try {
      notifier.setLoading();
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.session == null) {
        throw Exception('No session returned after sign in');
      }
      
      notifier.setAuthenticated(response.session!.user);
    } catch (e) {
      notifier.setError(e.toString());
      rethrow;
    }
  }

  /// Signs up a new user with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    final notifier = _ref.read(authStateProvider.notifier);
    try {
      notifier.setLoading();
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      
      if (response.session != null) {
        notifier.setAuthenticated(response.session!.user);
      } else {
        // Email confirmation required
        notifier.setUnauthenticated();
      }
    } catch (e) {
      notifier.setError('Failed to sign up: $e');
      rethrow;
    }
  }

  /// Signs in with Google
  Future<void> signInWithGoogle() async {
    final notifier = _ref.read(authStateProvider.notifier);
    try {
      notifier.setLoading();
      
      // Sign in with Google
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }
      
      final googleAuth = await googleUser.authentication;
      
      // Sign in with Supabase
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );
      
      if (response.session == null) {
        throw Exception('No session returned after Google sign in');
      }
      
      notifier.setAuthenticated(response.session!.user);
    } catch (e) {
      notifier.setError(e.toString());
      rethrow;
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    final notifier = _ref.read(authStateProvider.notifier);
    try {
      notifier.setLoading();
      
      // Sign out from Google if the user signed in with Google
      if (await GoogleSignIn().isSignedIn()) {
        await GoogleSignIn().signOut();
      }
      
      // Sign out from Supabase
      await _supabase.auth.signOut();
      notifier.setUnauthenticated();
    } catch (e) {
      notifier.setError('Failed to sign out: $e');
      rethrow;
    }
  }

  /// Sends a password reset email
  Future<void> resetPassword({required String email}) async {
    final notifier = _ref.read(authStateProvider.notifier);
    try {
      notifier.setLoading();
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.rivo://reset-password',
      );
    } catch (e) {
      notifier.setError('Failed to send password reset email: $e');
      rethrow;
    } finally {
      notifier.setUnauthenticated();
    }
  }

  /// Updates the user's password
  Future<void> updatePassword(String newPassword) async {
    final notifier = _ref.read(authStateProvider.notifier);
    try {
      notifier.setLoading();
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      notifier.setError('Failed to update password: $e');
      rethrow;
    }
  }
  
  /// Gets the current user
  User? get currentUser => _supabase.auth.currentUser;
}
