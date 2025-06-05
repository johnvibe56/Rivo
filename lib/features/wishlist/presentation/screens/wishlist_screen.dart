import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart' show AppButton;
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/features/wishlist/presentation/providers/wishlist_providers.dart';
import 'package:rivo/l10n/app_localizations.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    if (mounted) {
      setState(() {});
    }
    final user = ref.read(authStateProvider).value?.user;
    if (user != null) {
      // The wishlist items will be loaded through the provider
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value?.user;
    final wishlistState = ref.watch(wishlistNotifierProvider(user?.id ?? ''));
    final localizations = AppLocalizations.of(context)!; // Non-null assertion is safe here
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.myWishlist),
        centerTitle: true,
      ),
      body: user == null
          ? _buildSignInPrompt()
          : wishlistState.when(
              data: (wishlistItems) {
                if (wishlistItems.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildWishlistItems(wishlistItems, user.id);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => _buildErrorState(error, stackTrace),
            ),
    );
  }

  
  Widget _buildSignInPrompt() {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!; // Non-null assertion is safe here
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              localizations.signInToViewWishlist,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton.primary(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              label: localizations.signIn,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!; // Non-null assertion is safe here
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            localizations.wishlistEmpty,
            style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.hintColor,
                ),
          ),
          const SizedBox(height: 24),
          AppButton.secondary(
            onPressed: () => Navigator.pop(context),
            label: localizations.continueShopping,
            icon: Icons.arrow_back,
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItems(Set<String> wishlistItems, String userId) {
    final localizations = AppLocalizations.of(context)!; // Non-null assertion is safe here
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wishlistItems.length,
      itemBuilder: (BuildContext context, int index) {
        final productId = wishlistItems.elementAt(index);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.image, size: 48),
            title: Text(localizations.productId(productId)),
            subtitle: Text(localizations.productDetailsPlaceholder),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add to Cart Button
                AppButton.primary(
                  onPressed: () {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            localizations.addToCartWithStatus('Coming soon'),
                          ),
                        ),
                      );
                    }
                  },
                  label: '',
                  icon: Icons.add_shopping_cart,
                  height: 36,
                ),
                const SizedBox(width: 8),
                // Remove from Wishlist Button
                IconTheme(
                  data: const IconThemeData(color: Colors.red),
                  child: AppButton.secondary(
                    onPressed: () {
                      final repository = ref.read(wishlistRepositoryProvider);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      
                      repository.toggleWishlistItem(productId, userId).then((_) {
                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                localizations.removedFromWishlist,
                              ),
                            ),
                          );
                        }
                      });
                    },
                    label: '',
                    icon: Icons.favorite,
                    height: 36,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(Object error, StackTrace stackTrace) {
    debugPrint('Wishlist error: $error\n$stackTrace');
    final localizations = AppLocalizations.of(context); // Removed non-null assertion
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              localizations?.failedToLoadWishlist ?? '', // Safely access localizations
              style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            if (error.toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 24),
            AppButton.primary(
              onPressed: _loadWishlist,
              label: localizations!.retry,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}
