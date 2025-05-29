import 'package:rivo/core/error/result.dart';
import 'package:rivo/features/follow/domain/models/follow_model.dart';

abstract class FollowRepository {
  // Follow a seller
  Future<Result<bool>> followSeller(String sellerId);
  
  // Unfollow a seller
  Future<Result<bool>> unfollowSeller(String sellerId);
  
  // Check if current user is following a seller
  Future<Result<bool>> isFollowing(String sellerId);
  
  // Get list of seller IDs that the current user is following
  Future<Result<List<String>>> getFollowedSellerIds();
  
  // Get all follow relationships for the current user
  Future<Result<List<Follow>>> getFollows();
  
  // Get the number of followers for a user
  Future<Result<int>> getFollowerCount(String userId);
  
  // Get the number of users a user is following
  Future<Result<int>> getFollowingCount(String userId);
}
