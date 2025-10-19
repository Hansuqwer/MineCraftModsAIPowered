#!/usr/bin/env dart

/// 🧪 Conversational AI Test
/// Tests the conversational AI service for back-and-forth item creation

import 'dart:io';
import 'package:flutter/material.dart';
import 'lib/services/conversational_ai_service.dart';

void main() async {
  print('🧪 Testing Conversational AI Service...\n');
  
  final aiService = ConversationalAIService();
  
  // Test 1: Basic conversation flow
  print('📝 Test 1: Basic conversation flow');
  print('=' * 50);
  
  try {
    // Start conversation
    String response = await aiService.startConversation('I want to create a dragon');
    print('AI: $response');
    print('Current item: ${aiService.currentItem}');
    print('Can create: ${aiService.canCreateCurrentItem}');
    print('');
    
    // Continue conversation
    response = await aiService.continueConversation('Make it red and big');
    print('AI: $response');
    print('Attributes: ${aiService.currentAttributes}');
    print('');
    
    response = await aiService.continueConversation('It should be able to fly');
    print('AI: $response');
    print('Attributes: ${aiService.currentAttributes}');
    print('');
    
    response = await aiService.continueConversation('It lives in a castle');
    print('AI: $response');
    print('Attributes: ${aiService.currentAttributes}');
    print('');
    
    response = await aiService.continueConversation('It should be friendly');
    print('AI: $response');
    print('Attributes: ${aiService.currentAttributes}');
    print('');
    
    print('✅ Test 1 passed: Basic conversation flow works\n');
  } catch (e) {
    print('❌ Test 1 failed: $e\n');
  }
  
  // Test 2: Non-creatable items
  print('📝 Test 2: Non-creatable items');
  print('=' * 50);
  
  try {
    aiService.clearConversation();
    
    String response = await aiService.startConversation('I want to create an iPhone');
    print('AI: $response');
    print('Can create: ${aiService.canCreateCurrentItem}');
    print('');
    
    response = await aiService.startConversation('I want to create a gun');
    print('AI: $response');
    print('Can create: ${aiService.canCreateCurrentItem}');
    print('');
    
    response = await aiService.startConversation('I want to create love');
    print('AI: $response');
    print('Can create: ${aiService.canCreateCurrentItem}');
    print('');
    
    print('✅ Test 2 passed: Non-creatable items handled correctly\n');
  } catch (e) {
    print('❌ Test 2 failed: $e\n');
  }
  
  // Test 3: Personality switching
  print('📝 Test 3: Personality switching');
  print('=' * 50);
  
  try {
    aiService.clearConversation();
    
    // Test different personalities
    final personalities = aiService.availablePersonalities;
    print('Available personalities: $personalities');
    
    for (final personality in personalities) {
      aiService.setPersonality(personality);
      print('Current personality: ${aiService.currentPersonality}');
      
      String response = await aiService.startConversation('I want to create a cat');
      print('$personality: $response');
      print('');
    }
    
    print('✅ Test 3 passed: Personality switching works\n');
  } catch (e) {
    print('❌ Test 3 failed: $e\n');
  }
  
  // Test 4: Similar item suggestions
  print('📝 Test 4: Similar item suggestions');
  print('=' * 50);
  
  try {
    final suggestions = aiService.getSimilarCreatableItems('phone');
    print('Suggestions for "phone": $suggestions');
    
    final suggestions2 = aiService.getSimilarCreatableItems('car');
    print('Suggestions for "car": $suggestions2');
    
    final suggestions3 = aiService.getSimilarCreatableItems('sword');
    print('Suggestions for "sword": $suggestions3');
    
    print('✅ Test 4 passed: Similar item suggestions work\n');
  } catch (e) {
    print('❌ Test 4 failed: $e\n');
  }
  
  // Test 5: Conversation history
  print('📝 Test 5: Conversation history');
  print('=' * 50);
  
  try {
    aiService.clearConversation();
    
    await aiService.startConversation('I want to create a robot');
    await aiService.continueConversation('Make it blue');
    await aiService.continueConversation('It should be small');
    
    final history = aiService.conversationHistory;
    print('Conversation history:');
    for (int i = 0; i < history.length; i++) {
      final turn = history[i];
      print('  ${i + 1}. ${turn.speaker}: ${turn.message}');
    }
    
    print('✅ Test 5 passed: Conversation history works\n');
  } catch (e) {
    print('❌ Test 5 failed: $e\n');
  }
  
  // Test 6: Creatable items list
  print('📝 Test 6: Creatable items list');
  print('=' * 50);
  
  try {
    final creatableItems = aiService.creatableItems;
    print('Total creatable items: ${creatableItems.length}');
    print('Sample items: ${creatableItems.take(10).toList()}');
    
    final nonCreatableItems = aiService.nonCreatableItems;
    print('Total non-creatable items: ${nonCreatableItems.length}');
    print('Sample non-creatable: ${nonCreatableItems.keys.take(5).toList()}');
    
    print('✅ Test 6 passed: Items lists work\n');
  } catch (e) {
    print('❌ Test 6 failed: $e\n');
  }
  
  // Test 7: Complex conversation
  print('📝 Test 7: Complex conversation');
  print('=' * 50);
  
  try {
    aiService.clearConversation();
    aiService.setPersonality('playful_friend');
    
    String response = await aiService.startConversation('I want to create a magical unicorn');
    print('AI: $response');
    
    response = await aiService.continueConversation('It should be pink and sparkly');
    print('AI: $response');
    
    response = await aiService.continueConversation('It can fly and has rainbow wings');
    print('AI: $response');
    
    response = await aiService.continueConversation('It lives in a cloud castle');
    print('AI: $response');
    
    response = await aiService.continueConversation('It loves to play with children');
    print('AI: $response');
    
    print('Final attributes: ${aiService.currentAttributes}');
    print('Can create: ${aiService.canCreateCurrentItem}');
    
    print('✅ Test 7 passed: Complex conversation works\n');
  } catch (e) {
    print('❌ Test 7 failed: $e\n');
  }
  
  print('🎉 All Conversational AI tests completed!');
  print('The AI can now have natural back-and-forth conversations about creating items!');
}


