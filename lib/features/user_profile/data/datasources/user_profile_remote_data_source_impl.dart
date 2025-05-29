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
  Future<Profile> getUserProfile(String userId) async {
    Logger.d('🔍 [getUserProfile] Fetching profile for user: $userId');
    
    try {
      // First try to get the profile
      final response = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
          
      if (response != null) {
        Logger.d('✅ [getUserProfile] Profile found for user: $userId');
        final Map<String, dynamic> profileData = Map<String, dynamic>.from(response);
        return Profile.fromJson(profileData);
      }
      
      // If we get here, profile doesn't exist - create a default one using RPC
      Logger.d('ℹ️ [getUserProfile] Profile not found, creating default via RPC for user: $userId');
      try {
        final defaultUsername = 'user_${userId.substring(0, 8)}';
        final response = await createProfileViaRpc(
          userId: userId,
          username: defaultUsername,
        );
        
        Logger.d('✅ [getUserProfile] Default profile created successfully via RPC');
        return Profile.fromJson(response);
      } catch (createError, createStack) {
        final error = 'Failed to create default profile via RPC: $createError';
        Logger.e('❌ [getUserProfile] $error', createStack);
        throw ServerException(error, createStack);
      }
    } on PostgrestException catch (e, stackTrace) {
      final error = 'Database error: ${e.message}';
      Logger.e('❌ [getUserProfile] $error', stackTrace);
      throw ServerException(error, stackTrace);
    } on ServerException {
      rethrow; // Re-throw ServerException as is
    } catch (e, stackTrace) {
      final error = 'Unexpected error getting user profile: $e';
      Logger.e('❌ [getUserProfile] $error', stackTrace);
      throw ServerException(error, stackTrace);
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
    Logger.d('🔍 [getCurrentUserProfile] Getting current user from auth...');
    final user = _supabaseClient.auth.currentUser;
    
    if (user == null) {
      const error = 'No authenticated user found';
      Logger.e('❌ [getCurrentUserProfile] $error', StackTrace.current);
      throw ServerException(error, StackTrace.current);
    }
    
    Logger.d('👤 [getCurrentUserProfile] Current auth user ID: ${user.id}');
    Logger.d('📡 [getCurrentUserProfile] Fetching profile from Supabase...');
    
    try {
      // First try to get the profile
      final response = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      if (response != null) {
        Logger.d('✅ [getCurrentUserProfile] Profile found for user: ${user.id}');
        Logger.d('   - Username: ${response['username']}');
        Logger.d('   - Bio: ${response['bio'] ?? 'N/A'}');
        Logger.d('   - Avatar URL: ${response['avatar_url'] ?? 'N/A'}');
        
        try {
          final profile = Profile.fromJson(response);
          Logger.d('✅ [getCurrentUserProfile] Successfully parsed profile');
          return profile;
        } catch (e, stackTrace) {
          final error = 'Failed to parse profile data: $e';
          Logger.e('❌ [getCurrentUserProfile] $error', stackTrace);
          throw ServerException(error, stackTrace);
        }
      }
      
      // If we get here, profile doesn't exist - create a default one using RPC
      Logger.d('ℹ️ [getCurrentUserProfile] Profile not found, creating default via RPC for user: ${user.id}');
      try {
        final defaultUsername = 'user_${user.id.substring(0, 8)}';
        final response = await createProfileViaRpc(
          userId: user.id,
          username: defaultUsername,
        );
        
        Logger.d('✅ [getCurrentUserProfile] Default profile created successfully via RPC');
        return Profile.fromJson(response);
      } catch (createError, createStack) {
        final error = 'Failed to create default profile via RPC: $createError';
        Logger.e('❌ [getCurrentUserProfile] $error', createStack);
        throw ServerException(error, createStack);
      }
    } on PostgrestException catch (e, stackTrace) {
      final error = 'Database error: ${e.message}';
      Logger.e('❌ [getCurrentUserProfile] $error', stackTrace);
      throw ServerException(error, stackTrace);
    } catch (e, stackTrace) {
      final error = 'Unexpected error getting current user profile: $e';
      Logger.e('❌ [getCurrentUserProfile] $error', stackTrace);
      throw ServerException(error, stackTrace);
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
  Future<Map<String, dynamic>> createProfileViaRpc({
    required String userId,
    required String username,
  }) async {
    try {
      Logger.d('🔄 [createProfileViaRpc] Creating profile via RPC for user: $userId');
      
      final response = await _supabaseClient.rpc(
        'handle_new_profile',
        params: {
          'p_user_id': userId,
          'p_username': username,
        },
      );
      
      Logger.d('✅ [createProfileViaRpc] Profile created successfully');
      return response as Map<String, dynamic>;
    } on PostgrestException catch (e, stackTrace) {
      final error = 'Database error: ${e.message}';
      Logger.e('❌ [createProfileViaRpc] $error', stackTrace);
      throw ServerException(error, stackTrace);
    } catch (e, stackTrace) {
      final error = 'Unexpected error creating profile via RPC: $e';
      Logger.e('❌ [createProfileViaRpc] $error', stackTrace);
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
      
      Logger.d('Uploading profile image to path: $filePath');
 await _supabaseClient.storage
          .from('avatars')
          .upload(filePath, imageFile);
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
