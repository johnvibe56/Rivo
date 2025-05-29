import 'dart:async';
import 'dart:io';

import 'package:rivo/core/error/exceptions.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/user_profile/data/datasources/user_profile_remote_data_source.dart';
import 'package:rivo/features/user_profile/domain/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show 
    PostgrestException, 
    SupabaseClient;

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
      throw ServerException(e.message, StackTrace.current);
    } catch (e, stackTrace) {
      Logger.e('Error fetching user products: $e', stackTrace);
      throw ServerException(e.toString(), StackTrace.current);
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
        throw const ServerException('Username is already taken', StackTrace.empty);
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
      final error = 'Database error: ${e.message}';
      Logger.e(error, stackTrace);
      throw ServerException(error, stackTrace);
    } on Exception catch (e, stackTrace) {
      final error = 'Failed to create profile: $e';
      Logger.e(error, stackTrace);
      throw ServerException(error, stackTrace);
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
      final error = 'Database error: ${e.message}';
      Logger.e(error, stackTrace);
      throw ServerException(error, stackTrace);
    } on Exception catch (e, stackTrace) {
      final error = 'Failed to check username availability: $e';
      Logger.e(error, stackTrace);
      throw ServerException(error, stackTrace);
    }
  }

  @override
  Future<Profile> getCurrentUserProfile() async {
    try {
      Logger.d('🔍 [UserProfileRemoteDataSource] Getting current user from auth...');
      final user = _supabaseClient.auth.currentUser;
      
      if (user == null) {
        const error = 'No authenticated user found';
        Logger.e('❌ [UserProfileRemoteDataSource] $error', StackTrace.current);
        throw ServerException(error, StackTrace.current);
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
        throw ServerException(error, StackTrace.current);
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
        Logger.e('❌ [UserProfileRemoteDataSource] $error\n   - Raw data: $response', stackTrace);
        throw ServerException(error, stackTrace);
      }
      
    } on PostgrestException catch (e, stackTrace) {
      final error = 'Database error: ${e.message}';
      Logger.e('❌ [UserProfileRemoteDataSource] $error\n   - Details: ${e.details}\n   - Hint: ${e.hint}\n   - Code: ${e.code}', stackTrace);
      throw ServerException(error, stackTrace);
      
    } on ServerException {
      rethrow;
      
    } catch (e, stackTrace) {
      final error = 'Unexpected error: ${e.toString()}';
      Logger.e('❌ [UserProfileRemoteDataSource] $error', stackTrace);
      throw ServerException('Failed to get user profile', StackTrace.current);
    }
  }

  @override
  Future<void> updateProfile({
    required String username,
    String? bio,
    String? avatarUrl,
  }) async {
    Logger.d('[remoteDataSource.updateProfile] Called with username: $username, avatarUrl: $avatarUrl');
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        Logger.e('[remoteDataSource.updateProfile] User not authenticated', StackTrace.current);
        throw const ServerException('User not authenticated', StackTrace.empty);
      }

      Logger.d('[remoteDataSource.updateProfile] Updating profile for user: $userId');
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
      Logger.d('[remoteDataSource.updateProfile] Data to update: $data');
      await _supabaseClient
          .from('profiles')
          .update(data)
          .eq('id', userId);
      Logger.d('[remoteDataSource.updateProfile] Successfully updated profile');
    } on PostgrestException catch (e, stackTrace) {
      final error = '[remoteDataSource.updateProfile] Database error: ${e.message}';
      Logger.e(error, stackTrace);
      throw ServerException(error, stackTrace);
    } on Exception catch (e, stackTrace) {
      final error = '[remoteDataSource.updateProfile] Failed to update profile: $e';
      Logger.e(error, stackTrace);
      throw ServerException(error, stackTrace);
    }
  }

  @override
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw ServerException('User not authenticated', StackTrace.current);
      }

      Logger.d('📤 [UserProfile] Starting profile image upload for user: $userId');
      
      // Generate a unique filename for the image
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'profiles/$userId/$fileName';
      
      Logger.d('🔄 [UserProfile] Uploading file to path: $filePath');
      final response = await _supabaseClient.storage.from('avatars').upload(filePath, imageFile);
      Logger.d('[remoteDataSource.uploadProfileImage] File uploaded. Getting public URL...');
      final publicUrl = _supabaseClient.storage.from('avatars').getPublicUrl(filePath);
      Logger.d('[remoteDataSource.uploadProfileImage] Public URL: $publicUrl');
      return publicUrl;
    } on PostgrestException catch (e, stackTrace) {
      final error = '[remoteDataSource.uploadProfileImage] Database error: ${e.message}';
      Logger.e(error, stackTrace);
      throw ServerException(error, stackTrace);
    } on Exception catch (e, stackTrace) {
      final error = '[remoteDataSource.uploadProfileImage] Failed to upload profile image: $e';
      Logger.e(error, stackTrace);
      throw ServerException(error, stackTrace);
    }
  }
}
