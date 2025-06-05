import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/features/products/presentation/providers/delete_product_provider.dart';
import 'package:rivo/features/products/presentation/widgets/product_card.dart';
import 'package:rivo/features/user_profile/presentation/providers/user_profile_providers.dart';
import 'package:rivo/features/user_profile/presentation/widgets/profile_header.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart';
import 'package:rivo/l10n/app_localizations.dart';

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
    final errorMessage = AppLocalizations.of(navigatorContext)!.errorSigningOut;
    
    try {
      final authController = ref.read(authControllerProvider);
      await authController.signOut();
      if (!_isMounted) return;
      if (navigatorContext.mounted) {
        navigatorContext.go('/login');
      }
    } catch (e) {
      debugPrint('Error signing out: $e');
      if (_isMounted && navigatorContext.mounted) {
        ScaffoldMessenger.of(navigatorContext).showSnackBar(
          SnackBar(content: Text(errorMessage)),
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
    
    // Store the context and localizations before async gap
    final currentContext = context;
    final productDeletedMsg = AppLocalizations.of(currentContext)!.productDeleted;
    final failedToDeleteMsg = AppLocalizations.of(currentContext)!.failedToDeleteProduct;
    
    try {
      final success = await ref.read(deleteProductNotifierProvider.notifier).deleteProduct(productId);
      if (!_isMounted) return;
      
      if (success) {
        // Refresh the products list
        await _loadUserProducts(_currentUserId!, forceRefresh: true);
        
        if (_isMounted && currentContext.mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(content: Text(productDeletedMsg)),
          );
        }
      } else if (_isMounted && currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text(failedToDeleteMsg)),
        );
      }
    } catch (e) {
      if (_isMounted && currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorDeletingProduct)),
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
        title: Text(AppLocalizations.of(context)!.deleteProduct),
        content: Text(AppLocalizations.of(context)!.confirmDeleteProduct),
        actions: [
          AppButton.text(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            label: AppLocalizations.of(context)!.cancel,
          ),
          AppButton.danger(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            label: AppLocalizations.of(context)!.delete,
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
    if (!mounted) return;
    
    // Store context and localizations before async gap
    final currentContext = context;
    final errorMessage = AppLocalizations.of(currentContext)!.failedToOpenEditProfile;
    
    try {
      final result = await currentContext.push<bool>('/edit-profile');
      if (result == true && mounted) {
        // Refresh user data after editing profile
        _loadData();
      }
    } catch (e) {
      debugPrint('Error navigating to edit profile: $e');
      if (mounted && currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text(errorMessage)),
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
              content: Text(next.errorMessage ?? AppLocalizations.of(context)!.failedToDeleteProduct),
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
                title: Text(isCurrentUser 
                    ? AppLocalizations.of(context)!.myProfile 
                    : AppLocalizations.of(context)!.profile),
                actions: [
                  if (isCurrentUser) ...[
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined),
                      onPressed: () => context.go('/purchases'),
                      tooltip: AppLocalizations.of(context)!.myPurchases,
                      padding: const EdgeInsets.all(8),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _navigateToEditProfile(context),
                      tooltip: AppLocalizations.of(context)!.editProfile,
                      padding: const EdgeInsets.all(8),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: _signOut,
                      tooltip: AppLocalizations.of(context)!.signOut,
                      padding: const EdgeInsets.all(8),
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
                          ? SliverFillRemaining(
                              child: Center(child: Text(AppLocalizations.of(context)!.noProductsFound)),
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
                              Text(AppLocalizations.of(context)!.failedToLoadProducts),
                              const SizedBox(height: 16),
                              AppButton.secondary(
                                onPressed: () => _loadUserProducts(profileUserId, forceRefresh: true),
                                label: AppLocalizations.of(context)!.retry,
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      elevation: 4,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                Text(AppLocalizations.of(context)!.failedToLoadProfile),
                const SizedBox(height: 16),
                AppButton.secondary(
                  onPressed: _loadData,
                  label: AppLocalizations.of(context)!.retry,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  height: 36,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}