import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/core/navigation/app_navigation.dart';
import 'package:rivo/features/feed/presentation/widgets/marketplace_post_card.dart';
import 'package:rivo/features/wishlist/presentation/providers/wishlist_providers.dart';
import 'package:rivo/features/products/presentation/providers/product_providers.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart';
import 'package:rivo/l10n/app_localizations.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  static const String _tag = 'FeedScreen';

  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  bool _isInitialized = false;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    Logger.d('Initializing...', tag: _tag);
    
    // Set up scroll controller
    _scrollController.addListener(_onScroll);
    
    // Schedule the initial load after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isMounted) return;
      _isInitialized = true;
      _loadInitialProducts();
      _initializeWishlist();
    });
  }
  
  // Initialize wishlist after the first frame
  void _initializeWishlist() {
    if (!_isMounted) return;
    
    final currentUserId = ref.read(authStateProvider).valueOrNull?.user?.id;
    if (currentUserId != null) {
      Future.microtask(() {
        if (_isMounted) {
          ref.read(wishlistNotifierProvider(currentUserId).notifier).initialize();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Handle navigation returns by refreshing data
    if (_isInitialized && _isMounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isMounted) {
          _loadInitialProducts();
        }
      });
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialProducts() async {
    if (!_isMounted) return;
    
    // Capture BuildContext before async operation
    final currentContext = context;
    Logger.d('Triggering initial product load...', tag: _tag);
    
    try {
      // Ensure we're not in the build phase when modifying providers
      await Future.microtask(() => 
        ref.read(productListNotifierProvider.notifier).refresh()
      );
      Logger.d('Initial product load completed', tag: _tag);
    } catch (error, stackTrace) {
      Logger.e('Failed to load products: $error', stackTrace, tag: _tag);
      if (_isMounted) {
        if (!currentContext.mounted) return;
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(content: Text('Failed to load products')),
        );
      }
    }
  }

  void _onScroll() {
    if (_isLoading || !_isMounted) return;
    
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final delta = MediaQuery.of(context).size.height * 0.2; // Load more when 20% from bottom
    
    if (currentScroll >= (maxScroll - delta)) {
      _loadMoreProducts();
    }
  }
  
  Future<void> _loadMoreProducts() async {
    if (_isLoading || !_isMounted) return;
    
    // Capture BuildContext before async operation
    final currentContext = context;
    
    try {
      if (_isMounted) {
        setState(() {
          _isLoading = true;
        });
      }
      
      // Load the next page of products
      await Future.microtask(() => 
        ref.read(productListNotifierProvider.notifier).loadMore()
      );
    } catch (e, stackTrace) {
      Logger.e('Error loading more products: $e', stackTrace);
      if (_isMounted) {
        if (!currentContext.mounted) return;
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('Failed to load more products'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (_isMounted) {
        if (currentContext.mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListNotifierProvider);
    final hasMore = ref.watch(
      productListNotifierProvider.select((value) {
        return value.maybeWhen(
          data: (products) => products.isNotEmpty && products.length % 10 == 0,
          orElse: () => false,
        );
      }),
    );
    
    // Get current user ID from auth provider
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.valueOrNull?.user?.id;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppNavigation.goToProductUpload(context);
        },
        child: const Icon(Icons.add),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              AppButton.primary(
                onPressed: _loadInitialProducts,
                label: AppLocalizations.of(context)!.retry,
                fullWidth: false,
              ),
            ],
          ),
        ),
        data: (products) {
          Logger.d('Rendering ${products.length} products', tag: _tag);
          
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noProductsFound,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  AppButton.secondary(
                    onPressed: () => AppNavigation.goToProductUpload(context),
                    label: AppLocalizations.of(context)!.addYourFirstProduct,
                    icon: Icons.add,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: _loadInitialProducts,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  title: Text(
                    AppLocalizations.of(context)!.marketplace,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: _loadInitialProducts,
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.searchComingSoon)),
                        );
                      },
                      icon: const Icon(Icons.search, color: Colors.white, size: 28),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.cartIsEmpty)),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Show loading indicator at the bottom when there are more items to load
                        if (hasMore && index == products.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        
                        final product = products[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: MarketplacePostCard(
                            key: ValueKey(product.id),
                            product: product,
                            userId: currentUserId ?? '',
                            showWishlistButton: currentUserId != null,
                            onTap: () {
                              context.go('/product/${product.id}');
                            },
                            onMessage: () {
                              if (currentUserId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context)!.signInToMessage)),
                                );
                                return;
                              }
                              // TODO: Implement message functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!.messagingSeller(product.title),
                                  ),
                                ),
                              );
                            },
                            onBuy: () {
                              context.go('/product/${product.id}');
                            },
                          ),
                        );
                      },
                      childCount: products.length + (hasMore ? 1 : 0),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
