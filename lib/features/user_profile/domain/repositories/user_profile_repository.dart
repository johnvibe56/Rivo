import 'dart:io';

import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/user_profile/domain/models/profile_model.dart';

abstract class UserProfileRepository {
  Future<List<Product>> getUserProducts(String userId);
  
  /// Creates a new user profile
  Future<Profile> createProfile({
    required String userId,
    required String username,
    String? bio,
    String? avatarUrl,
  });
  
  /// Checks if a username is available
  Future<bool> isUsernameAvailable(String username);
  
  /// Gets the current user's profile
  Future<Profile> getCurrentUserProfile();
  
  /// Gets a user's profile by ID
  Future<Profile> getUserProfile(String userId);
  
  /// Updates the current user's profile
  Future<void> updateProfile({
    required String username,
    String? bio,
    File? imageFile,
  });
  
  /// Uploads a profile image and returns the public URL
  Future<String> uploadProfileImage(File imageFile);
}
