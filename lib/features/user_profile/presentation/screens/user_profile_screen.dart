import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/features/products/presentation/providers/delete_product_provider.dart';
import 'package:rivo/features/products/presentation/widgets/product_card.dart';
import 'package:rivo/features/user_profile/presentation/providers/user_profile_providers.dart';
import 'package:rivo/features/user_profile/presentation/screens/edit_profile_screen.dart';
import 'package:rivo/features/user_profile/presentation/widgets/profile_header.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String? userId;

  const UserProfileScreen({
    super.key,
    this.userId,
  });

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  bool _isMounted = false;
  String? _currentUserId;
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!_isMounted) return;

    final userId = widget.userId ?? ref.read(authStateProvider).value?.user?.id;
    if (userId == null || !_isMounted) return;

    _currentUserId = userId;
    await _loadUserProducts(userId);

    if (!_isMounted) return;

    ref.invalidate(userProfileProvider(userId));
  }

  Future<void> _loadUserProducts(String userId, {bool forceRefresh = false}) async {
    if (!_isMounted) return;

    try {
      await ref.read(userProductsProvider(userId).notifier).loadUserProducts(
            forceRefresh: forceRefresh,
          );
    } catch (e) {
      debugPrint('Error loading user products: $e');
    }
  }

  Future<void> _signOut() async {
    if (!_isMounted) return;
    final navigatorContext = context;
    
    try {
      await ref.read(authControllerProvider).signOut();
      if (!_isMounted) return;
      if (navigatorContext.mounted) {
        navigatorContext.go('/login');
      }
    } catch (e) {
      debugPrint('Error signing out: $e');
      if (_isMounted && navigatorContext.mounted) {
        ScaffoldMessenger.of(navigatorContext).showSnackBar(
          const SnackBar(content: Text('Error signing out')),
        );
      }
    }
  }

  Future<void> _handleProductDeleted() async {
    if (!_isMounted) return;
    final userId = _currentUserId;
    if (userId == null) return;
    await _loadUserProducts(userId, forceRefresh: true);
  }


  Future<void> _deleteProduct(BuildContext context, String productId) async {
    if (!_isMounted) return;
    
    // Store the context before async gap
    final currentContext = context;
    
    try {
      final success = await ref.read(deleteProductNotifierProvider.notifier).deleteProduct(productId);
      if (!_isMounted) return;
      
      if (success) {
        // Refresh the products list
        await _loadUserProducts(_currentUserId!, forceRefresh: true);
        
        if (_isMounted && currentContext.mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            const SnackBar(content: Text('Product deleted')),
          );
        }
      } else if (_isMounted && currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(content: Text('Failed to delete product')),
        );
      }
    } catch (e) {
      if (_isMounted && currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(content: Text('An error occurred while deleting the product')),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, String productId) async {
    if (!_isMounted) return;
    
    // Store the context before async gap
    final currentContext = context;
    
    final shouldDelete = await showDialog<bool>(
      context: currentContext,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && _isMounted) {
      // Use the stored context
      if (currentContext.mounted) {
        await _deleteProduct(currentContext, productId);
      }
    }
  }

  Future<void> _navigateToEditProfile(BuildContext context) async {
    if (!_isMounted) return;
    
    // Store the context before async gap
    final currentContext = context;
    
    try {
      // Get the navigator before the async gap
      final navigator = Navigator.of(currentContext, rootNavigator: true);
      
      // Navigate and wait for the result
      final result = await navigator.push<bool>(
        MaterialPageRoute<bool>(
          builder: (BuildContext context) => const EditProfileScreen(),
        ),
      );
      
      // If we got a result and the widget is still mounted, refresh the data
      if (_isMounted && result == true) {
        await _loadData();
      }
    } catch (e) {
      // Use the scaffold key to show the snackbar without context
      if (_isMounted && _scaffoldKey.currentState != null) {
        _scaffoldKey.currentState!.showSnackBar(
          const SnackBar(content: Text('Failed to open edit profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.value?.user?.id;
    final profileUserId = widget.userId ?? currentUserId;
    final isCurrentUser = currentUserId != null && currentUserId == profileUserId;

    if (profileUserId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userProductsAsync = ref.watch(userProductsProvider(profileUserId));
    final profileAsync = ref.watch(userProfileProvider(profileUserId));

    ref.listen(deleteProductNotifierProvider, (previous, next) {
      if (next.isLoading) return;
      
      if (next.errorMessage != null) {
        debugPrint('Error deleting product: ${next.errorMessage}');
        if (_isMounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage ?? 'Failed to delete product'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (next.successMessage != null) {
        if (_isMounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.successMessage!)),
          );
          _handleProductDeleted();
        }
      }
    });

    return profileAsync.when(
      data: (profile) => ScaffoldMessenger(
        key: _scaffoldKey,
        child: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: Text(isCurrentUser ? 'My Profile' : 'Profile'),
                actions: [
                  if (isCurrentUser) ...[
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _navigateToEditProfile(context),
                      tooltip: 'Edit Profile',
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: _signOut,
                      tooltip: 'Sign Out',
                    ),
                  ],
                ],
              ),
              body: RefreshIndicator(
                onRefresh: _loadData,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: ProfileHeader(
                        key: ValueKey('profile-${profile.id}'),
                        userId: profile.id,
                        displayName: profile.username,
                        bio: profile.bio,
                        avatarUrl: profile.avatarUrl,
                        productCount: userProductsAsync.valueOrNull?.length ?? 0,
                        isCurrentUser: isCurrentUser,
                        showBackButton: !isCurrentUser,
                      ),
                    ),
                    userProductsAsync.when(
                      data: (products) => products.isEmpty
                          ? const SliverFillRemaining(
                              child: Center(child: Text('No products found')),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.all(16.0),
                              sliver: SliverGrid(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.8,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final product = products[index];
                                    return GestureDetector(
                                      onLongPress: isCurrentUser 
                                          ? () => _showDeleteConfirmation(context, product.id)
                                          : null,
                                      child: ProductCard(
                                        product: product,
                                        showPurchaseButton: !isCurrentUser, // Only show purchase button if not the owner
                                        onTap: () {
                                          // Navigate to product details
                                          context.go('/product/${product.id}');
                                        },
                                      ),
                                    );
                                  },
                                  childCount: products.length,
                                ),
                              ),
                            ),
                      loading: () => const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, _) => SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Failed to load products'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _loadUserProducts(profileUserId, forceRefresh: true),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: isCurrentUser
                  ? FloatingActionButton(
                      onPressed: () => context.go('/sell'),
                      child: const Icon(Icons.add),
                    )
                  : null,
            );
          },
        ),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) {
        debugPrint('Error loading profile: $error');
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load profile'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}