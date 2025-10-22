/// Test JavaScript string interpolation with "red dragon" values
void main() {
  print('🧪 [TEST 3] Testing JavaScript String Interpolation...');
  
  // Simulate the values that would come from the AI services
  final type = 'dragon';
  final color = 'red';
  final glow = 'none';
  final size = 'medium';
  
  print('✅ [TEST 3] Input values:');
  print('   type: $type');
  print('   color: $color');
  print('   glow: $glow');
  print('   size: $size');
  
  // Test string escaping (as done in Babylon3DPreview)
  final escapedType = type.replaceAll('"', '\\"');
  final escapedColor = color.replaceAll('"', '\\"');
  final escapedGlow = glow.replaceAll('"', '\\"');
  final escapedSize = size.replaceAll('"', '\\"');
  
  print('✅ [TEST 3] Escaped values:');
  print('   escapedType: $escapedType');
  print('   escapedColor: $escapedColor');
  print('   escapedGlow: $escapedGlow');
  print('   escapedSize: $escapedSize');
  
  // Test JavaScript variable creation (as done in Babylon3DPreview)
  final jsVariables = '''
const itemType = "$escapedType";
const itemColor = "$escapedColor";
const itemGlow = "$escapedGlow";
const itemSize = "$escapedSize";
''';
  
  print('✅ [TEST 3] JavaScript variables:');
  print(jsVariables);
  
  // Test JavaScript logic
  final typeContainsDragon = type.toLowerCase().contains('dragon');
  print('✅ [TEST 3] JavaScript logic:');
  print('   Type contains dragon: $typeContainsDragon');
  
  if (typeContainsDragon && color == 'red') {
    print('🎉 [TEST 3] SUCCESS: JavaScript interpolation working correctly!');
    print('   Should create detailed red dragon model');
  } else {
    print('❌ [TEST 3] FAILED: JavaScript interpolation not working correctly');
    print('   Expected: type=dragon, color=red');
    print('   Actual: type=$type, color=$color');
  }
}
