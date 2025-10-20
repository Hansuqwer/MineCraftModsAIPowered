import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:async';
import 'dart:math';
import 'enhanced_ai_service.dart';

/// Kid-Friendly Voice Service
/// Optimized for children ages 4-10
class KidVoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  String _lastWords = '';
  int _attemptCount = 0;
  final int _maxAttempts = 3;

  // Enhanced kid-friendly voice commands
  static const Map<String, List<String>> _kidCommands = {
    'create': [
      'make me', 'I want', 'can you make', 'create', 'build me', 
      'give me', 'show me', 'let me have', 'I need', 'please make'
    ],
    'items': [
      // Creatures
      'dragon', 'cat', 'dog', 'unicorn', 'phoenix', 'dinosaur', 'monster', 'robot',
      // Weapons
      'sword', 'shield', 'bow', 'arrow', 'magic wand', 'staff', 'hammer', 'axe',
      // Vehicles
      'car', 'truck', 'boat', 'plane', 'rocket', 'spaceship', 'train', 'bike',
      // Buildings
      'house', 'castle', 'tower', 'bridge', 'tunnel', 'cave', 'tent', 'fort',
      // Characters
      'princess', 'knight', 'wizard', 'pirate', 'superhero', 'ninja', 'robot',
      // Objects
      'crown', 'ring', 'gem', 'crystal', 'key', 'treasure', 'coin', 'star'
    ],
    'colors': [
      'red', 'blue', 'green', 'yellow', 'purple', 'pink', 'orange', 'black', 'white',
      'rainbow', 'gold', 'silver', 'bronze', 'magic', 'sparkly', 'shiny', 'glowing'
    ],
    'effects': [
      'big', 'small', 'huge', 'tiny', 'flying', 'glowing', 'sparkly', 'magic', 
      'super', 'mega', 'fire', 'ice', 'lightning', 'wind', 'earth', 'water'
    ]
  };

  // Encouragement messages
  static const List<String> _encouragements = [
    "Wow! You're so creative!",
    "That's an amazing idea!",
    "You're becoming a great builder!",
    "I love your imagination!",
    "You're doing fantastic!",
    "That's a wonderful idea!",
    "You're so smart!",
    "I'm so proud of you!"
  ];

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  String get lastWords => _lastWords;

  /// Initialize speech recognition for kids
  Future<bool> initialize() async {
    try {
      _isAvailable = await _speech.initialize(
        onError: (error) => print('Kid voice error: $error'),
        onStatus: (status) => print('Kid voice status: $status'),
      );
      
      if (_isAvailable) {
        print('✅ Kid voice service initialized');
      } else {
        print('❌ Kid voice service not available');
      }
      
      return _isAvailable;
    } catch (e) {
      print('❌ Kid voice initialization error: $e');
      _isAvailable = false;
      return false;
    }
  }

  /// Listen for kid voice input with multiple attempts and kid-friendly settings
  Future<String?> listenForKids() async {
    if (!_isAvailable) {
      print('❌ Kid voice service not available');
      return null;
    }

    _attemptCount = 0;
    
    while (_attemptCount < _maxAttempts) {
      _attemptCount++;
      
      try {
        print('🎤 Kid voice attempt $_attemptCount of $_maxAttempts');
        
        _isListening = true;
        print('👂 Listening for kid voice...');
        
        String? result;
        bool isComplete = false;
        
        // Enhanced voice recognition for kids
        await _speech.listen(
          onResult: (speechResult) {
            _lastWords = speechResult.recognizedWords;
            print('👶 Kid said: "$_lastWords" (confidence: ${speechResult.confidence})');
            
            // Lower confidence threshold for kids (0.2 instead of 0.3)
            if (speechResult.confidence > 0.2) {
              if (speechResult.finalResult) {
                print('✅ Final result: $_lastWords (confidence: ${speechResult.confidence})');
                result = _lastWords;
                isComplete = true;
              }
            } else {
              print('⚠️ Low confidence result ignored: ${speechResult.confidence}');
            }
          },
          listenFor: Duration(seconds: 15), // Longer timeout for kids
          pauseFor: Duration(seconds: 4), // Longer pause for kids to think
          partialResults: true,
          localeId: 'en_US', // Use English for kids
          listenMode: ListenMode.confirmation, // Better for single commands
          cancelOnError: false, // Don't cancel on minor errors
          onSoundLevelChange: (level) {
            // Visual feedback for sound level
            print('🔊 Sound level: $level');
          },
        );
        
        // Wait for completion with kid-friendly timeout
        int waitTime = 0;
        while (_isListening && !isComplete && waitTime < 15000) {
          await Future.delayed(Duration(milliseconds: 100));
          waitTime += 100;
        }
        
        _isListening = false;

        if ((result ?? '').isNotEmpty) {
          print('✅ Kid voice recognized: "$result"');
          return result ?? '';
        } else {
          print('❌ No words recognized in attempt $_attemptCount');
          
          if (_attemptCount < _maxAttempts) {
            final encouragement = getEncouragement(_attemptCount);
            print('💬 $encouragement');
            // Wait a moment before next attempt
            await Future.delayed(Duration(seconds: 2));
          }
        }
      } catch (e) {
        print('❌ Kid voice error in attempt $_attemptCount: $e');
        _isListening = false;
        
        if (_attemptCount < _maxAttempts) {
          await Future.delayed(Duration(seconds: 2));
        }
      }
    }
    
    print('❌ All voice attempts failed');
    return null;
  }

  /// Get encouragement message for kids
  String getEncouragement(int attempt) {
    switch (attempt) {
      case 1:
        return "Try again! Speak clearly!";
      case 2:
        return "You're doing great! One more time!";
      case 3:
        return "Let me help you! Say 'Make me a dragon'";
      default:
        return "You're doing fantastic!";
    }
  }

  /// Get random encouragement message
  String getRandomEncouragement() {
    final random = Random();
    return _encouragements[random.nextInt(_encouragements.length)];
  }

  /// Parse kid voice input into item attributes with enhanced intelligence
  /// Parse kid voice with AI first, fallback to keyword matching
  Future<Map<String, dynamic>> parseKidVoiceWithAI(String voiceInput) async {
    print('🔍 Parsing kid voice: "$voiceInput"');

    try {
      // Try AI parsing first (PHASE 0.1 improvement)
      print('🤖 Attempting AI parsing...');
      final aiAttributes = await EnhancedAIService
          .parseEnhancedCreatureRequest('Create minecraft item: $voiceInput');

      // Convert to map format
      final attributes = _convertAIAttributesToMap(aiAttributes);
      print('✅ AI parsing successful: $attributes');
      return attributes;
    } catch (e) {
      print('⚠️ AI parsing failed, falling back to keyword matching: $e');
      // Fall back to local keyword matching
      return parseKidVoiceLocal(voiceInput);
    }
  }

  /// Local keyword matching (fallback if AI fails)
  Map<String, dynamic> parseKidVoiceLocal(String voiceInput) {
    final lowerInput = voiceInput.toLowerCase();
    final attributes = <String, dynamic>{};

    print('🔍 Using local keyword matching for: "$voiceInput"');

    // Enhanced item detection with fuzzy matching
    String? detectedItem;
    int bestMatch = 0;

    for (final item in _kidCommands['items']!) {
      // Exact match gets highest priority
      if (lowerInput.contains(item)) {
        final matchScore = item.length;
        if (matchScore > bestMatch) {
          bestMatch = matchScore;
          detectedItem = item;
        }
      }
    }

    if (detectedItem != null) {
      attributes['baseType'] = detectedItem;
      attributes['category'] = _getItemCategory(detectedItem);
      print('✅ Detected item: $detectedItem');
    }

    // Enhanced color detection
    Color? detectedColor;
    for (final color in _kidCommands['colors']!) {
      if (lowerInput.contains(color)) {
        detectedColor = _getColorFromName(color);
        break;
      }
    }

    if (detectedColor != null) {
      attributes['primaryColor'] = detectedColor;
      print('✅ Detected color: ${detectedColor.toString()}');
    }

    // Enhanced effects detection
    final effects = <String>[];
    for (final effect in _kidCommands['effects']!) {
      if (lowerInput.contains(effect)) {
        effects.add(effect);
      }
    }

    if (effects.isNotEmpty) {
      attributes['effects'] = effects;
      print('✅ Detected effects: $effects');
    }

    // Smart defaults based on context
    if (attributes['baseType'] == null) {
      // Try to guess from context
      if (lowerInput.contains('animal') || lowerInput.contains('pet')) {
        attributes['baseType'] = 'cat';
        attributes['category'] = 'creature';
      } else if (lowerInput.contains('weapon') || lowerInput.contains('fight')) {
        attributes['baseType'] = 'sword';
        attributes['category'] = 'weapon';
      } else if (lowerInput.contains('drive') || lowerInput.contains('go')) {
        attributes['baseType'] = 'car';
        attributes['category'] = 'vehicle';
      } else {
        attributes['baseType'] = 'creature';
        attributes['category'] = 'creature';
      }
    }

    // Set smart defaults
    attributes['primaryColor'] ??= Colors.blue;
    attributes['size'] ??= 'medium';
    attributes['personality'] ??= 'friendly';

    print('✅ Final parsed attributes: $attributes');
    return attributes;
  }

  /// Convert EnhancedCreatureAttributes to the map format
  Map<String, dynamic> _convertAIAttributesToMap(
    dynamic attributes,
  ) {
    try {
      // Handle both EnhancedCreatureAttributes object and Map
      final Map<String, dynamic> result = {};

      if (attributes is Map) {
        // Already a map
        result['baseType'] = attributes['baseType'] ?? 'creature';
        result['primaryColor'] = attributes['primaryColor'] ?? Colors.blue;
        result['category'] = _getItemCategory(attributes['baseType'] ?? 'creature');
      } else {
        // It's an EnhancedCreatureAttributes object
        // Access properties via reflection or toString
        result['baseType'] = attributes.baseType ?? 'creature';
        result['primaryColor'] = attributes.primaryColor ?? Colors.blue;
        result['category'] = _getItemCategory(attributes.baseType ?? 'creature');
        result['size'] = attributes.size?.toString().split('.').last ?? 'medium';
        result['personality'] = attributes.personality?.toString().split('.').last ?? 'friendly';
      }

      // Ensure required fields
      result['primaryColor'] ??= Colors.blue;
      result['size'] ??= 'medium';
      result['personality'] ??= 'friendly';
      result['effects'] ??= [];

      return result;
    } catch (e) {
      print('⚠️ Error converting AI attributes: $e');
      // Return safe defaults
      return {
        'baseType': 'creature',
        'primaryColor': Colors.blue,
        'category': 'creature',
        'size': 'medium',
        'personality': 'friendly',
        'effects': [],
      };
    }
  }

  /// Legacy method - kept for backward compatibility
  Map<String, dynamic> parseKidVoice(String voiceInput) {
    // Just call the local version for sync calls
    return parseKidVoiceLocal(voiceInput);
  }

  /// Get item category from item name
  String _getItemCategory(String item) {
    switch (item) {
      case 'dragon':
      case 'cat':
      case 'dog':
        return 'creature';
      case 'sword':
        return 'weapon';
      case 'car':
        return 'vehicle';
      case 'house':
      case 'castle':
        return 'furniture';
      default:
        return 'creature';
    }
  }

  /// Get color from color name
  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'gold':
        return Colors.amber;
      case 'rainbow':
        return Colors.blue; // Default for rainbow
      default:
        return Colors.blue;
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      print('🛑 Stopped listening for kid voice');
    }
  }

  /// Get kid-friendly prompts
  List<String> getKidPrompts() {
    return [
      "Say 'Make me a dragon!'",
      "Try 'I want a blue sword!'",
      "How about 'Create a rainbow cat!'",
      "You can say 'Make me a flying car!'",
      "Try 'Build me a castle!'",
      "Say 'I want a magic princess!'"
    ];
  }

  /// Check if voice input is kid-friendly
  bool isKidFriendly(String input) {
    final lowerInput = input.toLowerCase();
    
    // Check for kid-friendly words
    for (final category in _kidCommands.values) {
      for (final word in category) {
        if (lowerInput.contains(word)) {
          return true;
        }
      }
    }
    
    return false;
  }
}
