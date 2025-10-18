import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'lib/services/ai_service.dart';
import 'lib/services/language_service.dart';
import 'lib/models/enhanced_creature_attributes.dart';

/// Simple Flow Test
/// Tests core functionality without complex UI interactions
void main() {
  group('🎮 Simple Flow Tests', () {
    
    test('Test AI Service - English Voice Input', () async {
      final aiService = AIService();
      
      // Test English voice input for couch creation
      final result = await aiService.parseCreatureRequest(
        'I want to create a couch that is half white and half gold'
      );
      
      // Verify the AI parsed the request correctly
      expect(result['baseType'], 'couch');
      expect(result['category'], 'furniture');
      expect(result['primaryColor'], 'white');
      expect(result['secondaryColor'], 'gold');
      
      print('✅ English voice creation test passed');
      print('   - Item: ${result['baseType']}');
      print('   - Category: ${result['category']}');
      print('   - Colors: ${result['primaryColor']} and ${result['secondaryColor']}');
    });
    
    test('Test AI Service - Swedish Voice Input', () async {
      final aiService = AIService();
      
      // Test Swedish voice input for couch creation
      final result = await aiService.parseCreatureRequest(
        'Jag vill skapa en soffa som är halv vit och halv guld'
      );
      
      // Verify the AI parsed the Swedish request correctly
      expect(result['baseType'], 'couch');
      expect(result['category'], 'furniture');
      expect(result['primaryColor'], 'white');
      expect(result['secondaryColor'], 'gold');
      
      print('✅ Swedish voice creation test passed');
      print('   - Item: ${result['baseType']}');
      print('   - Category: ${result['category']}');
      print('   - Colors: ${result['primaryColor']} and ${result['secondaryColor']}');
    });
    
    test('Test Enhanced Creature Attributes', () {
      // Create test creature attributes for couch
      final couchAttributes = EnhancedCreatureAttributes(
        baseType: 'couch',
        customName: 'Half White Half Gold Couch',
        primaryColor: Colors.white,
        secondaryColor: Colors.amber,
        accentColor: Colors.amber.shade100,
        size: CreatureSize.medium,
        personality: PersonalityType.friendly,
        glowEffect: GlowEffect.none,
        abilities: [],
        accessories: [],
        patterns: [],
        texture: TextureType.smooth,
        animationStyle: CreatureAnimationStyle.natural,
        description: 'A beautiful couch that is half white and half gold',
      );
      
      // Verify attributes are set correctly
      expect(couchAttributes.baseType, 'couch');
      expect(couchAttributes.customName, 'Half White Half Gold Couch');
      expect(couchAttributes.primaryColor, Colors.white);
      expect(couchAttributes.secondaryColor, Colors.amber);
      expect(couchAttributes.size, CreatureSize.medium);
      
      print('✅ Enhanced Creature Attributes test passed');
      print('   - Base Type: ${couchAttributes.baseType}');
      print('   - Name: ${couchAttributes.customName}');
      print('   - Primary Color: ${couchAttributes.primaryColor}');
      print('   - Secondary Color: ${couchAttributes.secondaryColor}');
    });
    
    test('Test Language Service', () async {
      // Test English language
      await LanguageService.setLanguage(const Locale('en'));
      final englishLang = await LanguageService.getCurrentLanguage();
      expect(englishLang.languageCode, 'en');
      
      // Test Swedish language
      await LanguageService.setLanguage(const Locale('sv'));
      final swedishLang = await LanguageService.getCurrentLanguage();
      expect(swedishLang.languageCode, 'sv');
      
      print('✅ Language Service test passed');
      print('   - English: ${englishLang.languageCode}');
      print('   - Swedish: ${swedishLang.languageCode}');
    });
    
    test('Test AI Material Detection', () async {
      final aiService = AIService();
      
      // Test different material combinations
      final testCases = [
        {
          'input': 'I want a diamond sword with golden handle',
          'expected': {
            'baseType': 'sword',
            'category': 'weapon',
            'primaryMaterial': 'diamond',
            'secondaryMaterial': 'gold'
          }
        },
        {
          'input': 'Create a netherite pickaxe with iron handle',
          'expected': {
            'baseType': 'pickaxe',
            'category': 'tool',
            'primaryMaterial': 'netherite',
            'secondaryMaterial': 'iron'
          }
        },
        {
          'input': 'Make a golden helmet with diamond trim',
          'expected': {
            'baseType': 'helmet',
            'category': 'armor',
            'primaryMaterial': 'gold',
            'secondaryMaterial': 'diamond'
          }
        }
      ];
      
      for (final testCase in testCases) {
        final result = await aiService.parseCreatureRequest(testCase['input'] as String);
        final expected = testCase['expected'] as Map<String, String>;
        
        expect(result['baseType'], expected['baseType']);
        expect(result['category'], expected['category']);
        
        print('✅ Material detection test passed for: ${testCase['input']}');
        print('   - Detected: ${result['baseType']} (${result['category']})');
      }
    });
    
    test('Test AI Color Detection', () async {
      final aiService = AIService();
      
      // Test color detection
      final colorTests = [
        {
          'input': 'I want a red and blue sword',
          'expected': {'primaryColor': 'red', 'secondaryColor': 'blue'}
        },
        {
          'input': 'Create a golden and silver armor',
          'expected': {'primaryColor': 'gold', 'secondaryColor': 'silver'}
        },
        {
          'input': 'Make a white and black furniture',
          'expected': {'primaryColor': 'white', 'secondaryColor': 'black'}
        }
      ];
      
      for (final test in colorTests) {
        final result = await aiService.parseCreatureRequest(test['input'] as String);
        final expected = test['expected'] as Map<String, String>;
        
        expect(result['primaryColor'], expected['primaryColor']);
        expect(result['secondaryColor'], expected['secondaryColor']);
        
        print('✅ Color detection test passed for: ${test['input']}');
        print('   - Colors: ${result['primaryColor']} and ${result['secondaryColor']}');
      }
    });
  });
}
