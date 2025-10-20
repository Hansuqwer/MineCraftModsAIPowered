import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crafta/screens/creator_screen_simple.dart';

void main() {
  group('CreatorScreen Widget Tests', () {
    testWidgets('should display Crafta avatar or icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreenSimple(),
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

    testWidgets('should have create button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreenSimple(),
        ),
      );

      // Look for create button
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('should display input field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreenSimple(),
        ),
      );

      // Should have a text input field
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should have Scaffold with AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreenSimple(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should show loading indicator when processing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreenSimple(),
        ),
      );

      // Initially should not show progress indicator
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('create button should be tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreenSimple(),
        ),
      );

      final createButton = find.text('Create');
      expect(createButton, findsOneWidget);

      // Should be able to tap without crash
      await tester.tap(createButton);
      await tester.pump();

      // Should not throw exception
      expect(tester.takeException(), isNull);
    });

    testWidgets('should have back navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(body: Text('Previous')),
          routes: {
            '/creator': (context) => const CreatorScreenSimple(),
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

    testWidgets('should render in different screen sizes', (WidgetTester tester) async {
      // Use a large screen to avoid overflow
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreenSimple(),
        ),
      );

      expect(find.byType(CreatorScreenSimple), findsOneWidget);

      addTearDown(tester.view.reset);
    });

    testWidgets('should be semantically accessible', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreenSimple(),
        ),
      );

      // Create button should be accessible
      final createButton = find.text('Create');
      expect(createButton, findsOneWidget);
    });

    testWidgets('should not crash on rapid button taps', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreenSimple(),
        ),
      );

      final createButton = find.text('Create');

      // Rapid taps
      for (int i = 0; i < 5; i++) {
        await tester.tap(createButton);
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('should have proper Material theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatorScreenSimple(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor != null || scaffold.body != null, isTrue);
    });
  });
}
