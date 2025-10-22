/// Simple test to debug "red dragon" processing
void main() {
  print('🧪 [TEST] Testing "red dragon" processing...');
  
  // Test 1: Basic string processing
  final userInput = 'red dragon';
  print('✅ [TEST] User input: "$userInput"');
  
  // Test 2: Extract type
  String baseType = 'creature';
  if (userInput.toLowerCase().contains('dragon')) {
    baseType = 'dragon';
  }
  print('✅ [TEST] Extracted baseType: $baseType');
  
  // Test 3: Extract color
  String color = 'blue';
  if (userInput.toLowerCase().contains('red')) {
    color = 'red';
  }
  print('✅ [TEST] Extracted color: $color');
  
  // Test 4: Create final map
  final Map<String, dynamic> finalMap = {
    'creatureType': baseType,
    'color': color,
    'baseType': baseType,
    'customName': 'Red Dragon',
    'size': 'medium',
  };
  print('✅ [TEST] Final map: $finalMap');
  
  // Test 5: JavaScript string interpolation
  final type = finalMap['creatureType'] ?? 'cube';
  final colorStr = finalMap['color'] ?? 'blue';
  final size = finalMap['size'] ?? 'medium';
  
  print('✅ [TEST] JavaScript variables:');
  print('   itemType: "$type"');
  print('   itemColor: "$colorStr"');
  print('   itemSize: "$size"');
  print('   Type contains dragon: ${type.toLowerCase().contains('dragon')}');
  
  // Test 6: Expected result
  if (type.toLowerCase().contains('dragon') && colorStr == 'red') {
    print('🎉 [TEST] SUCCESS: Should show detailed red dragon!');
  } else {
    print('❌ [TEST] FAILED: Will show blocky model');
    print('   Expected: type=dragon, color=red');
    print('   Actual: type=$type, color=$colorStr');
  }
}
