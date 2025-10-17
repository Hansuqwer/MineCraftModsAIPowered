import 'dart:io';
import 'lib/services/ai_service.dart';
import 'lib/services/groq_ai_service.dart';
import 'lib/services/huggingface_ai_service.dart';
import 'lib/services/ollama_ai_service.dart';
import 'lib/services/offline_ai_service.dart';

/// Test script for AI services
Future<void> main() async {
  print('🧪 Testing AI Services...\n');
  
  final aiService = AIService();
  final groqService = GroqAIService();
  final hfService = HuggingFaceAIService();
  final ollamaService = OllamaAIService();
  final offlineService = OfflineAIService();
  
  final testMessage = 'I want a pink dragon with wings';
  
  print('📝 Test Message: "$testMessage"\n');
  
  // Test Groq API
  print('🟢 Testing Groq API...');
  try {
    final groqResponse = await groqService.getCraftaResponse(testMessage, age: 6);
    print('✅ Groq Response: $groqResponse\n');
  } catch (e) {
    print('❌ Groq Error: $e\n');
  }
  
  // Test Hugging Face API
  print('🤗 Testing Hugging Face API...');
  try {
    final hfResponse = await hfService.getCraftaResponse(testMessage, age: 6);
    print('✅ Hugging Face Response: $hfResponse\n');
  } catch (e) {
    print('❌ Hugging Face Error: $e\n');
  }
  
  // Test Ollama API
  print('🦙 Testing Ollama API...');
  try {
    final ollamaResponse = await ollamaService.getCraftaResponse(testMessage, age: 6);
    print('✅ Ollama Response: $ollamaResponse\n');
  } catch (e) {
    print('❌ Ollama Error: $e\n');
  }
  
  // Test Offline Service
  print('📱 Testing Offline Service...');
  try {
    final offlineResponse = await offlineService.getOfflineResponse(testMessage, age: 6);
    print('✅ Offline Response: $offlineResponse\n');
  } catch (e) {
    print('❌ Offline Error: $e\n');
  }
  
  // Test Main AI Service
  print('🎯 Testing Main AI Service...');
  try {
    final mainResponse = await aiService.getCraftaResponse(testMessage, age: 6);
    print('✅ Main AI Response: $mainResponse\n');
  } catch (e) {
    print('❌ Main AI Error: $e\n');
  }
  
  // Test Creature Parsing
  print('🔍 Testing Creature Parsing...');
  try {
    final attributes = await aiService.parseCreatureRequest(testMessage);
    print('✅ Parsed Attributes: $attributes\n');
  } catch (e) {
    print('❌ Parsing Error: $e\n');
  }
  
  // Test Suggestions
  print('💡 Testing AI Suggestions...');
  try {
    final attributes = await aiService.parseCreatureRequest(testMessage);
    final suggestions = aiService.generateCreationSuggestions(attributes);
    print('✅ Suggestions: $suggestions\n');
  } catch (e) {
    print('❌ Suggestions Error: $e\n');
  }
  
  print('🏁 AI Service Testing Complete!');
}
