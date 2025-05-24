import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/features/auth/presentation/screens/login_screen.dart';
import 'package:rivo/features/auth/presentation/screens/signup_screen.dart';
import 'package:rivo/features/auth/presentation/screens/splash_screen.dart';
import 'package:rivo/features/product_feed/presentation/screens/home_screen.dart';
import 'package:rivo/features/product_feed/presentation/screens/product_detail_screen.dart';
import 'package:rivo/features/profile/presentation/screens/profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // Auth Flow
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      // Main App
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'product/:id',
            name: 'product_detail',
            builder: (context, state) {
              final productId = state.pathParameters['id']!;
              return ProductDetailScreen(productId: productId);
            },
          ),
        ],
      ),
      // Profile
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      // Not Found
      GoRoute(
        path: '/not_found',
        name: 'not_found',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Page not found'),
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text('Page not found'),
      ),
    ),
  );
}
