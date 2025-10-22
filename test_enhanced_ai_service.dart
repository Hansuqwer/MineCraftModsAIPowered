import 'package:flutter/material.dart';
import 'lib/services/enhanced_ai_service.dart';

/// Test Enhanced AI Service with "red dragon" input
void main() async {
  print('🧪 [TEST 2] Testing Enhanced AI Service...');
  
  try {
    // Test the fallback method (since we don't have API key)
    print('🔍 [TEST 2] Testing fallback method...');
    final attributes = await EnhancedAIService.parseEnhancedCreatureRequest('red dragon');
    
    print('✅ [TEST 2] Enhanced AI Service Result:');
    print('   baseType: ${attributes.baseType}');
    print('   primaryColor: ${attributes.primaryColor}');
    print('   customName: ${attributes.customName}');
    print('   size: ${attributes.size}');
    
    // Test color mapping
    String colorName = 'blue';
    if (attributes.primaryColor == Colors.red) colorName = 'red';
    else if (attributes.primaryColor == Colors.blue) colorName = 'blue';
    else if (attributes.primaryColor == Colors.green) colorName = 'green';
    else if (attributes.primaryColor == Colors.black) colorName = 'black';
    
    print('✅ [TEST 2] Color mapping: ${attributes.primaryColor.value} -> $colorName');
    
    // Test final mapping (as done in CreatorScreenSimple)
    final Map<String, dynamic> finalMap = {
      'creatureType': attributes.baseType,
      'color': colorName,
      'baseType': attributes.baseType,
      'customName': attributes.customName,
      'size': attributes.size.name,
    };
    
    print('✅ [TEST 2] Final map: $finalMap');
    
    // Test JavaScript variables
    final type = finalMap['creatureType'] ?? 'cube';
    final color = finalMap['color'] ?? 'blue';
    final size = finalMap['size'] ?? 'medium';
    
    print('✅ [TEST 2] JavaScript variables:');
    print('   itemType: "$type"');
    print('   itemColor: "$color"');
    print('   itemSize: "$size"');
    print('   Type contains dragon: ${type.toLowerCase().contains('dragon')}');
    
    if (type.toLowerCase().contains('dragon') && color == 'red') {
      print('🎉 [TEST 2] SUCCESS: Enhanced AI Service working correctly!');
    } else {
      print('❌ [TEST 2] FAILED: Enhanced AI Service not working correctly');
      print('   Expected: type=dragon, color=red');
      print('   Actual: type=$type, color=$color');
    }
    
  } catch (e) {
    print('❌ [TEST 2] ERROR: $e');
  }
}
