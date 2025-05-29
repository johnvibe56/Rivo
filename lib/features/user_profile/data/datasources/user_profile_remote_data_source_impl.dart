import 'dart:async';
import 'dart:io';

import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/user_profile/data/datasources/user_profile_remote_data_source.dart';
import 'package:rivo/features/user_profile/domain/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final SupabaseClient _supabaseClient;

  UserProfileRemoteDataSourceImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<List<Product>> getUserProducts(String userId) async {
    try {
      Logger.d('Fetching products for user: $userId');
      
      final response = await _supabaseClient
          .from('products')
          .select('*')
          .eq('owner_id', userId)
          .order('created_at', ascending: false);
      
      Logger.d('Raw response received');
      
      final List<Product> products = [];
      for (final item in response) {
        try {
          final product = Product.fromJson(item);
          products.add(product);
        } catch (e, stackTrace) {
          Logger.e('Error parsing product: $e', stackTrace);
          continue;
        }
      }
      
      Logger.d('Successfully parsed ${products.length} products');
      return products;
    } on PostgrestException catch (e) {
      Logger.e('Postgrest error fetching user products: ${e.message}', StackTrace.current);
      throw ServerException(e.message);
    } catch (e, stackTrace) {
      Logger.e('Error fetching user products: $e', stackTrace);
      throw ServerException(e.toString());
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
      
      // First check if username is available
      final isAvailable = await isUsernameAvailable(username);
      if (!isAvailable) {
        throw const ServerException('Username is already taken');
      }
      
      final now = DateTime.now().toIso8601String();
      final response = await _supabaseClient
          .from('profiles')
          .insert({
            'id': userId,
            'username': username,
            'bio': bio ?? '',
            'avatar_url': avatarUrl,
            'created_at': now,
            'updated_at': now,
          })
          .select()
          .single();
      
      Logger.d('Profile created successfully');
      return Profile.fromJson(response);
    } on PostgrestException catch (e, stackTrace) {
      Logger.e(e, stackTrace);
      throw ServerException(e.message);
    } on Exception catch (e, stackTrace) {
      Logger.e(e, stackTrace);
      throw ServerException('Failed to create profile');
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    try {
      Logger.d('Checking if username is available: $username');
      
      if (username.isEmpty) return false;
      
      final response = await _supabaseClient
          .from('profiles')
          .select('id')
          .ilike('username', username)
          .limit(1);
      
      final isAvailable = response.isEmpty;
      Logger.d('Username $username available: $isAvailable');
      return isAvailable;
    } on PostgrestException catch (e, stackTrace) {
      Logger.e(e, stackTrace);
      throw ServerException(e.message);
    } on Exception catch (e, stackTrace) {
      Logger.e(e, stackTrace);
      throw ServerException('Failed to check username availability');
    }
  }

  @override
  Future<Profile> getCurrentUserProfile() async {
    try {
      Logger.d('🔍 [UserProfileRemoteDataSource] Getting current user from auth...');
      final user = _supabaseClient.auth.currentUser;
      
      if (user == null) {
        final error = 'No authenticated user found';
        Logger.e('❌ [UserProfileRemoteDataSource] $error', StackTrace.current);
        throw ServerException(error);
      }
      
      Logger.d('👤 [UserProfileRemoteDataSource] Current auth user ID: ${user.id}');
      Logger.d('📡 [UserProfileRemoteDataSource] Fetching profile from Supabase...');
      
      final response = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      if (response == null) {
        final error = 'Profile not found for user: ${user.id}. This usually means the user profile was not created during sign-up.';
        Logger.e('❌ [UserProfileRemoteDataSource] $error', StackTrace.current);
        throw ServerException(error);
      }
      
      Logger.d('✅ [UserProfileRemoteDataSource] Raw profile data received');
      Logger.d('   - ID: ${response['id']}');
      Logger.d('   - Username: ${response['username']}');
      Logger.d('   - Bio: ${response['bio'] ?? 'N/A'}');
      Logger.d('   - Avatar URL: ${response['avatar_url'] ?? 'N/A'}');
      
      try {
        final profile = Profile.fromJson(response);
        Logger.d('✅ [UserProfileRemoteDataSource] Successfully parsed profile: ${profile.id}');
        return profile;
      } catch (e, stackTrace) {
        final error = 'Failed to parse profile data: $e';
        Logger.e('❌ [UserProfileRemoteDataSource] $error', stackTrace);
        Logger.e('   - Raw data: $response');
        throw ServerException(error);
      }
      
    } on PostgrestException catch (e, stackTrace) {
      final error = 'Database error: ${e.message}';
      Logger.e('❌ [UserProfileRemoteDataSource] $error', stackTrace);
      Logger.e('   - Details: ${e.details}');
      Logger.e('   - Hint: ${e.hint}');
      Logger.e('   - Code: ${e.code}');
      throw ServerException(error);
      
    } on ServerException {
      rethrow;
      
    } catch (e, stackTrace) {
      final error = 'Unexpected error: ${e.toString()}';
      Logger.e('❌ [UserProfileRemoteDataSource] $error', stackTrace);
      throw ServerException('Failed to get user profile');
    }
  }

  @override
  Future<void> updateProfile({
    required String username,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerException('User not authenticated');
      }

      Logger.d('Updating profile for user: $userId');
      
      final data = {
        'username': username,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (bio != null) {
        data['bio'] = bio;
      }
      
      if (avatarUrl != null) {
        data['avatar_url'] = avatarUrl;
      }
      
      await _supabaseClient
          .from('profiles')
          .update(data)
          .eq('id', userId);
      
      Logger.d('Successfully updated profile');
    } on PostgrestException catch (e, stackTrace) {
      Logger.e(e, stackTrace);
      throw ServerException(e.message);
    } on Exception catch (e, stackTrace) {
      Logger.e(e, stackTrace);
      throw ServerException('Failed to update profile');
    }
  }

  @override
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerException('User not authenticated');
      }

      Logger.d('Uploading profile image for user: $userId');
      
      // Generate a unique filename for the image
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'profiles/$userId/$fileName';
      
      // Upload the file to Supabase Storage
      await _supabaseClient.storage
          .from('avatars')
          .upload(filePath, imageFile, fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ));
      
      // Get the public URL
      final response = _supabaseClient
          .storage
          .from('avatars')
          .getPublicUrl(filePath);
      
      Logger.d('Successfully uploaded profile image');
      return response;
    } on PostgrestException catch (e, stackTrace) {
      Logger.e(e, stackTrace);
      throw ServerException(e.message);
    } on Exception catch (e, stackTrace) {
      Logger.e(e, stackTrace);
      throw ServerException('Failed to upload profile image');
    }
  }
}
