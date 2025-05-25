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
import 'package:rivo/features/profile/presentation/screens/profile_screen.dart';

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
              context.go(AppRouter.getFullPath(AppRoutes.profile));
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
  
  // Main app routes - protected
  static const String feed = 'feed';
  static const String productFeed = 'product_feed';
  static const String productDetail = 'product_detail';
  static const String productUpload = 'product_upload';
  static const String profile = 'profile';
  
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
        return '/profile';
      case productUpload:
        return '/upload-product';
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
    if (routeName == AppRoutes.profile) return '/profile';
    
    // For other routes, use the getPath method
    return AppRoutes.getPath(routeName, params: params);
  }
  
  static bool _isAuthPath(String path) => _authRoutes.contains(path);

  // Shell route for main navigation
  static final _shellRoute = ShellRoute(
    builder: (context, state, child) {
      int currentIndex = 0;
      final location = state.uri.path;
      
      if (location.startsWith('/products')) {
        currentIndex = 1;
      } else if (location.startsWith('/profile')) {
        currentIndex = 2;
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
      
      // Profile route
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      
      // Product upload route
      GoRoute(
        path: '/upload-product',
        builder: (context, state) => const ProductUploadScreen(),
      ),
    ],
  );

  // Auth routes
  static final _authRoute = GoRoute(
    path: '/login',
    builder: (context, state) => const LoginScreen(),
    routes: [
      GoRoute(
        path: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
    ],
  );

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
      _authRoute,
      _splashRoute,
    ],
  );
}
