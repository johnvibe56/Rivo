import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rivo/core/presentation/widgets/loading_widget.dart';
import 'package:rivo/features/purchase_history/application/purchase_history_notifier.dart';
import 'package:rivo/features/purchase_history/domain/models/purchase_with_product_model.dart';
import 'package:rivo/features/purchase_history/presentation/screens/purchase_history_screen.dart';

// Mock the notifier
class MockPurchaseHistoryNotifier extends Mock
    implements PurchaseHistoryNotifier {}

// A simple test widget that wraps the PurchaseHistoryScreen with necessary providers
class TestApp extends StatelessWidget {
  const TestApp({
    super.key,
    required this.notifier,
  });

  final PurchaseHistoryNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        purchaseHistoryNotifierProvider.overrideWith((ref) => notifier),
      ],
      child: const MaterialApp(
        home: PurchaseHistoryScreen(),
      ),
    );
  }
}

void main() {
  late MockPurchaseHistoryNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockPurchaseHistoryNotifier();
  });

  testWidgets('PurchaseHistoryScreen shows loading state', (tester) async {
    // Mock the state to return loading
    when(() => mockNotifier.state).thenReturn(
      const AsyncValue.data(PurchaseHistoryState.loading()),
    );

    // Build our test widget
    await tester.pumpWidget(
      TestApp(notifier: mockNotifier),
    );
    
    // Wait for the initial build to complete
    await tester.pump();
    
    // Verify loading widget is shown
    final loadingWidgetFinder = find.byType(LoadingWidget);
    expect(loadingWidgetFinder, findsOneWidget);
  });
}
