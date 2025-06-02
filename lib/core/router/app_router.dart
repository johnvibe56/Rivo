import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Screens
import 'package:rivo/core/presentation/screens/error_screen.dart';
import 'package:rivo/features/auth/presentation/screens/login_screen.dart';
import 'package:rivo/features/auth/presentation/screens/signup_screen.dart';
import 'package:rivo/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:rivo/features/auth/presentation/screens/splash_screen.dart';
import 'package:rivo/features/feed/presentation/screens/feed_screen.dart';
import 'package:rivo/features/product_feed/presentation/screens/product_feed_screen.dart';
import 'package:rivo/features/product_feed/presentation/screens/product_detail_screen.dart';
import 'package:rivo/features/user_profile/presentation/screens/user_profile_screen.dart';
import 'package:rivo/features/user_profile/presentation/screens/seller_profile_screen.dart';
import 'package:rivo/features/user_profile/presentation/screens/edit_profile_screen.dart';
import 'package:rivo/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:rivo/features/cart/presentation/screens/cart_screen.dart';
import 'package:rivo/features/purchase_history/presentation/screens/purchase_history_screen.dart';
import 'package:rivo/features/product_upload/presentation/screens/product_upload_screen.dart';

// Providers
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';

// Routes
import 'package:rivo/core/router/app_routes.dart';

/// Main router class that handles all navigation in the app
class AppRouter {
  // Singleton instance
  static final AppRouter _instance = AppRouter._internal();
  
  // Factory constructor to return the singleton instance
  factory AppRouter() => _instance;
  
  // The router instance
  late final GoRouter _router;
  
  // Get the router instance
  GoRouter get router => _router;
  
  // Private constructor
  AppRouter._internal() {
    _router = _createRouter();
  }
  
  // List of routes that don't require authentication
  static const List<String> _publicRoutes = [
    '/splash',
    '/login',
    '/signup',
    '/forgot-password',
    '/onboarding',
  ];

  // List of auth routes that should redirect to home if user is authenticated
  static const List<String> _authRoutes = [
    '/login',
    '/signup',
    '/forgot-password',
  ];

  // Create the router configuration
  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: AppRoutes.getPath(AppRoutes.splash),
      debugLogDiagnostics: kDebugMode,
      errorBuilder: (context, state) => ErrorScreen(
        error: state.error,
        onRetry: () => context.go(AppRoutes.getPath(AppRoutes.splash)),
      ),
      redirect: (BuildContext context, GoRouterState state) {
        // Get the auth state using the container
        final container = ProviderScope.containerOf(context, listen: false);
        final authState = container.read(authStateProvider).valueOrNull;
        final isAuthenticated = authState?.user != null;
        
        // Skip redirection for public routes
        if (_publicRoutes.any((route) => state.uri.path.startsWith(route))) {
          // If user is authenticated and tries to access auth routes, redirect to home
          if (isAuthenticated && _authRoutes.any((route) => state.uri.path.startsWith(route))) {
            return AppRoutes.getPath(AppRoutes.feed);
          }
          return null;
        }
        
        // If not authenticated, redirect to login
        if (!isAuthenticated) {
          return AppRoutes.getPath(AppRoutes.login);
        }
        
        return null;
      },
      routes: [
        // Splash screen route
        GoRoute(
          path: AppRoutes.getPath(AppRoutes.splash),
          name: AppRoutes.splash,
          pageBuilder: (context, state) => const MaterialPage(
            child: SplashScreen(),
          ),
        ),
        
        // Auth routes
        GoRoute(
          path: AppRoutes.getPath(AppRoutes.login),
          name: AppRoutes.login,
          pageBuilder: (context, state) => const MaterialPage(
            child: LoginScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.getPath(AppRoutes.signup),
          name: AppRoutes.signup,
          pageBuilder: (context, state) => const MaterialPage(
            child: SignupScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.getPath(AppRoutes.forgotPassword),
          name: AppRoutes.forgotPassword,
          pageBuilder: (context, state) => const MaterialPage(
            child: ForgotPasswordScreen(),
          ),
        ),
        
        // Shell route for main app navigation
        ShellRoute(
          builder: (context, state, child) {
            // Determine the current index based on the current route
            int currentIndex = 0;
            final location = state.uri.path;
            
            if (location.startsWith(AppRoutes.getPath(AppRoutes.feed))) {
              currentIndex = 0;
            } else if (location.startsWith(AppRoutes.getPath(AppRoutes.productFeed))) {
              currentIndex = 1;
            } else if (location.startsWith(AppRoutes.getPath(AppRoutes.wishlist))) {
              currentIndex = 2;
            } else if (location.startsWith(AppRoutes.getPath(AppRoutes.cart))) {
              currentIndex = 3;
            } else if (location.startsWith(AppRoutes.getPath(AppRoutes.profile))) {
              currentIndex = 4;
            }
            
            return _MainScaffold(
              currentIndex: currentIndex,
              child: child,
            );
          },
          routes: [
            // Feed tab
            GoRoute(
              path: AppRoutes.getPath(AppRoutes.feed),
              name: AppRoutes.feed,
              pageBuilder: (context, state) => const MaterialPage(
                child: FeedScreen(),
              ),
            ),
            
            // Product feed tab
            GoRoute(
              path: AppRoutes.getPath(AppRoutes.productFeed),
              name: AppRoutes.productFeed,
              pageBuilder: (context, state) => const MaterialPage(
                child: ProductFeedScreen(),
              ),
            ),
            
            // Wishlist tab
            GoRoute(
              path: AppRoutes.getPath(AppRoutes.wishlist),
              name: AppRoutes.wishlist,
              pageBuilder: (context, state) => const MaterialPage(
                child: WishlistScreen(),
              ),
            ),
            
            // Cart tab
            GoRoute(
              path: AppRoutes.getPath(AppRoutes.cart),
              name: AppRoutes.cart,
              pageBuilder: (context, state) => const MaterialPage(
                child: CartScreen(),
              ),
            ),
            
            // User profile tab
            GoRoute(
              path: AppRoutes.getPath(AppRoutes.profile),
              name: AppRoutes.profile,
              pageBuilder: (context, state) => const MaterialPage(
                child: UserProfileScreen(),
              ),
            ),
            
            // Product detail
            GoRoute(
              path: '/product/:id',
              name: AppRoutes.productDetail,
              pageBuilder: (context, state) => MaterialPage(
                child: ProductDetailScreen(
                  productId: state.pathParameters['id']!,
                ),
              ),
            ),
            
            // Edit profile
            GoRoute(
              path: AppRoutes.getPath(AppRoutes.editProfile),
              name: AppRoutes.editProfile,
              pageBuilder: (context, state) => const MaterialPage(
                child: EditProfileScreen(),
              ),
            ),
            
            // Seller profile
            GoRoute(
              path: '/${AppRoutes.seller}/:sellerId',
              name: AppRoutes.seller,
              pageBuilder: (context, state) => MaterialPage(
                child: SellerProfileScreen(
                  sellerId: state.pathParameters['sellerId']!,
                ),
              ),
            ),
            
            // Purchase history
            GoRoute(
              path: AppRoutes.getPath(AppRoutes.purchaseHistory),
              name: AppRoutes.purchaseHistory,
              pageBuilder: (context, state) => const MaterialPage(
                child: PurchaseHistoryScreen(),
              ),
            ),
            
            // Product upload
            GoRoute(
              path: AppRoutes.getPath(AppRoutes.productUpload),
              name: AppRoutes.productUpload,
              pageBuilder: (context, state) => const MaterialPage(
                child: ProductUploadScreen(),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // Navigation helper methods
  
  /// Navigate to product detail screen
  static void goToProductDetail(BuildContext context, String productId) {
    context.go(
      AppRoutes.getPath(
        AppRoutes.productDetail,
        params: {'id': productId},
      ),
    );
  }
  
  /// Navigate to seller profile screen
  static void goToSellerProfile(
    BuildContext context, {
    required String sellerId,
    String? displayName,
  }) {
    context.go(
      '/${AppRoutes.seller}/$sellerId',
    );
  }
  
  /// Navigate to edit profile screen
  static void goToEditProfile(BuildContext context) {
    context.go(AppRoutes.getPath(AppRoutes.editProfile));
  }
  
  /// Navigate to user profile screen
  static void goToUserProfile(BuildContext context, [String? userId]) {
    if (userId != null) {
      context.go(
        AppRoutes.getPath(
          AppRoutes.userProfileById,
          params: {'userId': userId},
        ),
      );
    } else {
      context.go(AppRoutes.getPath(AppRoutes.profile));
    }
  }
}

/// Main scaffold widget that provides the app's basic layout including the bottom navigation bar
class _MainScaffold extends ConsumerWidget {
  final Widget child;
  final int currentIndex;

  const _MainScaffold({
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.getPath(AppRoutes.feed));
              break;
            case 1:
              context.go(AppRoutes.getPath(AppRoutes.productFeed));
              break;
            case 2:
              context.go(AppRoutes.getPath(AppRoutes.wishlist));
              break;
            case 3:
              context.go(AppRoutes.getPath(AppRoutes.cart));
              break;
            case 4:
              context.go(AppRoutes.getPath(AppRoutes.profile));
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
