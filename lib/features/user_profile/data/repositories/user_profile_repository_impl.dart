import 'dart:io';

import 'package:rivo/core/error/failures.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/user_profile/domain/models/profile_model.dart';
import 'package:rivo/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:rivo/features/user_profile/data/datasources/user_profile_remote_data_source.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;

  UserProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Product>> getUserProducts(String userId) async {
    try {
      Logger.d('Getting products for user: $userId');
      final products = await remoteDataSource.getUserProducts(userId);
      Logger.d('Successfully retrieved ${products.length} products');
      return products;
    } catch (e, stackTrace) {
      Logger.e('Error getting user products: $e', stackTrace);
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Profile> createProfile({
    required String userId,
    required String username,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      Logger.d('Creating profile for user: $userId with username: $username');
      final profile = await remoteDataSource.createProfile(
        userId: userId,
        username: username,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      Logger.d('Successfully created profile for user: $userId');
      return profile;
    } catch (e, stackTrace) {
      Logger.e('Error creating user profile: $e', stackTrace);
      throw ServerFailure('Failed to create user profile: ${e.toString()}');
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    try {
      Logger.d('Checking if username is available: $username');
      final isAvailable = await remoteDataSource.isUsernameAvailable(username);
      Logger.d('Username availability for $username: $isAvailable');
      return isAvailable;
    } catch (e, stackTrace) {
      Logger.e('Error checking username availability: $e', stackTrace);
      // If there's an error, assume username is not available to be safe
      return false;
    }
  }

  @override
  Future<Profile> getCurrentUserProfile() async {
    try {
      Logger.d('Getting current user profile');
      final profile = await remoteDataSource.getCurrentUserProfile();
      Logger.d('Successfully retrieved current user profile');
      return profile;
    } catch (e, stackTrace) {
      Logger.e('Error getting current user profile: $e', stackTrace);
      throw ServerFailure('Failed to get user profile: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProfile({
    required String username,
    String? bio,
    File? imageFile,
  }) async {
    try {
      Logger.d('Updating profile with username: $username');
      String? imageUrl;
      
      if (imageFile != null) {
        imageUrl = await uploadProfileImage(imageFile);
      }
      
      await remoteDataSource.updateProfile(
        username: username,
        bio: bio,
        avatarUrl: imageUrl,
      );
      
      Logger.d('Successfully updated profile');
    } catch (e, stackTrace) {
      Logger.e('Error updating profile: $e', stackTrace);
      throw ServerFailure('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      Logger.d('Uploading profile image');
      final imageUrl = await remoteDataSource.uploadProfileImage(imageFile);
      Logger.d('Successfully uploaded profile image');
      return imageUrl;
    } catch (e, stackTrace) {
      Logger.e('Error uploading profile image: $e', stackTrace);
      throw ServerFailure('Failed to upload profile image: ${e.toString()}');
    }
  }
}
