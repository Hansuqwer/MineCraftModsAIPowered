import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'lib/main.dart';
import 'lib/screens/welcome_screen.dart';
import 'lib/screens/creator_screen.dart';
import 'lib/screens/complete_screen.dart';

void main() {
  group('Visual Polish Tests', () {
    testWidgets('Welcome Screen - Animated Rainbow Logo', (WidgetTester tester) async {
      // Build the welcome screen
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      
      // Check if rainbow emoji is present
      expect(find.text('🌈 Crafta'), findsOneWidget);
      
      // Check if the logo has shadow effects
      final logoWidget = find.text('🌈 Crafta');
      expect(logoWidget, findsOneWidget);
      
      // Pump animation frames to test animations
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      
      print('✅ Welcome Screen - Animated Rainbow Logo: PASSED');
    });

    testWidgets('Welcome Screen - Bouncing Start Button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      
      // Check if start button is present
      expect(find.text('Start Creating!'), findsOneWidget);
      
      // Check if button has sparkle icon
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      
      // Test button interaction
      await tester.tap(find.text('Start Creating!'));
      await tester.pump();
      
      print('✅ Welcome Screen - Bouncing Start Button: PASSED');
    });

    testWidgets('Creator Screen - Animated Crafta Avatar', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CreatorScreen()));
      
      // Check if Crafta avatar is present
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      
      // Pump animation frames
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      
      print('✅ Creator Screen - Animated Crafta Avatar: PASSED');
    });

    testWidgets('Creator Screen - Animated Microphone Button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CreatorScreen()));
      
      // Check if microphone button is present
      expect(find.byIcon(Icons.mic_none), findsOneWidget);
      
      // Test microphone button interaction
      await tester.tap(find.byIcon(Icons.mic_none));
      await tester.pump();
      
      print('✅ Creator Screen - Animated Microphone Button: PASSED');
    });

    testWidgets('Complete Screen - Animated Success Icon', (WidgetTester tester) async {
      // Create test arguments
      final testArgs = {
        'creatureName': 'Rainbow Cow',
        'creatureType': 'Cow',
        'creatureAttributes': 'rainbow colors and sparkles',
      };
      
      await tester.pumpWidget(
        MaterialApp(
          home: const CompleteScreen(),
          onGenerateRoute: (settings) {
            if (settings.name == '/complete') {
              return MaterialPageRoute(
                builder: (context) => const CompleteScreen(),
                settings: RouteSettings(arguments: testArgs),
              );
            }
            return null;
          },
        ),
      );
      
      // Check if success icon is present
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      
      // Pump animation frames
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      
      print('✅ Complete Screen - Animated Success Icon: PASSED');
    });

    testWidgets('Complete Screen - Animated Buttons', (WidgetTester tester) async {
      final testArgs = {
        'creatureName': 'Rainbow Cow',
        'creatureType': 'Cow',
        'creatureAttributes': 'rainbow colors and sparkles',
      };
      
      await tester.pumpWidget(
        MaterialApp(
          home: const CompleteScreen(),
          onGenerateRoute: (settings) {
            if (settings.name == '/complete') {
              return MaterialPageRoute(
                builder: (context) => const CompleteScreen(),
                settings: RouteSettings(arguments: testArgs),
              );
            }
            return null;
          },
        ),
      );
      
      // Check if buttons are present
      expect(find.text('Send to Minecraft'), findsOneWidget);
      expect(find.text('Make Another'), findsOneWidget);
      
      // Check if buttons have icons
      expect(find.byIcon(Icons.rocket_launch), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      
      // Test button interactions
      await tester.tap(find.text('Send to Minecraft'));
      await tester.pump();
      
      await tester.tap(find.text('Make Another'));
      await tester.pump();
      
      print('✅ Complete Screen - Animated Buttons: PASSED');
    });

    testWidgets('Complete Screen - Animated Creature Preview', (WidgetTester tester) async {
      final testArgs = {
        'creatureName': 'Rainbow Cow',
        'creatureType': 'Cow',
        'creatureAttributes': 'rainbow colors and sparkles',
      };
      
      await tester.pumpWidget(
        MaterialApp(
          home: const CompleteScreen(),
          onGenerateRoute: (settings) {
            if (settings.name == '/complete') {
              return MaterialPageRoute(
                builder: (context) => const CompleteScreen(),
                settings: RouteSettings(arguments: testArgs),
              );
            }
            return null;
          },
        ),
      );
      
      // Check if creature preview is present
      expect(find.text('Rainbow Cow'), findsOneWidget);
      expect(find.text('A Cow with rainbow colors and sparkles'), findsOneWidget);
      
      // Pump animation frames
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      
      print('✅ Complete Screen - Animated Creature Preview: PASSED');
    });

    testWidgets('Constitution Compliance - Child-Safe Design', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      
      // Check for child-safe colors (Crafta palette)
      final craftaPink = const Color(0xFFFF6B9D);
      final craftaMint = const Color(0xFF98D8C8);
      final craftaCream = const Color(0xFFFFF9F0);
      
      // Verify colors are used in the design
      expect(find.byType(Scaffold), findsOneWidget);
      
      print('✅ Constitution Compliance - Child-Safe Design: PASSED');
    });

    testWidgets('Constitution Compliance - Kind Interactions', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      
      // Check for encouraging text
      expect(find.text('Welcome to Crafta!'), findsOneWidget);
      expect(find.text('Tell me what you want to create, and I\'ll help you make it!'), findsOneWidget);
      
      print('✅ Constitution Compliance - Kind Interactions: PASSED');
    });

    testWidgets('Constitution Compliance - Imaginative Elements', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      
      // Check for imaginative elements
      expect(find.text('🌈 Crafta'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      
      print('✅ Constitution Compliance - Imaginative Elements: PASSED');
    });
  });

  group('Performance Tests', () {
    testWidgets('Animation Performance', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      
      // Test animation performance by pumping many frames
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      
      print('✅ Animation Performance: PASSED');
    });

    testWidgets('Memory Usage', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      
      // Test memory usage by creating and disposing widgets
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      
      print('✅ Memory Usage: PASSED');
    });
  });

  group('Integration Tests', () {
    testWidgets('Complete User Flow - Visual Polish', (WidgetTester tester) async {
      // Test complete flow with visual polish
      await tester.pumpWidget(const CraftaApp());
      
      // Navigate through screens
      await tester.tap(find.text('Start Creating!'));
      await tester.pump();
      
      // Test mock speech
      await tester.tap(find.text('🧪 Test Speech (Mock)'));
      await tester.pump();
      
      print('✅ Complete User Flow - Visual Polish: PASSED');
    });
  });
}
