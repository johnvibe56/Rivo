import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/features/purchase_history/application/purchase_history_notifier.dart';
import 'package:rivo/features/purchase_history/domain/models/purchase_with_product_model.dart';
import 'package:rivo/features/purchase_history/domain/repositories/purchase_history_repository.dart';
import 'package:rivo/features/purchase_history/presentation/screens/purchase_history_screen.dart';

class MockPurchaseHistoryRepository extends Mock
    implements PurchaseHistoryRepository {}

class TestPurchaseHistoryNotifier extends PurchaseHistoryNotifier {
  @override
  FutureOr<PurchaseHistoryState> build() {
    return state.value ?? const PurchaseHistoryState.initial();
  }
}

void main() {
  final testDate = DateTime(2023, 1, 1);
  
  setUp(() {
    // Setup code if needed
  });

  testWidgets('shows loading indicator when loading', (tester) async {    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          purchaseHistoryNotifierProvider.overrideWith(TestPurchaseHistoryNotifier.new),
        ],
        child: const MaterialApp(
          home: PurchaseHistoryScreen(),
        ),
      ),
    );

    // Verify loading indicator is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows empty state when no purchases', (tester) async {
    final container = ProviderContainer(overrides: [
      purchaseHistoryNotifierProvider.overrideWith(TestPurchaseHistoryNotifier.new),
    ]);
    
    // Set the state after the container is created
    container.read(purchaseHistoryNotifierProvider.notifier).state = 
        const AsyncValue.data(PurchaseHistoryState.loaded([]));
    
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: PurchaseHistoryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No purchases yet'), findsOneWidget);
    expect(find.text('Your purchases will appear here'), findsOneWidget);
  });

  testWidgets('shows list of purchases when loaded', (tester) async {
    final container = ProviderContainer(overrides: [
      purchaseHistoryNotifierProvider.overrideWith(TestPurchaseHistoryNotifier.new),
    ]);
    
    // Set the state after the container is created
    container.read(purchaseHistoryNotifierProvider.notifier).state = 
        AsyncValue.data(
          PurchaseHistoryState.loaded([
            PurchaseWithProduct(
              id: '1',
              createdAt: testDate,
              product: const ProductDetails(
                id: 'p1',
                name: 'Test Product',
                imageUrl: 'https://example.com/image.jpg',
                price: 19.99,
              ),
            ),
          ]),
        );
    
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: PurchaseHistoryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('\$19.99'), findsOneWidget);
  });

  testWidgets('shows error message when fetch fails', (tester) async {
    final container = ProviderContainer(overrides: [
      purchaseHistoryNotifierProvider.overrideWith(TestPurchaseHistoryNotifier.new),
    ]);
    
    // Set the error state after the container is created
    container.read(purchaseHistoryNotifierProvider.notifier).state = 
        AsyncValue.error(
          const ServerFailure('Failed to load purchases'),
          StackTrace.current,
        );
    
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: PurchaseHistoryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Error loading purchases'), findsOneWidget);
    expect(find.text('Failed to load purchases'), findsOneWidget);
  });
}
