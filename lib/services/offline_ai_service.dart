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
    'pink dragon': 'A pink dragon! How cute and magical! Should it have wings?',
    'blue dragon': 'A blue dragon! Cool and mysterious! What effects should it have?',
    'golden dragon': 'A golden dragon! So shiny and special! Should it sparkle?',
    'tiny dragon': 'A tiny dragon! So adorable! What color should it be?',
    'big dragon': 'A huge dragon! That will be amazing! What color?',
    'flying dragon': 'A flying dragon! How cool! What color should it be?',
    'dragon couch': 'A dragon couch! That sounds amazing! Should it have dragon scales?',
    'dragon chair': 'A dragon chair! So cool! Should it have dragon wings?',
    'dragon table': 'A dragon table! How unique! Should it have a dragon head?',
    'dragon bed': 'A dragon bed! Perfect for sleeping! Should it have dragon scales?',
    
    // Foxes
    'fox': 'A fox! So clever and cute! What color would you like?',
    'blue fox': 'A blue fox! That\'s so unique! Should it have any special effects?',
    'red fox': 'A red fox! Classic and beautiful! What effects should it have?',
    'white fox': 'A white fox! So elegant! Should it have wings?',
    'flying fox': 'A flying fox! How amazing! What color should it be?',
    'fox with wings': 'A fox with wings! So magical! What color?',
    'blue fox with wings': 'A blue fox with wings! That sounds amazing!',
    'fox with two legs': 'A fox with two legs! That\'s interesting! What color?',
    'blue fox with two legs and wings': 'A blue fox with two legs and wings! That sounds incredible!',
    
    // Unicorns
    'unicorn': 'A unicorn! So magical! What color would you like?',
    'rainbow unicorn': 'A rainbow unicorn! How beautiful! Should it have sparkles?',
    'pink unicorn': 'A pink unicorn! So pretty and magical!',
    'golden unicorn': 'A golden unicorn! So shiny and special!',
    'flying unicorn': 'A flying unicorn! How amazing! What color?',
    'tiny unicorn': 'A tiny unicorn! So adorable! What color should it be?',
    
    // Cats
    'cat': 'A cat! So cute! What color would you like?',
    'rainbow cat': 'A rainbow cat! How colorful! Should it have wings?',
    'flying cat': 'A flying cat! How cool! What color should it be?',
    'pink cat': 'A pink cat! So cute! Should it have sparkles?',
    'golden cat': 'A golden cat! So shiny! Should it glow?',
    'cat with wings': 'A cat with wings! How magical! What color should it be?',
    
    // Dogs
    'dog': 'A dog! So friendly! What color would you like?',
    'rainbow dog': 'A rainbow dog! How colorful! Should it have wings?',
    'flying dog': 'A flying dog! How amazing! What color?',
    'pink dog': 'A pink dog! So cute! Should it have sparkles?',
    'golden dog': 'A golden dog! So shiny! Should it glow?',
    
    // Birds
    'bird': 'A bird! So free! What color would you like?',
    'rainbow bird': 'A rainbow bird! How colorful! Should it have sparkles?',
    'golden bird': 'A golden bird! So shiny! Should it glow?',
    'tiny bird': 'A tiny bird! So cute! What color?',
    'big bird': 'A big bird! So impressive! What color should it be?',
    
    // Fish
    'fish': 'A fish! So graceful! What color would you like?',
    'rainbow fish': 'A rainbow fish! How colorful! Should it have sparkles?',
    'golden fish': 'A golden fish! So shiny! Should it glow?',
    'tiny fish': 'A tiny fish! So cute! What color?',
    'big fish': 'A big fish! So impressive! What color should it be?',
    
    // Popular Minecraft Bedrock Addon Creatures
    'fox': 'A fox! So clever and cute! What color would you like?',
    'rainbow fox': 'A rainbow fox! How magical! Should it have sparkles?',
    'arctic fox': 'An arctic fox! So fluffy and white! Perfect for snow!',
    'red fox': 'A red fox! Classic and beautiful! What effects should it have?',
    
    'wolf': 'A wolf! Strong and loyal! What color would you like?',
    'rainbow wolf': 'A rainbow wolf! How unique! Should it have wings?',
    'white wolf': 'A white wolf! So majestic! Should it glow?',
    'black wolf': 'A black wolf! Mysterious and powerful!',
    
    'bear': 'A bear! Big and cuddly! What color would you like?',
    'rainbow bear': 'A rainbow bear! How colorful! Should it have sparkles?',
    'polar bear': 'A polar bear! White and fluffy! Perfect for ice!',
    'brown bear': 'A brown bear! Classic and strong!',
    
    'rabbit': 'A rabbit! So cute and bouncy! What color would you like?',
    'rainbow rabbit': 'A rainbow rabbit! How magical! Should it have wings?',
    'white rabbit': 'A white rabbit! Pure and fluffy!',
    'brown rabbit': 'A brown rabbit! Natural and cute!',
    
    'squirrel': 'A squirrel! So quick and clever! What color would you like?',
    'rainbow squirrel': 'A rainbow squirrel! How unique! Should it have sparkles?',
    'red squirrel': 'A red squirrel! Classic and cute!',
    'gray squirrel': 'A gray squirrel! Natural and smart!',
    
    'deer': 'A deer! So graceful and elegant! What color would you like?',
    'rainbow deer': 'A rainbow deer! How magical! Should it have antlers?',
    'white deer': 'A white deer! Pure and mystical!',
    'brown deer': 'A brown deer! Natural and beautiful!',
    
    // Popular Minecraft Bedrock Addon Furniture
    'throne': 'A throne! So royal and majestic! What color would you like?',
    'rainbow throne': 'A rainbow throne! How magical! Should it have sparkles?',
    'golden throne': 'A golden throne! So shiny and special!',
    'dragon throne': 'A dragon throne! Powerful and magical!',
    
    'bookshelf': 'A bookshelf! Perfect for storing books! What color would you like?',
    'rainbow bookshelf': 'A rainbow bookshelf! How colorful! Should it glow?',
    'magical bookshelf': 'A magical bookshelf! So enchanting!',
    'floating bookshelf': 'A floating bookshelf! How cool!',
    
    'lamp': 'A lamp! Perfect for lighting! What color would you like?',
    'rainbow lamp': 'A rainbow lamp! How colorful! Should it change colors?',
    'magical lamp': 'A magical lamp! So enchanting!',
    'floating lamp': 'A floating lamp! How amazing!',
    
    'chest': 'A chest! Perfect for storing treasures! What color would you like?',
    'rainbow chest': 'A rainbow chest! How magical! Should it have sparkles?',
    'golden chest': 'A golden chest! So valuable!',
    'magical chest': 'A magical chest! So enchanting!',
    
    'barrel': 'A barrel! Perfect for storage! What color would you like?',
    'rainbow barrel': 'A rainbow barrel! How colorful!',
    'wooden barrel': 'A wooden barrel! Classic and sturdy!',
    'metal barrel': 'A metal barrel! Strong and durable!',
    
    'shelf': 'A shelf! Perfect for displaying items! What color would you like?',
    'rainbow shelf': 'A rainbow shelf! How colorful!',
    'floating shelf': 'A floating shelf! How cool!',
    'magical shelf': 'A magical shelf! So enchanting!',
    
    // Popular Minecraft Bedrock Addon Weapons
    'sword': 'A sword! Perfect for adventure! What color would you like?',
    'rainbow sword': 'A rainbow sword! How magical! Should it glow?',
    'dragon sword': 'A dragon sword! Powerful and magical!',
    'golden sword': 'A golden sword! So shiny and special!',
    'magical sword': 'A magical sword! So enchanting!',
    
    'bow': 'A bow! Perfect for archery! What color would you like?',
    'rainbow bow': 'A rainbow bow! How magical! Should it have sparkles?',
    'magical bow': 'A magical bow! So enchanting!',
    'golden bow': 'A golden bow! So shiny and special!',
    
    'staff': 'A staff! Perfect for magic! What color would you like?',
    'rainbow staff': 'A rainbow staff! How magical! Should it glow?',
    'magical staff': 'A magical staff! So enchanting!',
    'crystal staff': 'A crystal staff! So beautiful and powerful!',
    
    // Popular Minecraft Bedrock Addon Armor
    'helmet': 'A helmet! Perfect for protection! What color would you like?',
    'rainbow helmet': 'A rainbow helmet! How magical! Should it glow?',
    'dragon helmet': 'A dragon helmet! Powerful and magical!',
    'golden helmet': 'A golden helmet! So shiny and special!',
    
    'armor': 'Armor! Perfect for protection! What color would you like?',
    'rainbow armor': 'Rainbow armor! How magical! Should it glow?',
    'dragon armor': 'Dragon armor! Powerful and magical!',
    'golden armor': 'Golden armor! So shiny and special!',
    
    'shield': 'A shield! Perfect for defense! What color would you like?',
    'rainbow shield': 'A rainbow shield! How magical! Should it glow?',
    'dragon shield': 'A dragon shield! Powerful and magical!',
    'magical shield': 'A magical shield! So enchanting!',
    
    // Popular Minecraft Bedrock Addon Blocks
    'crystal': 'A crystal! So beautiful and magical! What color would you like?',
    'rainbow crystal': 'A rainbow crystal! How magical! Should it glow?',
    'dragon crystal': 'A dragon crystal! Powerful and magical!',
    'floating crystal': 'A floating crystal! How amazing!',
    
    'gem': 'A gem! So precious and beautiful! What color would you like?',
    'rainbow gem': 'A rainbow gem! How magical! Should it sparkle?',
    'dragon gem': 'A dragon gem! Powerful and magical!',
    'floating gem': 'A floating gem! How amazing!',
    
    'orb': 'An orb! So mysterious and magical! What color would you like?',
    'rainbow orb': 'A rainbow orb! How magical! Should it glow?',
    'dragon orb': 'A dragon orb! Powerful and magical!',
    'floating orb': 'A floating orb! How amazing!',
    
    // Popular Minecraft Bedrock Addon Vehicles
    'boat': 'A boat! Perfect for sailing! What color would you like?',
    'rainbow boat': 'A rainbow boat! How magical! Should it glow?',
    'dragon boat': 'A dragon boat! Powerful and magical!',
    'flying boat': 'A flying boat! How amazing!',
    
    'car': 'A car! Perfect for driving! What color would you like?',
    'rainbow car': 'A rainbow car! How magical! Should it glow?',
    'dragon car': 'A dragon car! Powerful and magical!',
    'flying car': 'A flying car! How amazing!',
    
    'airplane': 'An airplane! Perfect for flying! What color would you like?',
    'rainbow airplane': 'A rainbow airplane! How magical! Should it glow?',
    'dragon airplane': 'A dragon airplane! Powerful and magical!',
    'magical airplane': 'A magical airplane! So enchanting!',
    'dragon bed': 'A dragon bed! How cozy! It will have dragon scales and magical effects!',
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
    print('🔍 Offline AI processing: "$userMessage" -> "$normalized"');

    // Try exact match first
    if (_commonResponses.containsKey(normalized)) {
      print('✅ Exact match found: $normalized');
      return _commonResponses[normalized]!;
    }

    // Try partial matches with better logic
    for (final key in _commonResponses.keys) {
      if (normalized.contains(key) || key.contains(normalized)) {
        print('✅ Partial match found: $key');
        return _commonResponses[key]!;
      }
    }

    // Try word-by-word matching for better recognition
    final words = normalized.split(' ');
    for (final word in words) {
      if (word.length > 2) { // Skip short words
        for (final key in _commonResponses.keys) {
          if (key.contains(word) || word.contains(key)) {
            print('✅ Word match found: $word in $key');
            return _commonResponses[key]!;
          }
        }
      }
    }

    // If no match, provide age-appropriate suggestion
    print('❌ No match found, using age suggestion');
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
