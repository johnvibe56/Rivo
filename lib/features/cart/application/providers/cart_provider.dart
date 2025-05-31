import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:rivo/features/cart/domain/models/cart_item_model.dart';
import 'package:rivo/features/cart/domain/repositories/cart_repository.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(CartItem item) {
    final index = state.indexWhere((cartItem) => cartItem.productId == item.productId);
    
    if (index >= 0) {
      // Item exists, update quantity
      state = [
        for (final cartItem in state)
          if (cartItem.productId == item.productId)
            cartItem.copyWith(quantity: cartItem.quantity + 1)
          else
            cartItem,
      ];
    } else {
      // Add new item
      state = [...state, item];
    }
  }

  void removeFromCart(String productId) {
    state = state.where((item) => item.productId != productId).toList();
  }

  void clear() {
    state = [];
  }
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(ref);
});

final cartItemsProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartItemsProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});

final cartTotalPriceProvider = Provider<double>((ref) {
  final items = ref.watch(cartItemsProvider);
  return items.fold(0.0, (sum, item) => sum + (item.productPrice * item.quantity));
});
