#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// 🧪 PHASE 1 TESTING - KID VOICE SYSTEM
/// Tests the enhanced voice system for kids 4-10
void main() async {
  print('🎤 PHASE 1 TESTING - KID VOICE SYSTEM');
  print('=' * 60);
  
  final results = <String, bool>{};
  
  // Test 1: Kid Voice Service Files
  print('\n📁 Test 1: Kid Voice Service Files');
  print('-' * 40);
  results['kid_voice_service'] = await testKidVoiceServiceFiles();
  
  // Test 2: Kid Voice Button Widget
  print('\n🎨 Test 2: Kid Voice Button Widget');
  print('-' * 40);
  results['kid_voice_button'] = await testKidVoiceButtonWidget();
  
  // Test 3: Voice Commands Database
  print('\n🗣️ Test 3: Voice Commands Database');
  print('-' * 40);
  results['voice_commands'] = await testVoiceCommandsDatabase();
  
  // Test 4: Kid-Friendly Features
  print('\n👶 Test 4: Kid-Friendly Features');
  print('-' * 40);
  results['kid_features'] = await testKidFriendlyFeatures();
  
  // Test 5: Integration Points
  print('\n🔗 Test 5: Integration Points');
  print('-' * 40);
  results['integration'] = await testIntegrationPoints();
  
  // Generate Final Report
  print('\n📊 PHASE 1 TESTING REPORT');
  print('=' * 60);
  generatePhase1Report(results);
}

/// Test 1: Kid Voice Service Files
Future<bool> testKidVoiceServiceFiles() async {
  try {
    // Check if KidVoiceService exists
    final kidVoiceServiceFile = File('lib/services/kid_voice_service.dart');
    if (!await kidVoiceServiceFile.exists()) {
      print('❌ KidVoiceService file missing');
      return false;
    }
    
    print('✅ KidVoiceService file exists');
    
    // Check file content for key features
    final content = await kidVoiceServiceFile.readAsString();
    
    // Check for kid-friendly features
    final requiredFeatures = [
      'listenForKids',
      'parseKidVoice',
      'getEncouragement',
      'getRandomEncouragement',
      '_kidCommands',
      '_encouragements',
      'Duration(seconds: 15)', // Longer timeout
      'confidence > 0.2', // Lower confidence threshold
      '_maxAttempts = 3', // Multiple attempts
    ];
    
    int foundFeatures = 0;
    for (final feature in requiredFeatures) {
      if (content.contains(feature)) {
        foundFeatures++;
        print('  ✅ $feature');
      } else {
        print('  ❌ Missing: $feature');
      }
    }
    
    final success = foundFeatures >= requiredFeatures.length * 0.8; // 80% success rate
    print('📊 Found $foundFeatures/${requiredFeatures.length} features (${(foundFeatures/requiredFeatures.length*100).round()}%)');
    
    return success;
  } catch (e) {
    print('❌ Error testing KidVoiceService: $e');
    return false;
  }
}

/// Test 2: Kid Voice Button Widget
Future<bool> testKidVoiceButtonWidget() async {
  try {
    // Check if KidVoiceButton exists
    final kidVoiceButtonFile = File('lib/widgets/kid_voice_button.dart');
    if (!await kidVoiceButtonFile.exists()) {
      print('❌ KidVoiceButton file missing');
      return false;
    }
    
    print('✅ KidVoiceButton file exists');
    
    // Check file content for kid-friendly UI features
    final content = await kidVoiceButtonFile.readAsString();
    
    // Check for kid-friendly UI features
    final requiredUIFeatures = [
      'width: 140', // Large button size
      'height: 140',
      'size: 70', // Large icon size
      'AnimatedBuilder',
      'Transform.scale',
      'LinearGradient',
      'BoxShadow',
      'Colors.purple',
      'Colors.pink',
      'Colors.blue',
      'Colors.cyan',
      'Colors.teal',
      'Colors.green',
      'Icons.mic',
      'Icons.mic_none',
      'fiber_manual_record', // Listening indicator
    ];
    
    int foundUIFeatures = 0;
    for (final feature in requiredUIFeatures) {
      if (content.contains(feature)) {
        foundUIFeatures++;
        print('  ✅ $feature');
      } else {
        print('  ❌ Missing: $feature');
      }
    }
    
    final success = foundUIFeatures >= requiredUIFeatures.length * 0.8;
    print('📊 Found $foundUIFeatures/${requiredUIFeatures.length} UI features (${(foundUIFeatures/requiredUIFeatures.length*100).round()}%)');
    
    return success;
  } catch (e) {
    print('❌ Error testing KidVoiceButton: $e');
    return false;
  }
}

/// Test 3: Voice Commands Database
Future<bool> testVoiceCommandsDatabase() async {
  try {
    final kidVoiceServiceFile = File('lib/services/kid_voice_service.dart');
    final content = await kidVoiceServiceFile.readAsString();
    
    // Check for comprehensive voice commands
    final requiredCommands = [
      // Create commands
      'make me', 'I want', 'can you make', 'create', 'build me',
      'give me', 'show me', 'let me have', 'I need', 'please make',
      
      // Items
      'dragon', 'cat', 'dog', 'unicorn', 'phoenix', 'dinosaur',
      'sword', 'shield', 'bow', 'arrow', 'magic wand',
      'car', 'truck', 'boat', 'plane', 'rocket', 'spaceship',
      'house', 'castle', 'tower', 'bridge', 'tunnel',
      'princess', 'knight', 'wizard', 'pirate', 'superhero',
      
      // Colors
      'red', 'blue', 'green', 'yellow', 'purple', 'pink',
      'rainbow', 'gold', 'silver', 'magic', 'sparkly',
      
      // Effects
      'big', 'small', 'huge', 'tiny', 'flying', 'glowing',
      'sparkly', 'magic', 'super', 'mega', 'fire', 'ice'
    ];
    
    int foundCommands = 0;
    for (final command in requiredCommands) {
      if (content.contains(command)) {
        foundCommands++;
        print('  ✅ "$command"');
      } else {
        print('  ❌ Missing: "$command"');
      }
    }
    
    final success = foundCommands >= requiredCommands.length * 0.8;
    print('📊 Found $foundCommands/${requiredCommands.length} voice commands (${(foundCommands/requiredCommands.length*100).round()}%)');
    
    return success;
  } catch (e) {
    print('❌ Error testing voice commands: $e');
    return false;
  }
}

/// Test 4: Kid-Friendly Features
Future<bool> testKidFriendlyFeatures() async {
  try {
    final kidVoiceServiceFile = File('lib/services/kid_voice_service.dart');
    final content = await kidVoiceServiceFile.readAsString();
    
    // Check for kid-friendly features
    final kidFeatures = [
      // Encouragement system
      'Wow! You\'re so creative!',
      'That\'s an amazing idea!',
      'You\'re becoming a great builder!',
      'I love your imagination!',
      'You\'re doing fantastic!',
      
      // Multiple attempts
      '_maxAttempts = 3',
      'attemptCount',
      'getEncouragement',
      
      // Lower confidence threshold
      'confidence > 0.2',
      
      // Longer timeouts
      'Duration(seconds: 15)',
      'Duration(seconds: 4)',
      
      // Kid-friendly prompts
      'getKidPrompts',
      'Say \'Make me a dragon!\'',
      'Try \'I want a blue sword!\'',
      
      // Smart parsing
      'parseKidVoice',
      'fuzzy matching',
      'smart defaults'
    ];
    
    int foundFeatures = 0;
    for (final feature in kidFeatures) {
      if (content.contains(feature)) {
        foundFeatures++;
        print('  ✅ $feature');
      } else {
        print('  ❌ Missing: $feature');
      }
    }
    
    final success = foundFeatures >= kidFeatures.length * 0.8;
    print('📊 Found $foundFeatures/${kidFeatures.length} kid-friendly features (${(foundFeatures/kidFeatures.length*100).round()}%)');
    
    return success;
  } catch (e) {
    print('❌ Error testing kid-friendly features: $e');
    return false;
  }
}

/// Test 5: Integration Points
Future<bool> testIntegrationPoints() async {
  try {
    // Check if integration points exist
    final integrationFiles = [
      'lib/screens/minecraft_3d_viewer_screen.dart',
      'lib/screens/enhanced_modern_screen.dart',
      'lib/screens/creator_screen_simple.dart',
    ];
    
    int foundIntegrations = 0;
    for (final filePath in integrationFiles) {
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.contains('SpeechService') || content.contains('_speechService')) {
          foundIntegrations++;
          print('  ✅ $filePath - Speech integration found');
        } else {
          print('  ❌ $filePath - No speech integration');
        }
      } else {
        print('  ❌ $filePath - File missing');
      }
    }
    
    final success = foundIntegrations >= integrationFiles.length * 0.8;
    print('📊 Found $foundIntegrations/${integrationFiles.length} integration points (${(foundIntegrations/integrationFiles.length*100).round()}%)');
    
    return success;
  } catch (e) {
    print('❌ Error testing integration points: $e');
    return false;
  }
}

/// Generate Phase 1 Report
void generatePhase1Report(Map<String, bool> results) {
  final passed = results.values.where((v) => v).length;
  final total = results.length;
  final percentage = ((passed / total) * 100).round();
  
  print('📊 PHASE 1 TEST RESULTS');
  print('-' * 30);
  
  for (final entry in results.entries) {
    final status = entry.value ? '✅ PASSED' : '❌ FAILED';
    print('${entry.key.padRight(20)}: $status');
  }
  
  print('-' * 30);
  print('TOTAL: $passed/$total tests passed ($percentage%)');
  
  if (percentage >= 90) {
    print('🎉 EXCELLENT! Phase 1 is ready for testing!');
  } else if (percentage >= 70) {
    print('⚠️ GOOD! Some improvements needed.');
  } else {
    print('🚨 CRITICAL! Major issues need fixing.');
  }
  
  // Save results to file
  final reportFile = File('PHASE_1_TEST_RESULTS_${DateTime.now().millisecondsSinceEpoch}.json');
  reportFile.writeAsStringSync(jsonEncode({
    'timestamp': DateTime.now().toIso8601String(),
    'phase': 'Phase 1 - Kid Voice System',
    'results': results,
    'summary': {
      'passed': passed,
      'total': total,
      'percentage': percentage
    }
  }));
  
  print('\n📄 Detailed report saved to: ${reportFile.path}');
}


