import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/core/presentation/screens/error_screen.dart';
import 'package:rivo/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:rivo/features/auth/presentation/screens/login_screen.dart';
import 'package:rivo/features/auth/presentation/screens/signup_screen.dart';
import 'package:rivo/features/auth/presentation/screens/splash_screen.dart';
import 'package:rivo/features/feed/presentation/screens/feed_screen.dart';
import 'package:rivo/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:rivo/features/profile/presentation/screens/profile_screen.dart';
// TODO: Uncomment when implementing product and profile features
// import 'package:rivo/features/product_feed/presentation/screens/product_detail_screen.dart';
// import 'package:rivo/features/profile/presentation/screens/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Centralized route names and paths for the application
class AppRoutes {
  // Auth routes
  static const String splash = 'splash';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String forgotPassword = 'forgot_password';
  static const String onboarding = 'onboarding';
  
  // Main app routes
  static const String feed = 'feed';
  static const String productDetail = 'product_detail';
  static const String profile = 'profile';
  
  // Helper to get the full path for a route
  static String getPath(String routeName, {Map<String, String>? params}) {
    switch (routeName) {
      case splash:
        return '/';
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
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.getPath(AppRoutes.splash),
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => ErrorScreen(
      error: state.error,
      onRetry: () => context.go(AppRoutes.getPath(AppRoutes.splash)),
    ),
    redirect: (BuildContext context, GoRouterState state) {
      // Check if the user is logged in
      final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
      
      // Define public routes that don't require authentication
      final isPublicRoute = [
        AppRoutes.getPath(AppRoutes.splash),
        AppRoutes.getPath(AppRoutes.login),
        AppRoutes.getPath(AppRoutes.signup),
        AppRoutes.getPath(AppRoutes.forgotPassword),
        AppRoutes.getPath(AppRoutes.onboarding),
      ].any((route) => state.matchedLocation.startsWith(route));
      
      // If the user is not logged in and trying to access a protected route
      if (!isLoggedIn && !isPublicRoute) {
        // Store the intended location to redirect back after login
        final loginPath = state.matchedLocation.isNotEmpty 
            ? '?redirect=${Uri.encodeComponent(state.matchedLocation)}' 
            : '';
        return '${AppRoutes.getPath(AppRoutes.login)}$loginPath';
      }
      
      // If the user is logged in and trying to access an auth route
      if (isLoggedIn && 
          (state.matchedLocation == AppRoutes.getPath(AppRoutes.login) || 
           state.matchedLocation == AppRoutes.getPath(AppRoutes.signup) ||
           state.matchedLocation == AppRoutes.getPath(AppRoutes.onboarding) ||
           state.matchedLocation == '/')) {  // Add check for root path
        // Check for a redirect parameter
        final redirect = state.uri.queryParameters['redirect'];
        if (redirect != null && redirect.isNotEmpty) {
          return redirect;
        }
        return AppRoutes.getPath(AppRoutes.feed);
      }
      
      // No redirect needed
      return null;
    },
    routes: [
      // Splash Screen - Shows while checking auth state
      GoRoute(
        path: AppRoutes.getPath(AppRoutes.splash),
        name: AppRoutes.splash,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      
      // Onboarding Flow
      GoRoute(
        path: AppRoutes.getPath(AppRoutes.onboarding),
        name: AppRoutes.onboarding,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
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
      
      // Auth Flow
      GoRoute(
        path: AppRoutes.getPath(AppRoutes.login),
        name: AppRoutes.login,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.getPath(AppRoutes.signup),
        name: AppRoutes.signup,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignupScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
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
          return child;
        },
        routes: [
          GoRoute(
            path: AppRoutes.getPath(AppRoutes.feed),
            name: AppRoutes.feed,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const FeedScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.getPath(AppRoutes.profile),
            name: AppRoutes.profile,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
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
