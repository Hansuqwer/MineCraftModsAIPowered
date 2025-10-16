import 'dart:math';

/// Offline AI Service for when network is unavailable
/// Provides cached responses and offline functionality
class OfflineAIService {
  /// Cache of common creature requests and responses
  static final Map<String, String> _commonResponses = {
    // Cows
    'rainbow cow': 'Wow! A rainbow cow sounds amazing! That will be so colorful and fun!',
    'pink cow': 'A pink cow! How cute! Should it have sparkles or glows?',
    'blue cow': 'A blue cow! That\'s so creative! What size should it be?',
    'tiny cow': 'A tiny cow! That will be adorable! What color would you like?',
    'big cow': 'A huge cow! That will be amazing! What color should it be?',
    'golden cow': 'A golden cow! So shiny! Should it have any special effects?',
    'purple cow': 'A purple cow! That\'s so unique! What should it do?',

    // Pigs
    'pink pig': 'A pink pig! That\'s perfect! Pigs love being pink!',
    'rainbow pig': 'A rainbow pig! How magical! Should it fly or have sparkles?',
    'sparkle pig': 'A pig with sparkles! That will shine so bright!',
    'flying pig': 'A flying pig! Now that\'s imaginative! What color?',
    'golden pig': 'A golden pig! So special! Should it glow?',
    'tiny pig': 'A tiny pig! How adorable! What color should it be?',

    // Chickens
    'blue chicken': 'A blue chicken! That\'s unique! Should it fly high?',
    'rainbow chicken': 'A rainbow chicken! So colorful! What effects should it have?',
    'tiny chicken': 'A tiny chicken! So cute and small! What color?',
    'golden chicken': 'A golden chicken! Like treasure! Should it sparkle?',
    'red chicken': 'A red chicken! So bright! What effects would you like?',
    'flying chicken': 'A flying chicken! How cool! What color should it be?',

    // Sheep
    'sheep': 'A sheep! Fluffy and fun! What color would you like?',
    'rainbow sheep': 'A rainbow sheep! So colorful and fluffy!',
    'pink sheep': 'A pink sheep! Super fluffy and pretty!',
    'blue sheep': 'A blue sheep! Cool and fluffy!',
    'purple sheep': 'A purple sheep! Magical and fluffy!',

    // Horses
    'horse': 'A horse! Strong and fast! What color?',
    'rainbow horse': 'A rainbow horse! Colorful and majestic!',
    'golden horse': 'A golden horse! Shiny and beautiful!',
    'white horse': 'A white horse! Pure and elegant!',
    'black horse': 'A black horse! Sleek and powerful!',

    // Dragons
    'dragon': 'A dragon! So exciting! What color dragon would you like?',
    'rainbow dragon': 'A rainbow dragon! Amazing! Should it breathe fire or sparkles?',
    'fire dragon': 'A fire dragon! Powerful! What color should the flames be?',
    'ice dragon': 'An ice dragon! Cool! Should it have frosty breath?',
    'lightning dragon': 'A lightning dragon! Electric! So powerful!',
    'purple dragon': 'A purple dragon! Majestic! What powers should it have?',
    'tiny dragon': 'A tiny dragon! Adorable! What should it breathe?',

    // Unicorns
    'unicorn': 'A unicorn! How magical! What color would you like?',
    'rainbow unicorn': 'A rainbow unicorn! So magical and colorful!',
    'sparkle unicorn': 'A unicorn with sparkles! That will be so shiny!',
    'pink unicorn': 'A pink unicorn! Sweet and magical!',
    'golden unicorn': 'A golden unicorn! Shiny and magical!',
    'flying unicorn': 'A flying unicorn! Double magical!',

    // Phoenix
    'phoenix': 'A phoenix! A bird of fire! What colors?',
    'fire phoenix': 'A fire phoenix! Rising from flames! Amazing!',
    'rainbow phoenix': 'A rainbow phoenix! Colorful and fiery!',
    'golden phoenix': 'A golden phoenix! Shining bright!',

    // Griffins
    'griffin': 'A griffin! Half eagle, half lion! So cool!',
    'golden griffin': 'A golden griffin! Majestic and powerful!',
    'white griffin': 'A white griffin! Noble and strong!',

    // Cats
    'cat': 'A cat! Purr-fect! What color cat?',
    'rainbow cat': 'A rainbow cat! Colorful and cute!',
    'black cat': 'A black cat! Mysterious and cool!',
    'golden cat': 'A golden cat! Shiny and special!',

    // Dogs
    'dog': 'A dog! Best friend! What kind?',
    'rainbow dog': 'A rainbow dog! Colorful and loyal!',
    'golden dog': 'A golden dog! Shiny and friendly!',
    'big dog': 'A big dog! Strong and protective!',

    // General
    'creature': 'What kind of creature would you like to create?',
    'animal': 'What animal would you like to make? A cow, pig, or chicken?',
    'default': 'That sounds fun! Tell me more about what you\'d like to create!',
  };

  /// Age-appropriate suggestions when offline
  static final Map<int, List<String>> _ageSuggestions = {
    5: [
      'How about a pink pig with sparkles?',
      'What about a tiny blue cow?',
      'A rainbow chicken sounds fun!',
      'Maybe a golden sheep?',
      'How about a glowing horse?',
    ],
    7: [
      'Want to try a rainbow dragon?',
      'How about a unicorn with sparkles?',
      'A phoenix with fire could be cool!',
      'What about a flying griffin?',
      'Maybe a magical cat?',
    ],
    10: [
      'Try a massive dragon with lightning!',
      'How about a phoenix with rainbow fire?',
      'A griffin that can teleport?',
      'What about a transforming unicorn?',
      'Maybe a dragon with all abilities?',
    ],
  };

  /// Get offline response for user input
  String getOfflineResponse(String userMessage, {int age = 6}) {
    final normalized = _normalizeInput(userMessage);

    // Try exact match first
    if (_commonResponses.containsKey(normalized)) {
      return _commonResponses[normalized]!;
    }

    // Try partial matches
    for (final key in _commonResponses.keys) {
      if (normalized.contains(key) || key.contains(normalized)) {
        return _commonResponses[key]!;
      }
    }

    // If no match, provide age-appropriate suggestion
    return _getAgeSuggestion(age);
  }

  /// Normalize user input for matching
  String _normalizeInput(String input) {
    return input
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace
  }

  /// Get age-appropriate suggestion
  String _getAgeSuggestion(int age) {
    final suggestions = _ageSuggestions[_getAgeGroup(age)] ?? _ageSuggestions[7]!;
    final random = Random();
    final suggestion = suggestions[random.nextInt(suggestions.length)];

    return 'I\'m working offline right now, but I can still help! $suggestion';
  }

  /// Get age group (5, 7, or 10)
  int _getAgeGroup(int age) {
    if (age <= 6) return 5;
    if (age <= 8) return 7;
    return 10;
  }

  /// Check if response is available offline
  bool hasOfflineResponse(String userMessage) {
    final normalized = _normalizeInput(userMessage);

    // Check exact match
    if (_commonResponses.containsKey(normalized)) {
      return true;
    }

    // Check partial match
    for (final key in _commonResponses.keys) {
      if (normalized.contains(key) || key.contains(normalized)) {
        return true;
      }
    }

    return false;
  }

  /// Get encouraging offline message
  String getOfflineEncouragement() {
    final encouragements = [
      'Great idea! Let\'s create something amazing together!',
      'I love your creativity! Let\'s make this happen!',
      'That sounds wonderful! You have great ideas!',
      'Awesome! Let\'s build something fun!',
      'Fantastic! I can\'t wait to see what you create!',
    ];

    final random = Random();
    return encouragements[random.nextInt(encouragements.length)];
  }

  /// Get offline help message
  String getOfflineHelpMessage() {
    return '''
I\'m working offline right now, but I can still help you create:
- Cows (pink, blue, rainbow, golden)
- Pigs (pink, sparkly, flying)
- Chickens (blue, rainbow, tiny)
- Dragons (rainbow, fire, ice)
- Unicorns (sparkly, magical)

Just tell me what you\'d like to make!
''';
  }

  /// Add custom response to cache (for learning)
  void cacheResponse(String input, String response) {
    final normalized = _normalizeInput(input);
    if (normalized.isNotEmpty && response.isNotEmpty) {
      _commonResponses[normalized] = response;
    }
  }

  /// Get all cached responses (for debugging)
  Map<String, String> getCachedResponses() {
    return Map.unmodifiable(_commonResponses);
  }

  /// Clear custom cached responses
  void clearCustomCache() {
    _commonResponses.removeWhere((key, value) =>
      !_isDefaultResponse(key)
    );
  }

  /// Check if response is a default one
  bool _isDefaultResponse(String key) {
    const defaultKeys = [
      'rainbow cow', 'pink cow', 'blue cow', 'tiny cow', 'big cow',
      'pink pig', 'rainbow pig', 'sparkle pig', 'flying pig',
      'blue chicken', 'rainbow chicken', 'tiny chicken', 'golden chicken',
      'dragon', 'rainbow dragon', 'fire dragon', 'ice dragon',
      'unicorn', 'rainbow unicorn', 'sparkle unicorn',
      'creature', 'animal', 'default',
    ];

    return defaultKeys.contains(key);
  }

  /// Get statistics about cached responses
  Map<String, int> getCacheStats() {
    return {
      'total_responses': _commonResponses.length,
      'default_responses': _commonResponses.keys.where(_isDefaultResponse).length,
      'custom_responses': _commonResponses.keys.where((k) => !_isDefaultResponse(k)).length,
      'age_groups': _ageSuggestions.length,
    };
  }
}
