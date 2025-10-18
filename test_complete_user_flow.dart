import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lib/main.dart' as app;
import 'lib/services/ai_service.dart';
import 'lib/services/speech_service.dart';
import 'lib/services/tts_service.dart';
import 'lib/services/language_service.dart';
import 'lib/models/enhanced_creature_attributes.dart';
import 'lib/screens/welcome_screen.dart';
import 'lib/screens/creator_screen_simple.dart';
import 'lib/screens/minecraft_3d_viewer_screen.dart';
import 'lib/services/comprehensive_ai_bedrock_service.dart';

/// Complete User Flow Test
/// Tests the entire journey from welcome page to game launch
void main() {
  group('🎮 Complete User Flow Tests', () {
    
    testWidgets('Test Welcome Page to Creator Flow', (WidgetTester tester) async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      
      // Build the app
      await tester.pumpWidget(app.MyApp());
      await tester.pumpAndSettle();
      
      // Verify welcome screen is displayed
      expect(find.text('CRAFTA'), findsOneWidget);
      expect(find.text('GET STARTED'), findsOneWidget);
      
      // Tap the get started button
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      
      // Verify we're on the creator screen
      expect(find.byType(CreatorScreenSimple), findsOneWidget);
    });
    
    testWidgets('Test Voice Creation in English', (WidgetTester tester) async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      
      // Set language to English
      await LanguageService.setLanguage(const Locale('en'));
      
      // Build the app
      await tester.pumpWidget(app.MyApp());
      await tester.pumpAndSettle();
      
      // Navigate to creator screen
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      
      // Simulate voice input for couch creation
      final aiService = AIService();
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
    
    testWidgets('Test Voice Creation in Swedish', (WidgetTester tester) async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      
      // Set language to Swedish
      await LanguageService.setLanguage(const Locale('sv'));
      
      // Build the app
      await tester.pumpWidget(app.MyApp());
      await tester.pumpAndSettle();
      
      // Navigate to creator screen
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      
      // Simulate Swedish voice input for couch creation
      final aiService = AIService();
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
    
    testWidgets('Test 3D Model Viewer', (WidgetTester tester) async {
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
      
      // Build the 3D viewer screen
      await tester.pumpWidget(
        MaterialApp(
          home: Minecraft3DViewerScreen(
            creatureAttributes: couchAttributes,
            creatureName: 'Half White Half Gold Couch',
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify 3D viewer is displayed
      expect(find.text('Your Creation'), findsOneWidget);
      expect(find.text('Half White Half Gold Couch'), findsOneWidget);
      
      print('✅ 3D Model Viewer test passed');
      print('   - Couch displayed in 3D viewer');
      print('   - Colors: White and Gold');
    });
    
    testWidgets('Test Export Functionality', (WidgetTester tester) async {
      // Create test creature attributes
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
      
      // Test export functionality
      final exportService = ComprehensiveAIBedrockService();
      
      // Generate manifest
      final manifest = await exportService.generateManifest(
        packName: 'Crafta AI Couch',
        description: 'Half White Half Gold Couch by Crafta',
        version: '1.0.0',
      );
      
      // Verify manifest structure
      expect(manifest['format_version'], 2);
      expect(manifest['header']['name'], 'Crafta AI Couch');
      expect(manifest['modules'], isA<List>());
      
      // Generate entity definition
      final entityDef = await exportService.generateEntityDefinition(
        attributes: couchAttributes,
        entityName: 'half_white_half_gold_couch',
      );
      
      // Verify entity definition
      expect(entityDef['format_version'], '1.20.0');
      expect(entityDef['minecraft:entity']['description']['identifier'], 'crafta:half_white_half_gold_couch');
      
      // Generate item definition
      final itemDef = await exportService.generateItemDefinition(
        attributes: couchAttributes,
        itemName: 'half_white_half_gold_couch',
      );
      
      // Verify item definition
      expect(itemDef['format_version'], '1.20.0');
      expect(itemDef['minecraft:item']['description']['identifier'], 'crafta:half_white_half_gold_couch');
      
      print('✅ Export functionality test passed');
      print('   - Manifest generated successfully');
      print('   - Entity definition created');
      print('   - Item definition created');
    });
    
    testWidgets('Test Complete Flow Integration', (WidgetTester tester) async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      
      // Build the app
      await tester.pumpWidget(app.MyApp());
      await tester.pumpAndSettle();
      
      // Step 1: Welcome Screen
      expect(find.text('CRAFTA'), findsOneWidget);
      await tester.tap(find.text('GET STARTED'));
      await tester.pumpAndSettle();
      
      // Step 2: Creator Screen
      expect(find.byType(CreatorScreenSimple), findsOneWidget);
      
      // Step 3: Simulate voice input
      final aiService = AIService();
      final result = await aiService.parseCreatureRequest(
        'I want to create a couch that is half white and half gold'
      );
      
      // Step 4: Create enhanced attributes
      final couchAttributes = EnhancedCreatureAttributes(
        baseType: result['baseType'] ?? 'couch',
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
      
      // Step 5: Navigate to 3D viewer
      await tester.pumpWidget(
        MaterialApp(
          home: Minecraft3DViewerScreen(
            creatureAttributes: couchAttributes,
            creatureName: 'Half White Half Gold Couch',
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify 3D viewer
      expect(find.text('Your Creation'), findsOneWidget);
      
      // Step 6: Test export
      final exportService = ComprehensiveAIBedrockService();
      final manifest = await exportService.generateManifest(
        packName: 'Crafta AI Couch',
        description: 'Half White Half Gold Couch by Crafta',
        version: '1.0.0',
      );
      
      expect(manifest['header']['name'], 'Crafta AI Couch');
      
      print('✅ Complete flow integration test passed');
      print('   - Welcome → Creator → Voice Input → 3D Viewer → Export');
      print('   - All components working together');
    });
  });
  
  group('🌍 Language Support Tests', () {
    
    testWidgets('Test English Language Support', (WidgetTester tester) async {
      await LanguageService.setLanguage(const Locale('en'));
      final currentLang = await LanguageService.getCurrentLanguage();
      expect(currentLang.languageCode, 'en');
      
      print('✅ English language support verified');
    });
    
    testWidgets('Test Swedish Language Support', (WidgetTester tester) async {
      await LanguageService.setLanguage(const Locale('sv'));
      final currentLang = await LanguageService.getCurrentLanguage();
      expect(currentLang.languageCode, 'sv');
      
      print('✅ Swedish language support verified');
    });
  });
  
  group('🎨 3D Viewer Tests', () {
    
    testWidgets('Test Couch 3D Model', (WidgetTester tester) async {
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
      
      await tester.pumpWidget(
        MaterialApp(
          home: Minecraft3DViewerScreen(
            creatureAttributes: couchAttributes,
            creatureName: 'Half White Half Gold Couch',
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify 3D viewer displays the couch
      expect(find.text('Your Creation'), findsOneWidget);
      expect(find.text('Half White Half Gold Couch'), findsOneWidget);
      
      print('✅ Couch 3D model test passed');
      print('   - Half white, half gold couch displayed');
    });
  });
  
  group('📦 Export Tests', () {
    
    testWidgets('Test Couch Export', (WidgetTester tester) async {
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
      
      final exportService = ComprehensiveAIBedrockService();
      
      // Test all export functions
      final manifest = await exportService.generateManifest(
        packName: 'Crafta AI Couch',
        description: 'Half White Half Gold Couch by Crafta',
        version: '1.0.0',
      );
      
      final entityDef = await exportService.generateEntityDefinition(
        attributes: couchAttributes,
        entityName: 'half_white_half_gold_couch',
      );
      
      final itemDef = await exportService.generateItemDefinition(
        attributes: couchAttributes,
        itemName: 'half_white_half_gold_couch',
      );
      
      final animationDef = await exportService.generateAnimationDefinition(
        attributes: couchAttributes,
        animationName: 'half_white_half_gold_couch',
      );
      
      // Verify all exports are valid
      expect(manifest['format_version'], 2);
      expect(entityDef['format_version'], '1.20.0');
      expect(itemDef['format_version'], '1.20.0');
      expect(animationDef['format_version'], '1.20.0');
      
      print('✅ Couch export test passed');
      print('   - Manifest: ✅');
      print('   - Entity Definition: ✅');
      print('   - Item Definition: ✅');
      print('   - Animation Definition: ✅');
    });
  });
}
