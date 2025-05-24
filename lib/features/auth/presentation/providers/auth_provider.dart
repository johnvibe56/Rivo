import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map((event) {
    return event.session?.user;
  });
});

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});

class AuthController {
  final _supabase = Supabase.instance.client;

  /// Signs in a user with email and password
  /// 
  /// [email] The user's email address
  /// [password] The user's password
  /// 
  /// Throws an [AuthException] if sign in fails
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthException(
        'Failed to sign in: ${e.message}',
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Signs up a new user with email and password
  /// 
  /// [email] The user's email address
  /// [password] The user's password
  /// [userMetadata] Optional metadata to store with the user
  /// 
  /// Throws an [AuthException] if sign up fails
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? userMetadata,
  }) async {
    try {
      return await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: userMetadata,
        emailRedirectTo: 'io.supabase.rivo://signup-callback',
      );
    } on AuthException catch (e) {
      throw AuthException(
        'Failed to sign up: ${e.message}',
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  
  /// Signs in a user with Google OAuth
  /// 
  /// Throws an [AuthException] if sign in fails
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Use the OAuth flow for both web and mobile
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        authScreenLaunchMode: LaunchMode.externalApplication,
        redirectTo: 'io.supabase.rivo://login-callback',
      );
      
      // The actual session will be handled by the auth state listener
      // Return the current session and user
      return AuthResponse(
        session: _supabase.auth.currentSession,
        user: _supabase.auth.currentUser,
      );
    } on AuthException catch (e) {
      throw AuthException(
        'Failed to sign in with Google: ${e.message}',
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw Exception('An unexpected error occurred during Google sign in: $e');
    }
  }

  /// Signs out the current user
  /// 
  /// Throws an exception if sign out fails
  Future<void> signOut() async {
    try {
      // Sign out from Google if the user signed in with Google
      if (await GoogleSignIn().isSignedIn()) {
        await GoogleSignIn().signOut();
      }
      
      // Sign out from Supabase
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw AuthException(
        'Failed to sign out: ${e.message}',
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw Exception('An unexpected error occurred during sign out: $e');
    }
  }

  User? get currentUser => _supabase.auth.currentUser;

  /// Sends a password reset email to the specified email address
  /// 
  /// [email] The email address to send the password reset email to
  /// 
  /// Throws an exception if the password reset email could not be sent
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.rivo://reset-password', // This should match your deep link setup
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Updates the user's password
  /// 
  /// [newPassword] The new password to set
  /// 
  /// Throws an exception if the password could not be updated
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      rethrow;
    }
  }
}
