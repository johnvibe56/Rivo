import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/core/constants/app_colors.dart';
import 'package:rivo/core/router/app_router.dart' as app_router;
import 'package:rivo/core/router/app_router.dart' show AppRoutes;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  
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
        curve: const Interval(0.0, 0.65, curve: Curves.easeInOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.elasticOut),
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
    try {
      // Add a minimum splash duration for better UX
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      
      if (!mounted) return;
      
      // Check if user is authenticated
      final session = supabase.Supabase.instance.client.auth.currentSession;
      final user = session?.user;
      
      // Ensure we show the splash screen for at least 1.5 seconds
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      if (user != null) {
        // User is authenticated, check if email is verified
        final isEmailVerified = user.emailConfirmedAt != null || user.isAnonymous;
        
        if (!isEmailVerified) {
          // Email not verified, show a message and redirect to login
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please verify your email before continuing'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.warning,
              ),
            );
            if (mounted) {
              // Go to login and clear the navigation stack
              context.go(app_router.AppRouter.getFullPath(AppRoutes.login));
            }
          }
          return;
        }
        
        // Navigate to home feed
        if (mounted) {
          context.go(app_router.AppRouter.getFullPath(AppRoutes.feed));
        }
      } else {
        // User is not authenticated, go to login
        if (mounted) {
          context.go(app_router.AppRouter.getFullPath(AppRoutes.login));
        }
      }
    } catch (e) {
      debugPrint('Error during splash navigation: $e');
      
      // If there's an error, navigate to login
      if (mounted) {
        context.go(app_router.AppRouter.getFullPath(AppRoutes.login));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo with animation
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _controller.value * 2 * 3.14159, // One full rotation
                          child: child,
                        );
                      },
                      child: Container(
                        width: 140,
                        height: 140,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primaryContainer,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // App name with animation
                    FadeTransition(
                      opacity: Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).animate(CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
                      )),
                      child: Text(
                        'Rivo',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Tagline with animation
                    FadeTransition(
                      opacity: Tween<double>(
                        begin: 0.0,
                        end: 0.8,
                      ).animate(CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
                      )),
                      child: Text(
                        'Your marketplace for everything',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Loading indicator with animation
                    FadeTransition(
                      opacity: Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).animate(CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
                      )),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
