import 'dart:async';

/// Content moderation service to ensure compliance with Minecraft EULA
/// and community standards
class ContentModerationService {
  static final ContentModerationService _instance = ContentModerationService._internal();
  factory ContentModerationService() => _instance;
  ContentModerationService._internal();

  // Harmful content patterns
  static const List<String> _hateSpeechPatterns = [
    'hate', 'racist', 'sexist', 'discriminat', 'slur', 'offensive',
    'terrorist', 'extremist', 'violent', 'threat', 'harass',
    'bully', 'intimidat', 'abuse', 'harm', 'hurt', 'kill',
    'murder', 'death', 'suicide', 'self-harm', 'dangerous'
  ];

  // Copyrighted content patterns
  static const List<String> _copyrightedPatterns = [
    'pokemon', 'pikachu', 'mario', 'sonic', 'disney', 'marvel',
    'dc comics', 'batman', 'superman', 'spiderman', 'star wars',
    'harry potter', 'lord of the rings', 'game of thrones',
    'minecraft official', 'mojang official', 'notch'
  ];

  // Illegal content patterns
  static const List<String> _illegalPatterns = [
    'drug', 'alcohol', 'weapon', 'gun', 'knife', 'bomb',
    'explosive', 'illegal', 'criminal', 'fraud', 'scam',
    'steal', 'rob', 'hack', 'cheat', 'exploit'
  ];

  // Age-inappropriate content patterns
  static const List<String> _ageInappropriatePatterns = [
    'adult', 'mature', 'explicit', 'sexual', 'nude', 'naked',
    'porn', 'xxx', 'adult content', 'mature content'
  ];

  /// Validate user input for harmful content
  static Future<bool> validateUserInput(String userInput) async {
    if (userInput.isEmpty) return false;

    final input = userInput.toLowerCase();

    // Check for harmful content
    if (_containsHarmfulContent(input)) {
      print('Content moderation: Blocked harmful content');
      return false;
    }

    // Check for copyrighted content
    if (_containsCopyrightedContent(input)) {
      print('Content moderation: Blocked copyrighted content');
      return false;
    }

    // Check for illegal content
    if (_containsIllegalContent(input)) {
      print('Content moderation: Blocked illegal content');
      return false;
    }

    // Check for age-inappropriate content
    if (_containsAgeInappropriateContent(input)) {
      print('Content moderation: Blocked age-inappropriate content');
      return false;
    }

    return true;
  }

  /// Check if content contains harmful speech
  static bool _containsHarmfulContent(String input) {
    for (final pattern in _hateSpeechPatterns) {
      if (input.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Check if content contains copyrighted material
  static bool _containsCopyrightedContent(String input) {
    for (final pattern in _copyrightedPatterns) {
      if (input.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Check if content contains illegal material
  static bool _containsIllegalContent(String input) {
    for (final pattern in _illegalPatterns) {
      if (input.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Check if content is age-inappropriate
  static bool _containsAgeInappropriateContent(String input) {
    for (final pattern in _ageInappropriatePatterns) {
      if (input.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Get moderation reason for blocked content
  static String getModerationReason(String userInput) {
    final input = userInput.toLowerCase();

    if (_containsHarmfulContent(input)) {
      return 'Content contains harmful or offensive language. Please use respectful language.';
    }

    if (_containsCopyrightedContent(input)) {
      return 'Content contains copyrighted material. Please create original content.';
    }

    if (_containsIllegalContent(input)) {
      return 'Content contains illegal or dangerous material. Please create safe content.';
    }

    if (_containsAgeInappropriateContent(input)) {
      return 'Content is not age-appropriate. Please create family-friendly content.';
    }

    return 'Content does not meet community standards.';
  }

  /// Validate creature attributes for compliance
  static Future<bool> validateCreatureAttributes(Map<String, dynamic> attributes) async {
    // Check creature type
    final creatureType = (attributes['creatureType'] ?? '').toString().toLowerCase();
    if (!await validateUserInput(creatureType)) {
      return false;
    }

    // Check effects
    final effects = (attributes['effects'] as List<dynamic>?) ?? [];
    for (final effect in effects) {
      if (!await validateUserInput(effect.toString())) {
        return false;
      }
    }

    // Check abilities
    final abilities = (attributes['abilities'] as List<dynamic>?) ?? [];
    for (final ability in abilities) {
      if (!await validateUserInput(ability.toString())) {
        return false;
      }
    }

    return true;
  }

  /// Get safe alternative suggestions
  static List<String> getSafeAlternatives(String blockedContent) {
    final input = blockedContent.toLowerCase();

    if (_containsHarmfulContent(input)) {
      return [
        'friendly creature',
        'happy animal',
        'cute pet',
        'magical friend',
        'helpful companion'
      ];
    }

    if (_containsCopyrightedContent(input)) {
      return [
        'original creature',
        'unique animal',
        'custom pet',
        'creative friend',
        'personal companion'
      ];
    }

    if (_containsIllegalContent(input)) {
      return [
        'safe creature',
        'friendly animal',
        'harmless pet',
        'gentle friend',
        'peaceful companion'
      ];
    }

    if (_containsAgeInappropriateContent(input)) {
      return [
        'family-friendly creature',
        'child-safe animal',
        'appropriate pet',
        'suitable friend',
        'wholesome companion'
      ];
    }

    return [
      'safe creature',
      'friendly animal',
      'appropriate pet',
      'suitable friend',
      'wholesome companion'
    ];
  }

  /// Check if content is safe for children
  static Future<bool> isChildSafe(String content) async {
    return await validateUserInput(content);
  }

  /// Get content rating
  static Future<String> getContentRating(String content) async {
    if (!(await validateUserInput(content))) {
      return 'BLOCKED';
    }

    final input = content.toLowerCase();
    if (input.contains('magic') || input.contains('fantasy')) {
      return 'EVERYONE';
    }

    return 'EVERYONE';
  }
}
