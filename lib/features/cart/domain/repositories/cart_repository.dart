import 'package:rivo/features/cart/domain/models/cart_item_model.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCartItems();
  Future<void> addToCart(CartItem item);
  Future<void> removeFromCart(String productId);
  Future<void> clearCart();
  Future<int> getItemCount();
  Future<double> getTotalPrice();
}
