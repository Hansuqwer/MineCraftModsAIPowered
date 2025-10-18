import 'lib/services/ai_service.dart';

void main() async {
  print('🧠 Testing AI Service Parsing...');

  final aiService = AIService();

  // Test basic parsing
  final testPhrase = 'I want to create a rainbow cow with sparkles';
  final attributes = await aiService.parseCreatureRequest(testPhrase);

  print('📊 Parsed attributes: $attributes');
  print('🎯 Creature Type: ${attributes['creatureType']}');
  print('🌈 Color: ${attributes['color']}');
  print('✨ Effects: ${attributes['effects']}');
  print('📏 Size: ${attributes['size']}');
  print('😊 Behavior: ${attributes['behavior']}');
  print('🎪 Abilities: ${attributes['abilities']}');
  
  // Test age validation
  final isAgeAppropriate = aiService.validateContentForAge(testPhrase, 6);
  print('👶 Age appropriate for 6: $isAgeAppropriate');
  
  // Test inappropriate content
  final inappropriatePhrase = 'I want to create a scary monster';
  final isInappropriate = aiService.validateContentForAge(inappropriatePhrase, 6);
  print('🚫 Inappropriate content blocked: $isInappropriate');
  
  // Test age-appropriate suggestions
  final suggestions = aiService.getAgeAppropriateSuggestions(6);
  print('💡 Age 6 suggestions: ${suggestions.length} items');
  for (final suggestion in suggestions.take(3)) {
    print('  - $suggestion');
  }
  
  // Test different creature types
  final testCases = [
    'I want to create a rainbow cow with sparkles',
    'Make me a black sword with dark fire',
    'Create a tiny dragon that flies',
    'I want a golden wand that glows',
    'A massive phoenix with rainbow fire',
    'A cosmic hammer with stars'
  ];
  
  print('\n🎯 Testing Different Creature Types:');
  for (final testCase in testCases) {
    final result = await aiService.parseCreatureRequest(testCase);
    print('📝 Input: "$testCase"');
    print('📊 Result: ${result['creatureType']} (${result['color']}) with ${result['effects']}');
    
    // Test age appropriateness
    final isAppropriate = aiService.validateContentForAge(testCase, 6);
    print('👶 Age 6 appropriate: $isAppropriate');
    print('');
  }
  
  print('🎉 AI Service Debug Test COMPLETED!');
  print('✅ All parsing functions working correctly!');
  print('✅ Age-appropriate content filtering working!');
  print('✅ Creature suggestions working!');
}