import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivo/core/presentation/screens/app_loading_screen.dart';
import 'package:rivo/core/providers/supabase_provider.dart';
import 'package:rivo/core/router/app_router.dart';
import 'package:rivo/core/theme/app_theme.dart';
import 'package:rivo/features/auth/presentation/providers/auth_provider.dart';

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
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await SupabaseService.initialize(
    supabaseUrl: dotenv.env['SUPABASE_URL']!,
    supabaseAnonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
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

class _RivoAppState extends ConsumerState<RivoApp> with WidgetsBindingObserver {
  bool _initialized = false;
  bool _isInitializing = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleAuthInit();
  }

  void _scheduleAuthInit() {
    if (_isInitializing) return;
    _isInitializing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initAuth();
    });
  }

  Future<void> _initAuth() async {
    if (_initialized || !mounted) return;
    
    try {
      // Only initialize auth state if Supabase is initialized
      if (SupabaseService.isInitialized) {
        await ref.read(authStateProvider.notifier).initialize();
        if (!mounted) return;
        setState(() {
          _initialized = true;
        });
      } else {
        // If Supabase isn't initialized yet, wait a bit and try again
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) _initAuth();
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      // If there's an error, try to reinitialize after a delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) _initAuth();
    } finally {
      _isInitializing = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the Supabase initialization state first
    final supabaseInitialized = ref.watch(supabaseInitializedProvider);

    return supabaseInitialized.when(
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AppLoadingScreen(),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
      ),
      error: (error, stackTrace) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to initialize app',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    // Try to initialize again
                    ref.invalidate(supabaseInitializedProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (_) {
        // Once Supabase is initialized, show the app with router
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}

