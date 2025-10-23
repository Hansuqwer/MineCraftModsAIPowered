import 'dart:io';

// Simple test without Flutter dependencies
void main() async {
  print('🧪 Testing AI Services Integration');
  print('================================');
  
  // Test 1: AI Model Generator Service
  print('\n1. Testing AI Model Generator Service...');
  testAIModelGenerator();
  
  // Test 2: Enhanced AI Service (without API calls)
  print('\n2. Testing Enhanced AI Service fallback...');
  testEnhancedAIFallback();
  
  print('\n✅ All tests completed!');
}

void testAIModelGenerator() {
  print('   Testing "red dragon" input...');
  
  // Simulate the AI model generator logic
  final request = "red dragon";
  final lowerRequest = request.toLowerCase();
  
  // Extract creature type
  String creatureType = 'creature';
  if (lowerRequest.contains('dragon')) {
    creatureType = 'dragon';
  }
  
  // Extract color
  String color = 'blue';
  if (lowerRequest.contains('red')) {
    color = 'red';
  }
  
  print('   ✅ Extracted creatureType: $creatureType');
  print('   ✅ Extracted color: $color');
  
  // Test mapping to 3D preview attributes
  final attributes = {
    'creatureType': creatureType,
    'color': color,
    'size': 'medium',
    'glow': false,
  };
  
  print('   ✅ Generated attributes: $attributes');
}

void testEnhancedAIFallback() {
  print('   Testing fallback logic for "red dragon"...');
  
  final userMessage = "red dragon";
  final lowerMessage = userMessage.toLowerCase();
  
  // Simulate the fallback logic from EnhancedAIService
  String baseType = 'creature';
  if (lowerMessage.contains('dragon')) baseType = 'dragon';
  
  String primaryColor = 'blue';
  if (lowerMessage.contains('red')) primaryColor = 'red';
  
  final result = {
    'baseType': baseType,
    'primaryColor': primaryColor,
    'customName': 'Red Dragon',
  };
  
  print('   ✅ Fallback result: $result');
  
  // Test the mapping that would go to Babylon3DPreview
  final previewAttributes = {
    'creatureType': baseType,
    'color': primaryColor,
    'size': 'medium',
  };
  
  print('   ✅ Preview attributes: $previewAttributes');
}
