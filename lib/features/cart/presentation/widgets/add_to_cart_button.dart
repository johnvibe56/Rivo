import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/features/cart/application/providers/cart_provider.dart';
import 'package:rivo/features/cart/domain/models/cart_item_model.dart';
import 'package:rivo/features/cart/presentation/screens/cart_screen.dart';

class AddToCartButton extends ConsumerStatefulWidget {
  final String productId;
  final String productName;
  final String productImage;
  final double productPrice;
  final bool isSold;
  final bool isOwner;

  const AddToCartButton({
    super.key,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    this.isSold = false,
    this.isOwner = false,
  });

  @override
  ConsumerState<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends ConsumerState<AddToCartButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Don't show the button if the product is sold or the user is the owner
    if (widget.isSold || widget.isOwner) {
      return const SizedBox.shrink();
    }

    return _isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
              onPressed: () => _addToCart(),
              tooltip: 'Add to cart',
            ),
          );
  }

  Future<void> _addToCart() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final cartItem = CartItem(
        productId: widget.productId,
        productName: widget.productName,
        productImage: widget.productImage,
        productPrice: widget.productPrice,
        quantity: 1,
      );

      await ref.read(cartRepositoryProvider).addToCart(cartItem);

      if (mounted) {
        // Show a snackbar feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.productName} added to cart'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).push<dynamic>(
                  MaterialPageRoute<dynamic>(
                    builder: (context) => const CartScreen(),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add item to cart'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
