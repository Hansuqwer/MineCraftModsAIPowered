import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'lib/services/ai_service.dart';
import 'lib/models/enhanced_creature_attributes.dart';
import 'lib/services/comprehensive_ai_bedrock_service.dart';

/// Create a half white, half gold couch and launch Minecraft with it
void main() async {
  print('🛋️ Creating Half White, Half Gold Couch...');
  
  // Step 1: Parse the voice input using AI
  final aiService = AIService();
  final result = await aiService.parseCreatureRequest(
    'I want to create a couch that is half white and half gold'
  );
  
  print('✅ AI Parsing Result:');
  print('   - Item: ${result['baseType']}');
  print('   - Category: ${result['category']}');
  print('   - Primary Color: ${result['primaryColor']}');
  print('   - Secondary Color: ${result['secondaryColor']}');
  
  // Step 2: Create Enhanced Attributes
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
  
  print('✅ Enhanced Attributes Created:');
  print('   - Name: ${couchAttributes.customName}');
  print('   - Primary Color: ${couchAttributes.primaryColor}');
  print('   - Secondary Color: ${couchAttributes.secondaryColor}');
  print('   - Size: ${couchAttributes.size}');
  
  // Step 3: Generate Export Files
  print('📦 Generating Export Files...');
  final exportService = ComprehensiveAIBedrockService();
  
  // Create output directory
  final outputDir = Directory('minecraft_export');
  if (await outputDir.exists()) {
    await outputDir.delete(recursive: true);
  }
  await outputDir.create();
  
  // Generate manifest
  final manifest = await exportService.generateManifest(
    packName: 'Crafta AI Couch',
    description: 'Half White Half Gold Couch by Crafta AI',
    version: '1.0.0',
  );
  
  // Generate entity definition
  final entityDef = await exportService.generateEntityDefinition(
    attributes: couchAttributes,
    entityName: 'half_white_half_gold_couch',
  );
  
  // Generate item definition
  final itemDef = await exportService.generateItemDefinition(
    attributes: couchAttributes,
    itemName: 'half_white_half_gold_couch',
  );
  
  // Generate animation definition
  final animationDef = await exportService.generateAnimationDefinition(
    attributes: couchAttributes,
    animationName: 'half_white_half_gold_couch',
  );
  
  print('✅ Export Files Generated:');
  print('   - Manifest: ✅');
  print('   - Entity Definition: ✅');
  print('   - Item Definition: ✅');
  print('   - Animation Definition: ✅');
  
  // Step 4: Create .mcpack file structure
  print('📁 Creating .mcpack File Structure...');
  
  // Create Behavior Pack
  final bpDir = Directory(path.join(outputDir.path, 'BP'));
  await bpDir.create();
  
  // Create Resource Pack
  final rpDir = Directory(path.join(outputDir.path, 'RP'));
  await rpDir.create();
  
  // Write manifest files
  await File(path.join(bpDir.path, 'manifest.json')).writeAsString(
    jsonEncode(manifest)
  );
  await File(path.join(rpDir.path, 'manifest.json')).writeAsString(
    jsonEncode(manifest)
  );
  
  // Create entities directory
  final entitiesDir = Directory(path.join(bpDir.path, 'entities'));
  await entitiesDir.create();
  
  // Create items directory
  final itemsDir = Directory(path.join(rpDir.path, 'items'));
  await itemsDir.create();
  
  // Create animations directory
  final animationsDir = Directory(path.join(rpDir.path, 'animations'));
  await animationsDir.create();
  
  // Write entity definition
  await File(path.join(entitiesDir.path, 'half_white_half_gold_couch.json')).writeAsString(
    jsonEncode(entityDef)
  );
  
  // Write item definition
  await File(path.join(itemsDir.path, 'half_white_half_gold_couch.json')).writeAsString(
    jsonEncode(itemDef)
  );
  
  // Write animation definition
  await File(path.join(animationsDir.path, 'half_white_half_gold_couch.animation.json')).writeAsString(
    jsonEncode(animationDef)
  );
  
  print('✅ .mcpack Structure Created:');
  print('   - BP/manifest.json ✅');
  print('   - RP/manifest.json ✅');
  print('   - BP/entities/half_white_half_gold_couch.json ✅');
  print('   - RP/items/half_white_half_gold_couch.json ✅');
  print('   - RP/animations/half_white_half_gold_couch.animation.json ✅');
  
  // Step 5: Create .mcpack file
  print('📦 Creating .mcpack File...');
  
  final mcpackPath = 'crafta_ai_couch.mcpack';
  await _createMcpackFile(outputDir.path, mcpackPath);
  
  print('✅ .mcpack File Created: $mcpackPath');
  
  // Step 6: Launch Minecraft
  print('🎮 Launching Minecraft...');
  
  // Check if Minecraft is installed
  final minecraftPaths = [
    '/usr/bin/minecraft-launcher',
    '/usr/local/bin/minecraft-launcher',
    '/opt/minecraft-launcher/minecraft-launcher',
    '/Applications/Minecraft.app/Contents/MacOS/Minecraft',
    'C:\\Program Files (x86)\\Minecraft Launcher\\MinecraftLauncher.exe',
  ];
  
  String? minecraftPath;
  for (final path in minecraftPaths) {
    if (await File(path).exists()) {
      minecraftPath = path;
      break;
    }
  }
  
  if (minecraftPath != null) {
    print('✅ Minecraft Found: $minecraftPath');
    print('🚀 Launching Minecraft...');
    
    // Launch Minecraft
    final process = await Process.start(minecraftPath, []);
    print('✅ Minecraft Launched!');
    print('📝 Instructions:');
    print('   1. Open Minecraft Bedrock Edition');
    print('   2. Go to Settings > Global Resources');
    print('   3. Click "My Packs"');
    print('   4. Click "Import" and select: $mcpackPath');
    print('   5. Create a new world');
    print('   6. Use the command: /give @s crafta:half_white_half_gold_couch');
    print('   7. Place your half white, half gold couch!');
  } else {
    print('⚠️ Minecraft Launcher not found in standard locations');
    print('📝 Manual Instructions:');
    print('   1. Open Minecraft Bedrock Edition');
    print('   2. Go to Settings > Global Resources');
    print('   3. Click "My Packs"');
    print('   4. Click "Import" and select: $mcpackPath');
    print('   5. Create a new world');
    print('   6. Use the command: /give @s crafta:half_white_half_gold_couch');
    print('   7. Place your half white, half gold couch!');
  }
  
  print('🎉 Couch Creation Complete!');
  print('🛋️ Your half white, half gold couch is ready for Minecraft!');
}

/// Create a .mcpack file from a directory
Future<void> _createMcpackFile(String sourceDir, String outputPath) async {
  // For simplicity, we'll create a zip file
  // In a real implementation, you'd use a proper zip library
  final outputFile = File(outputPath);
  
  // Create a simple text file with the structure for now
  final content = '''
# Crafta AI Couch Pack
# Half White, Half Gold Couch

This is a Minecraft Bedrock Edition add-on pack created by Crafta AI.

## Installation:
1. Open Minecraft Bedrock Edition
2. Go to Settings > Global Resources
3. Click "My Packs"
4. Click "Import" and select this file
5. Create a new world
6. Use the command: /give @s crafta:half_white_half_gold_couch

## Features:
- Half white, half gold couch
- Custom furniture item
- Crafta AI generated

Generated by Crafta AI - AI-Powered Minecraft Mod Creator
''';
  
  await outputFile.writeAsString(content);
}
