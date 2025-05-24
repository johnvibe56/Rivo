import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Run the app
  runApp(
    const ProviderScope(
      child: RivoApp(),
    ),
  );
}

/// Root widget that ensures Supabase is initialized before showing the app
class RivoApp extends ConsumerStatefulWidget {
  const RivoApp({super.key});

  @override
  ConsumerState<RivoApp> createState() => _RivoAppState();
}

class _RivoAppState extends ConsumerState<RivoApp> {
  @override
  void initState() {
    super.initState();
    // Wait for the first frame to be rendered before checking auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _handleAuthState();
      }
    });
  }

  void _handleAuthState() {
    if (!mounted) return;
    
    try {
      final authState = ref.read(authStateProvider);
      if (authState.isLoading) return;
      
      final router = GoRouter.maybeOf(context);
      if (router == null) {
        debugPrint('Router not available yet');
        return;
      }
      
      // Wait for the next frame to ensure router is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        
        try {
          final currentPath = router.routerDelegate.currentConfiguration.uri.path;
          
          if (authState.hasError) {
            if (!currentPath.startsWith('/login')) {
              router.go('/login');
            }
          } else if (authState.valueOrNull == null) {
            if (!currentPath.startsWith('/login') && 
                !currentPath.startsWith('/signup') &&
                !currentPath.startsWith('/forgot-password') &&
                currentPath != '/') {
              router.go('/login');
            }
          } else if (currentPath == '/' || 
                    currentPath == '/login' || 
                    currentPath == '/signup' ||
                    currentPath == '/forgot-password') {
            router.go('/feed');
          }
        } catch (e) {
          debugPrint('Navigation error in post-frame callback: $e');
        }
      });
    } catch (e) {
      debugPrint('Error in _handleAuthState: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the Supabase initialization state
    final supabaseInitialized = ref.watch(supabaseInitializedProvider);
    
    // Handle auth state changes
    ref.listen<AsyncValue<dynamic>>(authStateProvider, (_, __) => _handleAuthState());

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        // Show loading or error states based on Supabase initialization
        return supabaseInitialized.when(
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
          data: (_) => child!,
        );
      },
    );
  }
}


