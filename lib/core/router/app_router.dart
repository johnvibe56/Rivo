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
import 'package:rivo/features/product_feed/presentation/screens/product_feed_screen.dart';
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
  static const String profile = 'profile';
  
  // Add more route names as needed
  
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
      default:
        return '/';
    }
  }
}

class AppRouter {
  /// Helper method to get the full path for a route
  static String getFullPath(String routeName, {Map<String, String>? params}) {
    // For shell routes, we need to use the direct path
    if (routeName == AppRoutes.feed) return '/feed';
    if (routeName == AppRoutes.productFeed) return '/products';
    if (routeName == AppRoutes.profile) return '/profile';
    
    // For other routes, use the getPath method
    return AppRoutes.getPath(routeName, params: params);
  }

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
            final isAuthRoute = _authRoutes.any((route) => currentPath.startsWith(route));
            final isSplashRoute = currentPath == '/' || currentPath == splashPath;
            
            // Handle splash screen routing
            if (isSplashRoute) {
              // If we're already on the splash screen, don't redirect
              if (currentPath == splashPath) {
                return null;
              }
              // Otherwise, redirect to splash which will handle the auth state
              return splashPath;
            }

            // If user is not logged in and trying to access a protected route
            if (!isLoggedIn && !isPublicRoute) {
              // Store the intended location to redirect back after login
              final redirect = Uri.encodeComponent(state.uri.toString());
              return '${AppRouter.getFullPath(AppRoutes.login)}?redirect=$redirect';
            }

            // If user is logged in and trying to access an auth route, redirect to home
            if (isLoggedIn && isAuthRoute) {
              // Check if there's a redirect parameter
              final redirect = state.uri.queryParameters['redirect'];
              if (redirect != null && redirect.isNotEmpty) {
                return Uri.decodeComponent(redirect);
              }
              return AppRouter.getFullPath(AppRoutes.feed);
            }

            // No redirect needed
            return null;
          },
          loading: () {
            // If we're still loading the auth state, stay on the current route
            // or go to splash if we're not already there
            final splashPath = AppRoutes.getPath(AppRoutes.splash);
            if (state.uri.path != splashPath) {
              return splashPath;
            }
            return null;
          },
          error: (error, stackTrace) {
            debugPrint('Auth state error: $error');
            // In case of error, redirect to login
            return AppRouter.getFullPath(AppRoutes.login);
          },
        );
      } catch (e) {
        debugPrint('Router redirect error: $e');
        // In case of any error, redirect to login
        return AppRouter.getFullPath(AppRoutes.login);
      }
    },
    routes: [
      // Splash screen (initial route)
      GoRoute(
        path: '/splash',
        name: AppRoutes.splash,
        pageBuilder: (context, state) => const MaterialPage(
          child: SplashScreen(),
        ),
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.getPath(AppRoutes.login),
        name: AppRoutes.login,
        pageBuilder: (context, state) => MaterialPage(
          child: LoginScreen(
            redirect: state.uri.queryParameters['redirect'],
          ),
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
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      
      // Main App - Protected Routes with Shell
      ShellRoute(
        builder: (context, state, child) {
          // Determine the current index based on the current route
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
          // Feed screen
          GoRoute(
            path: '/feed',
            name: AppRoutes.feed,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FeedScreen(),
            ),
          ),
          
          // Product feed screen
          GoRoute(
            path: '/products',
            name: AppRoutes.productFeed,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProductFeedScreen(),
            ),
          ),
          
          // Profile screen
          GoRoute(
            path: '/profile',
            name: AppRoutes.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      // Product Detail - Will be implemented later
      /*
      GoRoute(
        path: 'product/:id',
        name: AppRoutes.productDetail,
        pageBuilder: (context, state) {
          final productId = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProductDetailScreen(productId: productId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(position: offsetAnimation, child: child);
                    },
                  );
                },
              ),
            ],
          ),
          
          // Profile
          GoRoute(
            path: AppRoutes.getPath(AppRoutes.profile),
            name: AppRoutes.profile,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          ),
        ],
      ),
      */
      
      // Not Found (404) - Must be the last route
      GoRoute(
        path: '/not_found',
        name: 'not_found',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '404',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Page not found'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.getPath(AppRoutes.splash)),
                    child: const Text('Go Home'),
                  ),
                ],
              ),
            ),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
    ],
    redirectLimit: 10,
  );

  // TODO: Implement this method when needed
  // static bool _isAuthRoute(String path) {
  //   final authRoutes = {'/login', '/signup', '/splash', '/forgot-password'};
  //   return authRoutes.contains(path);
  // }
}
