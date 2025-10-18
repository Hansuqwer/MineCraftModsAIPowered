import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enhanced_creature_attributes.dart';

/// Enhanced Voice AI Service
/// Provides human-like voice responses in English and Swedish
class EnhancedVoiceAIService {
  static const String _voicePersonalityKey = 'voice_personality';
  static const String _languageKey = 'voice_language';
  static const String _voiceHistoryKey = 'voice_history';

  /// Voice Personality Types
  static const Map<String, VoicePersonality> _personalities = {
    'friendly_teacher': VoicePersonality(
      name: 'Friendly Teacher',
      description: 'Warm, encouraging, and educational',
      traits: ['encouraging', 'patient', 'educational'],
      responseStyle: 'warm and supportive',
      emoji: '👩‍🏫',
    ),
    'playful_friend': VoicePersonality(
      name: 'Playful Friend',
      description: 'Fun, energetic, and creative',
      traits: ['energetic', 'creative', 'humorous'],
      responseStyle: 'fun and exciting',
      emoji: '🎉',
    ),
    'wise_mentor': VoicePersonality(
      name: 'Wise Mentor',
      description: 'Thoughtful, knowledgeable, and guiding',
      traits: ['thoughtful', 'knowledgeable', 'guiding'],
      responseStyle: 'wise and thoughtful',
      emoji: '🧙‍♂️',
    ),
    'adventurous_guide': VoicePersonality(
      name: 'Adventurous Guide',
      description: 'Bold, exciting, and inspiring',
      traits: ['bold', 'exciting', 'inspiring'],
      responseStyle: 'bold and adventurous',
      emoji: '🏔️',
    ),
  };

  /// Get current voice personality
  static Future<VoicePersonality> getCurrentPersonality() async {
    final prefs = await SharedPreferences.getInstance();
    final personalityJson = prefs.getString(_voicePersonalityKey);
    
    if (personalityJson != null) {
      final personalityMap = jsonDecode(personalityJson) as Map<String, dynamic>;
      return VoicePersonality.fromMap(personalityMap);
    }
    
    // Default to friendly teacher
    return _personalities['friendly_teacher']!;
  }

  /// Set voice personality
  static Future<void> setPersonality(String personalityType) async {
    final personality = _personalities[personalityType];
    if (personality == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_voicePersonalityKey, jsonEncode(personality.toMap()));
  }

  /// Get current language
  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  /// Set language
  static Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  /// Generate human-like voice response
  static Future<String> generateVoiceResponse({
    required String userMessage,
    required String context,
    required EnhancedCreatureAttributes? currentCreature,
    required String language,
  }) async {
    final personality = await getCurrentPersonality();
    final voiceHistory = await getVoiceHistory();
    
    // Analyze user message for emotional context
    final emotionalContext = _analyzeEmotionalContext(userMessage, language);
    
    // Generate contextual response
    final response = _generateContextualVoiceResponse(
      personality: personality,
      emotionalContext: emotionalContext,
      context: context,
      currentCreature: currentCreature,
      language: language,
      voiceHistory: voiceHistory,
    );

    // Add to voice history
    await addVoiceResponse(userMessage, response, language);

    return response;
  }

  /// Analyze emotional context of user message
  static EmotionalContext _analyzeEmotionalContext(String message, String language) {
    final lowerMessage = message.toLowerCase();
    
    // Detect excitement level
    int excitementLevel = 0;
    if (lowerMessage.contains('!') || lowerMessage.contains('awesome') || lowerMessage.contains('amazing')) {
      excitementLevel = 3;
    } else if (lowerMessage.contains('cool') || lowerMessage.contains('great')) {
      excitementLevel = 2;
    } else if (lowerMessage.contains('ok') || lowerMessage.contains('sure')) {
      excitementLevel = 1;
    }

    // Detect confidence level
    int confidenceLevel = 0;
    if (lowerMessage.contains('definitely') || lowerMessage.contains('absolutely')) {
      confidenceLevel = 3;
    } else if (lowerMessage.contains('maybe') || lowerMessage.contains('perhaps')) {
      confidenceLevel = 1;
    } else if (lowerMessage.contains('not sure') || lowerMessage.contains('confused')) {
      confidenceLevel = 0;
    }

    // Detect creativity level
    int creativityLevel = 0;
    if (lowerMessage.contains('creative') || lowerMessage.contains('unique') || lowerMessage.contains('special')) {
      creativityLevel = 3;
    } else if (lowerMessage.contains('different') || lowerMessage.contains('new')) {
      creativityLevel = 2;
    } else if (lowerMessage.contains('simple') || lowerMessage.contains('basic')) {
      creativityLevel = 1;
    }

    return EmotionalContext(
      excitementLevel: excitementLevel,
      confidenceLevel: confidenceLevel,
      creativityLevel: creativityLevel,
      isQuestion: lowerMessage.contains('?'),
      isExclamation: lowerMessage.contains('!'),
    );
  }

  /// Generate contextual voice response
  static String _generateContextualVoiceResponse({
    required VoicePersonality personality,
    required EmotionalContext emotionalContext,
    required String context,
    required EnhancedCreatureAttributes? currentCreature,
    required String language,
    required List<VoiceResponse> voiceHistory,
  }) {
    final responses = <String>[];

    // Add personality-based greeting
    responses.add(_getPersonalityGreeting(personality, emotionalContext, language));

    // Add contextual response based on situation
    if (context == 'creation') {
      responses.add(_getCreationResponse(personality, emotionalContext, language));
    } else if (context == 'modification') {
      responses.add(_getModificationResponse(personality, emotionalContext, language));
    } else if (context == 'suggestion') {
      responses.add(_getSuggestionResponse(personality, emotionalContext, language));
    } else if (context == 'celebration') {
      responses.add(_getCelebrationResponse(personality, emotionalContext, language));
    }

    // Add creature-specific response
    if (currentCreature != null) {
      responses.add(_getCreatureSpecificResponse(personality, currentCreature, emotionalContext, language));
    }

    // Add encouraging closing
    responses.add(_getEncouragingClosing(personality, emotionalContext, language));

    return responses.join(' ');
  }

  /// Get personality-based greeting
  static String _getPersonalityGreeting(VoicePersonality personality, EmotionalContext context, String language) {
    if (language == 'sv') {
      switch (personality.name) {
        case 'Friendly Teacher':
          return context.excitementLevel > 2 ? 'Hej! Jag ser att du är så peppad!' : 'Hej! Vad roligt att se dig här!';
        case 'Playful Friend':
          return context.excitementLevel > 2 ? 'Hej hej! Du verkar superexalterad!' : 'Hej! Låt oss ha kul tillsammans!';
        case 'Wise Mentor':
          return 'Hej, min vän. Jag ser att du är redo att lära dig.';
        case 'Adventurous Guide':
          return context.excitementLevel > 2 ? 'Hej! Du verkar redo för äventyr!' : 'Hej! Låt oss utforska tillsammans!';
        default:
          return 'Hej! Vad roligt att se dig!';
      }
    } else {
      switch (personality.name) {
        case 'Friendly Teacher':
          return context.excitementLevel > 2 ? 'Hello! I can see you\'re so excited!' : 'Hello! It\'s wonderful to see you here!';
        case 'Playful Friend':
          return context.excitementLevel > 2 ? 'Hey there! You seem super excited!' : 'Hey! Let\'s have some fun together!';
        case 'Wise Mentor':
          return 'Hello, my friend. I see you\'re ready to learn.';
        case 'Adventurous Guide':
          return context.excitementLevel > 2 ? 'Hello! You seem ready for adventure!' : 'Hello! Let\'s explore together!';
        default:
          return 'Hello! It\'s great to see you!';
      }
    }
  }

  /// Get creation response
  static String _getCreationResponse(VoicePersonality personality, EmotionalContext context, String language) {
    if (language == 'sv') {
      switch (personality.name) {
        case 'Friendly Teacher':
          return 'Låt oss skapa något fantastiskt tillsammans! Jag är här för att hjälpa dig varje steg på vägen.';
        case 'Playful Friend':
          return 'Ooh, låt oss göra något supercoolt! Det här kommer att bli så roligt!';
        case 'Wise Mentor':
          return 'Att skapa något nytt är alltid en underbar resa. Låt mig guida dig.';
        case 'Adventurous Guide':
          return 'Låt oss skapa något djärvt och fantastiskt! Det här kommer att bli ett äventyr!';
        default:
          return 'Låt oss skapa något tillsammans!';
      }
    } else {
      switch (personality.name) {
        case 'Friendly Teacher':
          return 'Let\'s create something amazing together! I\'m here to help you every step of the way.';
        case 'Playful Friend':
          return 'Ooh, let\'s make something super cool! This is going to be so much fun!';
        case 'Wise Mentor':
          return 'Creating something new is always a wonderful journey. Let me guide you.';
        case 'Adventurous Guide':
          return 'Let\'s create something bold and amazing! This is going to be an adventure!';
        default:
          return 'Let\'s create something together!';
      }
    }
  }

  /// Get modification response
  static String _getModificationResponse(VoicePersonality personality, EmotionalContext context, String language) {
    if (language == 'sv') {
      switch (personality.name) {
        case 'Friendly Teacher':
          return 'Självklart! Jag är här för att hjälpa dig göra det perfekt. Vad skulle du vilja ändra?';
        case 'Playful Friend':
          return 'Ooh, låt oss blanda om saker! Vilka roliga ändringar har du i åtanke?';
        case 'Wise Mentor':
          return 'Förfining är nyckeln till perfektion. Vilka aspekter skulle du vilja förbättra?';
        case 'Adventurous Guide':
          return 'Låt oss göra det ännu mer spännande! Vilka djärva ändringar tänker du på?';
        default:
          return 'Låt oss modifiera det tillsammans!';
      }
    } else {
      switch (personality.name) {
        case 'Friendly Teacher':
          return 'Of course! I\'m here to help you make it perfect. What would you like to change?';
        case 'Playful Friend':
          return 'Ooh, let\'s mix things up! What fun changes do you have in mind?';
        case 'Wise Mentor':
          return 'Refinement is the key to perfection. What aspects would you like to improve?';
        case 'Adventurous Guide':
          return 'Let\'s make it even more exciting! What bold changes are you thinking?';
        default:
          return 'Let\'s modify it together!';
      }
    }
  }

  /// Get suggestion response
  static String _getSuggestionResponse(VoicePersonality personality, EmotionalContext context, String language) {
    if (language == 'sv') {
      switch (personality.name) {
        case 'Friendly Teacher':
          return 'Jag har några idéer som kan göra din skapelse ännu bättre! Vill du höra dem?';
        case 'Playful Friend':
          return 'Ooh, jag har några superroliga förslag! Vill du höra vad jag tänker?';
        case 'Wise Mentor':
          return 'Jag ser potential för förbättringar. Låt mig dela mina insikter.';
        case 'Adventurous Guide':
          return 'Jag har några djärva idéer som kan göra det ännu mer spännande!';
        default:
          return 'Jag har några förslag för dig!';
      }
    } else {
      switch (personality.name) {
        case 'Friendly Teacher':
          return 'I have some ideas that could make your creation even better! Would you like to hear them?';
        case 'Playful Friend':
          return 'Ooh, I have some super fun suggestions! Want to hear what I\'m thinking?';
        case 'Wise Mentor':
          return 'I see potential for improvements. Let me share my insights.';
        case 'Adventurous Guide':
          return 'I have some bold ideas that could make it even more exciting!';
        default:
          return 'I have some suggestions for you!';
      }
    }
  }

  /// Get celebration response
  static String _getCelebrationResponse(VoicePersonality personality, EmotionalContext context, String language) {
    if (language == 'sv') {
      switch (personality.name) {
        case 'Friendly Teacher':
          return 'Fantastiskt jobbat! Du har skapat något riktigt speciellt!';
        case 'Playful Friend':
          return 'Woo-hoo! Det här är så coolt! Du är verkligen kreativ!';
        case 'Wise Mentor':
          return 'Utmärkt arbete. Du har visat stor kreativitet och visdom.';
        case 'Adventurous Guide':
          return 'Wow! Det här är verkligen ett äventyr! Du har gjort något fantastiskt!';
        default:
          return 'Bra jobbat! Det ser fantastiskt ut!';
      }
    } else {
      switch (personality.name) {
        case 'Friendly Teacher':
          return 'Fantastic work! You\'ve created something truly special!';
        case 'Playful Friend':
          return 'Woo-hoo! This is so cool! You\'re really creative!';
        case 'Wise Mentor':
          return 'Excellent work. You\'ve shown great creativity and wisdom.';
        case 'Adventurous Guide':
          return 'Wow! This is truly an adventure! You\'ve made something amazing!';
        default:
          return 'Great job! It looks fantastic!';
      }
    }
  }

  /// Get creature-specific response
  static String _getCreatureSpecificResponse(VoicePersonality personality, EnhancedCreatureAttributes creature, EmotionalContext context, String language) {
    if (language == 'sv') {
      switch (personality.name) {
        case 'Friendly Teacher':
          return 'Din ${creature.customName} ser underbar ut! Jag ser att du har tänkt på alla detaljer.';
        case 'Playful Friend':
          return 'Ooh, din ${creature.customName} är så cool! Jag älskar alla de roliga detaljerna!';
        case 'Wise Mentor':
          return 'Din ${creature.customName} visar stor potential. Du har gjort kloka val.';
        case 'Adventurous Guide':
          return 'Din ${creature.customName} är redo för äventyr! Vilka spännande funktioner!';
        default:
          return 'Din ${creature.customName} ser bra ut!';
      }
    } else {
      switch (personality.name) {
        case 'Friendly Teacher':
          return 'Your ${creature.customName} looks wonderful! I can see you\'ve thought about all the details.';
        case 'Playful Friend':
          return 'Ooh, your ${creature.customName} is so cool! I love all the fun details!';
        case 'Wise Mentor':
          return 'Your ${creature.customName} shows great potential. You\'ve made wise choices.';
        case 'Adventurous Guide':
          return 'Your ${creature.customName} is ready for adventure! What exciting features!';
        default:
          return 'Your ${creature.customName} looks great!';
      }
    }
  }

  /// Get encouraging closing
  static String _getEncouragingClosing(VoicePersonality personality, EmotionalContext context, String language) {
    if (language == 'sv') {
      switch (personality.name) {
        case 'Friendly Teacher':
          return 'Jag är så stolt över dig! Fortsätt att vara kreativ!';
        case 'Playful Friend':
          return 'Det här är så roligt! Låt oss göra mer tillsammans!';
        case 'Wise Mentor':
          return 'Du lär dig snabbt. Fortsätt att utforska din kreativitet.';
        case 'Adventurous Guide':
          return 'Du är en riktig äventyrare! Låt oss utforska mer!';
        default:
          return 'Bra jobbat! Fortsätt så!';
      }
    } else {
      switch (personality.name) {
        case 'Friendly Teacher':
          return 'I\'m so proud of you! Keep being creative!';
        case 'Playful Friend':
          return 'This is so much fun! Let\'s do more together!';
        case 'Wise Mentor':
          return 'You\'re learning quickly. Keep exploring your creativity.';
        case 'Adventurous Guide':
          return 'You\'re a real adventurer! Let\'s explore more!';
        default:
          return 'Great job! Keep it up!';
      }
    }
  }

  /// Add voice response to history
  static Future<void> addVoiceResponse(String userMessage, String aiResponse, String language) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_voiceHistoryKey);
    
    List<VoiceResponse> history = [];
    if (historyJson != null) {
      final historyList = jsonDecode(historyJson) as List<dynamic>;
      history = historyList.map((e) => VoiceResponse.fromMap(e)).toList();
    }

    history.add(VoiceResponse(
      userMessage: userMessage,
      aiResponse: aiResponse,
      language: language,
      timestamp: DateTime.now(),
    ));

    // Keep only last 100 responses
    if (history.length > 100) {
      history = history.sublist(history.length - 100);
    }

    await prefs.setString(_voiceHistoryKey, jsonEncode(history.map((e) => e.toMap()).toList()));
  }

  /// Get voice history
  static Future<List<VoiceResponse>> getVoiceHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_voiceHistoryKey);
    
    if (historyJson != null) {
      final historyList = jsonDecode(historyJson) as List<dynamic>;
      return historyList.map((e) => VoiceResponse.fromMap(e)).toList();
    }
    
    return [];
  }
}

/// Voice Personality Model
class VoicePersonality {
  final String name;
  final String description;
  final List<String> traits;
  final String responseStyle;
  final String emoji;

  const VoicePersonality({
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

  factory VoicePersonality.fromMap(Map<String, dynamic> map) {
    return VoicePersonality(
      name: map['name'],
      description: map['description'],
      traits: List<String>.from(map['traits']),
      responseStyle: map['responseStyle'],
      emoji: map['emoji'],
    );
  }
}

/// Emotional Context Model
class EmotionalContext {
  final int excitementLevel;
  final int confidenceLevel;
  final int creativityLevel;
  final bool isQuestion;
  final bool isExclamation;

  const EmotionalContext({
    required this.excitementLevel,
    required this.confidenceLevel,
    required this.creativityLevel,
    required this.isQuestion,
    required this.isExclamation,
  });
}

/// Voice Response Model
class VoiceResponse {
  final String userMessage;
  final String aiResponse;
  final String language;
  final DateTime timestamp;

  const VoiceResponse({
    required this.userMessage,
    required this.aiResponse,
    required this.language,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userMessage': userMessage,
      'aiResponse': aiResponse,
      'language': language,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory VoiceResponse.fromMap(Map<String, dynamic> map) {
    return VoiceResponse(
      userMessage: map['userMessage'],
      aiResponse: map['aiResponse'],
      language: map['language'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}
