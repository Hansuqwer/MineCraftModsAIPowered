import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'lib/services/language_service.dart';
import 'lib/services/swedish_ai_service.dart';
import 'lib/services/ai_service.dart';

/// Test language switching functionality
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🧪 Testing Language Switching...');
  
  // Test 1: Check current language
  print('\n1. Current Language:');
  final currentLocale = await LanguageService.getCurrentLanguage();
  print('   Current: ${currentLocale.languageCode}');
  
  // Test 2: Test Swedish AI responses
  print('\n2. Testing Swedish AI Responses:');
  final swedishResponse = SwedishAIService.getSwedishResponse('räv');
  print('   Swedish response: $swedishResponse');
  
  // Test 3: Test language switching
  print('\n3. Testing Language Switching:');
  
  // Switch to Swedish
  await LanguageService.setLanguage(const Locale('sv', ''));
  final swedishLocale = await LanguageService.getCurrentLanguage();
  print('   After switching to Swedish: ${swedishLocale.languageCode}');
  
  // Switch to English
  await LanguageService.setLanguage(const Locale('en', ''));
  final englishLocale = await LanguageService.getCurrentLanguage();
  print('   After switching to English: ${englishLocale.languageCode}');
  
  // Test 4: Test AI service language detection
  print('\n4. Testing AI Service Language Detection:');
  
  // Set to Swedish and test
  await LanguageService.setLanguage(const Locale('sv', ''));
  final aiService = AIService();
  final swedishAIResponse = await aiService.getCraftaResponse('räv');
  print('   Swedish AI response: $swedishAIResponse');
  
  // Set to English and test
  await LanguageService.setLanguage(const Locale('en', ''));
  final englishAIResponse = await aiService.getCraftaResponse('fox');
  print('   English AI response: $englishAIResponse');
  
  print('\n✅ Language switching test completed!');
}
