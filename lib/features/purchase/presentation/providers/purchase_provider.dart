import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/features/purchase/data/repositories/purchase_repository_impl.dart';
import 'package:rivo/features/purchase/domain/models/purchase_model.dart';
import 'package:rivo/features/purchase/domain/repositories/purchase_repository.dart';

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  return PurchaseRepositoryImpl();
});

final purchaseProductProvider = StateNotifierProvider.family<PurchaseNotifier, AsyncValue<PurchaseResult>, String>(
  (ref, productId) => PurchaseNotifier(
    ref.watch(purchaseRepositoryProvider),
    productId,
  ),
);

class PurchaseNotifier extends StateNotifier<AsyncValue<PurchaseResult>> {
  final PurchaseRepository _repository;
  final String productId;

  PurchaseNotifier(this._repository, this.productId) : super(const AsyncValue.loading()) {
    // Initialize with a default state
    state = AsyncValue.data(
      PurchaseResult(
        alreadyPurchased: false,
        errorMessage: 'No purchase attempted',
      ),
    );
  }

  Future<AsyncValue<PurchaseResult>> purchaseProduct() async {
    try {
      debugPrint('PurchaseNotifier - Starting purchase for product: $productId');
      state = const AsyncValue.loading();
      
      // Call the repository and get the result
      final result = await _repository.purchaseProduct(productId);
      
      // Log the result
      debugPrint('PurchaseNotifier - Purchase result: ${result.isSuccess}');
      if (result.isAlreadyPurchased) {
        debugPrint('Product was already purchased by this user');
      }
      
      // Update the state with the result
      state = AsyncValue.data(result);
      
      // Return the result wrapped in AsyncValue
      return state;
    } catch (e, stackTrace) {
      final errorMessage = 'Error during purchase: ${e.toString()}';
      debugPrint(errorMessage);
      debugPrint('Stack trace: $stackTrace');
      
      // Create a failure result with error details
      final errorResult = PurchaseResult.failure(errorMessage);
      
      // Update the state with the error
      state = AsyncValue.error(e, stackTrace);
      
      // Also return the error result
      return AsyncValue.data(errorResult);
    }
  }

  void reset() {
    state = AsyncValue.data(
      PurchaseResult(
        alreadyPurchased: false,
        errorMessage: 'No purchase attempted',
      ),
    );
  }
}

// Helper function to trigger a purchase
Future<PurchaseResult> triggerPurchase(WidgetRef ref, String productId) async {
  try {
    final notifier = ref.read(purchaseProductProvider(productId).notifier);
    final result = await notifier.purchaseProduct();
    
    return result.when(
      data: (purchaseResult) => purchaseResult,
      loading: () => PurchaseResult.failure('Purchase in progress'),
      error: (error, stack) => PurchaseResult.failure(error.toString()),
    );
  } catch (e) {
    return PurchaseResult.failure('Failed to process purchase: ${e.toString()}');
  }
}
