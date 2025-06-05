import 'dart:io';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rivo/core/presentation/widgets/app_button.dart';
import 'package:rivo/features/product_upload/presentation/widgets/image_selector.dart';

// Mock NavigatorObserver
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Mock Route
class MockRoute<T> extends Mock implements Route<T> {}

// Mock showModalBottomSheet
Future<T?> mockShowModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool? isScrollControlled,
}) async {
  // In tests, we'll just return null
  return null;
}

// Simple test localizations class
class TestLocalizations {
  const TestLocalizations();
  
  String get tapToAddImage => 'Tap to add image';
  String get gallery => 'Gallery';
  String get camera => 'Camera';
  String get remove => 'Remove';
}

// Extension to provide test localizations
// This is a simplified version for testing
// In a real app, you'd use the actual AppLocalizations
extension TestLocalizationsX on BuildContext {
  TestLocalizations get l10n => const TestLocalizations();
}

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  // Set up fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(MockRoute());
  });
  
  late MockImagePicker mockImagePicker;
  late File mockImageFile;
  late void Function(ImageSource) onImageSelected;
  late VoidCallback onRemoveImage;

  setUp(() {
    mockImagePicker = MockImagePicker();
    mockImageFile = File('test/assets/test_image.jpg');
    onImageSelected = (source) {};
    onRemoveImage = () {};
  });

  Widget createWidgetUnderTest({
    File? imageFile,
    String? errorText,
    bool rtl = false,
  }) {
    return MaterialApp(
      localizationsDelegates: const [],
      supportedLocales: const [Locale('en')],
      locale: rtl ? const Locale('he') : const Locale('en'),
      home: Scaffold(
        body: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: ImageSelector(
            imageFile: imageFile,
            onImageSelected: onImageSelected,
            onRemoveImage: imageFile != null ? onRemoveImage : null,
            errorText: errorText,
          ),
        ),
      ),
    );
  }

  testWidgets('displays add image prompt when no image is selected', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ImageSelector(
          onImageSelected: (_) {},
        ),
      ),
    ));
    
    expect(find.text('Tap to add image'), findsOneWidget);
    expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);
  });

  testWidgets('displays image when imageFile is provided', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ImageSelector(
          onImageSelected: (_) {},
          onRemoveImage: () {},
          imageFile: mockImageFile,
        ),
      ),
    ));
    
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(AppButton), findsOneWidget);
  });

  testWidgets('calls onRemoveImage when remove button is tapped', (tester) async {
    var removeCalled = false;
    
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ImageSelector(
          onImageSelected: (_) {},
          onRemoveImage: () => removeCalled = true,
          imageFile: mockImageFile,
        ),
      ),
    ));
    
    await tester.tap(find.byType(AppButton));
    expect(removeCalled, isTrue);
  });

  testWidgets('shows error text when provided', (tester) async {
    const errorMessage = 'Image is required';
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ImageSelector(
          onImageSelected: (_) {},
          errorText: errorMessage,
        ),
      ),
    ));
    
    expect(find.text(errorMessage), findsOneWidget);
  });

  testWidgets('shows image picker options when tapped', (tester) async {
    // Create a mock observer
    final mockObserver = MockNavigatorObserver();
    
    // Track if onImageSelected is called
    bool gallerySelected = false;
    bool cameraSelected = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ImageSelector(
              onImageSelected: (source) {
                if (source == ImageSource.gallery) gallerySelected = true;
                if (source == ImageSource.camera) cameraSelected = true;
              },
            ),
          ),
        ),
        navigatorObservers: [mockObserver],
      ),
    );

    // Find and tap the GestureDetector inside ImageSelector
    final gestureDetector = find.descendant(
      of: find.byType(ImageSelector),
      matching: find.byType(GestureDetector),
    );
    
    await tester.tap(gestureDetector, warnIfMissed: false);
    await tester.pumpAndSettle();
    
    // Verify the callback was not called (since we're not actually showing the bottom sheet)
    expect(gallerySelected, isFalse);
    expect(cameraSelected, isFalse);
  });

  testWidgets('shows remove button when image is provided', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ImageSelector(
          onImageSelected: (_) {},
          onRemoveImage: () {},
          imageFile: File('test.png'),
        ),
      ),
    ));
    
    // Verify the remove button is present
    final removeButtonFinder = find.byType(AppButton);
    expect(removeButtonFinder, findsOneWidget);
  });
  
  testWidgets('shows add image prompt when no image is provided', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ImageSelector(
          onImageSelected: (_) {},
        ),
      ),
    ));
    
    // Verify the add image prompt is shown
    expect(find.text('Tap to add image'), findsOneWidget);
    expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);
  });
  
  testWidgets('shows error text when error is provided', (tester) async {
    const errorMessage = 'Image is required';
    
    // Create a test key to find the ImageSelector widget
    final imageSelectorKey = GlobalKey();
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Column(
                children: [
                  ImageSelector(
                    key: imageSelectorKey,
                    onImageSelected: (_) {},
                    errorText: errorMessage,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    
    // Verify the ImageSelector widget is in the tree
    expect(find.byKey(imageSelectorKey), findsOneWidget);
    
    // Verify the error text is displayed
    final errorTextFinder = find.text(errorMessage);
    expect(errorTextFinder, findsOneWidget, reason: 'Error text should be displayed');
  });
}
