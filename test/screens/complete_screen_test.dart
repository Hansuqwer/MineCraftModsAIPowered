import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crafta/screens/complete_screen.dart';

void main() {
  group('CompleteScreen Widget Tests', () {
    testWidgets('should display success message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CompleteScreen(),
        ),
      );

      // Should have congratulations or success message
      expect(
        find.textContaining('Success', findRichText: true).evaluate().isNotEmpty ||
            find.textContaining('Complete', findRichText: true).evaluate().isNotEmpty ||
            find.textContaining('Great', findRichText: true).evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('should have celebration icon or animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CompleteScreen(),
        ),
      );

      // Should have some visual celebration element
      expect(
        find.byType(Icon).evaluate().isNotEmpty ||
            find.byType(Image).evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('should have action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CompleteScreen(),
          routes: {
            '/creature-preview': (context) => const Scaffold(body: Text('Preview')),
            '/creator': (context) => const Scaffold(body: Text('Creator')),
          },
        ),
      );

      // Should have at least one action button
      expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
    });

    testWidgets('should navigate when action button tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CompleteScreen(),
          routes: {
            '/creature-preview': (context) => const Scaffold(body: Text('Preview Screen')),
            '/creator': (context) => const Scaffold(body: Text('Creator Screen')),
          },
        ),
      );

      // Find and tap first button
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pumpAndSettle();

        // Should navigate somewhere
        expect(
          find.text('Preview Screen').evaluate().isNotEmpty ||
              find.text('Creator Screen').evaluate().isNotEmpty,
          isTrue,
        );
      }
    });

    testWidgets('should have Scaffold structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CompleteScreen(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display in both orientations', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: CompleteScreen(),
        ),
      );

      expect(find.byType(CompleteScreen), findsOneWidget);

      // Landscape
      tester.view.physicalSize = const Size(800, 400);
      await tester.pump();

      expect(find.byType(CompleteScreen), findsOneWidget);

      addTearDown(tester.view.reset);
    });

    testWidgets('buttons should be accessible', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CompleteScreen(),
        ),
      );

      final buttons = find.byType(ElevatedButton);
      for (final button in buttons.evaluate()) {
        final semantics = tester.getSemantics(find.byWidget(button.widget));
        expect(semantics.hasAction(SemanticsAction.tap), isTrue);
      }
    });

    testWidgets('should not crash on rapid taps', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CompleteScreen(),
          routes: {
            '/creature-preview': (context) => const Scaffold(body: Text('Preview')),
          },
        ),
      );

      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        for (int i = 0; i < 3; i++) {
          await tester.tap(buttons.first);
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      expect(tester.takeException(), isNull);
    });
  });
}
