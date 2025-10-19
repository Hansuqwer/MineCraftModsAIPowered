import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/conversation.dart';
import 'ai_service.dart';
import 'tts_service.dart';
import 'speech_service.dart';
import 'language_service.dart';
import 'local_storage_service.dart';

/// Voice personality types for Crafta
enum VoicePersonality {
  friendlyTeacher,    // Educational, patient, encouraging
  playfulFriend,      // Fun, energetic, silly
  wiseMentor,        // Thoughtful, guiding, wise
  creativeArtist,    // Imaginative, expressive, artistic
  encouragingCoach   // Motivational, supportive, positive
}

/// Enhanced conversational AI service with personality and context awareness
class EnhancedVoiceAIService {
  static final EnhancedVoiceAIService _instance = EnhancedVoiceAIService._internal();
  factory EnhancedVoiceAIService() => _instance;
  EnhancedVoiceAIService._internal();

  final TTSService _ttsService = TTSService();
  final SpeechService _speechService = SpeechService();
  final AIService _aiService = AIService();
  final LocalStorageService _storageService = LocalStorageService();

  // Conversation state
  Conversation? _currentConversation;
  VoicePersonality _currentPersonality = VoicePersonality.friendlyTeacher;
  Map<String, dynamic> _conversationContext = {};
  List<String> _conversationHistory = [];
  
  // Educational content database
  final Map<String, List<String>> _educationalFacts = {
    'dragon': [
      'Dragons are magical creatures that can fly and breathe fire!',
      'In many stories, dragons are very wise and live for hundreds of years.',
      'Some dragons are friendly and help people, while others guard treasure.',
      'Dragons have scales that can be many different colors like red, blue, or gold!'
    ],
    'unicorn': [
      'Unicorns are gentle creatures with a magical horn on their head!',
      'Their horns can heal people and make wishes come true.',
      'Unicorns love rainbows and are very kind to all animals.',
      'They live in enchanted forests and are very rare to see!'
    ],
    'cat': [
      'Cats are amazing pets that love to play and cuddle!',
      'They have excellent balance and can land on their feet.',
      'Cats purr when they are happy and comfortable.',
      'They are very independent but also love their human friends!'
    ],
    'dog': [
      'Dogs are loyal friends who love to play and protect their family!',
      'They can learn many tricks and commands.',
      'Dogs have an amazing sense of smell that is much better than humans.',
      'They are very social animals and love to be around people!'
    ],
    'cow': [
      'Cows are gentle farm animals that give us milk!',
      'They eat grass and hay and spend most of their day grazing.',
      'Cows have four stomachs to help them digest their food.',
      'They are very social and like to be with other cows!'
    ],
    'pig': [
      'Pigs are very smart animals that love to play in mud!',
      'They are actually very clean and use mud to cool off.',
      'Pigs can learn tricks and recognize their names.',
      'They are very social and love to be with their pig friends!'
    ],
    'chicken': [
      'Chickens are farm birds that lay eggs for us to eat!',
      'They love to scratch in the dirt looking for bugs and seeds.',
      'Chickens can fly short distances but prefer to walk.',
      'They are very good at taking care of their baby chicks!'
    ]
  };

  // Personality-specific response patterns
  final Map<VoicePersonality, Map<String, String>> _personalityResponses = {
    VoicePersonality.friendlyTeacher: {
      'greeting': 'Hello there! I\'m so excited to help you create something amazing today!',
      'encouragement': 'That\'s a wonderful idea! You\'re being so creative!',
      'question': 'Tell me more about what you\'d like to create!',
      'celebration': 'Fantastic work! You\'re learning so much about creativity!',
      'guidance': 'Let me help you think about this step by step.'
    },
    VoicePersonality.playfulFriend: {
      'greeting': 'Hey there, buddy! Ready to make something super cool together?',
      'encouragement': 'Whoa, that\'s awesome! You\'re like a little genius!',
      'question': 'Ooh, tell me more! I\'m super curious!',
      'celebration': 'Yay! That\'s going to be so much fun to play with!',
      'guidance': 'Let\'s figure this out together, like a team!'
    },
    VoicePersonality.wiseMentor: {
      'greeting': 'Greetings, young creator. I am here to guide your imagination.',
      'encouragement': 'Your creativity shows great wisdom and insight.',
      'question': 'What vision do you hold in your mind\'s eye?',
      'celebration': 'You have created something truly magnificent.',
      'guidance': 'Let us explore the depths of your imagination together.'
    },
    VoicePersonality.creativeArtist: {
      'greeting': 'Welcome to our creative studio! What masterpiece shall we paint today?',
      'encouragement': 'Your artistic vision is absolutely inspiring!',
      'question': 'What colors and shapes dance in your imagination?',
      'celebration': 'This creation will be a true work of art!',
      'guidance': 'Let\'s explore the endless possibilities of your creativity.'
    },
    VoicePersonality.encouragingCoach: {
      'greeting': 'Hey champion! Ready to create something incredible?',
      'encouragement': 'You\'re doing amazing! Keep that creative energy flowing!',
      'question': 'What amazing idea is brewing in that creative mind?',
      'celebration': 'Outstanding! You\'re becoming a real creative champion!',
      'guidance': 'Let\'s break this down and make it happen!'
    }
  };

  // Getters
  Conversation? get currentConversation => _currentConversation;
  VoicePersonality get currentPersonality => _currentPersonality;
  Map<String, dynamic> get conversationContext => _conversationContext;

  /// Initialize the enhanced voice AI service
  Future<bool> initialize() async {
    try {
      // Initialize TTS and speech services
      await _ttsService.initialize();
      await _speechService.initialize();
      
      // Load conversation history from storage
      await _loadConversationHistory();
      
      print('Enhanced Voice AI Service initialized successfully');
      return true;
    } catch (e) {
      print('Error initializing Enhanced Voice AI Service: $e');
      return false;
    }
  }

  /// Start a new conversation with the specified personality
  Future<void> startConversation({VoicePersonality? personality}) async {
    _currentPersonality = personality ?? VoicePersonality.friendlyTeacher;
    _currentConversation = Conversation(messages: []);
    _conversationContext = {};
    _conversationHistory = [];

    // Add greeting message
    final greeting = _personalityResponses[_currentPersonality]!['greeting']!;
    _currentConversation = _currentConversation!.addMessage(greeting, false);
    
    // Speak the greeting
    await _ttsService.speak(greeting);
  }

  /// Process user voice input and generate contextual response
  Future<String> processVoiceInput(String userInput) async {
    try {
      // Add user message to conversation
      _currentConversation = _currentConversation!.addMessage(userInput, true);
      _conversationHistory.add('User: $userInput');

      // Analyze user input for context
      final context = _analyzeUserInput(userInput);
      _conversationContext.addAll(context);

      // Generate AI response based on personality and context
      final aiResponse = await _generateContextualResponse(userInput, context);
      
      // Add AI response to conversation
      _currentConversation = _currentConversation!.addMessage(aiResponse, false);
      _conversationHistory.add('Crafta: $aiResponse');

      // Save conversation history
      await _saveConversationHistory();

      // Speak the response
      await _ttsService.speak(aiResponse);

      return aiResponse;
    } catch (e) {
      print('Error processing voice input: $e');
      final errorResponse = _getPersonalityResponse('encouragement') + 
          ' Let\'s try that again!';
      await _ttsService.speak(errorResponse);
      return errorResponse;
    }
  }

  /// Analyze user input to extract context and intent
  Map<String, dynamic> _analyzeUserInput(String input) {
    final context = <String, dynamic>{};
    final lowerInput = input.toLowerCase();

    // Detect creature type
    for (final creature in _educationalFacts.keys) {
      if (lowerInput.contains(creature)) {
        context['creatureType'] = creature;
        break;
      }
    }

    // Detect colors
    final colors = ['red', 'blue', 'green', 'yellow', 'purple', 'pink', 'rainbow', 'gold', 'silver'];
    for (final color in colors) {
      if (lowerInput.contains(color)) {
        context['color'] = color;
        break;
      }
    }

    // Detect effects
    final effects = ['flying', 'glowing', 'sparkly', 'magic', 'big', 'small', 'tiny', 'huge'];
    for (final effect in effects) {
      if (lowerInput.contains(effect)) {
        context['effects'] = context['effects'] ?? <String>[];
        (context['effects'] as List<String>).add(effect);
      }
    }

    // Detect questions
    if (lowerInput.contains('?') || lowerInput.contains('what') || 
        lowerInput.contains('how') || lowerInput.contains('why')) {
      context['isQuestion'] = true;
    }

    // Detect excitement
    if (lowerInput.contains('!') || lowerInput.contains('wow') || 
        lowerInput.contains('amazing') || lowerInput.contains('cool')) {
      context['isExcited'] = true;
    }

    return context;
  }

  /// Generate contextual AI response based on personality and conversation context
  Future<String> _generateContextualResponse(String userInput, Map<String, dynamic> context) async {
    try {
      // Build system prompt based on personality and context
      final systemPrompt = _buildSystemPrompt(context);
      
      // Build conversation history for context
      final conversationHistoryMaps = _buildConversationHistory();
      final conversationHistory = conversationHistoryMaps
          .map((m) => '${m['role']}: ${m['content']}')
          .toList();

      // Generate response using AI service
      final response = await _aiService.generateResponse(
        userInput,
        systemPrompt: systemPrompt,
        conversationHistory: conversationHistory
      );

      // Enhance response with personality and educational content
      return _enhanceResponse(response, context);
    } catch (e) {
      print('Error generating contextual response: $e');
      return _getPersonalityResponse('encouragement') + 
          ' I\'m having trouble thinking right now. Can you try again?';
    }
  }

  /// Build system prompt based on personality and context
  String _buildSystemPrompt(Map<String, dynamic> context) {
    final personality = _personalityResponses[_currentPersonality]!;
    final basePrompt = '''
You are Crafta, a friendly AI companion for children ages 4-10 who helps them create Minecraft creatures through voice interaction.

PERSONALITY: ${_currentPersonality.name}
- Greeting style: ${personality['greeting']}
- Encouragement style: ${personality['encouragement']}
- Question style: ${personality['question']}
- Celebration style: ${personality['celebration']}
- Guidance style: ${personality['guidance']}

CONVERSATION CONTEXT:
- Current creature type: ${context['creatureType'] ?? 'none specified'}
- Colors mentioned: ${context['color'] ?? 'none specified'}
- Effects mentioned: ${context['effects'] ?? 'none specified'}
- Is question: ${context['isQuestion'] ?? false}
- Is excited: ${context['isExcited'] ?? false}

GUIDELINES:
1. Always be encouraging and positive
2. Use simple, age-appropriate language
3. Ask follow-up questions to help children be more specific
4. Share educational facts about creatures when relevant
5. Keep responses short (1-2 sentences)
6. Use the personality style consistently
7. If the child mentions a creature, share a fun fact about it
8. Always end with a question to keep the conversation going

Current conversation context: ${_conversationContext.toString()}
''';

    return basePrompt;
  }

  /// Build conversation history for context
  List<Map<String, String>> _buildConversationHistory() {
    final history = <Map<String, String>>[];
    
    for (final message in _currentConversation?.messages ?? []) {
      history.add({
        'role': message.isFromUser ? 'user' : 'assistant',
        'content': message.text
      });
    }
    
    return history;
  }

  /// Enhance AI response with personality and educational content
  String _enhanceResponse(String response, Map<String, dynamic> context) {
    String enhancedResponse = response;

    // Add educational fact if creature type is mentioned
    if (context['creatureType'] != null) {
      final creatureType = context['creatureType'] as String;
      final facts = _educationalFacts[creatureType];
      if (facts != null && facts.isNotEmpty) {
        final randomFact = facts[DateTime.now().millisecond % facts.length];
        enhancedResponse += ' Did you know that $randomFact';
      }
    }

    // Add personality-specific encouragement
    if (context['isExcited'] == true) {
      enhancedResponse += ' ${_getPersonalityResponse('celebration')}';
    }

    // Ensure response ends with a question to continue conversation
    if (!enhancedResponse.contains('?')) {
      enhancedResponse += ' ${_getPersonalityResponse('question')}';
    }

    return enhancedResponse;
  }

  /// Get personality-specific response
  String _getPersonalityResponse(String type) {
    return _personalityResponses[_currentPersonality]![type] ?? 
           _personalityResponses[VoicePersonality.friendlyTeacher]![type]!;
  }

  /// Change voice personality
  Future<void> changePersonality(VoicePersonality newPersonality) async {
    _currentPersonality = newPersonality;
    
    // Announce personality change
    final announcement = 'I\'m now in ${_getPersonalityName(newPersonality)} mode! ' +
                        _getPersonalityResponse('greeting');
    
    if (_currentConversation != null) {
      _currentConversation = _currentConversation!.addMessage(announcement, false);
      await _ttsService.speak(announcement);
    }
  }

  /// Get personality display name
  String _getPersonalityName(VoicePersonality personality) {
    switch (personality) {
      case VoicePersonality.friendlyTeacher:
        return 'Friendly Teacher';
      case VoicePersonality.playfulFriend:
        return 'Playful Friend';
      case VoicePersonality.wiseMentor:
        return 'Wise Mentor';
      case VoicePersonality.creativeArtist:
        return 'Creative Artist';
      case VoicePersonality.encouragingCoach:
        return 'Encouraging Coach';
    }
  }

  /// Save conversation history to local storage
  Future<void> _saveConversationHistory() async {
    try {
      await _storageService.saveData('conversation_history', {
        'history': _conversationHistory,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving conversation history: $e');
    }
  }

  /// Load conversation history from local storage
  Future<void> _loadConversationHistory() async {
    try {
      final history = await _storageService.getData('conversation_history');
      if (history != null && history is List) {
        _conversationHistory = history.cast<String>();
      }
    } catch (e) {
      print('Error loading conversation history: $e');
    }
  }

  /// Clear conversation history
  Future<void> clearConversationHistory() async {
    _conversationHistory.clear();
    _conversationContext.clear();
    await _storageService.removeData('conversation_history');
  }

  /// Get conversation statistics
  Map<String, dynamic> getConversationStats() {
    return {
      'totalMessages': _currentConversation?.messages.length ?? 0,
      'userMessages': _currentConversation?.messages.where((m) => m.isFromUser).length ?? 0,
      'aiMessages': _currentConversation?.messages.where((m) => !m.isFromUser).length ?? 0,
      'currentPersonality': _getPersonalityName(_currentPersonality),
      'conversationDuration': _calculateConversationDuration(),
      'contextKeys': _conversationContext.keys.toList()
    };
  }

  /// Calculate conversation duration
  Duration _calculateConversationDuration() {
    if (_currentConversation?.messages.isEmpty ?? true) {
      return Duration.zero;
    }
    
    final firstMessage = _currentConversation!.messages.first;
    final lastMessage = _currentConversation!.messages.last;
    
    return lastMessage.timestamp.difference(firstMessage.timestamp);
  }

  /// End current conversation
  Future<void> endConversation() async {
    if (_currentConversation != null) {
      final farewell = _getPersonalityResponse('celebration') +
          ' It was so much fun creating with you today!';

      _currentConversation = _currentConversation!.addMessage(farewell, false);
      await _ttsService.speak(farewell);
    }

    _currentConversation = null;
    _conversationContext.clear();
  }

  /// Get current personality (static method for convenience)
  static Future<VoicePersonality> getCurrentPersonality() async {
    return _instance._currentPersonality;
  }

  /// Set personality by name (static method for convenience)
  static Future<void> setPersonality(String personalityName) async {
    try {
      final personality = VoicePersonality.values.firstWhere(
        (p) => p.name.toLowerCase() == personalityName.toLowerCase(),
        orElse: () => VoicePersonality.friendlyTeacher,
      );
      _instance._currentPersonality = personality;
      print('✓ Personality set to ${personality.name}');
    } catch (e) {
      print('Error setting personality: $e');
    }
  }

  /// Get current language (static method for convenience)
  static Future<String> getCurrentLanguage() async {
    final locale = await LanguageService.getCurrentLanguage();
    return locale.languageCode;
  }

  /// Generate voice response (static method for convenience)
  static Future<String> generateVoiceResponse(String prompt) async {
    return await _instance._generateContextualResponse(prompt, {});
  }
}

/// Extension for VoicePersonality enum to add properties
extension VoicePersonalityExt on VoicePersonality {
  /// Get emoji representing the personality
  String get emoji {
    switch (this) {
      case VoicePersonality.friendlyTeacher:
        return '👨‍🏫';
      case VoicePersonality.playfulFriend:
        return '😄';
      case VoicePersonality.wiseMentor:
        return '🧙';
      case VoicePersonality.creativeArtist:
        return '🎨';
      case VoicePersonality.encouragingCoach:
        return '💪';
    }
  }

  /// Get description of the personality
  String get description {
    switch (this) {
      case VoicePersonality.friendlyTeacher:
        return 'Warm, educational, and patient';
      case VoicePersonality.playfulFriend:
        return 'Fun, energetic, and silly';
      case VoicePersonality.wiseMentor:
        return 'Thoughtful, guiding, and wise';
      case VoicePersonality.creativeArtist:
        return 'Imaginative, expressive, and artistic';
      case VoicePersonality.encouragingCoach:
        return 'Motivational, supportive, and positive';
    }
  }
}