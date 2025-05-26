import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
// Removed unused import
import 'package:rivo/features/wishlist/presentation/providers/wishlist_providers.dart';

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
    final user = ref.read(authStateProvider).value?.user;
    if (user != null) {
      // The wishlist items will be loaded through the provider
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value?.user;
    final wishlistState = ref.watch(wishlistNotifierProvider(user?.id ?? ''));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text('Please sign in to view your wishlist'))
          : wishlistState.when(
              data: (wishlistItems) {
                if (wishlistItems.isEmpty) {
                  return const Center(
                    child: Text('No saved items yet'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: wishlistItems.length,
                  itemBuilder: (context, index) {
                    final productId = wishlistItems.elementAt(index);
                    // TODO: Fetch and display product details using productId
                    return ListTile(
                      title: Text('Product ID: $productId'),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () async {
                          final repository = ref.read(wishlistRepositoryProvider);
                          await repository.toggleWishlistItem(productId, user.id);
                          // Refresh the wishlist
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) {
                Logger.e(error, stackTrace);
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load wishlist'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadWishlist,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
