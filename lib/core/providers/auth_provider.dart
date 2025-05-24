import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider that exposes the current auth state
final authStateProvider = StreamProvider<AuthState>((ref) {
  // Get the auth state changes stream from Supabase
  final authStateChanges = Supabase.instance.client.auth.onAuthStateChange;
  
  return authStateChanges.map((event) => event);
});

/// Provider that exposes the current session
final sessionProvider = Provider<Session?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.session;
});

/// Provider that exposes the current user
final currentUserProvider = Provider<User?>((ref) {
  final session = ref.watch(sessionProvider);
  return session?.user;
});

/// Provider that checks if the user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});
