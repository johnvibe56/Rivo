import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/core/router/app_router.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/features/feed/presentation/widgets/marketplace_post_card.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/features/products/presentation/providers/delete_product_provider.dart';
import 'package:rivo/features/user_profile/presentation/providers/user_profile_providers.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    
    // Listen to auth state changes
    ref.listenManual<AsyncValue<dynamic>>(
      authStateProvider,
      (previous, next) {
        // When auth state changes and we have a user, load products
        if (next.value?.user != null && mounted) {
          _loadUserProducts();
        }
      },
    );
    
    // Initial load if we already have a user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(authStateProvider).value?.user != null) {
        _loadUserProducts();
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _loadUserProducts({bool forceRefresh = false}) async {
    if (!_isMounted) return;
    
    Logger.d('Starting to load user products (forceRefresh: $forceRefresh)');
    
    try {
      final userId = ref.read(authStateProvider).value?.user?.id;
      if (userId == null) {
        Logger.d('No user ID available');
        return;
      }
      
      Logger.d('Requesting products for user: $userId');
      await ref.read(userProductsProvider.notifier).loadUserProducts(
        userId,
        forceRefresh: forceRefresh,
      );
      Logger.d('Products load request completed');
    } catch (e, stackTrace) {
      Logger.e('Error loading products: $e', stackTrace);
      if (!_isMounted) return;
      
      // Store context in a local variable before async gap
      final context = this.context;
      if (!context.mounted) return;
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load your products')),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      // Store context in a local variable before async gap
      final context = this.context;
      
      // Get the auth controller
      final authController = ref.read(authControllerProvider);
      await authController.signOut();
      
      if (!_isMounted) return;
      
      // Use GoRouter to navigate to login screen
      if (context.mounted) {
        context.go(AppRouter.getFullPath(AppRoutes.login));
      }
    } catch (e, stackTrace) {
      Logger.e(e, stackTrace, tag: 'UserProfileScreen');
      
      if (!_isMounted) return;
      
      // Store context in a local variable before async gap
      final context = this.context;
      if (!context.mounted) return;
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to sign out')),
      );
    }
  }

  // Handle product deletion
  Future<void> _handleProductDeleted() async {
    final userId = ref.read(authStateProvider).value?.user?.id;
    if (userId == null || !mounted) return;
    
    // Refresh the product list
    await _loadUserProducts(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value?.user;
    final userProductsAsync = ref.watch(userProductsProvider);
    
      // Listen for product deletion state changes
    ref.listen(deleteProductNotifierProvider, (previous, next) {
      if (next.isLoading) return;
      
      if (next.errorMessage != null) {
        Logger.e('Error deleting product: ${next.errorMessage}', StackTrace.current);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage ?? 'Failed to delete product'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // Reset the delete state after showing the error
          if (next.productId != null) {
            ref.read(deleteProductNotifierProvider.notifier).reset();
          }
        }
      } else if (next.successMessage != null) {
        // Only handle success if we're still mounted
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.successMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // Reset the delete state after showing the success message
          if (next.productId != null) {
            ref.read(deleteProductNotifierProvider.notifier).reset();
          }
          
          _handleProductDeleted();
        }
      }
    });
    
    // Debug log the current state
    userProductsAsync.when(
      data: (products) => Logger.d('UI: Loaded ${products.length} products'),
      loading: () => Logger.d('UI: Loading products...'),
      error: (error, stackTrace) {
        Logger.e('UI: Error loading products: $error', stackTrace);
      },
    );
    
    // Show loading indicator if we're still waiting for auth or products
    if (authState.isLoading || (user == null && !authState.hasError)) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadUserProducts(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.email ?? 'User',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (context.mounted) {
                            context.push(AppRouter.getFullPath(AppRoutes.productUpload));
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Upload New Product'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // User's Products Section
              Text(
                'My Products',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // Products List
              userProductsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: Text('You haven\'t uploaded any products yet.'),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: MarketplacePostCard(
                          key: ValueKey('product-${product.id}'),
                          product: product,
                          userId: user?.id ?? '',
                          onTap: () {
                            // Refresh the product list when a product is deleted
                            _loadUserProducts(forceRefresh: true);
                          },
                          onMessage: () {
                            // Handle message action
                            if (context.mounted) {
                              context.push('/chat', extra: {
                                'product': product,
                                'sellerId': product.ownerId,
                              });
                            }
                          },
                          onBuy: () {
                            // Handle buy action
                            if (context.mounted) {
                              context.push('/product/${product.id}');
                            }
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) {
                  Logger.e('Error building UI: $error', stack);
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${error.toString()}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _loadUserProducts(forceRefresh: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
