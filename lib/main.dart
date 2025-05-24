import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/presentation/screens/app_loading_screen.dart';
import 'core/providers/auth_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';

/// Provider for Supabase initialization state
final supabaseInitializedProvider = FutureProvider<bool>((ref) async {
  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    
    // Get Supabase credentials
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception('Missing Supabase credentials in .env file');
    }
    
    // Initialize Supabase
    await SupabaseService.initialize(
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
    );
    
    return true;
  } catch (e, stackTrace) {
    debugPrint('Failed to initialize Supabase: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
});

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Run the app with error handling
  runApp(
    const ProviderScope(
      child: RivoApp(),
    ),
  );
}

/// Root widget that ensures Supabase is initialized before showing the app
class RivoApp extends ConsumerWidget {
  const RivoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the Supabase initialization state
    final supabaseInitialized = ref.watch(supabaseInitializedProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: supabaseInitialized.when(
        loading: () => const AppLoadingScreen(),
        error: (error, stackTrace) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to initialize app',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(supabaseInitializedProvider.future),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (_) => const MainApp(),
      ),
    );
  }
}

/// The main app widget that's shown after Supabase is initialized
class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the authentication state
    final authState = ref.watch(authStateProvider);
    
    // You can use the auth state to conditionally show different routes
    // For example, you could have different router configurations based on auth state
    // final router = isAuthenticated
    //     ? AppRouter.authenticatedRouter 
    //     : AppRouter.unauthenticatedRouter;
    
    // Log the authentication state for debugging
    authState.when(
      data: (state) => debugPrint('Auth state changed: ${state.event}'),
      loading: () => debugPrint('Loading auth state...'),
      error: (error, stack) => debugPrint('Auth state error: $error'),
    );
    
    return MaterialApp.router(
      title: 'Rivo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      // routerConfig: router, // Use the conditional router if needed
    );
  }
}
