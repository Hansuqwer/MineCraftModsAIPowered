import 'dart:math';
import 'ai_service.dart';

/// Enhanced AI service with better suggestions and context awareness
class EnhancedAIService {
  static final Random _random = Random();
  
  /// Get contextual suggestions based on current creation
  static List<String> getContextualSuggestions(Map<String, dynamic> creatureAttributes) {
    final creatureType = creatureAttributes['creatureType'] ?? 'creature';
    final color = creatureAttributes['color'] ?? 'rainbow';
    final effects = List<String>.from(creatureAttributes['effects'] ?? []);
    
    List<String> suggestions = [];
    
    // Color variations
    if (color == 'rainbow') {
      suggestions.addAll([
        'Try a ${_getRandomColor()} $creatureType',
        'How about a ${_getRandomColor()} $creatureType with ${_getRandomEffect()}?',
        'Create a ${_getRandomColor()} $creatureType that ${_getRandomAction()}',
      ]);
    }
    
    // Effect combinations
    if (effects.isEmpty) {
      suggestions.addAll([
        'Add ${_getRandomEffect()} to your $creatureType',
        'Make it ${_getRandomEffect()} and ${_getRandomEffect()}',
        'Give it ${_getRandomEffect()} powers',
      ]);
    }
    
    // Size variations
    suggestions.addAll([
      'Create a ${_getRandomSize()} $creatureType',
      'Make a ${_getRandomSize()} $creatureType with ${_getRandomEffect()}',
    ]);
    
    // Furniture suggestions
    if (creatureType.contains('chair') || creatureType.contains('table')) {
      suggestions.addAll([
        'Create a matching ${_getRandomFurniture()}',
        'Add a ${_getRandomFurniture()} to complete the set',
        'Make a ${_getRandomFurniture()} with the same style',
      ]);
    }
    
    // Creature combinations
    suggestions.addAll([
      'Create a ${_getRandomCreature()} to be friends with your $creatureType',
      'Make a ${_getRandomCreature()} that ${_getRandomAction()}',
      'Add a ${_getRandomCreature()} to your world',
    ]);
    
    // Shuffle and return top 6
    suggestions.shuffle(_random);
    return suggestions.take(6).toList();
  }
  
  /// Get enhanced age-appropriate suggestions
  static List<String> getEnhancedAgeSuggestions(int age) {
    if (age <= 6) {
      return [
        'Create a cute ${_getRandomCreature()}',
        'Make a ${_getRandomColor()} ${_getRandomCreature()}',
        'Add sparkles to your creation',
        'Create a ${_getRandomCreature()} that flies',
        'Make a rainbow ${_getRandomCreature()}',
        'Create a ${_getRandomCreature()} with wings',
      ];
    } else if (age <= 8) {
      return [
        'Create a ${_getRandomCreature()} with ${_getRandomEffect()}',
        'Make a ${_getRandomSize()} ${_getRandomCreature()}',
        'Create a ${_getRandomCreature()} that ${_getRandomAction()}',
        'Add ${_getRandomEffect()} to your creation',
        'Create a ${_getRandomColor()} ${_getRandomCreature()} with ${_getRandomEffect()}',
        'Make a ${_getRandomFurniture()} for your house',
      ];
    } else {
      return [
        'Create a ${_getRandomSize()} ${_getRandomCreature()} with ${_getRandomEffect()}',
        'Make a ${_getRandomCreature()} that ${_getRandomAction()} and has ${_getRandomEffect()}',
        'Create a ${_getRandomColor()} ${_getRandomCreature()} with ${_getRandomEffect()} powers',
        'Design a ${_getRandomFurniture()} with ${_getRandomEffect()}',
        'Create a ${_getRandomCreature()} that can ${_getRandomAction()} and ${_getRandomAction()}',
        'Make a ${_getRandomSize()} ${_getRandomCreature()} with ${_getRandomEffect()} and ${_getRandomEffect()}',
      ];
    }
  }
  
  /// Get enhanced encouraging responses
  static String getEnhancedEncouragingMessage() {
    final responses = [
      "That's amazing! What else would you like to create?",
      "Wow! That's so creative! Try something new!",
      "Fantastic! You're really good at this!",
      "Incredible! What's your next idea?",
      "Brilliant! Keep being creative!",
      "Awesome! You're a natural creator!",
      "Excellent! What should we make next?",
      "Wonderful! Your imagination is amazing!",
      "Outstanding! Keep up the great work!",
      "Spectacular! You're doing great!",
    ];
    return responses[_random.nextInt(responses.length)];
  }
  
  /// Get creative prompts
  static List<String> getCreativePrompts() {
    return [
      "Create a creature that lives in the clouds",
      "Make a furniture piece that can fly",
      "Design a creature that changes colors",
      "Create something that glows in the dark",
      "Make a creature that can swim and fly",
      "Design a furniture piece that's also a creature",
      "Create a creature made of light",
      "Make something that can talk",
      "Design a creature that's part plant",
      "Create a furniture piece that moves",
    ];
  }
  
  // Helper methods
  static String _getRandomColor() {
    final colors = ['red', 'blue', 'green', 'yellow', 'purple', 'orange', 'pink', 'gold', 'silver', 'rainbow'];
    return colors[_random.nextInt(colors.length)];
  }
  
  static String _getRandomEffect() {
    final effects = ['sparkles', 'glow', 'wings', 'fire', 'ice', 'lightning', 'magic', 'rainbow', 'shimmer', 'glitter'];
    return effects[_random.nextInt(effects.length)];
  }
  
  static String _getRandomAction() {
    final actions = ['flies', 'swims', 'glows', 'sparkles', 'dances', 'sings', 'jumps', 'runs', 'floats', 'shines'];
    return actions[_random.nextInt(actions.length)];
  }
  
  static String _getRandomSize() {
    final sizes = ['tiny', 'small', 'big', 'huge', 'giant', 'massive'];
    return sizes[_random.nextInt(sizes.length)];
  }
  
  static String _getRandomCreature() {
    final creatures = ['dragon', 'unicorn', 'phoenix', 'fox', 'wolf', 'bear', 'rabbit', 'squirrel', 'deer', 'cat', 'dog', 'bird'];
    return creatures[_random.nextInt(creatures.length)];
  }
  
  static String _getRandomFurniture() {
    final furniture = ['chair', 'table', 'sofa', 'bed', 'bookshelf', 'lamp', 'chest', 'barrel', 'shelf', 'throne'];
    return furniture[_random.nextInt(furniture.length)];
  }
}
