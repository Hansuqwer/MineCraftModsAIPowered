import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enhanced_creature_attributes.dart';

/// Enhanced AI Personality Service
/// Manages AI personality, memory, and contextual responses
class EnhancedAIPersonalityService {
  static const String _personalityKey = 'ai_personality';
  static const String _memoryKey = 'ai_memory';
  static const String _conversationHistoryKey = 'conversation_history';

  /// AI Personality Types
  static const Map<String, AIPersonality> _personalities = {
    'friendly': AIPersonality(
      name: 'Friendly',
      description: 'Warm, encouraging, and supportive',
      traits: ['encouraging', 'patient', 'helpful'],
      responseStyle: 'warm and encouraging',
      emoji: '😊',
    ),
    'playful': AIPersonality(
      name: 'Playful',
      description: 'Fun, energetic, and creative',
      traits: ['energetic', 'creative', 'humorous'],
      responseStyle: 'fun and energetic',
      emoji: '😄',
    ),
    'wise': AIPersonality(
      name: 'Wise',
      description: 'Thoughtful, knowledgeable, and guiding',
      traits: ['thoughtful', 'knowledgeable', 'guiding'],
      responseStyle: 'thoughtful and wise',
      emoji: '🧙',
    ),
    'adventurous': AIPersonality(
      name: 'Adventurous',
      description: 'Bold, exciting, and daring',
      traits: ['bold', 'exciting', 'daring'],
      responseStyle: 'bold and exciting',
      emoji: '🏔️',
    ),
  };

  /// Get current AI personality
  static Future<AIPersonality> getCurrentPersonality() async {
    final prefs = await SharedPreferences.getInstance();
    final personalityJson = prefs.getString(_personalityKey);
    
    if (personalityJson != null) {
      final personalityMap = jsonDecode(personalityJson) as Map<String, dynamic>;
      return AIPersonality.fromMap(personalityMap);
    }
    
    // Default to friendly personality
    return _personalities['friendly']!;
  }

  /// Set AI personality
  static Future<void> setPersonality(String personalityType) async {
    final personality = _personalities[personalityType];
    if (personality == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_personalityKey, jsonEncode(personality.toMap()));
  }

  /// Get AI memory
  static Future<AIMemory> getMemory() async {
    final prefs = await SharedPreferences.getInstance();
    final memoryJson = prefs.getString(_memoryKey);
    
    if (memoryJson != null) {
      final memoryMap = jsonDecode(memoryJson) as Map<String, dynamic>;
      return AIMemory.fromMap(memoryMap);
    }
    
    return AIMemory();
  }

  /// Update AI memory
  static Future<void> updateMemory({
    String? userPreference,
    String? favoriteColor,
    String? favoriteCreature,
    List<String>? recentCreations,
    String? userMood,
    Map<String, int>? interactionCounts,
  }) async {
    final memory = await getMemory();
    final updatedMemory = memory.copyWith(
      userPreference: userPreference ?? memory.userPreference,
      favoriteColor: favoriteColor ?? memory.favoriteColor,
      favoriteCreature: favoriteCreature ?? memory.favoriteCreature,
      recentCreations: recentCreations ?? memory.recentCreations,
      userMood: userMood ?? memory.userMood,
      interactionCounts: interactionCounts ?? memory.interactionCounts,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_memoryKey, jsonEncode(updatedMemory.toMap()));
  }

  /// Add conversation to history
  static Future<void> addConversation(String userMessage, String aiResponse) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_conversationHistoryKey);
    
    List<ConversationEntry> history = [];
    if (historyJson != null) {
      final historyList = jsonDecode(historyJson) as List<dynamic>;
      history = historyList.map((e) => ConversationEntry.fromMap(e)).toList();
    }

    history.add(ConversationEntry(
      userMessage: userMessage,
      aiResponse: aiResponse,
      timestamp: DateTime.now(),
    ));

    // Keep only last 50 conversations
    if (history.length > 50) {
      history = history.sublist(history.length - 50);
    }

    await prefs.setString(_conversationHistoryKey, jsonEncode(history.map((e) => e.toMap()).toList()));
  }

  /// Get conversation history
  static Future<List<ConversationEntry>> getConversationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_conversationHistoryKey);
    
    if (historyJson != null) {
      final historyList = jsonDecode(historyJson) as List<dynamic>;
      return historyList.map((e) => ConversationEntry.fromMap(e)).toList();
    }
    
    return [];
  }

  /// Generate personalized response
  static Future<String> generatePersonalizedResponse({
    required String userMessage,
    required String context,
    required EnhancedCreatureAttributes? currentCreature,
  }) async {
    final personality = await getCurrentPersonality();
    final memory = await getMemory();
    final history = await getConversationHistory();

    // Analyze user message for context
    final messageAnalysis = _analyzeUserMessage(userMessage);
    
    // Generate contextual response
    final response = _generateContextualResponse(
      personality: personality,
      memory: memory,
      messageAnalysis: messageAnalysis,
      context: context,
      currentCreature: currentCreature,
      conversationHistory: history,
    );

    // Update memory based on interaction
    await _updateMemoryFromInteraction(messageAnalysis, memory);

    // Add to conversation history
    await addConversation(userMessage, response);

    return response;
  }

  /// Analyze user message for context and intent
  static MessageAnalysis _analyzeUserMessage(String message) {
    final lowerMessage = message.toLowerCase();
    
    // Detect intent
    String intent = 'general';
    if (lowerMessage.contains('create') || lowerMessage.contains('make')) {
      intent = 'creation';
    } else if (lowerMessage.contains('change') || lowerMessage.contains('modify')) {
      intent = 'modification';
    } else if (lowerMessage.contains('help') || lowerMessage.contains('how')) {
      intent = 'help';
    } else if (lowerMessage.contains('thank') || lowerMessage.contains('thanks')) {
      intent = 'gratitude';
    }

    // Detect mood
    String mood = 'neutral';
    if (lowerMessage.contains('!') || lowerMessage.contains('awesome') || lowerMessage.contains('amazing')) {
      mood = 'excited';
    } else if (lowerMessage.contains('?') || lowerMessage.contains('confused')) {
      mood = 'curious';
    } else if (lowerMessage.contains('sad') || lowerMessage.contains('disappointed')) {
      mood = 'concerned';
    }

    // Detect preferences
    final colors = <String>[];
    if (lowerMessage.contains('red')) colors.add('red');
    if (lowerMessage.contains('blue')) colors.add('blue');
    if (lowerMessage.contains('green')) colors.add('green');
    if (lowerMessage.contains('purple')) colors.add('purple');
    if (lowerMessage.contains('gold')) colors.add('gold');

    final creatures = <String>[];
    if (lowerMessage.contains('dragon')) creatures.add('dragon');
    if (lowerMessage.contains('cat')) creatures.add('cat');
    if (lowerMessage.contains('dog')) creatures.add('dog');
    if (lowerMessage.contains('bird')) creatures.add('bird');

    return MessageAnalysis(
      intent: intent,
      mood: mood,
      colors: colors,
      creatures: creatures,
      isQuestion: lowerMessage.contains('?'),
      isExclamation: lowerMessage.contains('!'),
    );
  }

  /// Generate contextual response based on personality and memory
  static String _generateContextualResponse({
    required AIPersonality personality,
    required AIMemory memory,
    required MessageAnalysis messageAnalysis,
    required String context,
    required EnhancedCreatureAttributes? currentCreature,
    required List<ConversationEntry> conversationHistory,
  }) {
    final responses = <String>[];

    // Add personality-based greeting
    if (messageAnalysis.intent == 'creation') {
      responses.add(_getCreationResponse(personality, memory, messageAnalysis));
    } else if (messageAnalysis.intent == 'modification') {
      responses.add(_getModificationResponse(personality, memory, messageAnalysis));
    } else if (messageAnalysis.intent == 'help') {
      responses.add(_getHelpResponse(personality, memory, messageAnalysis));
    } else if (messageAnalysis.intent == 'gratitude') {
      responses.add(_getGratitudeResponse(personality, memory, messageAnalysis));
    } else {
      responses.add(_getGeneralResponse(personality, memory, messageAnalysis));
    }

    // Add memory-based personalization
    if (memory.favoriteColor != null && messageAnalysis.colors.contains(memory.favoriteColor!)) {
      responses.add(_getColorPreferenceResponse(personality, memory.favoriteColor!));
    }

    if (memory.favoriteCreature != null && messageAnalysis.creatures.contains(memory.favoriteCreature!)) {
      responses.add(_getCreaturePreferenceResponse(personality, memory.favoriteCreature!));
    }

    // Add contextual suggestions
    if (currentCreature != null) {
      responses.add(_getContextualSuggestion(personality, currentCreature, messageAnalysis));
    }

    return responses.join(' ');
  }

  /// Get creation response based on personality
  static String _getCreationResponse(AIPersonality personality, AIMemory memory, MessageAnalysis analysis) {
    switch (personality.name) {
      case 'Friendly':
        return 'I\'m so excited to help you create something amazing! ${analysis.colors.isNotEmpty ? "I love that you're thinking about ${analysis.colors.first}!" : ""}';
      case 'Playful':
        return 'Ooh, let\'s make something super cool! ${analysis.creatures.isNotEmpty ? "A ${analysis.creatures.first} sounds awesome!" : ""}';
      case 'Wise':
        return 'Creating something new is always a wonderful journey. ${analysis.colors.isNotEmpty ? "The color ${analysis.colors.first} has great potential." : ""}';
      case 'Adventurous':
        return 'Let\'s create something bold and amazing! ${analysis.creatures.isNotEmpty ? "A ${analysis.creatures.first} is perfect for an adventure!" : ""}';
      default:
        return 'Let\'s create something together!';
    }
  }

  /// Get modification response based on personality
  static String _getModificationResponse(AIPersonality personality, AIMemory memory, MessageAnalysis analysis) {
    switch (personality.name) {
      case 'Friendly':
        return 'Of course! I\'m here to help you make it perfect. What would you like to change?';
      case 'Playful':
        return 'Ooh, let\'s mix things up! What fun changes do you have in mind?';
      case 'Wise':
        return 'Refinement is the key to perfection. What aspects would you like to improve?';
      case 'Adventurous':
        return 'Let\'s make it even more exciting! What bold changes are you thinking?';
      default:
        return 'Let\'s modify it together!';
    }
  }

  /// Get help response based on personality
  static String _getHelpResponse(AIPersonality personality, AIMemory memory, MessageAnalysis analysis) {
    switch (personality.name) {
      case 'Friendly':
        return 'I\'m here to help! What would you like to know?';
      case 'Playful':
        return 'Ask away! I love helping with creative questions!';
      case 'Wise':
        return 'I\'m here to guide you. What knowledge do you seek?';
      case 'Adventurous':
        return 'Let\'s explore this together! What do you need to know?';
      default:
        return 'How can I help you?';
    }
  }

  /// Get gratitude response based on personality
  static String _getGratitudeResponse(AIPersonality personality, AIMemory memory, MessageAnalysis analysis) {
    switch (personality.name) {
      case 'Friendly':
        return 'You\'re so welcome! I love helping you create amazing things!';
      case 'Playful':
        return 'You\'re welcome! That was so much fun!';
      case 'Wise':
        return 'You\'re welcome. It\'s my pleasure to assist you.';
      case 'Adventurous':
        return 'You\'re welcome! That was an exciting adventure!';
      default:
        return 'You\'re welcome!';
    }
  }

  /// Get general response based on personality
  static String _getGeneralResponse(AIPersonality personality, AIMemory memory, MessageAnalysis analysis) {
    switch (personality.name) {
      case 'Friendly':
        return 'I\'m here to help you create something wonderful!';
      case 'Playful':
        return 'Let\'s have some fun creating together!';
      case 'Wise':
        return 'I\'m here to guide you on your creative journey.';
      case 'Adventurous':
        return 'Let\'s embark on an exciting creative adventure!';
      default:
        return 'I\'m here to help!';
    }
  }

  /// Get color preference response
  static String _getColorPreferenceResponse(AIPersonality personality, String color) {
    switch (personality.name) {
      case 'Friendly':
        return 'I remember you love $color! Great choice!';
      case 'Playful':
        return 'Ooh, $color again! You really love that color!';
      case 'Wise':
        return '$color is indeed a wonderful choice, as you\'ve shown before.';
      case 'Adventurous':
        return '$color is perfect for another exciting creation!';
      default:
        return 'I see you\'re using $color again!';
    }
  }

  /// Get creature preference response
  static String _getCreaturePreferenceResponse(AIPersonality personality, String creature) {
    switch (personality.name) {
      case 'Friendly':
        return 'Another $creature! I know how much you love them!';
      case 'Playful':
        return 'A $creature again! You\'re building quite a collection!';
      case 'Wise':
        return '$creature is indeed a favorite of yours.';
      case 'Adventurous':
        return 'Another $creature adventure! Let\'s make it amazing!';
      default:
        return 'I see you\'re creating another $creature!';
    }
  }

  /// Get contextual suggestion
  static String _getContextualSuggestion(AIPersonality personality, EnhancedCreatureAttributes creature, MessageAnalysis analysis) {
    switch (personality.name) {
      case 'Friendly':
        return 'Your ${creature.customName} is looking great! Would you like to add any special features?';
      case 'Playful':
        return 'Your ${creature.customName} is awesome! Want to make it even more fun?';
      case 'Wise':
        return 'Your ${creature.customName} shows great potential. What enhancements do you envision?';
      case 'Adventurous':
        return 'Your ${creature.customName} is ready for adventure! What exciting features should we add?';
      default:
        return 'Your ${creature.customName} is looking good!';
    }
  }

  /// Update memory based on interaction
  static Future<void> _updateMemoryFromInteraction(MessageAnalysis analysis, AIMemory memory) async {
    final updates = <String, dynamic>{};

    // Update favorite color
    if (analysis.colors.isNotEmpty) {
      updates['favoriteColor'] = analysis.colors.first;
    }

    // Update favorite creature
    if (analysis.creatures.isNotEmpty) {
      updates['favoriteCreature'] = analysis.creatures.first;
    }

    // Update interaction counts
    final interactionCounts = Map<String, int>.from(memory.interactionCounts);
    interactionCounts[analysis.intent] = (interactionCounts[analysis.intent] ?? 0) + 1;
    updates['interactionCounts'] = interactionCounts;

    // Update user mood
    if (analysis.mood != 'neutral') {
      updates['userMood'] = analysis.mood;
    }

    if (updates.isNotEmpty) {
      await updateMemory(
        favoriteColor: updates['favoriteColor'],
        favoriteCreature: updates['favoriteCreature'],
        userMood: updates['userMood'],
        interactionCounts: updates['interactionCounts'],
      );
    }
  }
}

/// AI Personality Model
class AIPersonality {
  final String name;
  final String description;
  final List<String> traits;
  final String responseStyle;
  final String emoji;

  const AIPersonality({
    required this.name,
    required this.description,
    required this.traits,
    required this.responseStyle,
    required this.emoji,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'traits': traits,
      'responseStyle': responseStyle,
      'emoji': emoji,
    };
  }

  factory AIPersonality.fromMap(Map<String, dynamic> map) {
    return AIPersonality(
      name: map['name'],
      description: map['description'],
      traits: List<String>.from(map['traits']),
      responseStyle: map['responseStyle'],
      emoji: map['emoji'],
    );
  }
}

/// AI Memory Model
class AIMemory {
  final String? userPreference;
  final String? favoriteColor;
  final String? favoriteCreature;
  final List<String> recentCreations;
  final String? userMood;
  final Map<String, int> interactionCounts;

  const AIMemory({
    this.userPreference,
    this.favoriteColor,
    this.favoriteCreature,
    this.recentCreations = const [],
    this.userMood,
    this.interactionCounts = const {},
  });

  AIMemory copyWith({
    String? userPreference,
    String? favoriteColor,
    String? favoriteCreature,
    List<String>? recentCreations,
    String? userMood,
    Map<String, int>? interactionCounts,
  }) {
    return AIMemory(
      userPreference: userPreference ?? this.userPreference,
      favoriteColor: favoriteColor ?? this.favoriteColor,
      favoriteCreature: favoriteCreature ?? this.favoriteCreature,
      recentCreations: recentCreations ?? this.recentCreations,
      userMood: userMood ?? this.userMood,
      interactionCounts: interactionCounts ?? this.interactionCounts,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userPreference': userPreference,
      'favoriteColor': favoriteColor,
      'favoriteCreature': favoriteCreature,
      'recentCreations': recentCreations,
      'userMood': userMood,
      'interactionCounts': interactionCounts,
    };
  }

  factory AIMemory.fromMap(Map<String, dynamic> map) {
    return AIMemory(
      userPreference: map['userPreference'],
      favoriteColor: map['favoriteColor'],
      favoriteCreature: map['favoriteCreature'],
      recentCreations: List<String>.from(map['recentCreations'] ?? []),
      userMood: map['userMood'],
      interactionCounts: Map<String, int>.from(map['interactionCounts'] ?? {}),
    );
  }
}

/// Message Analysis Model
class MessageAnalysis {
  final String intent;
  final String mood;
  final List<String> colors;
  final List<String> creatures;
  final bool isQuestion;
  final bool isExclamation;

  const MessageAnalysis({
    required this.intent,
    required this.mood,
    required this.colors,
    required this.creatures,
    required this.isQuestion,
    required this.isExclamation,
  });
}

/// Conversation Entry Model
class ConversationEntry {
  final String userMessage;
  final String aiResponse;
  final DateTime timestamp;

  const ConversationEntry({
    required this.userMessage,
    required this.aiResponse,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userMessage': userMessage,
      'aiResponse': aiResponse,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ConversationEntry.fromMap(Map<String, dynamic> map) {
    return ConversationEntry(
      userMessage: map['userMessage'],
      aiResponse: map['aiResponse'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}
