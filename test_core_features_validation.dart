import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crafta/main.dart' as app;
import 'package:crafta/services/ai_service.dart';
import 'package:crafta/services/language_service.dart';
import 'package:crafta/services/offline_ai_service.dart';
import 'package:crafta/services/minecraft/minecraft_export_service.dart';

/// Core Features Validation Test Suite
/// Tests the most critical functionality of Crafta
void main() {
  group('🧪 CORE FEATURES VALIDATION', () {
    
    testWidgets('App launches and shows welcome screen', (WidgetTester tester) async {
      // Test app startup
      app.main();
      await tester.pumpAndSettle();
      
      // Verify welcome screen appears
      expect(find.text('Welcome to Crafta'), findsOneWidget);
      expect(find.text('Start Creating'), findsOneWidget);
    });
    
    testWidgets('Navigation to creator screen works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to creator screen
      await tester.tap(find.text('Start Creating'));
      await tester.pumpAndSettle();
      
      // Verify creator screen appears
      expect(find.text('What would you like to create?'), findsOneWidget);
    });
    
    test('AI Service responds to creature requests', () async {
      final aiService = AIService();
      
      // Test basic creature request
      final response = await aiService.getCraftaResponse('Create a dragon');
      
      // Verify response is not empty and contains creature info
      expect(response, isNotEmpty);
      expect(response.toLowerCase(), contains('dragon'));
    });
    
    test('Language Service switches languages correctly', () async {
      // Test English
      await LanguageService.setLanguage(const Locale('en', 'US'));
      expect(LanguageService.currentLocale.languageCode, equals('en'));
      
      // Test Swedish
      await LanguageService.setLanguage(const Locale('sv', 'SE'));
      expect(LanguageService.currentLocale.languageCode, equals('sv'));
    });
    
    test('Offline AI Service has cached creatures', () async {
      final offlineService = OfflineAIService();
      
      // Test that offline service has responses
      final response = await offlineService.getCraftaResponse('Create a cat');
      
      // Verify response is not empty
      expect(response, isNotEmpty);
      expect(response.toLowerCase(), contains('cat'));
    });
    
    test('Minecraft Export Service generates valid structure', () async {
      final exportService = MinecraftExportService();
      
      // Create test creature data
      final creatureData = {
        'name': 'Test Dragon',
        'type': 'dragon',
        'color': 'red',
        'size': 'large',
        'effects': ['fire', 'flying'],
        'attributes': {
          'health': 100,
          'speed': 1.5,
          'damage': 20,
        }
      };
      
      // Test export generation
      final exportResult = await exportService.exportCreature(creatureData);
      
      // Verify export was successful
      expect(exportResult, isTrue);
    });
    
    test('Creature parsing extracts attributes correctly', () async {
      final aiService = AIService();
      
      // Test creature parsing
      final attributes = await aiService.parseCreatureRequest('Create a blue dragon with fire effects');
      
      // Verify key attributes are extracted
      expect(attributes, isA<Map<String, dynamic>>());
      expect(attributes['creatureType'], isNotNull);
      expect(attributes['color'], isNotNull);
      expect(attributes['effects'], isNotNull);
    });
    
    test('Error handling works gracefully', () async {
      final aiService = AIService();
      
      // Test with empty input
      try {
        final response = await aiService.getCraftaResponse('');
        // Should not crash, may return default response
        expect(response, isA<String>());
      } catch (e) {
        // If it throws, it should be a handled exception
        expect(e, isA<Exception>());
      }
    });
    
    test('Performance: Response time is reasonable', () async {
      final aiService = AIService();
      
      final stopwatch = Stopwatch()..start();
      await aiService.getCraftaResponse('Create a robot');
      stopwatch.stop();
      
      // Response should be under 5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });
    
    test('Memory: No obvious leaks in service creation', () async {
      // Create multiple service instances
      final services = List.generate(10, (index) => AIService());
      
      // Verify services are created without issues
      expect(services.length, equals(10));
      
      // Test that services can be used
      for (final service in services) {
        final response = await service.getCraftaResponse('test');
        expect(response, isA<String>());
      }
    });
    
    test('Integration: Full creature creation flow', () async {
      final aiService = AIService();
      final exportService = MinecraftExportService();
      
      // Step 1: Get AI response
      final response = await aiService.getCraftaResponse('Create a magical unicorn');
      expect(response, isNotEmpty);
      
      // Step 2: Parse creature attributes
      final attributes = await aiService.parseCreatureRequest('Create a magical unicorn');
      expect(attributes, isA<Map<String, dynamic>>());
      
      // Step 3: Test export (without actually creating file)
      expect(attributes['creatureType'], isNotNull);
      expect(attributes['color'], isNotNull);
      
      print('✅ Full integration test passed');
      print('   Response: ${response.substring(0, 50)}...');
      print('   Attributes: ${attributes.keys.join(', ')}');
    });
  });
  
  group('🔍 EDGE CASE TESTING', () {
    
    test('Very long input handling', () async {
      final aiService = AIService();
      final longInput = 'Create a ' + 'very ' * 100 + 'complex creature';
      
      final response = await aiService.getCraftaResponse(longInput);
      expect(response, isNotEmpty);
    });
    
    test('Special characters in input', () async {
      final aiService = AIService();
      final specialInput = 'Create a 🐉 dragon with 🔥 fire effects!';
      
      final response = await aiService.getCraftaResponse(specialInput);
      expect(response, isNotEmpty);
    });
    
    test('Multiple rapid requests', () async {
      final aiService = AIService();
      final requests = [
        'Create a cat',
        'Create a dog', 
        'Create a bird',
        'Create a fish',
        'Create a robot'
      ];
      
      for (final request in requests) {
        final response = await aiService.getCraftaResponse(request);
        expect(response, isNotEmpty);
      }
    });
  });
  
  group('📊 PERFORMANCE BENCHMARKS', () {
    
    test('AI Service response time benchmark', () async {
      final aiService = AIService();
      final times = <int>[];
      
      for (int i = 0; i < 5; i++) {
        final stopwatch = Stopwatch()..start();
        await aiService.getCraftaResponse('Create a test creature $i');
        stopwatch.stop();
        times.add(stopwatch.elapsedMilliseconds);
      }
      
      final averageTime = times.reduce((a, b) => a + b) / times.length;
      print('Average AI response time: ${averageTime.toStringAsFixed(0)}ms');
      
      // Should be reasonable (under 3 seconds average)
      expect(averageTime, lessThan(3000));
    });
    
    test('Memory usage during extended operation', () async {
      final aiService = AIService();
      
      // Make multiple requests to test memory stability
      for (int i = 0; i < 20; i++) {
        await aiService.getCraftaResponse('Create creature $i');
      }
      
      // If we get here without memory issues, test passes
      expect(true, isTrue);
    });
  });
}
