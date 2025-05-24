import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rivo/core/router/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AppLoadingScreen extends ConsumerStatefulWidget {
  const AppLoadingScreen({super.key});

  @override
  ConsumerState<AppLoadingScreen> createState() => _AppLoadingScreenState();
}

class _AppLoadingScreenState extends ConsumerState<AppLoadingScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (_initialized) return;
    
    try {
      // Wait for a short delay to ensure the router is ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      // Check if user is authenticated
      final session = supabase.Supabase.instance.client.auth.currentSession;
      final user = session?.user;
      
      if (user != null) {
        // User is authenticated, check if email is verified
        final isEmailVerified = user.emailConfirmedAt != null;
        
        if (!isEmailVerified && !user.isAnonymous) {
          // Email not verified, redirect to login
          if (mounted) {
            context.go(AppRoutes.login);
          }
          return;
        }
        
        // User is authenticated and email is verified, go to feed
        if (mounted) {
          context.go(AppRoutes.feed);
        }
      } else {
        // User is not authenticated, go to login
        if (mounted) {
          context.go(AppRoutes.login);
        }
      }
    } catch (e) {
      // If there's an error, still try to navigate to login
      if (mounted) {
        context.go(AppRoutes.login);
      }
    } finally {
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
