import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivo/features/product_upload/presentation/widgets/upload_form_fields.dart';
import 'package:rivo/l10n/app_localizations.dart';
import 'package:rivo/l10n/l10n.dart';

void main() {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late bool isSubmitting;
  late bool titleChangedCalled;
  late bool descriptionChangedCalled;
  late bool priceChangedCalled;
  late bool imageRemovedCalled;
  late bool imageSelectedCalled;

  setUp(() {
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    priceController = TextEditingController();
    isSubmitting = false;
    titleChangedCalled = false;
    descriptionChangedCalled = false;
    priceChangedCalled = false;
    imageRemovedCalled = false;
    imageSelectedCalled = false;
  });

  Widget createWidgetUnderTest({bool rtl = false}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: rtl ? const Locale('he') : const Locale('en'),
      home: Scaffold(
        body: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: UploadFormFields(
            titleController: titleController,
            descriptionController: descriptionController,
            priceController: priceController,
            imageFile: null,
            isSubmitting: isSubmitting,
            onTitleChanged: (_) => titleChangedCalled = true,
            onDescriptionChanged: (_) => descriptionChangedCalled = true,
            onPriceChanged: (_) => priceChangedCalled = true,
            onImageRemoved: () => imageRemovedCalled = true,
            onImageSelected: (_) => imageSelectedCalled = true,
          ),
        ),
      ),
    );
  }

  testWidgets('renders all form fields', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.byType(ImageSelector), findsOneWidget);
  });

  testWidgets('calls callbacks when text fields change', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    
    await tester.enterText(find.byType(TextFormField).at(0), 'Test Title');
    expect(titleChangedCalled, isTrue);
    
    await tester.enterText(find.byType(TextFormField).at(1), 'Test Description');
    expect(descriptionChangedCalled, isTrue);
    
    await tester.enterText(find.byType(TextFormField).at(2), '10.99');
    expect(priceChangedCalled, isTrue);
  });

  testWidgets('shows validation errors when isSubmitting is true', (tester) async {
    isSubmitting = true;
    await tester.pumpWidget(createWidgetUnderTest());
    
    // Trigger validation
    await tester.pump();
    
    expect(find.text('Title is required'), findsOneWidget);
    expect(find.text('Description is required'), findsOneWidget);
    expect(find.text('Price is required'), findsOneWidget);
  });

  testWidgets('respects RTL layout', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(rtl: true));
    
    final titleField = tester.widget<TextFormField>(find.byType(TextFormField).at(0));
    expect(titleField.textDirection, TextDirection.rtl);
    
    final descriptionField = tester.widget<TextFormField>(find.byType(TextFormField).at(1));
    expect(descriptionField.textDirection, TextDirection.rtl);
    
    final priceField = tester.widget<TextFormField>(find.byType(TextFormField).at(2));
    expect(priceField.textDirection, TextDirection.rtl);
  });

  testWidgets('disables fields when isSubmitting is true', (tester) async {
    isSubmitting = true;
    await tester.pumpWidget(createWidgetUnderTest());
    
    final textFields = tester.widgetList<TextFormField>(find.byType(TextFormField));
    for (final field in textFields) {
      expect(field.enabled, isFalse);
    }
  });
}
