import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enhanced_creature_attributes.dart';
import 'enhanced_voice_ai_service.dart';

/// Enhanced AI Suggestion Service
/// Provides intelligent suggestions for created items
class AISuggestionEnhancedService {
  static const String _suggestionHistoryKey = 'suggestion_history';
  static const String _userPreferencesKey = 'user_preferences';

  /// Generate intelligent suggestions for a created item
  static Future<List<ItemSuggestion>> generateSuggestions({
    required EnhancedCreatureAttributes item,
    required String language,
    required String context,
  }) async {
    final personality = await EnhancedVoiceAIService.getCurrentPersonality();
    final userPreferences = await getUserPreferences();
    final suggestionHistory = await getSuggestionHistory();

    // Analyze the item to determine suggestion types
    final suggestionTypes = _analyzeItemForSuggestions(item);
    
    // Generate suggestions based on analysis
    final suggestions = <ItemSuggestion>[];

    // Color suggestions
    if (suggestionTypes.contains(SuggestionType.color)) {
      suggestions.addAll(_generateColorSuggestions(item, personality, language));
    }

    // Size suggestions
    if (suggestionTypes.contains(SuggestionType.size)) {
      suggestions.addAll(_generateSizeSuggestions(item, personality, language));
    }

    // Ability suggestions
    if (suggestionTypes.contains(SuggestionType.ability)) {
      suggestions.addAll(_generateAbilitySuggestions(item, personality, language));
    }

    // Accessory suggestions
    if (suggestionTypes.contains(SuggestionType.accessory)) {
      suggestions.addAll(_generateAccessorySuggestions(item, personality, language));
    }

    // Material suggestions
    if (suggestionTypes.contains(SuggestionType.material)) {
      suggestions.addAll(_generateMaterialSuggestions(item, personality, language));
    }

    // Behavior suggestions
    if (suggestionTypes.contains(SuggestionType.behavior)) {
      suggestions.addAll(_generateBehaviorSuggestions(item, personality, language));
    }

    // Filter suggestions based on user preferences
    final filteredSuggestions = _filterSuggestionsByPreferences(suggestions, userPreferences);

    // Limit to 5 best suggestions
    final bestSuggestions = _rankSuggestions(filteredSuggestions, suggestionHistory).take(5).toList();

    return bestSuggestions;
  }

  /// Analyze item to determine what types of suggestions to make
  static List<SuggestionType> _analyzeItemForSuggestions(EnhancedCreatureAttributes item) {
    final suggestionTypes = <SuggestionType>[];

    // Always suggest colors
    suggestionTypes.add(SuggestionType.color);

    // Suggest size if it's not already varied
    if (item.size == CreatureSize.medium) {
      suggestionTypes.add(SuggestionType.size);
    }

    // Suggest abilities if none or few are present
    if (item.abilities.isEmpty || item.abilities.length < 2) {
      suggestionTypes.add(SuggestionType.ability);
    }

    // Suggest accessories if none are present
    if (item.accessories.isEmpty) {
      suggestionTypes.add(SuggestionType.accessory);
    }

    // Suggest materials for tools/weapons
    if (item.baseType.toLowerCase().contains('sword') || 
        item.baseType.toLowerCase().contains('pickaxe') ||
        item.baseType.toLowerCase().contains('axe')) {
      suggestionTypes.add(SuggestionType.material);
    }

    // Suggest behaviors for creatures
    if (item.baseType.toLowerCase().contains('dragon') ||
        item.baseType.toLowerCase().contains('creature') ||
        item.baseType.toLowerCase().contains('animal')) {
      suggestionTypes.add(SuggestionType.behavior);
    }

    return suggestionTypes;
  }

  /// Generate color suggestions
  static List<ItemSuggestion> _generateColorSuggestions(EnhancedCreatureAttributes item, VoicePersonality personality, String language) {
    final suggestions = <ItemSuggestion>[];

    // Get current colors
    final currentColors = [item.primaryColor, item.secondaryColor, item.accentColor];
    
    // Suggest complementary colors
    final complementaryColors = _getComplementaryColors(item.primaryColor);
    for (final color in complementaryColors) {
      if (!currentColors.contains(color)) {
        suggestions.add(ItemSuggestion(
          type: SuggestionType.color,
          title: language == 'sv' ? 'Försök med ${_getColorName(color, language)}' : 'Try ${_getColorName(color, language)}',
          description: language == 'sv' 
            ? '${_getColorName(color, language)} skulle se fantastiskt ut med din ${item.customName}!'
            : '${_getColorName(color, language)} would look amazing with your ${item.customName}!',
          action: language == 'sv' ? 'Ändra färg' : 'Change Color',
          priority: SuggestionPriority.medium,
          reasoning: language == 'sv' 
            ? 'Denna färg skulle skapa en vacker kontrast'
            : 'This color would create a beautiful contrast',
          personality: personality,
        ));
      }
    }

    // Suggest theme colors
    final themeColors = _getThemeColors(item.baseType);
    for (final color in themeColors) {
      if (!currentColors.contains(color)) {
        suggestions.add(ItemSuggestion(
          type: SuggestionType.color,
          title: language == 'sv' ? '${_getColorName(color, language)} tema' : '${_getColorName(color, language)} Theme',
          description: language == 'sv' 
            ? 'Ett ${_getColorName(color, language)} tema skulle passa perfekt för en ${item.baseType}!'
            : 'A ${_getColorName(color, language)} theme would be perfect for a ${item.baseType}!',
          action: language == 'sv' ? 'Använd tema' : 'Use Theme',
          priority: SuggestionPriority.high,
          reasoning: language == 'sv' 
            ? 'Detta tema passar perfekt för denna typ av föremål'
            : 'This theme fits perfectly for this type of item',
          personality: personality,
        ));
      }
    }

    return suggestions;
  }

  /// Generate size suggestions
  static List<ItemSuggestion> _generateSizeSuggestions(EnhancedCreatureAttributes item, VoicePersonality personality, String language) {
    final suggestions = <ItemSuggestion>[];

    // Suggest different sizes based on item type
    if (item.baseType.toLowerCase().contains('dragon')) {
      suggestions.add(ItemSuggestion(
        type: SuggestionType.size,
        title: language == 'sv' ? 'Gigantisk drake' : 'Giant Dragon',
        description: language == 'sv' 
          ? 'En gigantisk drake skulle vara så imponerande!'
          : 'A giant dragon would be so impressive!',
        action: language == 'sv' ? 'Gör gigantisk' : 'Make Giant',
        priority: SuggestionPriority.high,
        reasoning: language == 'sv' 
          ? 'Drakar ser bäst ut när de är stora och majestätiska'
          : 'Dragons look best when they\'re big and majestic',
        personality: personality,
      ));
    } else if (item.baseType.toLowerCase().contains('sword')) {
      suggestions.add(ItemSuggestion(
        type: SuggestionType.size,
        title: language == 'sv' ? 'Stor svärd' : 'Large Sword',
        description: language == 'sv' 
          ? 'Ett större svärd skulle vara mer imponerande!'
          : 'A larger sword would be more impressive!',
        action: language == 'sv' ? 'Gör större' : 'Make Larger',
        priority: SuggestionPriority.medium,
        reasoning: language == 'sv' 
          ? 'Större svärd är mer imponerande i strid'
          : 'Larger swords are more impressive in battle',
        personality: personality,
      ));
    }

    return suggestions;
  }

  /// Generate ability suggestions
  static List<ItemSuggestion> _generateAbilitySuggestions(EnhancedCreatureAttributes item, VoicePersonality personality, String language) {
    final suggestions = <ItemSuggestion>[];

    // Suggest abilities based on item type
    if (item.baseType.toLowerCase().contains('dragon')) {
      suggestions.add(ItemSuggestion(
        type: SuggestionType.ability,
        title: language == 'sv' ? 'Lägg till flygning' : 'Add Flying',
        description: language == 'sv' 
          ? 'En flygande drake skulle vara så cool!'
          : 'A flying dragon would be so cool!',
        action: language == 'sv' ? 'Lägg till flygning' : 'Add Flying',
        priority: SuggestionPriority.high,
        reasoning: language == 'sv' 
          ? 'Drakar kan flyga - det är deras naturliga förmåga'
          : 'Dragons can fly - it\'s their natural ability',
        personality: personality,
      ));
    } else if (item.baseType.toLowerCase().contains('sword')) {
      suggestions.add(ItemSuggestion(
        type: SuggestionType.ability,
        title: language == 'sv' ? 'Lägg till flammor' : 'Add Flames',
        description: language == 'sv' 
          ? 'Ett flammande svärd skulle vara så mäktigt!'
          : 'A flaming sword would be so powerful!',
        action: language == 'sv' ? 'Lägg till flammor' : 'Add Flames',
        priority: SuggestionPriority.high,
        reasoning: language == 'sv' 
          ? 'Flammande svärd är legendariska och mäktiga'
          : 'Flaming swords are legendary and powerful',
        personality: personality,
      ));
    }

    return suggestions;
  }

  /// Generate accessory suggestions
  static List<ItemSuggestion> _generateAccessorySuggestions(EnhancedCreatureAttributes item, VoicePersonality personality, String language) {
    final suggestions = <ItemSuggestion>[];

    // Suggest accessories based on item type
    if (item.baseType.toLowerCase().contains('dragon')) {
      suggestions.add(ItemSuggestion(
        type: SuggestionType.accessory,
        title: language == 'sv' ? 'Lägg till krona' : 'Add Crown',
        description: language == 'sv' 
          ? 'En krona skulle göra din drake till en kung!'
          : 'A crown would make your dragon a king!',
        action: language == 'sv' ? 'Lägg till krona' : 'Add Crown',
        priority: SuggestionPriority.medium,
        reasoning: language == 'sv' 
          ? 'Kronor gör drakar mer majestätiska'
          : 'Crowns make dragons more majestic',
        personality: personality,
      ));
    } else if (item.baseType.toLowerCase().contains('sword')) {
      suggestions.add(ItemSuggestion(
        type: SuggestionType.accessory,
        title: language == 'sv' ? 'Lägg till sköld' : 'Add Shield',
        description: language == 'sv' 
          ? 'En sköld skulle komplettera ditt svärd perfekt!'
          : 'A shield would complement your sword perfectly!',
        action: language == 'sv' ? 'Lägg till sköld' : 'Add Shield',
        priority: SuggestionPriority.medium,
        reasoning: language == 'sv' 
          ? 'Sköldar och svärd går perfekt ihop'
          : 'Shields and swords go perfectly together',
        personality: personality,
      ));
    }

    return suggestions;
  }

  /// Generate material suggestions
  static List<ItemSuggestion> _generateMaterialSuggestions(EnhancedCreatureAttributes item, VoicePersonality personality, String language) {
    final suggestions = <ItemSuggestion>[];

    // Suggest materials based on item type
    if (item.baseType.toLowerCase().contains('sword')) {
      suggestions.add(ItemSuggestion(
        type: SuggestionType.material,
        title: language == 'sv' ? 'Diamant svärd' : 'Diamond Sword',
        description: language == 'sv' 
          ? 'Ett diamant svärd skulle vara så starkt och vackert!'
          : 'A diamond sword would be so strong and beautiful!',
        action: language == 'sv' ? 'Använd diamant' : 'Use Diamond',
        priority: SuggestionPriority.high,
        reasoning: language == 'sv' 
          ? 'Diamant är det starkaste materialet för svärd'
          : 'Diamond is the strongest material for swords',
        personality: personality,
      ));
    } else if (item.baseType.toLowerCase().contains('pickaxe')) {
      suggestions.add(ItemSuggestion(
        type: SuggestionType.material,
        title: language == 'sv' ? 'Netherite hacka' : 'Netherite Pickaxe',
        description: language == 'sv' 
          ? 'En netherite hacka skulle vara så kraftfull!'
          : 'A netherite pickaxe would be so powerful!',
        action: language == 'sv' ? 'Använd netherite' : 'Use Netherite',
        priority: SuggestionPriority.high,
        reasoning: language == 'sv' 
          ? 'Netherite är det mest avancerade materialet'
          : 'Netherite is the most advanced material',
        personality: personality,
      ));
    }

    return suggestions;
  }

  /// Generate behavior suggestions
  static List<ItemSuggestion> _generateBehaviorSuggestions(EnhancedCreatureAttributes item, VoicePersonality personality, String language) {
    final suggestions = <ItemSuggestion>[];

    // Suggest behaviors based on item type
    if (item.baseType.toLowerCase().contains('dragon')) {
      suggestions.add(ItemSuggestion(
        type: SuggestionType.behavior,
        title: language == 'sv' ? 'Lägg till eldsprutning' : 'Add Fire Breathing',
        description: language == 'sv' 
          ? 'En drake som kan spruta eld skulle vara så cool!'
          : 'A dragon that can breathe fire would be so cool!',
        action: language == 'sv' ? 'Lägg till eldsprutning' : 'Add Fire Breathing',
        priority: SuggestionPriority.high,
        reasoning: language == 'sv' 
          ? 'Eldsprutning är en klassisk drakförmåga'
          : 'Fire breathing is a classic dragon ability',
        personality: personality,
      ));
    } else if (item.baseType.toLowerCase().contains('creature')) {
      suggestions.add(ItemSuggestion(
        type: SuggestionType.behavior,
        title: language == 'sv' ? 'Lägg till vänlighet' : 'Add Friendliness',
        description: language == 'sv' 
          ? 'En vänlig varelse skulle vara så trevlig att ha!'
          : 'A friendly creature would be so nice to have!',
        action: language == 'sv' ? 'Lägg till vänlighet' : 'Add Friendliness',
        priority: SuggestionPriority.medium,
        reasoning: language == 'sv' 
          ? 'Vänliga varelser är roligare att interagera med'
          : 'Friendly creatures are more fun to interact with',
        personality: personality,
      ));
    }

    return suggestions;
  }

  /// Get complementary colors for a given color
  static List<Color> _getComplementaryColors(Color color) {
    // Simple complementary color logic
    if (color == Colors.red) return [Colors.green, Colors.blue];
    if (color == Colors.blue) return [Colors.orange, Colors.red];
    if (color == Colors.green) return [Colors.red, Colors.purple];
    if (color == Colors.yellow) return [Colors.purple, Colors.blue];
    if (color == Colors.purple) return [Colors.yellow, Colors.green];
    if (color == Colors.orange) return [Colors.blue, Colors.purple];
    return [Colors.red, Colors.blue, Colors.green];
  }

  /// Get theme colors for an item type
  static List<Color> _getThemeColors(String itemType) {
    if (itemType.toLowerCase().contains('dragon')) {
      return [Colors.red, Colors.orange, Colors.yellow];
    } else if (itemType.toLowerCase().contains('sword')) {
      return [Colors.grey, Colors.blue, Colors.purple];
    } else if (itemType.toLowerCase().contains('pickaxe')) {
      return [Colors.brown, Colors.grey, Colors.blue];
    }
    return [Colors.red, Colors.blue, Colors.green];
  }

  /// Get color name in specified language
  static String _getColorName(Color color, String language) {
    if (language == 'sv') {
      if (color == Colors.red) return 'röd';
      if (color == Colors.blue) return 'blå';
      if (color == Colors.green) return 'grön';
      if (color == Colors.yellow) return 'gul';
      if (color == Colors.purple) return 'lila';
      if (color == Colors.orange) return 'orange';
      if (color == Colors.pink) return 'rosa';
      if (color == Colors.cyan) return 'cyan';
      if (color == Colors.brown) return 'brun';
      if (color == Colors.grey) return 'grå';
      if (color == Colors.black) return 'svart';
      if (color == Colors.white) return 'vit';
      return 'färg';
    } else {
      if (color == Colors.red) return 'red';
      if (color == Colors.blue) return 'blue';
      if (color == Colors.green) return 'green';
      if (color == Colors.yellow) return 'yellow';
      if (color == Colors.purple) return 'purple';
      if (color == Colors.orange) return 'orange';
      if (color == Colors.pink) return 'pink';
      if (color == Colors.cyan) return 'cyan';
      if (color == Colors.brown) return 'brown';
      if (color == Colors.grey) return 'grey';
      if (color == Colors.black) return 'black';
      if (color == Colors.white) return 'white';
      return 'color';
    }
  }

  /// Filter suggestions based on user preferences
  static List<ItemSuggestion> _filterSuggestionsByPreferences(List<ItemSuggestion> suggestions, UserPreferences preferences) {
    return suggestions.where((suggestion) {
      // Filter based on user preferences
      if (preferences.avoidedSuggestionTypes.contains(suggestion.type)) {
        return false;
      }
      
      // Filter based on priority preferences
      if (preferences.preferredPriority == SuggestionPriority.low && suggestion.priority == SuggestionPriority.high) {
        return false;
      }
      
      return true;
    }).toList();
  }

  /// Rank suggestions based on history and preferences
  static List<ItemSuggestion> _rankSuggestions(List<ItemSuggestion> suggestions, List<SuggestionHistory> history) {
    // Sort by priority first
    suggestions.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    
    // Boost suggestions that haven't been shown recently
    final now = DateTime.now();
    for (final suggestion in suggestions) {
      final recentHistory = history.where((h) => 
        h.suggestionType == suggestion.type && 
        now.difference(h.timestamp).inDays < 7
      ).length;
      
      if (recentHistory == 0) {
        // Boost suggestions that haven't been shown recently
        suggestion.boostScore = 1.5;
      }
    }
    
    // Sort by boost score
    suggestions.sort((a, b) => b.boostScore.compareTo(a.boostScore));
    
    return suggestions;
  }

  /// Get user preferences
  static Future<UserPreferences> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = prefs.getString(_userPreferencesKey);
    
    if (preferencesJson != null) {
      final preferencesMap = jsonDecode(preferencesJson) as Map<String, dynamic>;
      return UserPreferences.fromMap(preferencesMap);
    }
    
    return UserPreferences();
  }

  /// Save user preferences
  static Future<void> saveUserPreferences(UserPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPreferencesKey, jsonEncode(preferences.toMap()));
  }

  /// Get suggestion history
  static Future<List<SuggestionHistory>> getSuggestionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_suggestionHistoryKey);
    
    if (historyJson != null) {
      final historyList = jsonDecode(historyJson) as List<dynamic>;
      return historyList.map((e) => SuggestionHistory.fromMap(e)).toList();
    }
    
    return [];
  }

  /// Add suggestion to history
  static Future<void> addSuggestionToHistory(SuggestionType type, bool wasAccepted) async {
    final history = await getSuggestionHistory();
    history.add(SuggestionHistory(
      suggestionType: type,
      wasAccepted: wasAccepted,
      timestamp: DateTime.now(),
    ));

    // Keep only last 100 entries
    if (history.length > 100) {
      history.removeRange(0, history.length - 100);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_suggestionHistoryKey, jsonEncode(history.map((e) => e.toMap()).toList()));
  }
}

/// Item Suggestion Model
class ItemSuggestion {
  final SuggestionType type;
  final String title;
  final String description;
  final String action;
  final SuggestionPriority priority;
  final String reasoning;
  final VoicePersonality personality;
  double boostScore;

  ItemSuggestion({
    required this.type,
    required this.title,
    required this.description,
    required this.action,
    required this.priority,
    required this.reasoning,
    required this.personality,
    this.boostScore = 1.0,
  });
}

/// Suggestion Types
enum SuggestionType {
  color,
  size,
  ability,
  accessory,
  material,
  behavior,
}

/// Suggestion Priority
enum SuggestionPriority {
  low,
  medium,
  high,
}

/// User Preferences Model
class UserPreferences {
  final List<SuggestionType> avoidedSuggestionTypes;
  final SuggestionPriority? preferredPriority;
  final bool enableVoiceSuggestions;
  final bool enableVisualSuggestions;

  UserPreferences({
    this.avoidedSuggestionTypes = const [],
    this.preferredPriority,
    this.enableVoiceSuggestions = true,
    this.enableVisualSuggestions = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'avoidedSuggestionTypes': avoidedSuggestionTypes.map((e) => e.index).toList(),
      'preferredPriority': preferredPriority?.index,
      'enableVoiceSuggestions': enableVoiceSuggestions,
      'enableVisualSuggestions': enableVisualSuggestions,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      avoidedSuggestionTypes: (map['avoidedSuggestionTypes'] as List<dynamic>?)
          ?.map((e) => SuggestionType.values[e])
          .toList() ?? [],
      preferredPriority: map['preferredPriority'] != null 
          ? SuggestionPriority.values[map['preferredPriority']] 
          : null,
      enableVoiceSuggestions: map['enableVoiceSuggestions'] ?? true,
      enableVisualSuggestions: map['enableVisualSuggestions'] ?? true,
    );
  }
}

/// Suggestion History Model
class SuggestionHistory {
  final SuggestionType suggestionType;
  final bool wasAccepted;
  final DateTime timestamp;

  SuggestionHistory({
    required this.suggestionType,
    required this.wasAccepted,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'suggestionType': suggestionType.index,
      'wasAccepted': wasAccepted,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory SuggestionHistory.fromMap(Map<String, dynamic> map) {
    return SuggestionHistory(
      suggestionType: SuggestionType.values[map['suggestionType']],
      wasAccepted: map['wasAccepted'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}
