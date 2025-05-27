import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/features/products/presentation/providers/product_providers.dart';
import 'package:rivo/features/products/presentation/providers/product_repository_provider.dart';

// Provider to track deleted product IDs
final deletedProductsProvider = StateNotifierProvider<DeletedProductsNotifier, Set<String>>(
  (ref) => DeletedProductsNotifier(),
);

class DeletedProductsNotifier extends StateNotifier<Set<String>> {
  DeletedProductsNotifier() : super(<String>{});

  void addDeletedProduct(String productId) {
    state = {...state, productId};
  }

  bool isDeleted(String productId) => state.contains(productId);
}

// State for delete product operation
@immutable
class DeleteProductState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final String? productId;

  const DeleteProductState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.productId,
  });

  DeleteProductState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    String? productId,
  }) {
    return DeleteProductState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      productId: productId ?? this.productId,
    );
  }
}

class DeleteProductNotifier extends StateNotifier<DeleteProductState> {
  DeleteProductNotifier(this.ref) : super(const DeleteProductState());
  
  final Ref ref;
  final Set<String> _deletedProductIds = {};
  final Set<String> _pendingDeletions = {};
  
  /// Checks if a product is marked as deleted
  bool isProductDeleted(String productId) => _deletedProductIds.contains(productId);
  
  /// Checks if a product is currently being deleted
  bool isDeleting(String productId) => _pendingDeletions.contains(productId);
  
  /// Deletes a product and manages the deletion state
  Future<bool> deleteProduct(String productId) async {
    if (state.isLoading || ref.read(deletedProductsProvider).contains(productId)) {
      return false;
    }
    
    // Mark the product as deleted immediately
    ref.read(deletedProductsProvider.notifier).addDeletedProduct(productId);
    
    // Prevent duplicate deletion attempts
    if (_pendingDeletions.contains(productId)) {
      debugPrint('⚠️ [DeleteProductNotifier] Product $productId is already being deleted');
      return false;
    }
    
    try {
      _pendingDeletions.add(productId);
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
        productId: productId,
      );
      
      final productRepository = ref.read(productRepositoryRefProvider);
      final result = await productRepository.deleteProduct(productId);
      
      return await result.fold(
        (failure) async {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            successMessage: null,
          );
          _pendingDeletions.remove(productId);
          return false;
        },
        (_) async {
          _deletedProductIds.add(productId);
          _pendingDeletions.remove(productId);
          
          // Invalidate relevant providers to refresh the UI
          ref.invalidate(productListNotifierProvider);
          ref.invalidate(productNotifierProvider(productId));
          
          // Invalidate wishlist provider to ensure UI updates
          // The wishlistNotifierProvider is a family provider, so we need to invalidate all instances
          // or handle invalidation at the consumer level
          debugPrint('🔄 [DeleteProductNotifier] Product deleted, UI refresh should handle wishlist updates');
          
          // Note: The wishlistNotifierProvider is a family provider that requires a userId
          // The actual invalidation should be handled by the UI components that consume the wishlist
          // by listening to the product list changes and refreshing their state accordingly
          
          state = state.copyWith(
            isLoading: false,
            successMessage: 'Product deleted successfully',
            errorMessage: null,
            productId: null,
          );
          
          // Clear success message after a delay
          await Future<void>.delayed(const Duration(seconds: 3));
          if (state.productId == null) {  // Only clear if no new operation started
            state = state.copyWith(successMessage: null);
          }
          
          return true;
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [DeleteProductNotifier] Error deleting product: $e');
      debugPrint('Stack trace: $stackTrace');
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred while deleting the product',
        successMessage: null,
      );
      _pendingDeletions.remove(productId);
      
      // Clear error after a delay
      _clearErrorAfterDelay();
      
      return false;
    }
  }
  
  /// Clears any error message after a delay
  void _clearErrorAfterDelay() async {
    await Future<void>.delayed(const Duration(seconds: 5));
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
  
  /// Resets the state to initial values
  void reset() {
    state = const DeleteProductState();
    _pendingDeletions.clear();
  }
  
  /// Clears any error message
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
  
  /// Clears any success message
  void clearSuccess() {
    if (state.successMessage != null) {
      state = state.copyWith(successMessage: null);
    }
  }
}

// Provider for the DeleteProductNotifier
final deleteProductNotifierProvider = StateNotifierProvider<DeleteProductNotifier, DeleteProductState>((ref) {
  return DeleteProductNotifier(ref);
});

// Provider for the delete product function
Future<bool> deleteProductFunction(Ref ref, String productId) async {
  try {
    final notifier = ref.read(deleteProductNotifierProvider.notifier);
    return await notifier.deleteProduct(productId);
  } catch (e, stackTrace) {
    debugPrint('❌ [DeleteProductFunction] Error: $e');
    debugPrint('❌ [DeleteProductFunction] Stack trace: $stackTrace');
    rethrow;
  }
}

/// Provider for the delete product function
final deleteProductFunctionProvider = FutureProvider.family<bool, String>((ref, productId) async {
  return deleteProductFunction(ref, productId);
});

/// Provider to check if a specific product is being deleted
final isDeletingProductProvider = Provider.family<bool, String>((ref, productId) {
  final state = ref.watch(deleteProductNotifierProvider);
  return state.isLoading && state.productId == productId;
});

/// Provider to check if a product has been deleted
final isProductDeletedProvider = Provider.family<bool, String>((ref, productId) {
  final notifier = ref.read(deleteProductNotifierProvider.notifier);
  return notifier.isProductDeleted(productId);
});
