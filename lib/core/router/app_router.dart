import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/core/presentation/screens/error_screen.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';
import 'package:rivo/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:rivo/features/auth/presentation/screens/login_screen.dart';
import 'package:rivo/features/auth/presentation/screens/signup_screen.dart';
import 'package:rivo/features/auth/presentation/screens/splash_screen.dart';
import 'package:rivo/features/feed/presentation/screens/feed_screen.dart';
import 'package:rivo/features/product_feed/presentation/screens/product_detail_screen.dart';
import 'package:rivo/features/product_feed/presentation/screens/product_feed_screen.dart';
import 'package:rivo/features/product_upload/presentation/screens/product_upload_screen.dart';
import 'package:rivo/features/user_profile/presentation/screens/seller_profile_screen.dart';
import 'package:rivo/features/user_profile/presentation/screens/edit_profile_screen.dart';
import 'package:rivo/features/user_profile/presentation/screens/user_profile_screen.dart';
import 'package:rivo/features/wishlist/presentation/screens/wishlist_screen.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;
  final int currentIndex;

  const MainScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRouter.getFullPath(AppRoutes.feed));
              break;
            case 1:
              context.go(AppRouter.getFullPath(AppRoutes.productFeed));
              break;
            case 2:
              context.go(AppRouter.getFullPath(AppRoutes.wishlist));
              break;
            case 3:
              context.go(AppRouter.getFullPath(AppRoutes.userProfile));
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// List of routes that don't require authentication
const _publicRoutes = [
  '/',
  '/splash',
  '/login',
  '/signup',
  '/forgot-password',
  '/onboarding',
  '/seller/:sellerId',
];

/// List of routes that should redirect to home if user is already authenticated
const _authRoutes = [
  '/login',
  '/signup',
  '/forgot-password',
];

/// Centralized route names and paths for the application
class AppRoutes {
  // Auth routes
  static const String splash = 'splash';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String forgotPassword = 'forgot_password';
  static const String onboarding = 'onboarding';
  
  // User profile routes
  static const String userProfile = 'user-profile';
  static const String sellerProfile = 'seller';
  static const String editProfile = 'edit-profile';
  
  // Main app routes - protected
  static const String feed = 'feed';
  static const String productFeed = 'product_feed';
  static const String productDetail = 'product_detail';
  static const String productUpload = 'product_upload';
  static const String profile = 'user_profile'; // Updated to use user_profile
  static const String wishlist = 'wishlist'; // Added wishlist route
  static const String seller = 'seller_profile';
  
  // Helper to get the full path for a route
  static String getPath(String routeName, {Map<String, String>? params}) {
    switch (routeName) {
      case splash:
        return '/splash';
      case login:
        return '/login';
      case signup:
        return '/signup';
      case forgotPassword:
        return '/forgot-password';
      case onboarding:
        return '/onboarding';
      case feed:
        return '/feed';
      case productFeed:
        return '/products';
      case productDetail:
        return '/product/${params?['id'] ?? ':id'}';
      case profile:
        return '/user_profile';
      case productUpload:
        return '/upload-product';
      case wishlist:
        return '/wishlist';
      case sellerProfile:
        return '/seller/${params?['sellerId'] ?? ':sellerId'}';
      case editProfile:
        return '/edit-profile';
      default:
        return '/';
    }
  }
}

class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();
  
  /// Helper method to get the full path for a route
  static String getFullPath(String routeName, {Map<String, String>? params}) {
    // For shell routes, we need to use the direct path
    if (routeName == AppRoutes.feed) return '/feed';
    if (routeName == AppRoutes.productFeed) return '/products';
    if (routeName == AppRoutes.profile || routeName == AppRoutes.userProfile) return '/user_profile';
    
    // For other routes, use the getPath method
    return AppRoutes.getPath(routeName, params: params);
  }
  
  static void goToProductDetail(BuildContext context, String productId) {
    context.go(getFullPath(
      AppRoutes.productDetail,
      params: {'id': productId},
    ));
  }
  
  /// Redirect to the seller profile screen
  static void goToSellerProfile(BuildContext context, {
    required String sellerId,
    String? displayName,
  }) {
    final uri = Uri(
      path: getFullPath(
        AppRoutes.sellerProfile,
        params: {'sellerId': sellerId},
      ),
      queryParameters: displayName != null ? {'name': displayName} : null,
    );
    context.go(uri.toString());
  }
  
  /// Navigate to the edit profile screen
  static void goToEditProfile(BuildContext context) {
    context.go(getFullPath(AppRoutes.editProfile));
  }
  
  static bool _isAuthPath(String path) {
    return _authRoutes.any((route) => path == route || path.startsWith('$route/'));
  }

  // Shell route for main navigation
  static final _shellRoute = ShellRoute(
    builder: (context, state, child) {
      // Don't show bottom navigation for edit profile
      if (state.uri.path == '/edit-profile') {
        return child;
      }
      
      int currentIndex = 0;
      final location = state.uri.path;
      
      if (location.startsWith('/products')) {
        currentIndex = 1;
      } else if (location.startsWith('/wishlist')) {
        currentIndex = 2;
      } else if (location.startsWith('/user_profile') || location.startsWith('/profile')) {
        currentIndex = 3;
      }
      
      return MainScaffold(
        currentIndex: currentIndex,
        child: child,
      );
    },
    routes: [
      // Feed route
      GoRoute(
        path: '/feed',
        builder: (context, state) => const FeedScreen(),
      ),
      
      // Product feed route
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductFeedScreen(),
      ),
      
      // Product detail route
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailScreen(productId: productId);
        },
      ),
      
      // User Profile route
      GoRoute(
        path: '/user_profile',
        name: AppRoutes.userProfile,
        builder: (context, state) => const UserProfileScreen(),
      ),
      
      // Wishlist route
      GoRoute(
        path: '/wishlist',
        name: AppRoutes.wishlist,
        builder: (context, state) => const WishlistScreen(),
      ),
      
      // Seller Profile route
      GoRoute(
        path: '/seller/:sellerId',
        name: AppRoutes.sellerProfile,
        builder: (context, state) {
          final sellerId = state.pathParameters['sellerId']!;
          final displayName = state.uri.queryParameters['name'];
          return SellerProfileScreen(
            sellerId: sellerId,
            displayName: displayName,
          );
        },
      ),
      
      // Product upload route
      GoRoute(
        path: '/upload-product',
        builder: (context, state) => const ProductUploadScreen(),
      ),
      
      // Edit Profile route
      GoRoute(
        path: '/edit-profile',
        name: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );

  // Auth routes
  static final authRouteList = [
    // Login route
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    
    // Signup route (accessible at both /signup and /login/signup)
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    
    // Forgot password route (accessible at /forgot-password and /login/forgot-password)
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    
    // Nested routes for backward compatibility
    GoRoute(
      path: '/login/signup',
      redirect: (context, state) => '/signup',
    ),
    GoRoute(
      path: '/login/forgot-password',
      redirect: (context, state) => '/forgot-password',
    ),
  ];

  // Splash screen route
  static final _splashRoute = GoRoute(
    path: '/splash',
    builder: (context, state) => const SplashScreen(),
  );

  // Main router configuration
  static final router = GoRouter(
    initialLocation: AppRoutes.getPath(AppRoutes.splash),
    errorBuilder: (context, state) => ErrorScreen(
      error: state.error,
      onRetry: () => context.go(AppRoutes.getPath(AppRoutes.splash)),
    ),
    redirect: (BuildContext context, GoRouterState state) async {
      try {
        // Skip redirection for public routes
        if (_publicRoutes.any((route) => state.uri.path.startsWith(route))) {
          return null;
        }

        // Get the auth state
        final container = ProviderScope.containerOf(context);
        final authState = container.read(authStateProvider);
        final splashPath = AppRoutes.getPath(AppRoutes.splash);
        
        return authState.when(
          data: (authState) {
            final isLoggedIn = authState.isAuthenticated;
            final currentPath = state.uri.path;
            final isPublicRoute = _publicRoutes.any((route) => currentPath.startsWith(route));
            final isAuthPath = _isAuthPath(currentPath);
            final isSplashRoute = currentPath == '/' || currentPath == splashPath;
            
            // Handle splash screen routing
            if (isSplashRoute) {
              return currentPath == splashPath ? null : splashPath;
            }

            // If user is not logged in and trying to access a protected route
            if (!isLoggedIn && !isPublicRoute) {
              final redirect = Uri.encodeComponent(state.uri.toString());
              return '${AppRouter.getFullPath(AppRoutes.login)}?redirect=$redirect';
            }

            // If user is logged in and trying to access an auth route, redirect to home
            if (isLoggedIn && isAuthPath) {
              final redirect = state.uri.queryParameters['redirect'];
              if (redirect != null && redirect.isNotEmpty) {
                return Uri.decodeComponent(redirect);
              }
              return AppRouter.getFullPath(AppRoutes.feed);
            }

            return null;
          },
          loading: () => state.uri.path == splashPath ? null : splashPath,
          error: (_, __) => AppRouter.getFullPath(AppRoutes.login),
        );
      } catch (e) {
        debugPrint('Router redirect error: $e');
        return AppRouter.getFullPath(AppRoutes.login);
      }
    },
    routes: [
      _shellRoute,
      ...authRouteList,  // Use spread operator to include all auth routes
      _splashRoute,
    ],
  );
}
