import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/core/constants/app_colors.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start the animation
    _controller.forward();
    
    // Start the navigation flow
    _navigateToNextScreen();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Future<void> _navigateToNextScreen() async {
    // Add a small delay to show the splash screen
    await Future<void>.delayed(const Duration(seconds: 2));
    
    try {
      // Get the current auth state
      final authState = ref.read(authStateProvider).valueOrNull;
      
      if (!mounted) return;
      
      // Navigate based on auth state
      if (authState?.isAuthenticated == true) {
        // If user is authenticated, go to home
        if (authState?.user?.emailConfirmedAt != null) {
          context.go('/feed');
        } else {
          // If email is not verified, show message and go to login
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please verify your email before continuing'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.warning,
              ),
            );
            context.go('/login');
          }
        }
      } else {
        // If not authenticated, go to login
        context.go('/login');
      }
    } catch (e) {
      debugPrint('Error during splash navigation: $e');
      // If there's an error, navigate to login
      if (mounted) {
        context.go('/login');
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              FlutterLogo(
                size: 150,
                style: FlutterLogoStyle.horizontal,
              ),
              const SizedBox(height: 24),
              // App name
              Text(
                'RIVO',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
