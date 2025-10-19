import "../models/conversation.dart";
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'offline_ai_service.dart';
import 'connectivity_service.dart';
import 'local_storage_service.dart';
import 'content_moderation_service.dart';
import 'ollama_ai_service.dart';
import 'huggingface_ai_service.dart';
import 'groq_ai_service.dart';
import 'api_key_manager.dart';
import 'swedish_ai_service.dart';
import 'language_service.dart';
import 'debug_service.dart';

/// Exception for content moderation violations
class ContentModerationException implements Exception {
  final String message;
  ContentModerationException(this.message);
  
  @override
  String toString() => 'ContentModerationException: $message';
}

/// Exception for AI service errors
class AIServiceException implements Exception {
  final String message;
  final String? service;
  AIServiceException(this.message, [this.service]);
  
  @override
  String toString() => 'AIServiceException${service != null ? ' ($service)' : ''}: $message';
}

/// Exception for network connectivity issues
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

/// AI Provider configuration
class AIProvider {
  final String name;
  final bool isAvailable;
  final int priority;
  final String? errorMessage;
  
  const AIProvider({
    required this.name,
    required this.isAvailable,
    required this.priority,
    this.errorMessage,
  });
}

/// Enhanced AI Service with multiple provider fallbacks
class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static final List<AIProvider> _providers = [];
  static int _currentProviderIndex = 0;
  static final Map<String, int> _providerFailures = {};
  static const int _maxFailures = 3;
  static const Duration _failureResetTime = Duration(hours: 1);
  
  /// Initialize AI providers
  static Future<void> initialize() async {
    _providers.clear();
    _providerFailures.clear();
    
    // Check OpenAI
    final openaiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    _providers.add(AIProvider(
      name: 'OpenAI',
      isAvailable: openaiKey.isNotEmpty,
      priority: 1,
      errorMessage: openaiKey.isEmpty ? 'OpenAI API key not configured' : null,
    ));
    
    // Check Groq
    final groqKey = dotenv.env['GROQ_API_KEY'] ?? '';
    _providers.add(AIProvider(
      name: 'Groq',
      isAvailable: groqKey.isNotEmpty,
      priority: 2,
      errorMessage: groqKey.isEmpty ? 'Groq API key not configured' : null,
    ));
    
    // Check Hugging Face
    final hfKey = dotenv.env['HUGGINGFACE_API_KEY'] ?? '';
    _providers.add(AIProvider(
      name: 'HuggingFace',
      isAvailable: hfKey.isNotEmpty,
      priority: 3,
      errorMessage: hfKey.isEmpty ? 'HuggingFace API key not configured' : null,
    ));
    
    // Check Ollama (local)
    _providers.add(AIProvider(
      name: 'Ollama',
      isAvailable: true, // Always available if running locally
      priority: 4,
    ));
    
    // Offline mode (always available)
    _providers.add(AIProvider(
      name: 'Offline',
      isAvailable: true,
      priority: 5,
    ));
    
    // Sort by priority
    _providers.sort((a, b) => a.priority.compareTo(b.priority));
    
    print('🤖 AI Providers initialized: ${_providers.map((p) => '${p.name}(${p.isAvailable ? "✓" : "✗"})').join(", ")}');
  }
  
  /// Get current provider
  static AIProvider get _currentProvider => _providers[_currentProviderIndex];
  
  /// Switch to next available provider
  static void _switchToNextProvider() {
    for (int i = 0; i < _providers.length; i++) {
      final index = (_currentProviderIndex + 1 + i) % _providers.length;
      final provider = _providers[index];
      
      if (provider.isAvailable && (_providerFailures[provider.name] ?? 0) < _maxFailures) {
        _currentProviderIndex = index;
        print('🔄 Switched to AI provider: ${provider.name}');
        return;
      }
    }
    
    // If no providers available, use offline mode
    _currentProviderIndex = _providers.length - 1;
    print('⚠️ All AI providers failed, using offline mode');
  }
  
  /// Record provider failure
  static void _recordProviderFailure(String providerName) {
    _providerFailures[providerName] = (_providerFailures[providerName] ?? 0) + 1;
    print('❌ Provider $providerName failed (${_providerFailures[providerName]}/${_maxFailures})');
  }
  
  /// Reset provider failures after timeout
  static void _resetProviderFailures() {
    final now = DateTime.now();
    _providerFailures.removeWhere((key, value) {
      // This is simplified - in a real app you'd track timestamps
      return value < _maxFailures;
    });
  }
  
  /// Get API key for current provider
  static String get _currentApiKey {
    switch (_currentProvider.name) {
      case 'OpenAI':
        return dotenv.env['OPENAI_API_KEY'] ?? '';
      case 'Groq':
        return dotenv.env['GROQ_API_KEY'] ?? '';
      case 'HuggingFace':
        return dotenv.env['HUGGINGFACE_API_KEY'] ?? '';
      default:
        return '';
    }
  }
  
  /// Check if setup is needed
  Future<bool> needsSetup() async {
    await initialize();
    return _providers.where((p) => p.isAvailable).length == 1; // Only offline available
  }
  
  /// Get recommended setup steps
  Future<List<String>> getRecommendedSetup() async {
    await initialize();
    final recommendations = <String>[];
    
    for (final provider in _providers) {
      if (!provider.isAvailable && provider.errorMessage != null) {
        recommendations.add(provider.errorMessage!);
      }
    }
    
    return recommendations;
  }
  
  /// Get Crafta response with fallback
  Future<String> getCraftaResponse(String userMessage, {int age = 6}) async {
    await initialize();
    _resetProviderFailures();
    
    final originalProvider = _currentProviderIndex;
    int attempts = 0;
    const maxAttempts = 3;
    
    while (attempts < maxAttempts) {
      try {
        final response = await _getResponseFromCurrentProvider(userMessage, age);
        
        // Reset failure count on success
        _providerFailures[_currentProvider.name] = 0;
        
        return response;
      } catch (e) {
        print('❌ ${_currentProvider.name} failed: $e');
        _recordProviderFailure(_currentProvider.name);
        _switchToNextProvider();
        attempts++;
        
        if (attempts >= maxAttempts) {
          throw AIServiceException('All AI providers failed after $maxAttempts attempts', 'All');
        }
      }
    }
    
    throw AIServiceException('Unexpected error in AI service');
  }
  
  /// Get response from current provider
  Future<String> _getResponseFromCurrentProvider(String userMessage, int age) async {
    switch (_currentProvider.name) {
      case 'OpenAI':
        return await _getOpenAIResponse(userMessage, age);
      case 'Groq':
        return await _getGroqResponse(userMessage, age);
      case 'HuggingFace':
        return await _getHuggingFaceResponse(userMessage, age);
      case 'Ollama':
        return await _getOllamaResponse(userMessage, age);
      case 'Offline':
        return await _getOfflineResponse(userMessage, age);
      default:
        throw AIServiceException('Unknown provider: ${_currentProvider.name}');
    }
  }
  
  /// OpenAI response
  Future<String> _getOpenAIResponse(String userMessage, int age) async {
    final apiKey = _currentApiKey;
    if (apiKey.isEmpty) {
      throw AIServiceException('OpenAI API key not configured', 'OpenAI');
    }
    
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content': _getSystemPrompt(age),
          },
          {
            'role': 'user',
            'content': userMessage,
          },
        ],
        'max_tokens': 500,
        'temperature': 0.7,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] ?? 'Sorry, I could not generate a response.';
    } else {
      throw AIServiceException('OpenAI API error: ${response.statusCode}', 'OpenAI');
    }
  }
  
  /// Groq response
  Future<String> _getGroqResponse(String userMessage, int age) async {
    final apiKey = _currentApiKey;
    if (apiKey.isEmpty) {
      throw AIServiceException('Groq API key not configured', 'Groq');
    }
    
    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'llama3-8b-8192',
        'messages': [
          {
            'role': 'system',
            'content': _getSystemPrompt(age),
          },
          {
            'role': 'user',
            'content': userMessage,
          },
        ],
        'max_tokens': 500,
        'temperature': 0.7,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] ?? 'Sorry, I could not generate a response.';
    } else {
      throw AIServiceException('Groq API error: ${response.statusCode}', 'Groq');
    }
  }
  
  /// Hugging Face response
  Future<String> _getHuggingFaceResponse(String userMessage, int age) async {
    final apiKey = _currentApiKey;
    if (apiKey.isEmpty) {
      throw AIServiceException('HuggingFace API key not configured', 'HuggingFace');
    }
    
    final response = await http.post(
      Uri.parse('https://api-inference.huggingface.co/models/microsoft/DialoGPT-medium'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'inputs': userMessage,
        'parameters': {
          'max_length': 200,
          'temperature': 0.7,
        },
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        return data[0]['generated_text'] ?? 'Sorry, I could not generate a response.';
      }
      return 'Sorry, I could not generate a response.';
    } else {
      throw AIServiceException('HuggingFace API error: ${response.statusCode}', 'HuggingFace');
    }
  }
  
  /// Ollama response
  Future<String> _getOllamaResponse(String userMessage, int age) async {
    try {
      final ollamaService = OllamaAIService();
      return await ollamaService.getCraftaResponse(userMessage, age: age);
    } catch (e) {
      throw AIServiceException('Ollama error: $e', 'Ollama');
    }
  }
  
  /// Offline response
  Future<String> _getOfflineResponse(String userMessage, int age) async {
    try {
      final offlineService = OfflineAIService();
      return offlineService.getOfflineResponse(userMessage, age: age);
    } catch (e) {
      throw AIServiceException('Offline service error: $e', 'Offline');
    }
  }
  
  /// Get system prompt based on age
  String _getSystemPrompt(int age) {
    final basePrompt = '''You are Crafta, a friendly AI assistant that helps children create Minecraft items. 
You are designed for children aged $age and should be:
- Encouraging and positive
- Use simple, age-appropriate language
- Be creative and imaginative
- Support ALL Minecraft items: creatures, weapons, armor, furniture, vehicles, food, blocks, tools, magical items
- Always be safe and appropriate

When a child describes ANY item they want to create (creature, sword, car, iPhone, armor, table, etc.), respond with enthusiasm and ask follow-up questions to help them design it better. 
Keep responses short and engaging (2-3 sentences max).''';

    if (age <= 6) {
      return basePrompt + '\n\nUse very simple words and lots of encouragement!';
    } else if (age <= 10) {
      return basePrompt + '\n\nUse simple words but you can be a bit more detailed.';
    } else {
      return basePrompt + '\n\nYou can use more complex language and provide more detailed suggestions.';
    }
  }
  
  /// Check if online
  Future<bool> isOnline() async {
    try {
      final connectivityService = ConnectivityService();
      return await connectivityService.checkConnectivity();
    } catch (e) {
      return false;
    }
  }
  
  /// Parse item request with enhanced error handling (supports all item types)
  Future<Map<String, dynamic>> parseCreatureRequest(String userMessage) async {
    try {
      // Enhanced item parsing with automatic categorization
      final itemData = <String, dynamic>{};
      
      // Auto-detect item category and type
      final lowerMessage = userMessage.toLowerCase();
      
      // Detect tools (pickaxe, axe, shovel, hoe, etc.) - realistic tools only
      if (lowerMessage.contains('pickaxe') || lowerMessage.contains('pick') || lowerMessage.contains('mining')) {
        itemData['category'] = 'tool';
        itemData['baseType'] = 'pickaxe';
      } else if (lowerMessage.contains('axe') || lowerMessage.contains('chopping')) {
        itemData['category'] = 'tool';
        itemData['baseType'] = 'axe';
      } else if (lowerMessage.contains('shovel') || lowerMessage.contains('digging')) {
        itemData['category'] = 'tool';
        itemData['baseType'] = 'shovel';
      } else if (lowerMessage.contains('hoe') || lowerMessage.contains('farming')) {
        itemData['category'] = 'tool';
        itemData['baseType'] = 'hoe';
      }
      // Detect weapons (sword, bow, etc.) - realistic weapons only
      else if (lowerMessage.contains('sword')) {
        itemData['category'] = 'weapon';
        itemData['baseType'] = 'sword';
      } else if (lowerMessage.contains('bow') || lowerMessage.contains('arrow')) {
        itemData['category'] = 'weapon';
        itemData['baseType'] = 'bow';
      }
      // Detect armor (helmet, chestplate, etc.) - realistic armor only
      else if (lowerMessage.contains('helmet')) {
        itemData['category'] = 'armor';
        itemData['baseType'] = 'helmet';
      } else if (lowerMessage.contains('chestplate') || lowerMessage.contains('chest plate')) {
        itemData['category'] = 'armor';
        itemData['baseType'] = 'chestplate';
      } else if (lowerMessage.contains('boots') || lowerMessage.contains('shoes')) {
        itemData['category'] = 'armor';
        itemData['baseType'] = 'boots';
      } else if (lowerMessage.contains('shield')) {
        itemData['category'] = 'armor';
        itemData['baseType'] = 'shield';
      }
      // Detect furniture (chair, table, couch, etc.) - realistic furniture only
      else if (lowerMessage.contains('chair')) {
        itemData['category'] = 'furniture';
        itemData['baseType'] = 'chair';
      } else if (lowerMessage.contains('table')) {
        itemData['category'] = 'furniture';
        itemData['baseType'] = 'table';
      } else if (lowerMessage.contains('couch') || lowerMessage.contains('sofa')) {
        itemData['category'] = 'furniture';
        itemData['baseType'] = 'couch';
      } else if (lowerMessage.contains('bed')) {
        itemData['category'] = 'furniture';
        itemData['baseType'] = 'bed';
      }
      // Detect vehicles (car, boat, plane, etc.) - realistic vehicles only
      else if (lowerMessage.contains('car')) {
        itemData['category'] = 'vehicle';
        itemData['baseType'] = 'car';
      } else if (lowerMessage.contains('boat')) {
        itemData['category'] = 'vehicle';
        itemData['baseType'] = 'boat';
      } else if (lowerMessage.contains('plane') || lowerMessage.contains('airplane')) {
        itemData['category'] = 'vehicle';
        itemData['baseType'] = 'plane';
      }
      // Enhanced detection for ALL item types
      else {
        // Try to detect what type of item they want
        if (lowerMessage.contains('sword') || lowerMessage.contains('weapon') || lowerMessage.contains('blade')) {
          itemData['category'] = 'weapon';
          itemData['baseType'] = 'sword';
        } else if (lowerMessage.contains('armor') || lowerMessage.contains('helmet') || lowerMessage.contains('chestplate')) {
          itemData['category'] = 'armor';
          itemData['baseType'] = 'armor';
        } else if (lowerMessage.contains('car') || lowerMessage.contains('vehicle') || lowerMessage.contains('boat')) {
          itemData['category'] = 'vehicle';
          itemData['baseType'] = 'car';
        } else if (lowerMessage.contains('table') || lowerMessage.contains('chair') || lowerMessage.contains('furniture')) {
          itemData['category'] = 'furniture';
          itemData['baseType'] = 'table';
        } else if (lowerMessage.contains('phone') || lowerMessage.contains('iphone') || lowerMessage.contains('device')) {
          itemData['category'] = 'tool';
          itemData['baseType'] = 'phone';
        } else if (lowerMessage.contains('food') || lowerMessage.contains('apple') || lowerMessage.contains('bread')) {
          itemData['category'] = 'food';
          itemData['baseType'] = 'apple';
        } else if (lowerMessage.contains('block') || lowerMessage.contains('stone') || lowerMessage.contains('wood')) {
          itemData['category'] = 'block';
          itemData['baseType'] = 'block';
        } else {
          // Default to creature only if no other type detected
          itemData['category'] = 'creature';
          final creatureTypes = ['cow', 'pig', 'chicken', 'sheep', 'horse', 'cat', 'dog', 'dragon', 'unicorn', 'phoenix'];
          for (final type in creatureTypes) {
            if (lowerMessage.contains(type)) {
              itemData['baseType'] = type;
              break;
            }
          }
          if (!itemData.containsKey('baseType')) {
            itemData['baseType'] = 'creature'; // Default creature
          }
        }
      }
      
      // Extract materials and colors - realistic Minecraft materials
      final materials = ['wood', 'stone', 'iron', 'gold', 'diamond', 'netherite', 'leather', 'chain', 'turtle'];
      final colors = ['red', 'blue', 'green', 'yellow', 'purple', 'pink', 'orange', 'black', 'white', 'rainbow', 'golden', 'gold'];
      
      // Minecraft material types for AI understanding
      final materialTypes = {
        'entity': 'basic opaque material',
        'entity_alphatest': 'supports transparent pixels',
        'entity_alphablend': 'supports translucent pixels', 
        'entity_emissive': 'solid, alpha channel used as emissive',
        'entity_emissive_alpha': 'alpha channel for emissiveness'
      };
      final foundMaterials = <String>[];
      final foundColors = <String>[];
      
      // Check for materials
      for (final material in materials) {
        if (lowerMessage.contains(material)) {
          foundMaterials.add(material);
        }
      }
      
      // Check for colors
      for (final color in colors) {
        if (lowerMessage.contains(color)) {
          foundColors.add(color);
        }
      }
      
      // Handle specific material combinations based on Bedrock Wiki
      if (lowerMessage.contains('shiny') || lowerMessage.contains('shinny')) {
        itemData['material'] = 'polished';
        itemData['material_type'] = 'entity_emissive'; // Glowing material
      }
      if (lowerMessage.contains('inlaid') || lowerMessage.contains('inlay')) {
        itemData['decoration'] = 'inlaid';
        itemData['decoration_type'] = 'entity_alphatest'; // Transparent decorations
      }
      if (lowerMessage.contains('diamond')) {
        itemData['decoration_material'] = 'diamond';
        itemData['decoration_glow'] = true;
      }
      if (lowerMessage.contains('transparent') || lowerMessage.contains('glass')) {
        itemData['material_type'] = 'entity_alphablend'; // Translucent material
      }
      if (lowerMessage.contains('glow') || lowerMessage.contains('glowing')) {
        itemData['material_type'] = 'entity_emissive_alpha'; // Emissive with alpha
      }
      
      if (foundMaterials.isNotEmpty) {
        itemData['primaryMaterial'] = foundMaterials.first;
        if (foundMaterials.length > 1) {
          itemData['secondaryMaterial'] = foundMaterials[1];
        }
      }
      if (foundColors.isNotEmpty) {
        itemData['primaryColor'] = foundColors.first;
        if (foundColors.length > 1) {
          itemData['secondaryColor'] = foundColors[1];
        }
      }
      
      // Extract size
      if (lowerMessage.contains('tiny') || lowerMessage.contains('small')) {
        itemData['size'] = 'small';
      } else if (lowerMessage.contains('large') || lowerMessage.contains('big')) {
        itemData['size'] = 'large';
      } else if (lowerMessage.contains('giant') || lowerMessage.contains('huge')) {
        itemData['size'] = 'giant';
      } else {
        itemData['size'] = 'medium';
      }
      
      // Extract special abilities
      final abilities = <String>[];
      if (userMessage.toLowerCase().contains('fly') || userMessage.toLowerCase().contains('flying')) {
        abilities.add('flying');
      }
      if (userMessage.toLowerCase().contains('swim') || userMessage.toLowerCase().contains('swimming')) {
        abilities.add('swimming');
      }
      if (userMessage.toLowerCase().contains('fire') || userMessage.toLowerCase().contains('flame')) {
        abilities.add('fire_breath');
      }
      if (userMessage.toLowerCase().contains('ice') || userMessage.toLowerCase().contains('freeze')) {
        abilities.add('ice_breath');
      }
      if (userMessage.toLowerCase().contains('magic') || userMessage.toLowerCase().contains('spell')) {
        abilities.add('magic');
      }
      if (abilities.isNotEmpty) {
        itemData['abilities'] = abilities;
      }
      
      // Add personality based on description
      if (lowerMessage.contains('friendly') || lowerMessage.contains('nice')) {
        itemData['personality'] = 'friendly';
      } else if (lowerMessage.contains('playful') || lowerMessage.contains('fun')) {
        itemData['personality'] = 'playful';
      } else if (lowerMessage.contains('brave') || lowerMessage.contains('courageous')) {
        itemData['personality'] = 'brave';
      } else {
        itemData['personality'] = 'friendly';
      }
      
      // Add realistic description
      String description = 'A ${itemData['size'] ?? 'medium'} ${itemData['baseType'] ?? 'item'}';
      
      if (itemData.containsKey('primaryMaterial')) {
        description += ' made of ${itemData['primaryMaterial']}';
      }
      if (itemData.containsKey('decoration') && itemData.containsKey('decoration_material')) {
        description += ' with ${itemData['decoration']} ${itemData['decoration_material']}';
      }
      if (foundColors.isNotEmpty) {
        description += ' in ${foundColors.join(' and ')} colors';
      }
      
      itemData['description'] = description;
      
      return itemData;
    } catch (e) {
      print('Error parsing item request: $e');
      return {
        'category': 'creature',
        'baseType': 'cow',
        'size': 'medium',
        'personality': 'friendly',
        'description': 'A friendly creature created with Crafta!',
      };
    }
  }
  
  /// Process user input and return conversation with creature attributes
  Future<Conversation?> processUserInput(String userMessage, Conversation currentConversation) async {
    try {
      // Add user message to conversation
      final updatedConversation = currentConversation.addMessage(userMessage, true);
      
      // Get AI response with fallback
      final aiResponse = await getCraftaResponse(userMessage);
      
      // Parse item attributes from the response (supports all item types)
      final itemAttributes = await parseCreatureRequest(userMessage);
      
      // Add AI response to conversation
      final finalConversation = updatedConversation.addMessage(aiResponse, false);

      // If we have creature attributes, mark conversation as complete
      // if (creatureAttributes.isNotEmpty) {
      //   return finalConversation.markComplete(creatureAttributes);
      // }

      return finalConversation;
    } catch (e) {
      print('Error processing user input: $e');
      
      // Fallback response
      final fallbackResponse = getEncouragingResponse();
      final updatedConversation = currentConversation.addMessage(userMessage, true);
      final finalConversation = updatedConversation.addMessage(fallbackResponse, false);
      
      return finalConversation;
    }
  }
  
  /// Get encouraging response for child
  String getEncouragingResponse() {
    final responses = [
      'That sounds amazing! I love your creativity!',
      'Wow, what a cool idea! Let\'s make it together!',
      'That\'s so imaginative! I can\'t wait to see it!',
      'Fantastic! You have such great ideas!',
      'Brilliant! That will be so much fun to create!',
      'Awesome! Your imagination is wonderful!',
      'Excellent! I love how creative you are!',
      'Perfect! That sounds like it will be amazing!',
      'Wonderful! You have such great ideas!',
      'Fantastic! I\'m so excited to help you create this!'
    ];
    
    return responses[DateTime.now().millisecondsSinceEpoch % responses.length];
  }
  
  /// Generate response with optional system prompt and conversation history
  /// Used by voice services for personality-aware responses
  Future<String> generateResponse(
    String userInput, {
    String? systemPrompt,
    List<String>? conversationHistory,
  }) async {
    await initialize();

    // Build context message with system prompt if provided
    String contextMessage = userInput;
    if (systemPrompt != null) {
      contextMessage = '$systemPrompt\n\nUser: $userInput';
    }

    // Add conversation history if provided
    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      final historyText = conversationHistory.join('\n');
      contextMessage = '$historyText\n\nUser: $userInput';
    }

    try {
      // Use existing getCraftaResponse with context
      final response = await getCraftaResponse(contextMessage);
      return response;
    } catch (e) {
      print('Error generating response: $e');
      rethrow;
    }
  }

  /// Get current provider status
  static Map<String, dynamic> getProviderStatus() {
    return {
      'currentProvider': _currentProvider.name,
      'providers': _providers.map((p) => {
        'name': p.name,
        'available': p.isAvailable,
        'failures': _providerFailures[p.name] ?? 0,
      }).toList(),
    };
  }
}
