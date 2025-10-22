import 'package:flutter/material.dart';
import 'lib/services/ai_model_generator_service.dart';
import 'lib/services/enhanced_ai_service.dart';

/// Test script to debug "red dragon" processing
void main() async {
  print('🧪 [TEST] Testing "red dragon" processing...');
  
  try {
    // Test 1: AI Model Generator (offline fallback)
    print('\n🔍 [TEST] Testing AI Model Generator...');
    final attributes = AIModelGeneratorService.createAttributesFromRequest('red dragon');
    print('✅ [TEST] AI Model Generator Result:');
    print('   baseType: ${attributes.baseType}');
    print('   primaryColor: ${attributes.primaryColor}');
    print('   customName: ${attributes.customName}');
    
    // Test 2: Enhanced AI Service (online)
    print('\n🔍 [TEST] Testing Enhanced AI Service...');
    try {
      final enhancedAttributes = await EnhancedAIService.parseEnhancedCreatureRequest('red dragon');
      print('✅ [TEST] Enhanced AI Service Result:');
      print('   baseType: ${enhancedAttributes.baseType}');
      print('   primaryColor: ${enhancedAttributes.primaryColor}');
      print('   customName: ${enhancedAttributes.customName}');
    } catch (e) {
      print('❌ [TEST] Enhanced AI Service failed: $e');
      print('💡 [TEST] This is expected if no API key is configured');
    }
    
    // Test 3: Color mapping
    print('\n🔍 [TEST] Testing color mapping...');
    final color = attributes.primaryColor;
    String colorName = 'blue';
    if (color == Colors.red) colorName = 'red';
    else if (color == Colors.blue) colorName = 'blue';
    else if (color == Colors.green) colorName = 'green';
    else if (color == Colors.black) colorName = 'black';
    print('✅ [TEST] Color mapping: ${color.value} -> $colorName');
    
    // Test 4: Final mapping (as done in CreatorScreenSimple)
    print('\n🔍 [TEST] Testing final mapping...');
    final Map<String, dynamic> finalMap = {
      'creatureType': attributes.baseType,
      'color': colorName,
      'baseType': attributes.baseType,
      'customName': attributes.customName,
      'size': attributes.size.name,
    };
    print('✅ [TEST] Final map: $finalMap');
    
    // Test 5: JavaScript string interpolation
    print('\n🔍 [TEST] Testing JavaScript string interpolation...');
    final type = finalMap['creatureType'] ?? 'cube';
    final colorStr = finalMap['color'] ?? 'blue';
    final size = finalMap['size'] ?? 'medium';
    
    print('✅ [TEST] JavaScript variables:');
    print('   itemType: "$type"');
    print('   itemColor: "$colorStr"');
    print('   itemSize: "$size"');
    print('   Type contains dragon: ${type.toLowerCase().includes('dragon')}');
    
    print('\n🎉 [TEST] All tests completed!');
    
  } catch (e) {
    print('❌ [TEST] Error: $e');
  }
}
