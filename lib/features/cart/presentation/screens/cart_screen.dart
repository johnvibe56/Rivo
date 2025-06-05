import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/features/cart/application/providers/cart_provider.dart';
import 'package:rivo/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart';
import 'package:rivo/l10n/app_localizations.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartItemsProvider);
    final totalPrice = ref.watch(cartTotalPriceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.yourCart),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.yourCartIsEmpty))
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return CartItemTile(
                        item: item,
                        onRemove: () => _removeItem(ref, item.productId),
                      );
                    },
                  ),
          ),
          _buildCheckoutSection(context, ref, totalPrice),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(
      BuildContext context, WidgetRef ref, double totalPrice) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppLocalizations.of(context)!.total}:'
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            child: AppButton.primary(
              onPressed: () => _checkout(context),
              label: AppLocalizations.of(context)!.checkout,
              fullWidth: true,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _removeItem(WidgetRef ref, String productId) {
    ref.read(cartItemsProvider.notifier).removeFromCart(productId);
  }

  void _checkout(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.checkoutSimulationComplete),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
