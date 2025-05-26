import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/wishlist/data/datasources/wishlist_remote_data_source.dart';
import 'package:rivo/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:rivo/features/wishlist/domain/repositories/wishlist_repository.dart';

// Providers
final wishlistRemoteDataSourceProvider = Provider<WishlistRemoteDataSource>((ref) {
  return WishlistRemoteDataSource();
});

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final remoteDataSource = ref.watch(wishlistRemoteDataSourceProvider);
  return WishlistRepositoryImpl(remoteDataSource);
});

// State Notifier for managing wishlist state
class WishlistNotifier extends StateNotifier<AsyncValue<Set<String>>> {
  static const String _tag = 'WishlistNotifier';
  final WishlistRepository _repository;
  final String userId;
  bool _mounted = true;
  
  WishlistNotifier(this._repository, this.userId) : super(const AsyncValue.loading());

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
  
  @override
  bool get mounted => _mounted;
  
  // Helper to safely update state only if the notifier is still mounted
  void _safeUpdateState(AsyncValue<Set<String>> newState) {
    if (_mounted) {
      state = newState;
    }
  }

  // Initialize with user's wishlisted product IDs
  Future<void> initialize() async {
    if (!_mounted) return;
    _safeUpdateState(const AsyncValue.loading());
    try {
      final result = await _repository.getWishlistedProductIds(userId);
      if (!_mounted) return;
      
      result.fold(
        (failure) => _safeUpdateState(AsyncValue.error(failure, StackTrace.current)),
        (productIds) => _safeUpdateState(AsyncValue.data(Set<String>.from(productIds))),
      );
    } catch (e, stackTrace) {
      if (!_mounted) return;
      _safeUpdateState(AsyncValue.error(e, stackTrace));
    }
  }

  // Toggle wishlist status for a product
  Future<void> toggleWishlist(String productId, String userId) async {
    Logger.d('toggleWishlist called for productId: $productId, userId: $userId', tag: _tag);
    if (!_mounted) return;
    
    // Create a new state update function that will be scheduled after the build
    void updateState(Set<String> newWishlist) {
      if (!_mounted) return;
      _safeUpdateState(AsyncValue.data(Set<String>.from(newWishlist)));
    }
    
    // Helper function to handle state updates safely
    void safeUpdate(Set<String> newWishlist) {
      if (!_mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_mounted) updateState(newWishlist);
      });
    }
    
    try {
      // Get current state
      final currentState = state;
      if (currentState is! AsyncData<Set<String>>) {
        Logger.e('Invalid state: $currentState', StackTrace.current, tag: _tag);
        throw StateError('Invalid state: $currentState');
      }
      
      final wishlist = Set<String>.from(currentState.value);
      final isInWishlist = wishlist.contains(productId);
      
      Logger.d('Current wishlist before update: ${wishlist.toList()}', tag: _tag);
      Logger.d('Product is currently ${isInWishlist ? 'in' : 'not in'} wishlist', tag: _tag);
      
      // Update UI immediately
      final updatedWishlist = Set<String>.from(wishlist);
      if (isInWishlist) {
        updatedWishlist.remove(productId);
        Logger.d('Removed product from wishlist', tag: _tag);
      } else {
        updatedWishlist.add(productId);
        Logger.d('Added product to wishlist', tag: _tag);
      }
      Logger.d('New wishlist after local update: ${updatedWishlist.toList()}', tag: _tag);
      
      // Update state safely after the build phase
      safeUpdate(updatedWishlist);

      // Sync with server
      Logger.d('Syncing with server...', tag: _tag);
      final result = await _repository.toggleWishlistItem(productId, userId);
      
      await result.fold(
        (failure) async {
          Logger.e('Server sync failed: ${failure.message}', StackTrace.current, tag: _tag);
          // Revert on failure
          final revertedWishlist = Set<String>.from(updatedWishlist);
          if (isInWishlist) {
            revertedWishlist.add(productId);
            Logger.d('Reverted: Added product back to wishlist', tag: _tag);
          } else {
            revertedWishlist.remove(productId);
            Logger.d('Reverted: Removed product from wishlist', tag: _tag);
          }
          
          // Update state safely after the build phase
          safeUpdate(revertedWishlist);
          
          Logger.d('Wishlist after revert: ${revertedWishlist.toList()}', tag: _tag);
          throw failure;
        },
        (_) async {
          Logger.d('Server sync completed successfully', tag: _tag);
          Logger.d('Final wishlist state: ${updatedWishlist.toList()}', tag: _tag);
          return null; // Success - no need to update state again
        },
      );
    } catch (e, stackTrace) {
      Logger.e('Failed to toggle wishlist: $e', stackTrace, tag: _tag);
      rethrow;
    }
  }

  // Check if a product is in the wishlist
  bool isProductInWishlist(String productId) {
    final currentState = state;
    if (currentState is AsyncData<Set<String>>) {
      return currentState.value.contains(productId);
    }
    return false;
  }
}

// Provider for the wishlist notifier
final wishlistNotifierProvider = StateNotifierProvider.family<WishlistNotifier, AsyncValue<Set<String>>, String>(
  (ref, userId) {
    final repository = ref.watch(wishlistRepositoryProvider);
    final notifier = WishlistNotifier(repository, userId)..initialize();
    // Add a listener to dispose the notifier when the provider is disposed
    ref.onDispose(() => notifier.dispose());
    return notifier;
  },
);
