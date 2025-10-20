import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crafta/screens/welcome_screen.dart';

void main() {
  group('WelcomeScreen Widget Tests', () {
    testWidgets('should display app title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      expect(find.text('Crafta'), findsOneWidget);
    });

    testWidgets('should display welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      // Check for welcome-related text
      expect(find.textContaining('Welcome', findRichText: true), findsAtLeastNWidgets(1));
    });

    testWidgets('should have Start Creating button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const WelcomeScreen(),
          routes: {
            '/creator': (context) => const Scaffold(body: Text('Creator')),
          },
        ),
      );

      // Find button by text
      final startButton = find.text('Start Creating');
      expect(startButton, findsOneWidget);
    });

    testWidgets('should navigate to creator screen when Start Creating is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const WelcomeScreen(),
          routes: {
            '/creator': (context) => const Scaffold(body: Text('Creator Screen')),
          },
        ),
      );

      // Tap the start button
      final startButton = find.text('Start Creating');
      await tester.tap(startButton);
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.text('Creator Screen'), findsOneWidget);
    });

    testWidgets('should have Parent Settings button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const WelcomeScreen(),
          routes: {
            '/parent-settings': (context) => const Scaffold(body: Text('Settings')),
          },
        ),
      );

      // Look for settings-related button
      expect(find.textContaining('Parent', findRichText: true), findsAtLeastNWidgets(1));
    });

    testWidgets('should display logo or icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      // Check for icon or image widget
      expect(
        find.byType(Icon).evaluate().isNotEmpty ||
            find.byType(Image).evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      // Should have a Scaffold
      expect(find.byType(Scaffold), findsOneWidget);

      // Should have some form of container/column for layout
      expect(
        find.byType(Column).evaluate().isNotEmpty ||
            find.byType(Center).evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('should be accessible with semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      // Check that tappable elements have semantics
      final buttons = find.byType(ElevatedButton);
      for (final button in buttons.evaluate()) {
        final semantics = tester.getSemantics(find.byWidget(button.widget));
        expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
      }
    });

    testWidgets('should handle multiple taps gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const WelcomeScreen(),
          routes: {
            '/creator': (context) => const Scaffold(body: Text('Creator')),
          },
        ),
      );

      final startButton = find.text('Start Creating');

      // Tap multiple times
      await tester.tap(startButton);
      await tester.pump();
      await tester.tap(startButton);
      await tester.pump();

      // Should not crash
      expect(tester.takeException(), isNull);
    });

    testWidgets('should display in both portrait and landscape', (WidgetTester tester) async {
      // Portrait
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      expect(find.byType(WelcomeScreen), findsOneWidget);

      // Landscape
      tester.view.physicalSize = const Size(800, 400);
      await tester.pump();

      expect(find.byType(WelcomeScreen), findsOneWidget);

      // Reset
      addTearDown(tester.view.reset);
    });
  });
}
