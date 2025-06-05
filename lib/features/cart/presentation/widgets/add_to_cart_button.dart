import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/features/cart/application/providers/cart_provider.dart';
import 'package:rivo/features/cart/domain/models/cart_item_model.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart';
import 'package:rivo/l10n/app_localizations.dart';

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
  bool _isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
    // Don't show the button if the product is sold or the user is the owner
    if (widget.isSold || widget.isOwner) {
      return const SizedBox.shrink();
    }

    return AppButton.primary(
      onPressed: _isAddingToCart ? null : _addToCart,
      label: AppLocalizations.of(context)!.addToCart,
      icon: Icons.add_shopping_cart,
      isLoading: _isAddingToCart,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      height: 40.0,
      borderRadius: 8.0,
    );
  }

  Future<void> _addToCart() async {
    if (_isAddingToCart) return;

    setState(() => _isAddingToCart = true);

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
            content: Text(
              '${widget.productName} ${AppLocalizations.of(context)!.addedToCart}',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.viewCart,
              textColor: Colors.white,
              onPressed: () {
                context.go('/cart');
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToAddToCart),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }
}
