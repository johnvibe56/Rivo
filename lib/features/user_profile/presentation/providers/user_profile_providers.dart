import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
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



/// Provider to fetch any user's profile from the DB (including avatarUrl)
final userProfileProvider = FutureProvider.family<Profile, String>((ref, userId) async {
  final repository = ref.watch(userProfileRepositoryProvider);
  try {
    if (userId == ref.read(authStateProvider).value?.user?.id) {
      return repository.getCurrentUserProfile();
    } else {
      return repository.getUserProfile(userId);
    }
  } catch (e, stackTrace) {
    Logger.e('Error in userProfileProvider: $e', stackTrace);
    rethrow;
  }
});

/// Alias for backward compatibility
final currentUserProfileProvider = userProfileProvider;

/// Provider for any user's products
final userProductsProvider = StateNotifierProvider.family<UserProductsNotifier, AsyncValue<List<Product>>, String>((ref, userId) {
  final repository = ref.watch(userProfileRepositoryProvider);
  return UserProductsNotifier(repository, userId);
});

/// Notifier for managing user products
class UserProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final UserProfileRepository _repository;
  final String _userId;
  bool _isLoading = false;
  
  UserProductsNotifier(this._repository, this._userId) : super(const AsyncValue.loading()) {
    loadUserProducts();
  }

  Future<void> loadUserProducts({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;
    
    try {
      _isLoading = true;
      if (!state.hasValue || state.value!.isEmpty) {
        state = const AsyncValue.loading();
      }
      
      final products = await _repository.getUserProducts(_userId);
      state = AsyncValue.data(products);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } finally {
      _isLoading = false;
    }
  }
}
