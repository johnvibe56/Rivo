import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivo/core/presentation/screens/app_loading_screen.dart';
import 'package:rivo/main.dart';

void main() {
  testWidgets('App loads with loading screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AppLoadingScreen(),
        ),
      ),
    );

    // Verify that loading text is shown
    expect(find.text('Loading...'), findsOneWidget);
  });

  testWidgets('Main app widget renders', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: RivoApp(),
      ),
    );

    // Verify the app renders
    expect(find.byType(RivoApp), findsOneWidget);
  });
}
