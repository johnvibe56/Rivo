import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rivo/core/router/app_router.dart';
import 'package:rivo/l10n/app_localizations.dart';
import 'package:rivo/core/providers/supabase_provider.dart';
import 'package:rivo/core/providers/locale_provider.dart';
import 'package:rivo/core/theme/app_theme.dart';
import 'package:rivo/core/utils/logger.dart';
import 'package:rivo/core/utils/rtl_utils.dart';

// Global router instance for easy access throughout the app
final appRouter = AppRouter();

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logger
  Logger.setDebug(true);
  
  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    
    // Initialize Supabase
    await SupabaseService.initialize(
      supabaseUrl: dotenv.env['SUPABASE_URL'] ?? '',
      supabaseAnonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
    
    // Run the app with ProviderScope and GoRouter
    runApp(
      ProviderScope(
        child: RivoApp(),
      ),
    );
  } catch (e, stackTrace) {
    Logger.e(e, stackTrace, tag: 'App Initialization');
    // Show error UI or fallback
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize app. Please try again later.'),
          ),
        ),
      ),
    );
  }
}

class RivoApp extends ConsumerWidget {
  const RivoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isRtl = RtlUtils.isRtlLocale(locale.languageCode);
    
    // Set the text direction based on the current locale
    final textDirection = isRtl ? TextDirection.rtl : TextDirection.ltr;
    
    return MaterialApp.router(
      title: 'RIVO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        platform: Platform.isIOS ? TargetPlatform.iOS : TargetPlatform.android,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        platform: Platform.isIOS ? TargetPlatform.iOS : TargetPlatform.android,
        colorScheme: ColorScheme.dark(
          primary: AppTheme.primaryColor,
          secondary: AppTheme.accentColor,
          surface: AppTheme.backgroundColor,
          error: AppTheme.errorColor,
        ),
      ),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('he'), // Hebrew
      ],
      routerConfig: appRouter.router,
      builder: (context, child) {
        return Directionality(
          textDirection: textDirection,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              // Ensure text scales with device settings
              textScaler: TextScaler.linear(
                MediaQuery.textScalerOf(context).scale(1.0),
              ),
              // Handle RTL padding
              padding: EdgeInsets.only(
                left: isRtl ? 0.0 : MediaQuery.paddingOf(context).left,
                right: isRtl ? MediaQuery.paddingOf(context).right : 0.0,
                top: MediaQuery.paddingOf(context).top,
                bottom: MediaQuery.paddingOf(context).bottom,
              ),
            ),
            child: child!,
          ),
        );
      },
    );
  }
}
