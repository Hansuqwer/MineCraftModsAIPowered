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
import 'api_key_service.dart';
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
  final String? apiKey;
  final String? baseUrl;
  final String? model;
  
  const AIProvider({
    required this.name,
    required this.isAvailable,
    this.apiKey,
    this.baseUrl,
    this.model,
  });
}

/// Main AI Service
/// Handles AI responses and conversation management
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Provider management
  static int _currentProviderIndex = 0;
  static final List<AIProvider> _providers = [
    const AIProvider(
      name: 'OpenAI',
      isAvailable: true,
      apiKey: null, // Will be loaded from storage
      baseUrl: 'https://api.openai.com/v1/chat/completions',
      model: 'gpt-4o-mini',
    ),
    const AIProvider(
      name: 'Groq',
      isAvailable: true,
      apiKey: null, // Will be loaded from storage
      baseUrl: 'https://api.groq.com/openai/v1/chat/completions',
      model: 'llama-3.1-8b-instant',
    ),
    const AIProvider(
      name: 'HuggingFace',
      isAvailable: true,
      apiKey: null, // Will be loaded from storage
      baseUrl: 'https://api-inference.huggingface.co/models/microsoft/DialoGPT-medium',
      model: 'microsoft/DialoGPT-medium',
    ),
    const AIProvider(
      name: 'Ollama',
      isAvailable: false, // Local only
      baseUrl: 'http://localhost:11434/api/generate',
      model: 'llama2',
    ),
    const AIProvider(
      name: 'Offline',
      isAvailable: true,
    ),
  ];

  static final Map<String, int> _providerFailures = {};
  static AIProvider get _currentProvider => _providers[_currentProviderIndex];

  // Services
  final ConnectivityService _connectivityService = ConnectivityService();
  final ContentModerationService _contentModerationService = ContentModerationService();
  final LocalStorageService _storageService = LocalStorageService();
  final ApiKeyService _apiKeyService = ApiKeyService();
  final SwedishAIService _swedishAIService = SwedishAIService();
  final DebugService _debugService = DebugService();

  bool _isInitialized = false;

  /// Initialize the AI service
  Future<void> initialize() async {
    if (_isInitialized) return;

    print('🤖 [AI_SERVICE] Initializing AI service...');
    
    // Load API keys
    await _loadApiKeys();
    
    // Check connectivity
    final isConnected = await _connectivityService.checkConnectivity();
    print('🌐 [AI_SERVICE] Connectivity: ${isConnected ? "Connected" : "Offline"}');
    
    _isInitialized = true;
    print('✅ [AI_SERVICE] AI service initialized');
  }

  /// Load API keys from storage
  Future<void> _loadApiKeys() async {
    try {
      final openaiKey = await _apiKeyService.getApiKey();
      
      print('🔑 [AI_SERVICE] API Keys loaded:');
      print('  - OpenAI: ${openaiKey != null ? "✅" : "❌"}');
    } catch (e) {
      print('❌ [AI_SERVICE] Error loading API keys: $e');
    }
  }

  /// Generate response for conversation
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

  /// Get Crafta response with enhanced parsing
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

  /// OpenAI response with enhanced parsing
  Future<String> _getOpenAIResponse(String userMessage, int age) async {
    print('🔍 [DEBUG] === OPENAI API CALL START ===');
    try {
      // Step 1: Load API key
      print('🔍 [DEBUG] Step 1: Loading API key from secure storage...');
      final apiKey = await _apiKeyService.getApiKey();

      if (apiKey == null) {
        print('❌ [DEBUG] FAILED: No API key found in storage');
        print('💡 [DEBUG] User needs to configure API key in settings');
        throw AIServiceException('OpenAI API key not found - Please configure in settings', 'OpenAI');
      }

      print('✅ [DEBUG] Step 1: API key loaded: ${apiKey.substring(0, 7)}...${apiKey.substring(apiKey.length - 4)}');
      print('🔍 [DEBUG] Key length: ${apiKey.length} characters');

      // Step 2: Check connectivity
      print('🔍 [DEBUG] Step 2: Checking internet connectivity...');
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        print('❌ [DEBUG] FAILED: No internet connection');
        throw AIServiceException('No internet connection - Using offline mode', 'OpenAI');
      }
      print('✅ [DEBUG] Step 2: Internet connected');

      // Step 3: Make API call
      print('🔍 [DEBUG] Step 3: Making API call to OpenAI...');
      print('🔍 [DEBUG] Endpoint: https://api.openai.com/v1/chat/completions');
      print('🔍 [DEBUG] Model: gpt-4o-mini');
      print('🔍 [DEBUG] Message length: ${userMessage.length} chars');

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': _getEnhancedSystemPrompt(age),
            },
            {
              'role': 'user',
              'content': userMessage,
            },
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('❌ [DEBUG] FAILED: API request timed out after 30 seconds');
          throw TimeoutException('OpenAI API request timed out');
        },
      );

      print('🔍 [DEBUG] Step 3: Response received');
      print('🔍 [DEBUG] Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ [DEBUG] Step 4: Parsing successful response...');
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        print('✅ [DEBUG] === OPENAI API CALL SUCCESS ===');
        print('🤖 [DEBUG] Response preview: ${content.substring(0, content.length > 100 ? 100 : content.length)}...');
        return content;
      } else {
        print('❌ [DEBUG] FAILED: OpenAI API returned error status');
        print('❌ [DEBUG] Status: ${response.statusCode}');
        print('❌ [DEBUG] Body: ${response.body}');

        // Parse error message if available
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
          print('❌ [DEBUG] Error message: $errorMessage');
          throw AIServiceException('OpenAI API error (${response.statusCode}): $errorMessage', 'OpenAI');
        } catch (e) {
          throw AIServiceException('OpenAI API error: ${response.statusCode}', 'OpenAI');
        }
      }
    } on TimeoutException catch (e) {
      print('❌ [DEBUG] === OPENAI API CALL FAILED: TIMEOUT ===');
      throw AIServiceException('OpenAI API timeout: $e', 'OpenAI');
    } on SocketException catch (e) {
      print('❌ [DEBUG] === OPENAI API CALL FAILED: NETWORK ===');
      print('❌ [DEBUG] Network error: $e');
      throw AIServiceException('Network error: Unable to reach OpenAI servers', 'OpenAI');
    } catch (e) {
      print('❌ [DEBUG] === OPENAI API CALL FAILED: UNEXPECTED ===');
      print('❌ [DEBUG] Error type: ${e.runtimeType}');
      print('❌ [DEBUG] Error: $e');
      throw AIServiceException('OpenAI error: $e', 'OpenAI');
    }
  }

  /// Groq response with enhanced parsing
  Future<String> _getGroqResponse(String userMessage, int age) async {
    try {
      // For now, just use offline mode for Groq
      return await _getOfflineResponse(userMessage, age);
    } catch (e) {
      throw AIServiceException('Groq error: $e', 'Groq');
    }
  }

  /// Hugging Face response
  Future<String> _getHuggingFaceResponse(String userMessage, int age) async {
    try {
      // For now, just use offline mode for HuggingFace
      return await _getOfflineResponse(userMessage, age);
    } catch (e) {
      throw AIServiceException('HuggingFace error: $e', 'HuggingFace');
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

  /// Enhanced system prompt for parsing Minecraft items
  String _getEnhancedSystemPrompt(int age) {
    return '''You are Crafta, an AI assistant that helps children create custom Minecraft items through natural language.

IMPORTANT: When a child asks for something specific, use EXACTLY what they ask for. Don't change their requests.

You can create ALL types of Minecraft items:
- CREATURES: dragon, cat, dog, robot, unicorn, phoenix, dinosaur, monster, etc.
- WEAPONS: sword, bow, axe, hammer, magic wand, staff, etc.
- ARMOR: helmet, chestplate, leggings, boots, shield, etc.
- FURNITURE: chair, table, bed, lamp, bookshelf, etc.
- VEHICLES: car, boat, plane, rocket, spaceship, train, etc.
- BUILDINGS: house, castle, tower, bridge, etc.
- TOOLS: pickaxe, shovel, hoe, fishing rod, etc.
- DECORATIONS: flower, plant, statue, painting, etc.

Examples:
- "blue sword" → Create a blue sword
- "dragon with red eyes and it should be black" → Create a black dragon with red eyes
- "make me a blue sword" → Create a blue sword
- "red chair" → Create a red chair
- "golden helmet" → Create a golden helmet

Your task is to:
1. Understand what the child wants to create
2. Respond with enthusiasm and encouragement
3. Ask follow-up questions to help them design it better
4. Keep responses short and engaging (2-3 sentences max)

Always be safe, kind, and imaginative. Focus on positive, creative attributes.
Use EXACTLY what the child asks for - don't change their requests.

For children aged $age, use ${age <= 6 ? 'very simple words and lots of encouragement' : age <= 10 ? 'simple words but you can be a bit more detailed' : 'more complex language and provide more detailed suggestions'}.''';
  }

  /// Parse creature request (legacy method - kept for compatibility)
  Future<Map<String, dynamic>> parseCreatureRequest(String userMessage) async {
    // This method is kept for compatibility but the actual parsing
    // should be done by the EnhancedAIService
    return {
      'baseType': 'creature',
      'primaryColor': 'blue',
      'size': 'medium',
      'personality': 'friendly',
    };
  }

  /// Process user input and return conversation
  Future<Conversation> processUserInput(String userMessage, Conversation currentConversation) async {
    try {
      // Add user message to conversation
      final updatedConversation = currentConversation.addMessage(userMessage, true);
      
      // Generate AI response
      final aiResponse = await getCraftaResponse(userMessage);
      
      // Add AI response to conversation
      final finalConversation = updatedConversation.addMessage(aiResponse, false);

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
      'I\'m so excited to help you create that!',
      'What a fantastic idea! Tell me more about it!',
      'You have such a great imagination!',
      'That\'s going to be so much fun to make!',
      'I can\'t wait to see what we create!',
      'You\'re such a creative thinker!',
    ];
    
    final random = DateTime.now().millisecondsSinceEpoch % responses.length;
    return responses[random];
  }

  /// Switch to next available provider
  void _switchToNextProvider() {
    _currentProviderIndex = (_currentProviderIndex + 1) % _providers.length;
    print('🔄 [AI_SERVICE] Switched to provider: ${_currentProvider.name}');
  }

  /// Record provider failure
  void _recordProviderFailure(String providerName) {
    _providerFailures[providerName] = (_providerFailures[providerName] ?? 0) + 1;
  }

  /// Reset provider failures
  void _resetProviderFailures() {
    _providerFailures.clear();
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
