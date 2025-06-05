import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rivo/core/error/failures.dart';
import 'package:rivo/features/product_upload/domain/entities/product.dart';
import 'package:rivo/features/product_upload/presentation/screens/product_upload_screen.dart';
import 'package:rivo/features/product_upload/presentation/widgets/upload_error_widget.dart';
import 'package:rivo/features/product_upload/presentation/widgets/upload_success_widget.dart';
import 'package:rivo/l10n/app_localizations.dart';
import 'package:rivo/l10n/l10n.dart';

import '../../../../test_utils/test_utils.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mockRepository;
  late ProviderContainer container;
  late File mockImageFile;

  setUp(() {
    mockRepository = MockProductRepository();
    container = createContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    mockImageFile = File('test/assets/test_image.jpg');
  });

  testWidgets('completes product upload flow successfully', (tester) async {
    // Arrange
    when(() => mockRepository.uploadProduct(any())).thenAnswer(
      (_) async => Product.empty().copyWith(id: '123'),
    );

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProductUploadScreen(),
        ),
      ),
    );

    // Act - Enter product details
    await tester.enterText(
      find.bySemanticsLabel('Title'),
      'Test Product',
    );
    await tester.enterText(
      find.bySemanticsLabel('Description'),
      'Test Description',
    );
    await tester.enterText(
      find.bySemanticsLabel('Price'),
      '29.99',
    );

    // Simulate image selection
    // Note: In a real test, you'd need to mock the image picker

    // Submit the form
    await tester.tap(find.text('Upload'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(UploadSuccessWidget), findsOneWidget);
    verify(() => mockRepository.uploadProduct(any())).called(1);
  });

  testWidgets('shows error when upload fails', (tester) async {
    // Arrange
    when(() => mockRepository.uploadProduct(any())).thenThrow(
      const ServerFailure('Upload failed'),
    );

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProductUploadScreen(),
        ),
      ),
    );

    // Act - Submit form with empty fields to trigger validation
    await tester.tap(find.text('Upload'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(UploadErrorWidget), findsOneWidget);
  });

  testWidgets('validates required fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProductUploadScreen(),
        ),
      ),
    );

    // Act - Submit form with empty fields
    await tester.tap(find.text('Upload'));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Title is required'), findsOneWidget);
    expect(find.text('Description is required'), findsOneWidget);
    expect(find.text('Price is required'), findsOneWidget);
    expect(find.text('Image is required'), findsOneWidget);
  });

  testWidgets('handles RTL layout correctly', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          locale: const Locale('he'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Directionality(
            textDirection: TextDirection.rtl,
            child: ProductUploadScreen(),
          ),
        ),
      ),
    );

    // Verify RTL layout
    expect(
      tester.getSemantics(find.text('Title')).textDirection,
      TextDirection.rtl,
    );
  });
}
