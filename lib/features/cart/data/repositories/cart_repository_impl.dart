import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/features/cart/application/providers/cart_provider.dart';
import 'package:rivo/features/cart/domain/models/cart_item_model.dart';
import 'package:rivo/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final Ref ref;
  
  CartRepositoryImpl(this.ref);

  @override
  Future<List<CartItem>> getCartItems() async {
    return ref.read(cartItemsProvider);
  }

  @override
  Future<void> addToCart(CartItem item) async {
    ref.read(cartItemsProvider.notifier).addItem(item);
  }

  @override
  Future<void> removeFromCart(String productId) async {
    ref.read(cartItemsProvider.notifier).removeFromCart(productId);
  }

  @override
  Future<void> clearCart() async {
    ref.read(cartItemsProvider.notifier).clear();
  }

  @override
  Future<int> getItemCount() async {
    final items = ref.read(cartItemsProvider);
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  @override
  Future<double> getTotalPrice() async {
    final items = ref.read(cartItemsProvider);
    return items.fold<double>(0.0, (sum, item) => sum + (item.productPrice * item.quantity));
  }
}
