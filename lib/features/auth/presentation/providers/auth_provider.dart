import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:rivo/features/user_profile/presentation/providers/user_profile_providers.dart';
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
  
  // Get profile repository
  UserProfileRepository get _profileRepository => _ref.read(userProfileRepositoryProvider);

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

  /// Signs up a new user with email and password and creates their profile
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    String? fullName,
  }) async {
    final notifier = _ref.read(authStateProvider.notifier);
    try {
      notifier.setLoading();
      
      // 0. First check if username is available
      final isUsernameAvailable = await _profileRepository.isUsernameAvailable(username);
      
      if (!isUsernameAvailable) {
        throw Exception('Username is already taken');
      }
      
      // 1. Sign up the user with Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName ?? '',
          'username': username, // Store username in auth metadata for easy access
          'avatar_url': null,
        },
        emailRedirectTo: 'io.supabase.rivo://login-callback', // Update this with your deep link
      );
      
      if (response.user == null) {
        throw Exception('No user returned after sign up');
      }
      
      // 2. Create user profile in the database
      await _createUserProfile(
        userId: response.user!.id,
        email: email,
        username: username,
        fullName: fullName,
      );
      
      if (response.session != null) {
        // User is signed in (email confirmation not required)
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
  
  /// Creates a user profile in the database
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String username,
    String? fullName,
  }) async {
    try {
      Logger.d('Creating profile for user: $userId');
      
      // Get the user profile repository
      final profileRepo = _ref.read(userProfileRepositoryProvider);
      
      // Create the user profile
      await profileRepo.createProfile(
        userId: userId,
        username: username,
        bio: fullName != null ? 'Hello! I\'m $fullName' : 'New Rivo user',
        avatarUrl: null, // Will use default avatar
      );
      
      Logger.d('Successfully created profile for user: $userId');
    } catch (e, stackTrace) {
      Logger.e('Error creating user profile: $e', stackTrace);
      // If profile creation fails, we should clean up the auth user
      try {
        await _supabase.auth.admin.deleteUser(userId);
      } catch (deleteError, stackTrace) {
        Logger.e(
          deleteError,
          stackTrace,
        );
      }
      rethrow;
    }
  }

  /// Signs in with Google
  Future<void> signInWithGoogle() async {
    final notifier = _ref.read(authStateProvider.notifier);
    try {
      notifier.setLoading();
      
      // Trigger Google authentication
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was canceled');
      }
      
      // Get the authentication details
      final googleAuth = await googleUser.authentication;
      
      // Sign in to Supabase with Google
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );
      
      if (response.user == null) {
        throw Exception('No user returned after Google sign in');
      }
      
      // Generate a username from the email (remove @domain.com and replace special chars)
      final usernameBase = response.user!.email?.split('@').first ?? 'user';
      var username = usernameBase.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      
      // Make sure username is unique
      var isUsernameAvailable = await _profileRepository.isUsernameAvailable(username);
          
      var suffix = 1;
      var tempUsername = username;
      while (!isUsernameAvailable) {
        tempUsername = '${username}_$suffix';
        isUsernameAvailable = await _profileRepository.isUsernameAvailable(tempUsername);
        suffix++;
      }
      username = tempUsername;
      
      // Update user metadata with Google profile info and create profile if it doesn't exist
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': googleUser.displayName ?? username,
            'username': username,
            'avatar_url': googleUser.photoUrl,
          },
        ),
      );
      
      try {
        await _createUserProfile(
          userId: response.user!.id,
          email: response.user!.email!,
          username: username,
          fullName: googleUser.displayName ?? username,
        );
      } catch (e) {
        log('Error creating profile during Google sign in', error: e);
        // Continue even if profile creation fails, as it might already exist
      }
      
      notifier.setAuthenticated(response.user);
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
