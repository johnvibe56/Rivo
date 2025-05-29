import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/products/domain/models/product_model.dart';
import 'package:rivo/features/user_profile/data/datasources/user_profile_remote_data_source_impl.dart';
import 'package:rivo/features/user_profile/data/repositories/user_profile_repository_impl.dart';
import 'package:rivo/features/user_profile/domain/models/profile_model.dart';
import 'package:rivo/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Remote Data Source
final userProfileRemoteDataSourceProvider = Provider<UserProfileRemoteDataSourceImpl>((ref) {
  final supabase = Supabase.instance.client;
  return UserProfileRemoteDataSourceImpl(supabaseClient: supabase);
});

// Repository
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final remoteDataSource = ref.watch(userProfileRemoteDataSourceProvider);
  return UserProfileRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Notifier
class UserProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final UserProfileRepository _repository;
  bool _isLoading = false;
  
  UserProductsNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadUserProducts(String userId, {bool forceRefresh = false}) async {
    Logger.d('loadUserProducts called (forceRefresh: $forceRefresh)');
    
    // If we're already loading, skip unless it's a forced refresh
    if (_isLoading && !forceRefresh) {
      Logger.d('Already loading, skipping');
      return;
    }
    
    // If we have data and it's not a forced refresh, skip
    if (state.hasValue && state.value!.isNotEmpty && !forceRefresh) {
      Logger.d('Already have products, skipping');
      return;
    }
    
    try {
      _isLoading = true;
      Logger.d('Loading products for user: $userId');
      
      // Only show loading state if we don't have data yet
      if (!state.hasValue || state.value!.isEmpty) {
        state = const AsyncValue.loading();
      }
      
      final products = await _repository.getUserProducts(userId);
      Logger.d('Successfully loaded ${products.length} products');
      state = AsyncValue.data(products);
    } catch (e, stackTrace) {
      Logger.e('Error loading products: $e', stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  // No need to override anything here
  // We'll let the StateNotifier handle the state updates
}

// Provider
final userProductsProvider = StateNotifierProvider<UserProductsNotifier, AsyncValue<List<Product>>>((ref) {
  final repository = ref.watch(userProfileRepositoryProvider);
  return UserProductsNotifier(repository);
});

/// Provider to fetch the current user's profile from the DB (including avatarUrl)
final currentUserProfileProvider = FutureProvider<Profile>((ref) async {
  final repository = ref.watch(userProfileRepositoryProvider);
  return repository.getCurrentUserProfile();
});
