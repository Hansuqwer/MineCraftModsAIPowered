import 'package:flutter/material.dart';
import 'lib/services/ai_model_generator_service.dart';

/// Test AI Model Generator Service with "red dragon" input
void main() async {
  print('🧪 [TEST 1] Testing AI Model Generator Service...');
  
  try {
    final attributes = AIModelGeneratorService.createAttributesFromRequest('red dragon');
    
    print('✅ [TEST 1] AI Model Generator Result:');
    print('   baseType: ${attributes.baseType}');
    print('   primaryColor: ${attributes.primaryColor}');
    print('   customName: ${attributes.customName}');
    print('   size: ${attributes.size}');
    print('   abilities: ${attributes.abilities}');
    print('   accessories: ${attributes.accessories}');
    
    // Test color mapping
    String colorName = 'blue';
    if (attributes.primaryColor == Colors.red) colorName = 'red';
    else if (attributes.primaryColor == Colors.blue) colorName = 'blue';
    else if (attributes.primaryColor == Colors.green) colorName = 'green';
    else if (attributes.primaryColor == Colors.black) colorName = 'black';
    
    print('✅ [TEST 1] Color mapping: ${attributes.primaryColor.value} -> $colorName');
    
    // Test final mapping (as done in CreatorScreenSimple)
    final Map<String, dynamic> finalMap = {
      'creatureType': attributes.baseType,
      'color': colorName,
      'baseType': attributes.baseType,
      'customName': attributes.customName,
      'size': attributes.size.name,
    };
    
    print('✅ [TEST 1] Final map: $finalMap');
    
    // Test JavaScript variables
    final type = finalMap['creatureType'] ?? 'cube';
    final color = finalMap['color'] ?? 'blue';
    final size = finalMap['size'] ?? 'medium';
    
    print('✅ [TEST 1] JavaScript variables:');
    print('   itemType: "$type"');
    print('   itemColor: "$color"');
    print('   itemSize: "$size"');
    print('   Type contains dragon: ${type.toLowerCase().contains('dragon')}');
    
    if (type.toLowerCase().contains('dragon') && color == 'red') {
      print('🎉 [TEST 1] SUCCESS: AI Model Generator working correctly!');
    } else {
      print('❌ [TEST 1] FAILED: AI Model Generator not working correctly');
      print('   Expected: type=dragon, color=red');
      print('   Actual: type=$type, color=$color');
    }
    
  } catch (e) {
    print('❌ [TEST 1] ERROR: $e');
  }
}
