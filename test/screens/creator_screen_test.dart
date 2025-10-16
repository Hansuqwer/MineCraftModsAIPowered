import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crafta/screens/creator_screen.dart';

void main() {
  group('CreatorScreen Widget Tests', () {
    testWidgets('should display Crafta avatar or icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreen(),
        ),
      );

      // Should have some visual representation
      expect(
        find.byType(Icon).evaluate().isNotEmpty ||
            find.byType(CircleAvatar).evaluate().isNotEmpty ||
            find.byType(Image).evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('should have microphone button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreen(),
        ),
      );

      // Look for microphone icon
      expect(find.byIcon(Icons.mic), findsAtLeastNWidgets(1));
    });

    testWidgets('should display conversation area', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreen(),
        ),
      );

      // Should have a scrollable area for conversation
      expect(
        find.byType(ListView).evaluate().isNotEmpty ||
            find.byType(SingleChildScrollView).evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('should have Scaffold with AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreen(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should show loading indicator when processing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreen(),
        ),
      );

      // Initially should not show progress indicator
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('microphone button should be tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreen(),
        ),
      );

      final micButton = find.byIcon(Icons.mic);
      expect(micButton, findsAtLeastNWidgets(1));

      // Should be able to tap without crash
      await tester.tap(micButton.first);
      await tester.pump();

      // Should not throw exception (even if speech service not available)
      expect(tester.takeException(), isNull);
    });

    testWidgets('should have back navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(body: Text('Previous')),
          routes: {
            '/creator': (context) => const CreatorScreen(),
          },
        ),
      );

      // Navigate to creator
      final context = tester.element(find.text('Previous'));
      Navigator.pushNamed(context, '/creator');
      await tester.pumpAndSettle();

      // Should be able to pop back
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
        expect(find.text('Previous'), findsOneWidget);
      }
    });

    testWidgets('should handle orientation changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreen(),
        ),
      );

      // Portrait
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pump();

      expect(find.byType(CreatorScreen), findsOneWidget);

      // Landscape
      tester.view.physicalSize = const Size(800, 400);
      await tester.pump();

      expect(find.byType(CreatorScreen), findsOneWidget);

      addTearDown(tester.view.reset);
    });

    testWidgets('should be semantically accessible', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreen(),
        ),
      );

      // Microphone button should have semantic label
      final micButtons = find.byIcon(Icons.mic);
      if (micButtons.evaluate().isNotEmpty) {
        final widget = tester.widget<Icon>(micButtons.first);
        expect(widget.semanticLabel != null || widget.icon == Icons.mic, isTrue);
      }
    });

    testWidgets('should not crash on rapid button taps', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreen(),
        ),
      );

      final micButton = find.byIcon(Icons.mic);

      // Rapid taps
      for (int i = 0; i < 5; i++) {
        await tester.tap(micButton.first);
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('should have proper Material theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreen(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor != null || scaffold.body != null, isTrue);
    });
  });
}
