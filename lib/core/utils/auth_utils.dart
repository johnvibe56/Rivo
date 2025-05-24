import 'package:supabase_flutter/supabase_flutter.dart';

/// A utility class for handling authentication-related operations.
class AuthUtils {
  /// Private constructor to prevent instantiation
  AuthUtils._();

  /// Checks if the current user is authenticated
  /// 
  /// Returns `true` if the user is logged in, `false` otherwise
  static bool isAuthenticated() {
    final session = Supabase.instance.client.auth.currentSession;
    return session != null;
  }

  /// Gets the current user's ID if authenticated
  /// 
  /// Returns the user's UUID if authenticated, `null` otherwise
  static String? getCurrentUserId() {
    return Supabase.instance.client.auth.currentUser?.id;
  }

  /// Gets the current user's email if authenticated
  /// 
  /// Returns the user's email if authenticated, `null` otherwise
  static String? getCurrentUserEmail() {
    return Supabase.instance.client.auth.currentUser?.email;
  }

  /// Gets the current user's display name if available
  /// 
  /// Returns the user's display name if available, otherwise returns email
  static String? getCurrentUserDisplayName() {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.userMetadata?['full_name'] ?? user?.email;
  }

  /// Checks if the current user has a specific role
  /// 
  /// [role] - The role to check against
  /// Returns `true` if the user has the specified role, `false` otherwise
  static Future<bool> hasRole(String role) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    // Example: Check user role from user_metadata or a separate profiles table
    // This is a basic implementation - adjust according to your auth setup
    final userData = user.userMetadata;
    return userData?['role'] == role;
  }
}
