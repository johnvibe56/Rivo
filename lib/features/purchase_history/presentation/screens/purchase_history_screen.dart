import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/features/purchase_history/application/purchase_history_notifier.dart';
import 'package:rivo/features/purchase_history/presentation/widgets/purchase_history_card.dart';
import 'package:rivo/features/purchase_history/domain/models/purchase_with_product_model.dart';
import 'package:go_router/go_router.dart';

class PurchaseHistoryScreen extends ConsumerStatefulWidget {
  const PurchaseHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends ConsumerState<PurchaseHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch purchases when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(purchaseHistoryNotifierProvider.notifier).fetchPurchases();
    });
  }

  @override
  Widget build(BuildContext context) {
    final purchaseHistoryState = ref.watch(purchaseHistoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Purchases'),
      ),
      body: purchaseHistoryState.when(
        data: (state) => state.when(
          initial: () => const Center(child: Text('No purchases yet')),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (purchases) => _buildPurchaseList(purchases),
          error: (failure) => _buildErrorState(context, failure, ref),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildUnexpectedError(context, error, ref),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    Failure failure,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    
    // Different icons and messages based on error type
    final (icon, message, actionText, showLoginButton) = switch (failure) {
      NetworkFailure() => (
          Icons.signal_wifi_off,
          'No internet connection. Please check your connection and try again.',
          'Retry',
          false,
        ),
      ServerFailure() => (
          Icons.error_outline,
          'Unable to load purchases. Please try again later.\n${failure.message}',
          'Retry',
          false,
        ),
      UnauthorizedFailure() => (
          Icons.login,
          'Please sign in to view your purchase history',
          'Sign In',
          true,
        ),
      _ => (
          Icons.error_outline,
          'An error occurred: ${failure.message}',
          'Retry',
          false,
        ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading purchases',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () => ref
                  .read(purchaseHistoryNotifierProvider.notifier)
                  .fetchPurchases(),
              child: Text(actionText),
            ),
            if (showLoginButton) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // Navigate to login screen
                  // context.push('/login');
                },
                child: const Text('Go to Login'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUnexpectedError(
    BuildContext context,
    Object error,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: theme.colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Unexpected Error',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'An unexpected error occurred while loading your purchases.\nPlease try again later.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () => ref
                  .read(purchaseHistoryNotifierProvider.notifier)
                  .fetchPurchases(),
              child: const Text('Retry'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // Optionally report the error
                debugPrint('Purchase history error: $error');
              },
              child: const Text('Report Issue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseList(List<PurchaseWithProduct> purchases) {
    if (purchases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No purchases yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Your purchases will appear here',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(purchaseHistoryNotifierProvider.notifier)
          .fetchPurchases(),
      child: ListView.builder(
        itemCount: purchases.length,
        itemBuilder: (context, index) {
          final purchase = purchases[index];
          return PurchaseHistoryCard(
            purchase: purchase,
            onTap: () {
              // Navigate to product detail screen
              // TODO: Uncomment and implement navigation when ProductDetailScreen is available
              // context.push('/product/${purchase.product.id}');
            },
          );
        },
      ),
    );
  }
}
