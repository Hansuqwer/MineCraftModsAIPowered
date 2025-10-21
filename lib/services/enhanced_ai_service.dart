import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/enhanced_creature_attributes.dart';
import './api_key_service.dart';

/// Enhanced AI service for advanced creature customization
class EnhancedAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  /// Get API key from secure storage or .env file
  static Future<String?> _getApiKey() async {
    // Try to get from ApiKeyService first
    final apiKeyService = ApiKeyService();
    final storedKey = await apiKeyService.getApiKey();

    if (storedKey != null && storedKey.isNotEmpty) {
      print('✅ [ENHANCED_AI] Using API key from secure storage');
      return storedKey;
    }

    // Fall back to .env file
    final envKey = dotenv.env['OPENAI_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      print('⚠️ [ENHANCED_AI] Using API key from .env file');
      return envKey;
    }

    print('❌ [ENHANCED_AI] No API key found - will use offline mode');
    return null;
  }

  /// Parse enhanced creature request with advanced attributes
  static Future<EnhancedCreatureAttributes> parseEnhancedCreatureRequest(
    String userMessage,
  ) async {
    try {
      // Get API key
      final apiKey = await _getApiKey();

      // If no API key, use offline mode
      if (apiKey == null) {
        print('⚠️ [ENHANCED_AI] No API key available, using fallback');
        return _getDefaultAttributes(userMessage);
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': _getEnhancedSystemPrompt(),
            },
            {
              'role': 'user',
              'content': userMessage,
            },
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return _parseAIResponse(content);
      } else {
        print('AI API error: ${response.statusCode}');
        return _getDefaultAttributes(userMessage);
      }
    } catch (e) {
      print('Enhanced AI parsing error: $e');
      return _getDefaultAttributes(userMessage);
    }
  }

  /// Get enhanced system prompt for advanced parsing
  static String _getEnhancedSystemPrompt() {
    return '''
You are Crafta, an AI assistant that helps children create custom Minecraft creatures through natural language.

Your task is to parse user requests and extract detailed creature attributes including:

1. BASE TYPE: dragon, cat, robot, unicorn, dinosaur, etc.
2. COLORS: primary, secondary, accent colors
3. SIZE: tiny, small, medium, large, giant
4. PERSONALITY: friendly, playful, shy, brave, curious
5. ABILITIES: flying, swimming, fire breath, ice breath, magic, teleportation, invisibility, super strength, super speed, healing, shapeshifting, weather control
6. ACCESSORIES: wizard hat, crown, sunglasses, armor, magic wand, crystal ball, etc.
7. PATTERNS: stripes, spots, sparkles, rainbow, stars, hearts
8. TEXTURE: smooth, rough, scaly, furry, metallic, glassy
9. GLOW EFFECT: none, soft, bright, pulsing, rainbow
10. ANIMATION STYLE: natural, bouncy, graceful, energetic, calm

Respond with a JSON object containing these attributes. Be creative and child-friendly.

Example response format:
{
  "baseType": "dragon",
  "primaryColor": "red",
  "secondaryColor": "gold",
  "accentColor": "orange",
  "size": "large",
  "abilities": ["flying", "fireBreath", "magic"],
  "accessories": ["wizard hat", "magic wand"],
  "personality": "brave",
  "patterns": ["sparkles", "rainbow"],
  "texture": "scaly",
  "glowEffect": "bright",
  "animationStyle": "energetic",
  "customName": "Firewing",
  "description": "A brave dragon with magical powers"
}

Always be safe, kind, and imaginative. Focus on positive, creative attributes.
''';
  }

  /// Parse AI response into enhanced attributes
  static EnhancedCreatureAttributes _parseAIResponse(String content) {
    try {
      // Extract JSON from response
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      
      if (jsonStart == -1 || jsonEnd == 0) {
        return _getDefaultAttributes(content);
      }
      
      final jsonString = content.substring(jsonStart, jsonEnd);
      final data = jsonDecode(jsonString);
      
      return EnhancedCreatureAttributes(
        baseType: data['baseType'] ?? 'creature',
        primaryColor: _parseColor(data['primaryColor']) ?? Colors.blue,
        secondaryColor: _parseColor(data['secondaryColor']) ?? Colors.blue.shade300,
        accentColor: _parseColor(data['accentColor']) ?? Colors.blue.shade100,
        size: _parseSize(data['size']),
        abilities: _parseAbilities(data['abilities']),
        accessories: _parseAccessories(data['accessories']),
        personality: _parsePersonality(data['personality']),
        patterns: _parsePatterns(data['patterns']),
        texture: _parseTexture(data['texture']),
        glowEffect: _parseGlowEffect(data['glowEffect']),
        animationStyle: _parseAnimationStyle(data['animationStyle']),
        customName: data['customName'] ?? 'My Creature',
        description: data['description'] ?? 'A wonderful creature created with Crafta',
      );
    } catch (e) {
      print('Error parsing AI response: $e');
      return _getDefaultAttributes(content);
    }
  }

  /// Get default attributes when parsing fails
  static EnhancedCreatureAttributes _getDefaultAttributes(String userMessage) {
    return EnhancedCreatureAttributes(
      baseType: _extractBaseType(userMessage),
      primaryColor: Colors.blue,
      secondaryColor: Colors.blue.shade300,
      accentColor: Colors.blue.shade100,
      size: CreatureSize.medium,
      abilities: [],
      accessories: [],
      personality: PersonalityType.friendly,
      patterns: [],
      texture: TextureType.smooth,
      glowEffect: GlowEffect.none,
      animationStyle: CreatureAnimationStyle.natural,
      customName: 'My Creature',
      description: 'A wonderful creature created with Crafta',
    );
  }

  /// Extract base type from user message
  static String _extractBaseType(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('dragon')) return 'dragon';
    if (lowerMessage.contains('cat')) return 'cat';
    if (lowerMessage.contains('dog')) return 'dog';
    if (lowerMessage.contains('robot')) return 'robot';
    if (lowerMessage.contains('unicorn')) return 'unicorn';
    if (lowerMessage.contains('dinosaur')) return 'dinosaur';
    if (lowerMessage.contains('bird')) return 'bird';
    if (lowerMessage.contains('fish')) return 'fish';
    if (lowerMessage.contains('bear')) return 'bear';
    if (lowerMessage.contains('lion')) return 'lion';
    if (lowerMessage.contains('tiger')) return 'tiger';
    if (lowerMessage.contains('elephant')) return 'elephant';
    if (lowerMessage.contains('monkey')) return 'monkey';
    if (lowerMessage.contains('penguin')) return 'penguin';
    if (lowerMessage.contains('owl')) return 'owl';
    if (lowerMessage.contains('butterfly')) return 'butterfly';
    if (lowerMessage.contains('spider')) return 'spider';
    if (lowerMessage.contains('snake')) return 'snake';
    if (lowerMessage.contains('frog')) return 'frog';
    if (lowerMessage.contains('rabbit')) return 'rabbit';
    if (lowerMessage.contains('mouse')) return 'mouse';
    if (lowerMessage.contains('horse')) return 'horse';
    if (lowerMessage.contains('cow')) return 'cow';
    if (lowerMessage.contains('pig')) return 'pig';
    if (lowerMessage.contains('sheep')) return 'sheep';
    if (lowerMessage.contains('chicken')) return 'chicken';
    if (lowerMessage.contains('duck')) return 'duck';
    if (lowerMessage.contains('goose')) return 'goose';
    if (lowerMessage.contains('turkey')) return 'turkey';
    if (lowerMessage.contains('goat')) return 'goat';
    if (lowerMessage.contains('deer')) return 'deer';
    if (lowerMessage.contains('wolf')) return 'wolf';
    if (lowerMessage.contains('fox')) return 'fox';
    if (lowerMessage.contains('raccoon')) return 'raccoon';
    if (lowerMessage.contains('squirrel')) return 'squirrel';
    if (lowerMessage.contains('chipmunk')) return 'chipmunk';
    if (lowerMessage.contains('hedgehog')) return 'hedgehog';
    if (lowerMessage.contains('hamster')) return 'hamster';
    if (lowerMessage.contains('guinea pig')) return 'guinea pig';
    if (lowerMessage.contains('ferret')) return 'ferret';
    if (lowerMessage.contains('skunk')) return 'skunk';
    if (lowerMessage.contains('opossum')) return 'opossum';
    if (lowerMessage.contains('beaver')) return 'beaver';
    if (lowerMessage.contains('otter')) return 'otter';
    if (lowerMessage.contains('seal')) return 'seal';
    if (lowerMessage.contains('walrus')) return 'walrus';
    if (lowerMessage.contains('whale')) return 'whale';
    if (lowerMessage.contains('dolphin')) return 'dolphin';
    if (lowerMessage.contains('shark')) return 'shark';
    if (lowerMessage.contains('octopus')) return 'octopus';
    if (lowerMessage.contains('squid')) return 'squid';
    if (lowerMessage.contains('jellyfish')) return 'jellyfish';
    if (lowerMessage.contains('starfish')) return 'starfish';
    if (lowerMessage.contains('crab')) return 'crab';
    if (lowerMessage.contains('lobster')) return 'lobster';
    if (lowerMessage.contains('shrimp')) return 'shrimp';
    if (lowerMessage.contains('snail')) return 'snail';
    if (lowerMessage.contains('slug')) return 'slug';
    if (lowerMessage.contains('worm')) return 'worm';
    if (lowerMessage.contains('ant')) return 'ant';
    if (lowerMessage.contains('bee')) return 'bee';
    if (lowerMessage.contains('wasp')) return 'wasp';
    if (lowerMessage.contains('hornet')) return 'hornet';
    if (lowerMessage.contains('beetle')) return 'beetle';
    if (lowerMessage.contains('ladybug')) return 'ladybug';
    if (lowerMessage.contains('dragonfly')) return 'dragonfly';
    if (lowerMessage.contains('damselfly')) return 'damselfly';
    if (lowerMessage.contains('mantis')) return 'mantis';
    if (lowerMessage.contains('cricket')) return 'cricket';
    if (lowerMessage.contains('grasshopper')) return 'grasshopper';
    if (lowerMessage.contains('katydid')) return 'katydid';
    if (lowerMessage.contains('cicada')) return 'cicada';
    if (lowerMessage.contains('locust')) return 'locust';
    if (lowerMessage.contains('moth')) return 'moth';
    if (lowerMessage.contains('caterpillar')) return 'caterpillar';
    if (lowerMessage.contains('chrysalis')) return 'chrysalis';
    if (lowerMessage.contains('cocoon')) return 'cocoon';
    if (lowerMessage.contains('pupa')) return 'pupa';
    if (lowerMessage.contains('larva')) return 'larva';
    if (lowerMessage.contains('nymph')) return 'nymph';
    if (lowerMessage.contains('grub')) return 'grub';
    if (lowerMessage.contains('maggot')) return 'maggot';
    if (lowerMessage.contains('fly')) return 'fly';
    if (lowerMessage.contains('mosquito')) return 'mosquito';
    if (lowerMessage.contains('gnat')) return 'gnat';
    if (lowerMessage.contains('midge')) return 'midge';
    if (lowerMessage.contains('flea')) return 'flea';
    if (lowerMessage.contains('tick')) return 'tick';
    if (lowerMessage.contains('mite')) return 'mite';
    if (lowerMessage.contains('louse')) return 'louse';
    if (lowerMessage.contains('bedbug')) return 'bedbug';
    if (lowerMessage.contains('cockroach')) return 'cockroach';
    if (lowerMessage.contains('termite')) return 'termite';
    if (lowerMessage.contains('earwig')) return 'earwig';
    if (lowerMessage.contains('silverfish')) return 'silverfish';
    if (lowerMessage.contains('firebrat')) return 'firebrat';
    if (lowerMessage.contains('booklice')) return 'booklice';
    if (lowerMessage.contains('psocid')) return 'psocid';
    if (lowerMessage.contains('thrips')) return 'thrips';
    if (lowerMessage.contains('aphid')) return 'aphid';
    if (lowerMessage.contains('scale')) return 'scale';
    if (lowerMessage.contains('mealybug')) return 'mealybug';
    if (lowerMessage.contains('whitefly')) return 'whitefly';
    if (lowerMessage.contains('leafhopper')) return 'leafhopper';
    if (lowerMessage.contains('planthopper')) return 'planthopper';
    if (lowerMessage.contains('treehopper')) return 'treehopper';
    if (lowerMessage.contains('froghopper')) return 'froghopper';
    if (lowerMessage.contains('spittlebug')) return 'spittlebug';
    if (lowerMessage.contains('leafminer')) return 'leafminer';
    if (lowerMessage.contains('gall wasp')) return 'gall wasp';
    if (lowerMessage.contains('gall fly')) return 'gall fly';
    if (lowerMessage.contains('gall midge')) return 'gall midge';
    if (lowerMessage.contains('gall gnat')) return 'gall gnat';
    if (lowerMessage.contains('gall aphid')) return 'gall aphid';
    if (lowerMessage.contains('gall mite')) return 'gall mite';
    if (lowerMessage.contains('gall thrips')) return 'gall thrips';
    if (lowerMessage.contains('gall beetle')) return 'gall beetle';
    if (lowerMessage.contains('gall weevil')) return 'gall weevil';
    if (lowerMessage.contains('gall sawfly')) return 'gall sawfly';
    if (lowerMessage.contains('gall moth')) return 'gall moth';
    if (lowerMessage.contains('gall butterfly')) return 'gall butterfly';
    if (lowerMessage.contains('gall skipper')) return 'gall skipper';
    if (lowerMessage.contains('gall skipper')) return 'gall skipper';
    
    return 'creature';
  }

  // Helper methods for parsing
  static Color? _parseColor(String? color) {
    if (color == null) return null;
    switch (color.toLowerCase()) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'yellow': return Colors.yellow;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'pink': return Colors.pink;
      case 'brown': return Colors.brown;
      case 'black': return Colors.black;
      case 'white': return Colors.white;
      case 'gold': return Colors.amber;
      case 'silver': return Colors.grey;
      case 'cyan': return Colors.cyan;
      case 'magenta': return Colors.pink;
      case 'lime': return Colors.lime;
      case 'indigo': return Colors.indigo;
      case 'violet': return Colors.deepPurple;
      default: return Colors.blue;
    }
  }

  static CreatureSize _parseSize(String? size) {
    switch (size?.toLowerCase()) {
      case 'tiny': return CreatureSize.tiny;
      case 'small': return CreatureSize.small;
      case 'large': return CreatureSize.large;
      case 'giant': return CreatureSize.giant;
      default: return CreatureSize.medium;
    }
  }

  static List<SpecialAbility> _parseAbilities(List<dynamic>? abilities) {
    if (abilities == null) return [];
    
    List<SpecialAbility> result = [];
    for (String ability in abilities) {
      switch (ability.toLowerCase()) {
        case 'flying': result.add(SpecialAbility.flying); break;
        case 'swimming': result.add(SpecialAbility.swimming); break;
        case 'fire breath': result.add(SpecialAbility.fireBreath); break;
        case 'ice breath': result.add(SpecialAbility.iceBreath); break;
        case 'magic': result.add(SpecialAbility.magic); break;
        case 'teleportation': result.add(SpecialAbility.teleportation); break;
        case 'invisibility': result.add(SpecialAbility.invisibility); break;
        case 'super strength': result.add(SpecialAbility.superStrength); break;
        case 'super speed': result.add(SpecialAbility.superSpeed); break;
        case 'healing': result.add(SpecialAbility.healing); break;
        case 'shapeshifting': result.add(SpecialAbility.shapeshifting); break;
        case 'weather control': result.add(SpecialAbility.weatherControl); break;
      }
    }
    return result;
  }

  static List<AccessoryType> _parseAccessories(List<dynamic>? accessories) {
    if (accessories == null) return [];
    
    List<AccessoryType> result = [];
    for (String accessory in accessories) {
      final found = AccessoryType.values.firstWhere(
        (a) => a.name.toLowerCase() == accessory.toLowerCase(),
        orElse: () => AccessoryType.hat,
      );
      result.add(found);
    }
    return result;
  }

  static PersonalityType _parsePersonality(String? personality) {
    switch (personality?.toLowerCase()) {
      case 'friendly': return PersonalityType.friendly;
      case 'playful': return PersonalityType.playful;
      case 'shy': return PersonalityType.shy;
      case 'brave': return PersonalityType.brave;
      case 'curious': return PersonalityType.curious;
      default: return PersonalityType.friendly;
    }
  }

  static List<Pattern> _parsePatterns(List<dynamic>? patterns) {
    if (patterns == null) return [];
    
    List<Pattern> result = [];
    for (String pattern in patterns) {
      switch (pattern.toLowerCase()) {
        case 'stripes': result.add(Pattern.stripes); break;
        case 'spots': result.add(Pattern.spots); break;
        case 'sparkles': result.add(Pattern.sparkles); break;
        case 'rainbow': result.add(Pattern.rainbow); break;
        case 'stars': result.add(Pattern.stars); break;
        case 'hearts': result.add(Pattern.hearts); break;
      }
    }
    return result;
  }

  static TextureType _parseTexture(String? texture) {
    switch (texture?.toLowerCase()) {
      case 'smooth': return TextureType.smooth;
      case 'rough': return TextureType.rough;
      case 'scaly': return TextureType.scaly;
      case 'furry': return TextureType.furry;
      case 'metallic': return TextureType.metallic;
      case 'glassy': return TextureType.glassy;
      default: return TextureType.smooth;
    }
  }

  static GlowEffect _parseGlowEffect(String? glow) {
    switch (glow?.toLowerCase()) {
      case 'soft': return GlowEffect.soft;
      case 'bright': return GlowEffect.bright;
      case 'pulsing': return GlowEffect.pulsing;
      case 'rainbow': return GlowEffect.rainbow;
      default: return GlowEffect.none;
    }
  }

  static CreatureAnimationStyle _parseAnimationStyle(String? style) {
    switch (style?.toLowerCase()) {
      case 'bouncy': return CreatureAnimationStyle.bouncy;
      case 'graceful': return CreatureAnimationStyle.graceful;
      case 'energetic': return CreatureAnimationStyle.energetic;
      case 'calm': return CreatureAnimationStyle.calm;
      default: return CreatureAnimationStyle.natural;
    }
  }

  /// Get contextual suggestions based on creature attributes
  static List<String> getContextualSuggestions(EnhancedCreatureAttributes attributes) {
    List<String> suggestions = [];
    
    // Base type suggestions
    switch (attributes.baseType.toLowerCase()) {
      case 'dragon':
        suggestions.addAll([
          'Add fire breath ability',
          'Make it fly with wings',
          'Give it magical powers',
          'Add a crown for royalty',
        ]);
        break;
      case 'cat':
        suggestions.addAll([
          'Make it playful and bouncy',
          'Add super speed ability',
          'Give it a wizard hat',
          'Make it rainbow colored',
        ]);
        break;
      case 'robot':
        suggestions.addAll([
          'Add super strength',
          'Make it metallic texture',
          'Give it magic abilities',
          'Add glowing effects',
        ]);
        break;
      default:
        suggestions.addAll([
          'Add special abilities',
          'Change the size',
          'Add accessories',
          'Customize colors',
        ]);
    }
    
    // Personality-based suggestions
    switch (attributes.personality) {
      case PersonalityType.friendly:
        suggestions.add('Add healing ability');
        break;
      case PersonalityType.playful:
        suggestions.add('Make it bouncy animation');
        break;
      case PersonalityType.brave:
        suggestions.add('Add super strength');
        break;
      case PersonalityType.curious:
        suggestions.add('Add teleportation ability');
        break;
      case PersonalityType.shy:
        suggestions.add('Add invisibility ability');
        break;
    }
    
    return suggestions.take(4).toList();
  }

  /// Get age-appropriate suggestions
  static List<String> getEnhancedAgeSuggestions(int age) {
    if (age <= 5) {
      return [
        'Create a friendly animal',
        'Make it colorful and bright',
        'Add sparkles and magic',
        'Make it small and cute',
      ];
    } else if (age <= 8) {
      return [
        'Create a magical creature',
        'Add special powers',
        'Make it fly or swim',
        'Give it a cool name',
      ];
    } else {
      return [
        'Create a complex creature',
        'Add multiple abilities',
        'Customize all attributes',
        'Create a unique design',
      ];
    }
  }
}