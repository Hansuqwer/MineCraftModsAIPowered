import 'package:flutter/material.dart';
import 'lib/services/ai_service.dart';

void main() async {
  print('🧪 Testing Cat with Wings Creation');
  print('==================================');
  
  final aiService = AIService();
  
  try {
    // Test the cat creation
    print('🔍 Testing: "I want a cat with wings"');
    final attributes = await aiService.parseCreatureRequest('I want a cat with wings');
    print('✅ Success! Attributes: $attributes');
    
    if (attributes['creatureType'] == 'cat') {
      print('🎯 CAT DETECTED!');
      print('   Type: ${attributes['creatureType']}');
      print('   Color: ${attributes['color']}');
      print('   Effects: ${attributes['effects']}');
      print('   Abilities: ${attributes['abilities']}');
    } else {
      print('❌ Not detected as cat');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
  
  print('\n🎉 Test completed!');
}

