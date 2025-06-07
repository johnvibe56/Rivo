import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/features/purchase_history/application/purchase_history_notifier.dart';
import 'package:rivo/features/purchase_history/domain/models/purchase_with_product_model.dart';
import 'package:rivo/features/purchase_history/presentation/screens/purchase_history_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Mock notifier that implements PurchaseHistoryNotifier
class MockPurchaseHistoryNotifier extends StateNotifier<AsyncValue<PurchaseHistoryState>>
    with Mock
    implements PurchaseHistoryNotifier {
  MockPurchaseHistoryNotifier() : super(const AsyncValue.loading()) {
    // Initialize with empty state
    state = const AsyncValue.data(PurchaseHistoryState.loaded([]));
  }

  @override
  Future<void> fetchPurchases() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 100));
    state = const AsyncValue.data(PurchaseHistoryState.loaded([]));
  }
}

// Mock notifier that implements PurchaseHistoryNotifier
class MockPurchaseHistoryNotifier extends StateNotifier<AsyncValue<PurchaseHistoryState>>
    with Mock
    implements PurchaseHistoryNotifier {
  MockPurchaseHistoryNotifier() : super(const AsyncValue.loading()) {
    // Initialize with empty state
    state = const AsyncValue.data(PurchaseHistoryState.loaded([]));
  }

  @override
  Future<void> fetchPurchases() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 100));
    state = const AsyncValue.data(PurchaseHistoryState.loaded([]));
  }
}



void main() {
  late MockPurchaseHistoryNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockPurchaseHistoryNotifier();
    // Register fallback values for Mocktail
    registerFallbackValue(const AsyncValue.loading());
  });

  testWidgets('PurchaseHistoryScreen integration test', (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          purchaseHistoryNotifierProvider.overrideWith((ref) => mockNotifier),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('he'),
          ],
          locale: const Locale('en'),
          home: const PurchaseHistoryScreen(),
        ),
      ),
    );
    
    // Initial loading state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Wait for initial load to complete
    await tester.pumpAndSettle();
    
    // Verify empty state is shown
    expect(find.text('No purchases yet'), findsOneWidget);
    
    // Test pull-to-refresh
    await tester.fling(
      find.byType(RefreshIndicator),
      const Offset(0, 300),
      1000, // velocity
    );
    
    // Verify loading indicator appears during refresh
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Wait for refresh to complete
    await tester.pumpAndSettle();
    
    // Verify empty state is still shown after refresh
    expect(find.text('No purchases yet'), findsOneWidget);
    
    // Test error state
    mockNotifier.state = AsyncValue.error(
      const ServerFailure('Test error'),
      StackTrace.current,
    );
    await tester.pumpAndSettle();
    
    // Verify error message is shown
    expect(find.text('Failed to load data. Please try again later.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    
    // Test retry button
    final retryButton = find.text('Retry');
    await tester.tap(retryButton);
    await tester.pumpAndSettle();
    
    // Verify loading state during retry
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Complete the retry with success
    mockNotifier.state = const AsyncValue.data(PurchaseHistoryState.loaded([]));
    await tester.pumpAndSettle();
    
    // Verify empty state is shown again
    expect(find.text('No purchases yet'), findsOneWidget);
    expect(find.text('No purchases yet'), findsOneWidget);
  });

  testWidgets('PurchaseHistoryScreen error state', (tester) async {
    // Set up error state
    mockNotifier.state = AsyncValue.error(
      const ServerFailure('Test error'),
      StackTrace.current,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          purchaseHistoryNotifierProvider.overrideWith((ref) => mockNotifier),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PurchaseHistoryScreen(),
        ),
      ),
    );

    // Wait for initial build
    await tester.pump();

    // Verify error message is shown
    expect(
      find.text('Unable to load purchases. Please try again later.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);

    // Test retry button
    await tester.tap(find.text('Retry'));
    await tester.pump();

    // Verify loading state during retry
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('PurchaseHistoryScreen unauthorized state', (tester) async {
    // Set up unauthorized state
    mockNotifier.state = const AsyncValue.data(
      PurchaseHistoryState.error(UnauthorizedFailure()),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          purchaseHistoryNotifierProvider.overrideWith((ref) => mockNotifier),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PurchaseHistoryScreen(),
        ),
      ),
    );

    // Wait for initial build
    await tester.pump();

    // Verify unauthorized message is shown
    expect(
      find.text('Please sign in to view your purchase history'),
      findsOneWidget,
    );
    expect(find.text('Login'), findsOneWidget);
  });
}
