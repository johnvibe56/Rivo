import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/core/error/result.dart';
import 'package:rivo/core/network/network_info_provider.dart';
import 'package:rivo/features/follow/data/repositories/follow_repository_impl.dart';
import 'package:rivo/features/follow/domain/models/follow_model.dart';
import 'package:rivo/features/follow/domain/repositories/follow_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider for the FollowRepository
final followRepositoryProvider = Provider<FollowRepository>((ref) {
  final supabase = Supabase.instance.client;
  final networkInfo = ref.watch(networkInfoProvider);
  return FollowRepositoryImpl(
    supabaseClient: supabase,
    networkInfo: networkInfo,
  );
});

// Provider for checking follow status
final followStatusProvider = FutureProvider.family<Result<bool>, String>(
  (ref, String sellerId) async {
    try {
      final repository = ref.watch(followRepositoryProvider);
      return await repository.isFollowing(sellerId);
    } catch (e) {
      return Result.failure(AppFailure(
        message: 'Failed to check follow status',
        error: e,
      ));
    }
  },
);

// Provider for getting all followed seller IDs
final followedSellerIdsProvider = FutureProvider<Result<List<String>>>((ref) async {
  try {
    final repository = ref.watch(followRepositoryProvider);
    return await repository.getFollowedSellerIds();
  } catch (e) {
    return Result.failure(AppFailure(
      message: 'Failed to load followed sellers',
      error: e,
    ));
  }
});

// Provider for getting all follow relationships
final followsProvider = FutureProvider<Result<List<Follow>>>((ref) async {
  try {
    final repository = ref.watch(followRepositoryProvider);
    return await repository.getFollows();
  } catch (e) {
    return Result.failure(AppFailure(
      message: 'Failed to load follows',
      error: e,
    ));
  }
});

// Provider for toggling follow status
final toggleFollowProvider = FutureProvider.family<Result<bool>, String>(
  (ref, String sellerId) async {
    try {
      final repository = ref.read(followRepositoryProvider);
      
      // Invalidate the current follow status to force a refresh
      ref.invalidate(followStatusProvider(sellerId));
      
      // Get the current follow status
      final isFollowingResult = await repository.isFollowing(sellerId);
      
      return isFollowingResult.when(
        success: (isFollowing) async {
          // Perform the appropriate action based on current state
          final result = isFollowing 
              ? await repository.unfollowSeller(sellerId)
              : await repository.followSeller(sellerId);
              
          // Invalidate all relevant providers to refresh the UI
          ref.invalidate(followStatusProvider(sellerId));
          ref.invalidate(followsProvider);
          ref.invalidate(followedSellerIdsProvider);
          
          return result;
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(AppFailure(
        message: 'Failed to toggle follow status',
        error: e,
      ));
    }
  },
);

// Provider for getting follower count for a user
final followerCountProvider = FutureProvider.family<Result<int>, String>((ref, String userId) async {
  try {
    final repository = ref.watch(followRepositoryProvider);
    return await repository.getFollowerCount(userId);
  } catch (e) {
    return Result.failure(AppFailure(
      message: 'Failed to load follower count',
      error: e,
    ));
  }
});

// Provider for getting following count for a user
final followingCountProvider = FutureProvider.family<Result<int>, String>((ref, String userId) async {
  try {
    final repository = ref.watch(followRepositoryProvider);
    return await repository.getFollowingCount(userId);
  } catch (e) {
    return Result.failure(AppFailure(
      message: 'Failed to load following count',
      error: e,
    ));
  }
});

// Provider for checking if current user is following any sellers
final hasFollowedSellersProvider = FutureProvider<bool>((ref) async {
  final follows = await ref.watch(followsProvider.future);
  return follows.when(
    success: (follows) => follows.isNotEmpty,
    failure: (_) => false,
  );
});
