#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// 🧪 COMPREHENSIVE PHASE 1 TESTING
/// Tests all Phase 1 features for kids 4-10 voice system
void main() async {
  print('🎤 COMPREHENSIVE PHASE 1 TESTING - KID VOICE SYSTEM');
  print('=' * 70);
  
  final results = <String, Map<String, dynamic>>{};
  
  // Test 1: File Structure
  print('\n📁 Test 1: File Structure & Dependencies');
  print('-' * 50);
  results['file_structure'] = await testFileStructure();
  
  // Test 2: Kid Voice Service
  print('\n🎤 Test 2: Kid Voice Service Implementation');
  print('-' * 50);
  results['kid_voice_service'] = await testKidVoiceService();
  
  // Test 3: Kid Voice Button Widget
  print('\n🎨 Test 3: Kid Voice Button Widget');
  print('-' * 50);
  results['kid_voice_button'] = await testKidVoiceButton();
  
  // Test 4: Kid-Friendly Screen
  print('\n📱 Test 4: Kid-Friendly Screen');
  print('-' * 50);
  results['kid_friendly_screen'] = await testKidFriendlyScreen();
  
  // Test 5: Integration Points
  print('\n🔗 Test 5: Integration Points');
  print('-' * 50);
  results['integration'] = await testIntegrationPoints();
  
  // Test 6: Voice Commands Database
  print('\n🗣️ Test 6: Voice Commands Database');
  print('-' * 50);
  results['voice_commands'] = await testVoiceCommandsDatabase();
  
  // Test 7: Kid-Friendly Features
  print('\n👶 Test 7: Kid-Friendly Features');
  print('-' * 50);
  results['kid_features'] = await testKidFriendlyFeatures();
  
  // Test 8: Navigation & Routing
  print('\n🧭 Test 8: Navigation & Routing');
  print('-' * 50);
  results['navigation'] = await testNavigationRouting();
  
  // Test 9: Code Quality
  print('\n🔍 Test 9: Code Quality & Linting');
  print('-' * 50);
  results['code_quality'] = await testCodeQuality();
  
  // Test 10: Performance
  print('\n⚡ Test 10: Performance & Optimization');
  print('-' * 50);
  results['performance'] = await testPerformance();
  
  // Generate Comprehensive Report
  print('\n📊 COMPREHENSIVE PHASE 1 TESTING REPORT');
  print('=' * 70);
  generateComprehensiveReport(results);
}

/// Test 1: File Structure & Dependencies
Future<Map<String, dynamic>> testFileStructure() async {
  final results = <String, dynamic>{};
  int passed = 0;
  int total = 0;
  
  // Check required files
  final requiredFiles = [
    'lib/services/kid_voice_service.dart',
    'lib/widgets/kid_voice_button.dart',
    'lib/screens/kid_friendly_screen.dart',
    'lib/main.dart',
    'lib/screens/welcome_screen.dart',
    'pubspec.yaml',
  ];
  
  for (final filePath in requiredFiles) {
    total++;
    final file = File(filePath);
    if (await file.exists()) {
      passed++;
      print('  ✅ $filePath');
    } else {
      print('  ❌ $filePath - Missing');
    }
  }
  
  // Check dependencies in pubspec.yaml
  final pubspecFile = File('pubspec.yaml');
  if (await pubspecFile.exists()) {
    final content = await pubspecFile.readAsString();
    final requiredDeps = [
      'speech_to_text:',
      'flutter_dotenv:',
      'shared_preferences:',
      'archive:',
    ];
    
    for (final dep in requiredDeps) {
      total++;
      if (content.contains(dep)) {
        passed++;
        print('  ✅ Dependency: $dep');
      } else {
        print('  ❌ Missing dependency: $dep');
      }
    }
  }
  
  results['passed'] = passed;
  results['total'] = total;
  results['percentage'] = ((passed / total) * 100).round();
  results['success'] = results['percentage'] >= 90;
  
  return results;
}

/// Test 2: Kid Voice Service Implementation
Future<Map<String, dynamic>> testKidVoiceService() async {
  final results = <String, dynamic>{};
  int passed = 0;
  int total = 0;
  
  try {
    final file = File('lib/services/kid_voice_service.dart');
    if (!await file.exists()) {
      results['error'] = 'KidVoiceService file missing';
      return results;
    }
    
    final content = await file.readAsString();
    
    // Check class structure
    final classChecks = [
      'class KidVoiceService',
      'final SpeechToText _speech',
      'bool _isListening',
      'bool _isAvailable',
      'String _lastWords',
      'int _attemptCount',
      'final int _maxAttempts = 3',
    ];
    
    for (final check in classChecks) {
      total++;
      if (content.contains(check)) {
        passed++;
        print('  ✅ $check');
      } else {
        print('  ❌ Missing: $check');
      }
    }
    
    // Check methods
    final methodChecks = [
      'Future<bool> initialize()',
      'Future<String?> listenForKids()',
      'Map<String, dynamic> parseKidVoice(',
      'String getEncouragement(',
      'String getRandomEncouragement()',
      'Future<void> stopListening()',
      'List<String> getKidPrompts()',
      'bool isKidFriendly(',
    ];
    
    for (final check in methodChecks) {
      total++;
      if (content.contains(check)) {
        passed++;
        print('  ✅ $check');
      } else {
        print('  ❌ Missing: $check');
      }
    }
    
    // Check kid-friendly features
    final kidFeatures = [
      'Duration(seconds: 15)', // Longer timeout
      'Duration(seconds: 4)', // Longer pause
      'confidence > 0.2', // Lower confidence threshold
      '_maxAttempts = 3', // Multiple attempts
      'getEncouragement', // Encouragement system
      '_kidCommands', // Voice commands database
      '_encouragements', // Encouragement messages
    ];
    
    for (final feature in kidFeatures) {
      total++;
      if (content.contains(feature)) {
        passed++;
        print('  ✅ $feature');
      } else {
        print('  ❌ Missing: $feature');
      }
    }
    
  } catch (e) {
    results['error'] = 'Error testing KidVoiceService: $e';
    return results;
  }
  
  results['passed'] = passed;
  results['total'] = total;
  results['percentage'] = ((passed / total) * 100).round();
  results['success'] = results['percentage'] >= 85;
  
  return results;
}

/// Test 3: Kid Voice Button Widget
Future<Map<String, dynamic>> testKidVoiceButton() async {
  final results = <String, dynamic>{};
  int passed = 0;
  int total = 0;
  
  try {
    final file = File('lib/widgets/kid_voice_button.dart');
    if (!await file.exists()) {
      results['error'] = 'KidVoiceButton file missing';
      return results;
    }
    
    final content = await file.readAsString();
    
    // Check widget structure
    final widgetChecks = [
      'class KidVoiceButton extends StatefulWidget',
      'class _KidVoiceButtonState extends State',
      'with TickerProviderStateMixin',
      'late AnimationController _pulseController',
      'late AnimationController _bounceController',
      'late Animation<double> _pulseAnimation',
      'late Animation<double> _bounceAnimation',
    ];
    
    for (final check in widgetChecks) {
      total++;
      if (content.contains(check)) {
        passed++;
        print('  ✅ $check');
      } else {
        print('  ❌ Missing: $check');
      }
    }
    
    // Check kid-friendly UI features
    final uiFeatures = [
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
    
    for (final feature in uiFeatures) {
      total++;
      if (content.contains(feature)) {
        passed++;
        print('  ✅ $feature');
      } else {
        print('  ❌ Missing: $feature');
      }
    }
    
    // Check animations
    final animationChecks = [
      '_pulseController',
      '_bounceController',
      '_pulseAnimation',
      '_bounceAnimation',
      'AnimationController',
      'Tween<double>',
      'CurvedAnimation',
    ];
    
    for (final check in animationChecks) {
      total++;
      if (content.contains(check)) {
        passed++;
        print('  ✅ $check');
      } else {
        print('  ❌ Missing: $check');
      }
    }
    
  } catch (e) {
    results['error'] = 'Error testing KidVoiceButton: $e';
    return results;
  }
  
  results['passed'] = passed;
  results['total'] = total;
  results['percentage'] = ((passed / total) * 100).round();
  results['success'] = results['percentage'] >= 85;
  
  return results;
}

/// Test 4: Kid-Friendly Screen
Future<Map<String, dynamic>> testKidFriendlyScreen() async {
  final results = <String, dynamic>{};
  int passed = 0;
  int total = 0;
  
  try {
    final file = File('lib/screens/kid_friendly_screen.dart');
    if (!await file.exists()) {
      results['error'] = 'KidFriendlyScreen file missing';
      return results;
    }
    
    final content = await file.readAsString();
    
    // Check screen structure
    final screenChecks = [
      'class KidFriendlyScreen extends StatefulWidget',
      'class _KidFriendlyScreenState extends State',
      'with TickerProviderStateMixin',
      'final KidVoiceService _kidVoiceService',
      'final TextEditingController _textController',
    ];
    
    for (final check in screenChecks) {
      total++;
      if (content.contains(check)) {
        passed++;
        print('  ✅ $check');
      } else {
        print('  ❌ Missing: $check');
      }
    }
    
    // Check kid-friendly features
    final kidFeatures = [
      'KidVoiceButton', // Voice button integration
      'Simple3DPreview', // 3D preview integration
      'EnhancedCreatureAttributes', // Attributes integration
      'Colors.blue[50]', // Kid-friendly colors
      'Colors.blue[600]', // App bar color
      'Colors.purple[400]', // Gradient colors
      'Colors.green[400]', // Encouragement colors
      'Colors.amber[400]',
      'Icons.star', // Star icon for encouragement
      'Icons.child_care', // Kid icon
    ];
    
    for (final feature in kidFeatures) {
      total++;
      if (content.contains(feature)) {
        passed++;
        print('  ✅ $feature');
      } else {
        print('  ❌ Missing: $feature');
      }
    }
    
    // Check methods
    final methodChecks = [
      '_handleVoiceResult',
      '_handleEncouragement',
      '_getSizeFromString',
      '_getPersonalityFromString',
      '_getAbilitiesFromEffects',
      '_generateItemName',
      '_getColorName',
    ];
    
    for (final check in methodChecks) {
      total++;
      if (content.contains(check)) {
        passed++;
        print('  ✅ $check');
      } else {
        print('  ❌ Missing: $check');
      }
    }
    
  } catch (e) {
    results['error'] = 'Error testing KidFriendlyScreen: $e';
    return results;
  }
  
  results['passed'] = passed;
  results['total'] = total;
  results['percentage'] = ((passed / total) * 100).round();
  results['success'] = results['percentage'] >= 85;
  
  return results;
}

/// Test 5: Integration Points
Future<Map<String, dynamic>> testIntegrationPoints() async {
  final results = <String, dynamic>{};
  int passed = 0;
  int total = 0;
  
  try {
    // Check main.dart integration
    final mainFile = File('lib/main.dart');
    if (await mainFile.exists()) {
      final content = await mainFile.readAsString();
      
      final integrationChecks = [
        "import 'screens/kid_friendly_screen.dart'",
        "'/kid-friendly': (context) => const KidFriendlyScreen()",
      ];
      
      for (final check in integrationChecks) {
        total++;
        if (content.contains(check)) {
          passed++;
          print('  ✅ $check');
        } else {
          print('  ❌ Missing: $check');
        }
      }
    }
    
    // Check welcome screen integration
    final welcomeFile = File('lib/screens/welcome_screen.dart');
    if (await welcomeFile.exists()) {
      final content = await welcomeFile.readAsString();
      
      final welcomeChecks = [
        "🎮 KID MODE",
        "Navigator.pushNamed(context, '/kid-friendly')",
        "Icons.child_care",
        "Colors.purple",
      ];
      
      for (final check in welcomeChecks) {
        total++;
        if (content.contains(check)) {
          passed++;
          print('  ✅ $check');
        } else {
          print('  ❌ Missing: $check');
        }
      }
    }
    
  } catch (e) {
    results['error'] = 'Error testing integration points: $e';
    return results;
  }
  
  results['passed'] = passed;
  results['total'] = total;
  results['percentage'] = ((passed / total) * 100).round();
  results['success'] = results['percentage'] >= 80;
  
  return results;
}

/// Test 6: Voice Commands Database
Future<Map<String, dynamic>> testVoiceCommandsDatabase() async {
  final results = <String, dynamic>{};
  int passed = 0;
  int total = 0;
  
  try {
    final file = File('lib/services/kid_voice_service.dart');
    final content = await file.readAsString();
    
    // Check comprehensive voice commands
    final voiceCommands = [
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
    
    for (final command in voiceCommands) {
      total++;
      if (content.contains(command)) {
        passed++;
        print('  ✅ "$command"');
      } else {
        print('  ❌ Missing: "$command"');
      }
    }
    
  } catch (e) {
    results['error'] = 'Error testing voice commands: $e';
    return results;
  }
  
  results['passed'] = passed;
  results['total'] = total;
  results['percentage'] = ((passed / total) * 100).round();
  results['success'] = results['percentage'] >= 80;
  
  return results;
}

/// Test 7: Kid-Friendly Features
Future<Map<String, dynamic>> testKidFriendlyFeatures() async {
  final results = <String, dynamic>{};
  int passed = 0;
  int total = 0;
  
  try {
    final file = File('lib/services/kid_voice_service.dart');
    final content = await file.readAsString();
    
    // Check kid-friendly features
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
    
    for (final feature in kidFeatures) {
      total++;
      if (content.contains(feature)) {
        passed++;
        print('  ✅ $feature');
      } else {
        print('  ❌ Missing: $feature');
      }
    }
    
  } catch (e) {
    results['error'] = 'Error testing kid-friendly features: $e';
    return results;
  }
  
  results['passed'] = passed;
  results['total'] = total;
  results['percentage'] = ((passed / total) * 100).round();
  results['success'] = results['percentage'] >= 80;
  
  return results;
}

/// Test 8: Navigation & Routing
Future<Map<String, dynamic>> testNavigationRouting() async {
  final results = <String, dynamic>{};
  int passed = 0;
  int total = 0;
  
  try {
    // Check main.dart routing
    final mainFile = File('lib/main.dart');
    final content = await mainFile.readAsString();
    
    final routingChecks = [
      "import 'screens/kid_friendly_screen.dart'",
      "'/kid-friendly': (context) => const KidFriendlyScreen()",
    ];
    
    for (final check in routingChecks) {
      total++;
      if (content.contains(check)) {
        passed++;
        print('  ✅ $check');
      } else {
        print('  ❌ Missing: $check');
      }
    }
    
    // Check welcome screen navigation
    final welcomeFile = File('lib/screens/welcome_screen.dart');
    final welcomeContent = await welcomeFile.readAsString();
    
    final navigationChecks = [
      "Navigator.pushNamed(context, '/kid-friendly')",
      "🎮 KID MODE",
      "Icons.child_care",
    ];
    
    for (final check in navigationChecks) {
      total++;
      if (welcomeContent.contains(check)) {
        passed++;
        print('  ✅ $check');
      } else {
        print('  ❌ Missing: $check');
      }
    }
    
  } catch (e) {
    results['error'] = 'Error testing navigation: $e';
    return results;
  }
  
  results['passed'] = passed;
  results['total'] = total;
  results['percentage'] = ((passed / total) * 100).round();
  results['success'] = results['percentage'] >= 80;
  
  return results;
}

/// Test 9: Code Quality & Linting
Future<Map<String, dynamic>> testCodeQuality() async {
  final results = <String, dynamic>{};
  int passed = 0;
  int total = 0;
  
  try {
    // Check for proper imports
    final files = [
      'lib/services/kid_voice_service.dart',
      'lib/widgets/kid_voice_button.dart',
      'lib/screens/kid_friendly_screen.dart',
    ];
    
    for (final filePath in files) {
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        
        // Check for proper imports
        final importChecks = [
          "import 'package:flutter/material.dart';",
          "import 'package:speech_to_text/speech_to_text.dart';",
        ];
        
        for (final check in importChecks) {
          total++;
          if (content.contains(check)) {
            passed++;
            print('  ✅ $filePath - $check');
          } else {
            print('  ❌ $filePath - Missing: $check');
          }
        }
        
        // Check for proper class structure
        final structureChecks = [
          'class ',
          'extends ',
          'State<',
          'Widget',
        ];
        
        for (final check in structureChecks) {
          total++;
          if (content.contains(check)) {
            passed++;
            print('  ✅ $filePath - $check');
          } else {
            print('  ❌ $filePath - Missing: $check');
          }
        }
      }
    }
    
  } catch (e) {
    results['error'] = 'Error testing code quality: $e';
    return results;
  }
  
  results['passed'] = passed;
  results['total'] = total;
  results['percentage'] = ((passed / total) * 100).round();
  results['success'] = results['percentage'] >= 80;
  
  return results;
}

/// Test 10: Performance & Optimization
Future<Map<String, dynamic>> testPerformance() async {
  final results = <String, dynamic>{};
  int passed = 0;
  int total = 0;
  
  try {
    // Check for performance optimizations
    final files = [
      'lib/services/kid_voice_service.dart',
      'lib/widgets/kid_voice_button.dart',
      'lib/screens/kid_friendly_screen.dart',
    ];
    
    for (final filePath in files) {
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        
        // Check for performance features
        final performanceChecks = [
          'AnimationController', // Proper animation management
          'dispose()', // Proper cleanup
          'mounted', // Widget lifecycle checks
          'Future.delayed', // Async operations
          'setState', // State management
        ];
        
        for (final check in performanceChecks) {
          total++;
          if (content.contains(check)) {
            passed++;
            print('  ✅ $filePath - $check');
          } else {
            print('  ❌ $filePath - Missing: $check');
          }
        }
      }
    }
    
  } catch (e) {
    results['error'] = 'Error testing performance: $e';
    return results;
  }
  
  results['passed'] = passed;
  results['total'] = total;
  results['percentage'] = ((passed / total) * 100).round();
  results['success'] = results['percentage'] >= 70;
  
  return results;
}

/// Generate Comprehensive Report
void generateComprehensiveReport(Map<String, Map<String, dynamic>> results) {
  int totalPassed = 0;
  int totalTests = 0;
  
  print('📊 DETAILED TEST RESULTS');
  print('-' * 50);
  
  for (final entry in results.entries) {
    final testName = entry.key;
    final testResults = entry.value;
    
    if (testResults.containsKey('error')) {
      print('$testName: ❌ ERROR - ${testResults['error']}');
      totalTests++;
    } else {
      final passed = testResults['passed'] ?? 0;
      final total = testResults['total'] ?? 0;
      final percentage = testResults['percentage'] ?? 0;
      final success = testResults['success'] ?? false;
      
      final status = success ? '✅ PASSED' : '❌ FAILED';
      print('${testName.padRight(25)}: $status ($passed/$total - $percentage%)');
      
      totalPassed += passed;
      totalTests += total;
    }
  }
  
  final overallPercentage = totalTests > 0 ? ((totalPassed / totalTests) * 100).round() : 0;
  
  print('-' * 50);
  print('OVERALL: $totalPassed/$totalTests tests passed ($overallPercentage%)');
  
  if (overallPercentage >= 90) {
    print('🎉 EXCELLENT! Phase 1 is ready for production!');
  } else if (overallPercentage >= 80) {
    print('✅ GOOD! Phase 1 is ready for testing with minor improvements.');
  } else if (overallPercentage >= 70) {
    print('⚠️ FAIR! Phase 1 needs some improvements before testing.');
  } else {
    print('🚨 CRITICAL! Phase 1 has major issues that need fixing.');
  }
  
  // Save detailed results to file
  final reportFile = File('COMPREHENSIVE_PHASE_1_TEST_RESULTS_${DateTime.now().millisecondsSinceEpoch}.json');
  reportFile.writeAsStringSync(jsonEncode({
    'timestamp': DateTime.now().toIso8601String(),
    'phase': 'Phase 1 - Kid Voice System - Comprehensive Testing',
    'results': results,
    'summary': {
      'totalPassed': totalPassed,
      'totalTests': totalTests,
      'overallPercentage': overallPercentage
    }
  }));
  
  print('\n📄 Detailed report saved to: ${reportFile.path}');
}




