import 'package:rivo/core/error/result.dart';
import 'package:rivo/core/error/failures.dart' as failures;
import 'package:rivo/core/network/network_info.dart';
import 'package:rivo/features/follow/domain/models/follow_model.dart';
import 'package:rivo/features/follow/domain/repositories/follow_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class FollowRepositoryImpl implements FollowRepository {
  final SupabaseClient supabaseClient;
  final NetworkInfo networkInfo;

  FollowRepositoryImpl({
    required this.supabaseClient,
    required this.networkInfo,
  });

  @override
  Future<Result<bool>> followSeller(String sellerId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Result<bool>.failure(failures.NoInternetFailure());
      }

      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return Result<bool>.failure(failures.UnauthenticatedFailure());
      }
      
      final currentUserId = currentUser.id;
      
      // Check if already following
      final followingStatus = await isFollowing(sellerId);
      
      return await followingStatus.when(
        success: (isFollowing) async {
          if (isFollowing) {
            return Result<bool>.success(true); // Already following
          }
          
          // Not following, so follow
          try {
            await supabaseClient.from('followers').insert({
              'follower_id': currentUserId,
              'seller_id': sellerId,
              'created_at': DateTime.now().toIso8601String(),
            }).select();
            
            return Result<bool>.success(true);
          } on PostgrestException catch (e) {
            if (e.code == '23505') { // Unique violation
              return Result<bool>.success(true); // Already following
            }
            rethrow;
          }
        },
        failure: (error) => Result<bool>.failure(error),
      );
    } on PostgrestException catch (e) {
      if (e.code == '23505') { // Unique violation
        return Result<bool>.success(true); // Already following
      }
      return Result<bool>.failure(failures.AppFailure('Database error: ${e.message}'));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error in followSeller: $e');
        print('Stack trace: $stackTrace');
      }
      return Result<bool>.failure(failures.AppFailure('Failed to follow seller'));
    }
  }

  @override
  Future<Result<bool>> unfollowSeller(String sellerId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Result<bool>.failure(failures.NoInternetFailure());
      }

      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return Result<bool>.failure(failures.UnauthenticatedFailure());
      }
      
      final currentUserId = currentUser.id;

      // Check if following
      final followingStatus = await isFollowing(sellerId);
      
      return await followingStatus.when(
        success: (isFollowingStatus) async {
          if (!isFollowingStatus) {
            return Result<bool>.success(true); // Already not following
          }
          
          // Unfollow
          try {
            await supabaseClient
                .from('followers')
                .delete()
                .eq('follower_id', currentUserId)
                .eq('seller_id', sellerId);
          } on PostgrestException {
            rethrow;
          }
          
          return Result<bool>.success(true);
        },
        failure: (error) => Result<bool>.failure(error),
      );
    } on PostgrestException catch (e) {
      return Result<bool>.failure(failures.AppFailure('Database error: ${e.message}'));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error in unfollowSeller: $e');
        print('Stack trace: $stackTrace');
      }
      return Result<bool>.failure(failures.AppFailure('Failed to unfollow seller'));
    }
  }

  @override
  Future<Result<bool>> isFollowing(String sellerId) async {
    if (!await networkInfo.isConnected) {
      return Result.failure(failures.NoInternetFailure());
    }

    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return Result.failure(failures.UnauthenticatedFailure());
      }
      final currentUserId = currentUser.id;

      final response = await supabaseClient
          .from('followers')
          .select('*')
          .eq('follower_id', currentUserId)
          .eq('seller_id', sellerId)
          .maybeSingle();

      return Result.success(response != null);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // No rows found
        return Result.success(false);
      }
      return Result.failure(failures.AppFailure('Database error'));
    } catch (e) {
      return Result.failure(failures.AppFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<String>>> getFollowedSellerIds() async {
    final result = await getFollows();
    return result.when(
      success: (follows) {
        final sellerIds = follows.map((f) => f.sellerId).toList();
        return Result.success(sellerIds);
      },
      failure: (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<List<Follow>>> getFollows() async {
    try {
      if (!await networkInfo.isConnected) {
        return Result<List<Follow>>.failure(failures.NoInternetFailure());
      }

      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return Result<List<Follow>>.failure(failures.UnauthenticatedFailure());
      }
      
      final response = await supabaseClient
          .from('followers')
          .select()
          .eq('follower_id', currentUser.id);
      
      final follows = response.map<Follow>((json) => Follow.fromJson(json)).toList();
      return Result<List<Follow>>.success(follows);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error in getFollows: $e');
        print('Stack trace: $stackTrace');
      }
      return Result<List<Follow>>.failure(
          failures.AppFailure('Failed to load follows'));
    }
  }
  
  @override
  Future<Result<int>> getFollowerCount(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Result<int>.failure(failures.NoInternetFailure());
      }
      
      final response = await supabaseClient
          .from('followers')
          .select()
          .eq('seller_id', userId);
          
      return Result<int>.success(response.length);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error in getFollowerCount: $e');
        print('Stack trace: $stackTrace');
      }
      return Result<int>.failure(
          failures.AppFailure('Failed to load follower count'));
    }
  }
  
  @override
  Future<Result<int>> getFollowingCount(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Result<int>.failure(failures.NoInternetFailure());
      }
      
      final response = await supabaseClient
          .from('followers')
          .select()
          .eq('follower_id', userId);
          
      return Result<int>.success(response.length);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error in getFollowingCount: $e');
        print('Stack trace: $stackTrace');
      }
      return Result<int>.failure(
          failures.AppFailure('Failed to load following count'));
    }
  }
}
