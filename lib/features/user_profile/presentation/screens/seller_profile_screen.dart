import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/features/follow/presentation/providers/follow_provider.dart';
import 'package:rivo/features/products/presentation/widgets/product_card.dart';
import 'package:rivo/features/user_profile/presentation/providers/user_profile_providers.dart';
import 'package:rivo/features/user_profile/presentation/widgets/profile_header.dart';

class SellerProfileScreen extends ConsumerStatefulWidget {
  final String sellerId;
  final String? displayName;

  const SellerProfileScreen({
    super.key,
    required this.sellerId,
    this.displayName,
  });

  @override
  ConsumerState<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends ConsumerState<SellerProfileScreen> {
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _loadSellerProducts();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _loadSellerProducts({bool forceRefresh = false}) async {
    if (!_isMounted) return;
    
    try {
      await ref.read(userProductsProvider.notifier).loadUserProducts(
        widget.sellerId,
        forceRefresh: forceRefresh,
      );
    } catch (e, stackTrace) {
      Logger.e('Error loading seller products: $e', stackTrace);
      if (!_isMounted) return;
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load seller products')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).valueOrNull?.user;
    final isCurrentUser = currentUser?.id == widget.sellerId;
    final userProductsAsync = ref.watch(userProductsProvider);
    
    // Get follower count
    final followerCount = ref.watch(followedSellerIdsProvider).when(
      data: (result) => result.when(
        success: (follows) => follows.length,
        failure: (_) => 0,
      ),
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.displayName ?? 'Seller Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadSellerProducts(forceRefresh: true),
        child: userProductsAsync.when(
          data: (products) {
            return CustomScrollView(
              slivers: [
                // Profile Header
                SliverToBoxAdapter(
                  child: ProfileHeader(
                    userId: widget.sellerId,
                    displayName: widget.displayName,
                    avatarUrl: null, // TODO: Get seller's avatar URL
                    productCount: products.length,
                    followerCount: followerCount,
                    followingCount: 0, // TODO: Implement following count
                    isCurrentUser: isCurrentUser,
                  ),
                ),
                
                // Products Grid
                if (products.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = products[index];
                          return ProductCard(
                            product: product,
                            showUserActions: false,
                          );
                        },
                        childCount: products.length,
                      ),
                    ),
                  )
                else
                  const SliverFillRemaining(
                    child: Center(
                      child: Text('No products available'),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Text('Failed to load products: $error'),
          ),
        ),
      ),
    );
  }
}
