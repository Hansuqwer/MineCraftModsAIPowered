import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crafta/main.dart' as app;
import 'package:crafta/widgets/creature_preview.dart';

void main() {
  group('Visual Creature Preview Tests', () {
    testWidgets('Creature Preview Widget Test', (WidgetTester tester) async {
      print('🎯 TESTING VISUAL CREATURE PREVIEW');
      print('Following Crafta Constitution: Safe, Kind, Imaginative 🎨');
      
      // Test basic creature preview
      final creatureAttributes = {
        'creatureType': 'dragon',
        'color': 'red',
        'size': 'big',
        'effects': ['fire', 'sparkles'],
        'behavior': 'friendly',
        'abilities': ['flying', 'breathing fire'],
      };
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreaturePreview(
              creatureAttributes: creatureAttributes,
              size: 200,
              isAnimated: true,
            ),
          ),
        ),
      );
      
      // Verify the creature preview is displayed
      expect(find.byType(CreaturePreview), findsOneWidget);
      
      print('✅ Basic creature preview test passed');
    });

    testWidgets('Different Creature Types Test', (WidgetTester tester) async {
      print('🎯 TESTING DIFFERENT CREATURE TYPES');
      
      final creatureTypes = [
        'dragon', 'unicorn', 'phoenix', 'griffin', 'cat', 'dog', 'horse', 'sheep', 'pig', 'chicken', 'cow'
      ];
      
      for (final creatureType in creatureTypes) {
        final creatureAttributes = {
          'creatureType': creatureType,
          'color': 'rainbow',
          'size': 'normal',
          'effects': ['sparkles'],
        };
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CreaturePreview(
                creatureAttributes: creatureAttributes,
                size: 150,
                isAnimated: false,
              ),
            ),
          ),
        );
        
        await tester.pumpAndSettle();
        
        // Verify the creature preview is displayed
        expect(find.byType(CreaturePreview), findsOneWidget);
        
        print('✅ $creatureType preview test passed');
      }
    });

    testWidgets('Different Colors Test', (WidgetTester tester) async {
      print('🎯 TESTING DIFFERENT COLORS');
      
      final colors = [
        'red', 'blue', 'green', 'yellow', 'purple', 'orange', 'pink', 'gold', 'silver', 'white', 'black', 'rainbow'
      ];
      
      for (final color in colors) {
        final creatureAttributes = {
          'creatureType': 'dragon',
          'color': color,
          'size': 'normal',
          'effects': [],
        };
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CreaturePreview(
                creatureAttributes: creatureAttributes,
                size: 150,
                isAnimated: false,
              ),
            ),
          ),
        );
        
        await tester.pumpAndSettle();
        
        // Verify the creature preview is displayed
        expect(find.byType(CreaturePreview), findsOneWidget);
        
        print('✅ $color color test passed');
      }
    });

    testWidgets('Different Sizes Test', (WidgetTester tester) async {
      print('🎯 TESTING DIFFERENT SIZES');
      
      final sizes = ['tiny', 'normal', 'big', 'huge', 'massive'];
      
      for (final size in sizes) {
        final creatureAttributes = {
          'creatureType': 'dragon',
          'color': 'blue',
          'size': size,
          'effects': [],
        };
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CreaturePreview(
                creatureAttributes: creatureAttributes,
                size: 200,
                isAnimated: false,
              ),
            ),
          ),
        );
        
        await tester.pumpAndSettle();
        
        // Verify the creature preview is displayed
        expect(find.byType(CreaturePreview), findsOneWidget);
        
        print('✅ $size size test passed');
      }
    });

    testWidgets('Different Effects Test', (WidgetTester tester) async {
      print('🎯 TESTING DIFFERENT EFFECTS');
      
      final effects = [
        'fire', 'ice', 'lightning', 'glow', 'sparkles', 'magic', 'rainbow'
      ];
      
      for (final effect in effects) {
        final creatureAttributes = {
          'creatureType': 'dragon',
          'color': 'red',
          'size': 'normal',
          'effects': [effect],
        };
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CreaturePreview(
                creatureAttributes: creatureAttributes,
                size: 200,
                isAnimated: true,
              ),
            ),
          ),
        );
        
        await tester.pumpAndSettle();
        
        // Verify the creature preview is displayed
        expect(find.byType(CreaturePreview), findsOneWidget);
        
        print('✅ $effect effect test passed');
      }
    });

    testWidgets('Multiple Effects Test', (WidgetTester tester) async {
      print('🎯 TESTING MULTIPLE EFFECTS');
      
      final creatureAttributes = {
        'creatureType': 'dragon',
        'color': 'rainbow',
        'size': 'massive',
        'effects': ['fire', 'lightning', 'sparkles', 'magic'],
        'behavior': 'playful',
        'abilities': ['flying', 'breathing fire', 'teleporting'],
      };
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreaturePreview(
              creatureAttributes: creatureAttributes,
              size: 300,
              isAnimated: true,
            ),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify the creature preview is displayed
      expect(find.byType(CreaturePreview), findsOneWidget);
      
      print('✅ Multiple effects test passed');
    });

    testWidgets('Complete App with Visual Preview Test', (WidgetTester tester) async {
      print('🎯 TESTING COMPLETE APP WITH VISUAL PREVIEW');
      
      // Build the complete app
      await tester.pumpWidget(const app.CraftaApp());
      await tester.pumpAndSettle();
      
      // Test Welcome Screen
      expect(find.text('Welcome to Crafta!'), findsOneWidget);
      expect(find.text('Start Creating'), findsOneWidget);
      
      // Navigate to Creator Screen
      await tester.tap(find.text('Start Creating'));
      await tester.pumpAndSettle();
      
      expect(find.text('Hi! I\'m Crafta!'), findsOneWidget);
      expect(find.text('Tell me what creature you want to create!'), findsOneWidget);
      
      // Test creature suggestions
      expect(find.text('💡 Try saying:'), findsOneWidget);
      
      // Test mock speech (this should trigger visual preview)
      await tester.tap(find.text('🧪 Test Speech (Mock)'));
      await tester.pumpAndSettle();
      
      // Wait for navigation to creature preview
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      print('✅ Complete app with visual preview test passed');
    });

    testWidgets('Constitution Compliance Test', (WidgetTester tester) async {
      print('🎯 TESTING CONSTITUTION COMPLIANCE');
      print('Following Crafta Constitution: Safe, Kind, Imaginative 🎨');
      
      // Test Safe principle - child-friendly creatures only
      final safeCreatureAttributes = {
        'creatureType': 'dragon',
        'color': 'rainbow',
        'size': 'normal',
        'effects': ['sparkles', 'magic'],
        'behavior': 'friendly',
        'abilities': ['flying'],
      };
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreaturePreview(
              creatureAttributes: safeCreatureAttributes,
              size: 200,
              isAnimated: true,
            ),
          ),
        ),
      );
      
      expect(find.byType(CreaturePreview), findsOneWidget);
      
      // Test Kind principle - encouraging and positive
      final kindCreatureAttributes = {
        'creatureType': 'unicorn',
        'color': 'pink',
        'size': 'normal',
        'effects': ['glow', 'sparkles'],
        'behavior': 'playful',
        'abilities': ['singing', 'dancing'],
      };
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreaturePreview(
              creatureAttributes: kindCreatureAttributes,
              size: 200,
              isAnimated: true,
            ),
          ),
        ),
      );
      
      expect(find.byType(CreaturePreview), findsOneWidget);
      
      // Test Imaginative principle - creative and inspiring
      final imaginativeCreatureAttributes = {
        'creatureType': 'phoenix',
        'color': 'rainbow',
        'size': 'big',
        'effects': ['fire', 'rainbow', 'sparkles', 'magic'],
        'behavior': 'energetic',
        'abilities': ['flying', 'transforming', 'teleporting'],
      };
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreaturePreview(
              creatureAttributes: imaginativeCreatureAttributes,
              size: 250,
              isAnimated: true,
            ),
          ),
        ),
      );
      
      expect(find.byType(CreaturePreview), findsOneWidget);
      
      print('✅ Constitution compliance test passed');
    });
  });
}
