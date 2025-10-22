import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/enhanced_creature_attributes.dart';
import './api_key_service.dart';
import './ai_model_generator_service.dart';

/// Enhanced AI service for advanced creature customization
class EnhancedAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  /// Get API key from secure storage or .env file
  static Future<String?> _getApiKey() async {
    print('🔍 [ENHANCED_AI] Checking for API key...');
    
    // Try to get from ApiKeyService first
    final apiKeyService = ApiKeyService();
    final storedKey = await apiKeyService.getApiKey();
    
    print('🔍 [ENHANCED_AI] Stored key result: ${storedKey != null ? 'FOUND (${storedKey.substring(0, 7)}...)' : 'NOT FOUND'}');

    if (storedKey != null && storedKey.isNotEmpty) {
      print('✅ [ENHANCED_AI] Using API key from secure storage');
      return storedKey;
    }

    // Fall back to .env file
    final envKey = dotenv.env['OPENAI_API_KEY'];
    print('🔍 [ENHANCED_AI] .env key result: ${envKey != null ? 'FOUND (${envKey.substring(0, 7)}...)' : 'NOT FOUND'}');
    
    if (envKey != null && envKey.isNotEmpty) {
      print('⚠️ [ENHANCED_AI] Using API key from .env file');
      return envKey;
    }

    print('❌ [ENHANCED_AI] No API key found - will use offline mode');
    return null;
  }

  /// Validate that AI response matches user input
  static bool _validateResponse(String userInput, Map<String, dynamic> response) {
    final userLower = userInput.toLowerCase();
    final baseType = (response['baseType'] ?? '').toString().toLowerCase();
    final primaryColor = (response['primaryColor'] ?? '').toString().toLowerCase();

    // Check if user mentioned a specific item type
    final itemTypes = ['sword', 'dragon', 'chair', 'table', 'armor', 'helmet',
                       'shield', 'axe', 'bow', 'castle', 'house', 'car', 'boat'];

    for (final type in itemTypes) {
      if (userLower.contains(type)) {
        // User mentioned this type, so baseType MUST match
        if (!baseType.contains(type) && baseType != type) {
          print('❌ [VALIDATION] User said "$type" but AI returned "$baseType" - REJECTED!');
          return false;
        }
      }
    }

    // Check if user mentioned a specific color (with variants)
    final colorVariants = {
      'black': ['black'],
      'white': ['white'],
      'red': ['red'],
      'blue': ['blue'],
      'green': ['green'],
      'yellow': ['yellow'],
      'purple': ['purple', 'violet'],
      'pink': ['pink'],
      'orange': ['orange'],
      'brown': ['brown'],
      'gray': ['gray', 'grey'],
      'gold': ['gold', 'golden', 'amber'],
      'silver': ['silver'],
    };

    for (final entry in colorVariants.entries) {
      final colorName = entry.key;
      final variants = entry.value;

      // Check if user mentioned any variant of this color
      for (final variant in variants) {
        if (userLower.contains(variant)) {
          // User mentioned this color, so primaryColor MUST match
          bool matches = false;
          for (final checkVariant in variants) {
            if (primaryColor.contains(checkVariant) || primaryColor == checkVariant) {
              matches = true;
              break;
            }
          }

          if (!matches) {
            print('❌ [VALIDATION] User said "$variant" but AI returned "$primaryColor" - REJECTED!');
            return false;
          }
        }
      }
    }

    print('✅ [VALIDATION] Response matches user input');
    return true;
  }

  /// Parse enhanced creature request with advanced attributes
  static Future<EnhancedCreatureAttributes> parseEnhancedCreatureRequest(
    String userMessage,
  ) async {
    print('🔍 [ENHANCED_AI] === API CALL START ===');
    print('🔍 [ENHANCED_AI] User request: $userMessage');

    try {
      // Step 1: Get API key
      print('🔍 [ENHANCED_AI] Step 1: Loading API key...');
      final apiKey = await _getApiKey();

      // If no API key, require internet setup
      if (apiKey == null) {
        print('❌ [ENHANCED_AI] No API key found - internet connection required');
        print('💡 [ENHANCED_AI] Please configure OpenAI API key in settings');
        throw Exception('Internet connection and API key required. Please configure OpenAI API key in app settings.');
      }

      print('✅ [ENHANCED_AI] Step 1: API key loaded: ${apiKey.substring(0, 7)}...${apiKey.substring(apiKey.length - 4)}');
      print('🔍 [ENHANCED_AI] Key length: ${apiKey.length} characters');

      // Step 2: Make API call with timeout
      print('🔍 [ENHANCED_AI] Step 2: Making API call to OpenAI...');
      print('🔍 [ENHANCED_AI] Endpoint: $_baseUrl');
      print('🔍 [ENHANCED_AI] Model: gpt-4o-mini');
      print('🔍 [ENHANCED_AI] Message length: ${userMessage.length} chars');

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
          'temperature': 0.1,  // Low temperature = more literal, less creative
          'max_tokens': 1000,
          'response_format': {'type': 'json_object'},  // FORCE JSON-only output
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('❌ [ENHANCED_AI] FAILED: API request timed out after 30 seconds');
          print('💡 [ENHANCED_AI] This usually means slow internet connection');
          throw Exception('OpenAI API timeout - Check your internet connection');
        },
      );

      print('🔍 [ENHANCED_AI] Step 2: Response received');
      print('🔍 [ENHANCED_AI] Status code: ${response.statusCode}');

      // Step 3: Parse response
      if (response.statusCode == 200) {
        print('✅ [ENHANCED_AI] Step 3: Parsing successful response...');
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        print('✅ [ENHANCED_AI] === API CALL SUCCESS ===');
        print('🤖 [ENHANCED_AI] Response preview: ${content.substring(0, content.length > 100 ? 100 : content.length)}...');
        return _parseAIResponse(content, userMessage);
      } else {
        print('❌ [ENHANCED_AI] FAILED: OpenAI API returned error status');
        print('❌ [ENHANCED_AI] Status: ${response.statusCode}');
        print('❌ [ENHANCED_AI] Body: ${response.body}');

        // Parse error message if available
        String errorMessage = 'API error ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error']?['message'] ?? errorMessage;
          print('❌ [ENHANCED_AI] Error message: $errorMessage');
        } catch (e) {
          // Couldn't parse error body
        }

        print('⚠️ [ENHANCED_AI] Falling back to offline mode');
        return _getDefaultAttributes(userMessage);
      }
    } on Exception catch (e) {
      print('❌ [ENHANCED_AI] === API CALL FAILED ===');
      print('❌ [ENHANCED_AI] Error type: ${e.runtimeType}');
      print('❌ [ENHANCED_AI] Error: $e');

      if (e.toString().contains('SocketException')) {
        print('💡 [ENHANCED_AI] Network error - No internet connection or can\'t reach OpenAI servers');
      } else if (e.toString().contains('timeout')) {
        print('💡 [ENHANCED_AI] Timeout error - Request took too long (>30 seconds)');
      } else {
        print('💡 [ENHANCED_AI] Unexpected error - See details above');
      }

      print('⚠️ [ENHANCED_AI] Internet connection required for AI features');
      print('🤖 [ENHANCED_AI] Using AI model generator as fallback...');
      return AIModelGeneratorService.createAttributesFromRequest(userMessage);
    } catch (e) {
      print('❌ [ENHANCED_AI] === UNEXPECTED ERROR ===');
      print('❌ [ENHANCED_AI] Error: $e');
      print('⚠️ [ENHANCED_AI] Internet connection required for AI features');
      print('🤖 [ENHANCED_AI] Using AI model generator as fallback...');
      return AIModelGeneratorService.createAttributesFromRequest(userMessage);
    }
  }

  /// Get enhanced system prompt for advanced parsing
  static String _getEnhancedSystemPrompt() {
    return '''
You are a strict JSON parser. Output ONLY valid JSON, absolutely NO other text.

CRITICAL - DO NOT CHANGE USER INPUT:
- If user says "sword" → baseType MUST be "sword" (NOT dragon, NOT anything else)
- If user says "dragon" → baseType MUST be "dragon" (NOT sword, NOT anything else)
- If user says "black" → primaryColor MUST be "black" (NOT blue, NOT anything else)
- If user says "chair" → baseType MUST be "chair" (NOT dragon, NOT creature)

YOU ARE NOT ALLOWED TO BE CREATIVE WITH THE BASE TYPE OR COLOR.
Use EXACTLY what the user typed. DO NOT substitute words.

JSON Schema (REQUIRED fields marked with *):
{
  "baseType": string*,        // EXACTLY what they asked for: "dragon", "sword", "chair", etc.
  "category": string*,        // "creature", "weapon", "armor", "furniture", "vehicle", "tool", "decoration"
  "primaryColor": string*,    // "black", "blue", "red", "green", "yellow", "purple", "pink", "orange", "white", "brown", "gold", "silver"
  "secondaryColor": string,   // Optional second color
  "accentColor": string,      // Optional accent color
  "size": string,             // "tiny", "small", "medium", "large", "giant" (default: "medium")
  "abilities": array,         // ["flying", "swimming", "fireBreath", "iceBreath", "magic", "invisible", "teleport"]
  "accessories": array,       // ["red eyes", "wizard hat", "crown", "diamond handle", "golden trim"]
  "personality": string,      // "friendly", "playful", "shy", "brave", "curious", "fierce"
  "patterns": array,          // ["stripes", "spots", "sparkles", "rainbow", "stars", "hearts"]
  "texture": string,          // "smooth", "rough", "scaly", "furry", "metallic", "glassy"
  "glowEffect": string,       // "none", "soft", "bright", "pulsing", "rainbow"
  "animationStyle": string,   // "natural", "bouncy", "graceful", "energetic", "calm"
  "customName": string*,      // Creative name based on description
  "description": string*      // One-sentence description
}

EXAMPLES:

Input: "black dragon"
Output:
{
  "baseType": "dragon",
  "category": "creature",
  "primaryColor": "black",
  "secondaryColor": "gray",
  "size": "giant",
  "abilities": ["flying", "fireBreath"],
  "accessories": [],
  "personality": "fierce",
  "patterns": [],
  "texture": "scaly",
  "glowEffect": "none",
  "animationStyle": "natural",
  "customName": "Black Dragon",
  "description": "A fierce black dragon that breathes fire"
}

Input: "blue sword with diamonds in handle"
Output:
{
  "baseType": "sword",
  "category": "weapon",
  "primaryColor": "blue",
  "secondaryColor": "silver",
  "accentColor": "white",
  "size": "medium",
  "abilities": [],
  "accessories": ["diamond handle"],
  "personality": "friendly",
  "patterns": ["sparkles"],
  "texture": "metallic",
  "glowEffect": "soft",
  "animationStyle": "natural",
  "customName": "Diamond Blue Sword",
  "description": "A shiny blue sword with diamonds in the handle"
}

Input: "red dragon with green scales"
Output:
{
  "baseType": "dragon",
  "category": "creature",
  "primaryColor": "red",
  "secondaryColor": "green",
  "size": "giant",
  "abilities": ["flying", "fireBreath"],
  "accessories": [],
  "personality": "fierce",
  "patterns": ["spots"],
  "texture": "scaly",
  "glowEffect": "none",
  "animationStyle": "natural",
  "customName": "Red Dragon",
  "description": "A red dragon with green scales"
}

Input: "black glowing sword"
Output:
{
  "baseType": "sword",
  "category": "weapon",
  "primaryColor": "black",
  "secondaryColor": "gray",
  "size": "medium",
  "abilities": [],
  "accessories": [],
  "personality": "friendly",
  "patterns": [],
  "texture": "metallic",
  "glowEffect": "bright",
  "animationStyle": "natural",
  "customName": "Black Glowing Sword",
  "description": "A black sword that glows brightly"
}

CRITICAL: If user mentions "sword", baseType MUST be "sword". If user mentions "dragon", baseType MUST be "dragon". NEVER substitute one for the other!

Remember: ONLY JSON output, nothing else!
''';
  }

  /// Parse AI response into enhanced attributes
  static EnhancedCreatureAttributes _parseAIResponse(String content, String userInput) {
    try {
      // Extract JSON from response
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;

      if (jsonStart == -1 || jsonEnd == 0) {
        print('⚠️ [ENHANCED_AI] No JSON found in response, using fallback');
        return _getDefaultAttributes(content);
      }

      final jsonString = content.substring(jsonStart, jsonEnd);
      print('🔍 [ENHANCED_AI] Extracted JSON: $jsonString');

      final Map<String, dynamic> data = jsonDecode(jsonString);

      // VALIDATE: Check if response matches user input
      if (!_validateResponse(userInput, data)) {
        print('❌ [ENHANCED_AI] Validation failed - AI changed user input!');
        print('💡 [ENHANCED_AI] Using fallback with user\'s exact words');
        return _getDefaultAttributes(userInput);
      }

      return EnhancedCreatureAttributes(
        baseType: data['baseType'] ?? 'creature',
        primaryColor: _parseColor(data['primaryColor']),
        secondaryColor: _parseColor(data['secondaryColor']),
        accentColor: _parseColor(data['accentColor']),
        size: _parseSize(data['size']),
        abilities: _parseAbilities(data['abilities']),
        accessories: _parseAccessories(data['accessories']),
        personality: _parsePersonality(data['personality']),
        patterns: _parsePatterns(data['patterns']),
        texture: _parseTexture(data['texture']),
        glowEffect: _parseGlowEffect(data['glowEffect']),
        animationStyle: _parseAnimationStyle(data['animationStyle']),
        customName: data['customName'] ?? '',
        description: data['description'] ?? '',
      );
    } catch (e) {
      print('❌ [ENHANCED_AI] Error parsing AI response: $e');
      return _getDefaultAttributes(content);
    }
  }

  /// Parse color from string
  static Color _parseColor(String? colorString) {
    if (colorString == null) return Colors.blue;
    
    switch (colorString.toLowerCase()) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'yellow': return Colors.yellow;
      case 'purple': return Colors.purple;
      case 'pink': return Colors.pink;
      case 'orange': return Colors.orange;
      case 'black': return Colors.black;
      case 'white': return Colors.white;
      case 'brown': return Colors.brown;
      case 'grey': case 'gray': return Colors.grey;
      case 'gold': case 'amber': case 'golden': return Colors.amber;
      case 'silver': return Colors.grey[400]!;
      default: return Colors.blue;
    }
  }

  /// Parse size from string
  static CreatureSize _parseSize(String? sizeString) {
    if (sizeString == null) return CreatureSize.medium;
    
    switch (sizeString.toLowerCase()) {
      case 'tiny': return CreatureSize.tiny;
      case 'small': return CreatureSize.small;
      case 'medium': return CreatureSize.medium;
      case 'large': return CreatureSize.large;
      case 'giant': return CreatureSize.giant;
      default: return CreatureSize.medium;
    }
  }

  /// Parse personality from string
  static PersonalityType _parsePersonality(String? personalityString) {
    if (personalityString == null) return PersonalityType.friendly;
    
    switch (personalityString.toLowerCase()) {
      case 'friendly': return PersonalityType.friendly;
      case 'playful': return PersonalityType.playful;
      case 'shy': return PersonalityType.shy;
      case 'brave': return PersonalityType.brave;
      case 'curious': return PersonalityType.curious;
      default: return PersonalityType.friendly;
    }
  }

  /// Parse abilities from list
  static List<SpecialAbility> _parseAbilities(dynamic abilitiesData) {
    if (abilitiesData == null || abilitiesData is! List) return [];
    
    final List<SpecialAbility> abilities = [];
    for (final ability in abilitiesData) {
      if (ability is String) {
        switch (ability.toLowerCase()) {
          case 'flying': abilities.add(SpecialAbility.flying); break;
          case 'swimming': abilities.add(SpecialAbility.swimming); break;
          case 'firebreath': case 'fire_breath': abilities.add(SpecialAbility.fireBreath); break;
          case 'icebreath': case 'ice_breath': abilities.add(SpecialAbility.iceBreath); break;
          case 'magic': abilities.add(SpecialAbility.magic); break;
          case 'teleportation': abilities.add(SpecialAbility.teleportation); break;
          case 'invisibility': abilities.add(SpecialAbility.invisibility); break;
          case 'superstrength': case 'super_strength': abilities.add(SpecialAbility.superStrength); break;
          case 'superspeed': case 'super_speed': abilities.add(SpecialAbility.superSpeed); break;
          case 'healing': abilities.add(SpecialAbility.healing); break;
          case 'shapeshifting': abilities.add(SpecialAbility.shapeshifting); break;
          case 'weathercontrol': case 'weather_control': abilities.add(SpecialAbility.weatherControl); break;
        }
      }
    }
    return abilities;
  }

  /// Parse accessories from list
  static List<AccessoryType> _parseAccessories(dynamic accessoriesData) {
    if (accessoriesData == null || accessoriesData is! List) return [];
    
    final List<AccessoryType> accessories = [];
    for (final accessory in accessoriesData) {
      if (accessory is String) {
        final lowerAccessory = accessory.toLowerCase();
        if (lowerAccessory.contains('hat') || lowerAccessory.contains('crown')) {
          accessories.add(AccessoryType.hat);
        } else if (lowerAccessory.contains('glass') || lowerAccessory.contains('eye')) {
          accessories.add(AccessoryType.glasses);
        } else if (lowerAccessory.contains('armor') || lowerAccessory.contains('armour')) {
          accessories.add(AccessoryType.armor);
        } else if (lowerAccessory.contains('magic') || lowerAccessory.contains('wand')) {
          accessories.add(AccessoryType.magical);
        }
      }
    }
    return accessories;
  }

  /// Parse patterns from list
  static List<Pattern> _parsePatterns(dynamic patternsData) {
    if (patternsData == null || patternsData is! List) return [];
    
    final List<Pattern> patterns = [];
    for (final pattern in patternsData) {
      if (pattern is String) {
        switch (pattern.toLowerCase()) {
          case 'stripes': patterns.add(Pattern.stripes); break;
          case 'spots': patterns.add(Pattern.spots); break;
          case 'sparkles': patterns.add(Pattern.sparkles); break;
          case 'rainbow': patterns.add(Pattern.rainbow); break;
          case 'stars': patterns.add(Pattern.stars); break;
          case 'hearts': patterns.add(Pattern.hearts); break;
        }
      }
    }
    return patterns;
  }

  /// Parse texture from string
  static TextureType _parseTexture(String? textureString) {
    if (textureString == null) return TextureType.smooth;
    
    switch (textureString.toLowerCase()) {
      case 'smooth': return TextureType.smooth;
      case 'rough': return TextureType.rough;
      case 'scaly': return TextureType.scaly;
      case 'furry': return TextureType.furry;
      case 'metallic': return TextureType.metallic;
      case 'glassy': return TextureType.glassy;
      default: return TextureType.smooth;
    }
  }

  /// Parse glow effect from string
  static GlowEffect _parseGlowEffect(String? glowString) {
    if (glowString == null) return GlowEffect.none;
    
    switch (glowString.toLowerCase()) {
      case 'none': return GlowEffect.none;
      case 'soft': return GlowEffect.soft;
      case 'bright': return GlowEffect.bright;
      case 'pulsing': return GlowEffect.pulsing;
      case 'rainbow': return GlowEffect.rainbow;
      default: return GlowEffect.none;
    }
  }

  /// Parse animation style from string
  static CreatureAnimationStyle _parseAnimationStyle(String? animationString) {
    if (animationString == null) return CreatureAnimationStyle.natural;
    
    switch (animationString.toLowerCase()) {
      case 'natural': return CreatureAnimationStyle.natural;
      case 'bouncy': return CreatureAnimationStyle.bouncy;
      case 'graceful': return CreatureAnimationStyle.graceful;
      case 'energetic': return CreatureAnimationStyle.energetic;
      case 'calm': return CreatureAnimationStyle.calm;
      default: return CreatureAnimationStyle.natural;
    }
  }

  /// Test function to verify color mapping
  static void testColorMapping() {
    print('🧪 [TEST] Testing color mapping...');
    final testCases = ['golden helmet', 'blue sword', 'red chair', 'green dragon'];
    
    for (final testCase in testCases) {
      final result = _getDefaultAttributes(testCase);
      print('🧪 [TEST] "$testCase" -> baseType: ${result.baseType}, color: ${result.primaryColor}');
    }
  }

  /// Get default attributes when AI fails
  static EnhancedCreatureAttributes _getDefaultAttributes(String userMessage) {
    print('⚠️ [ENHANCED_AI] Using default attributes for: $userMessage');
    
    // Try to extract basic info from user message
    final lowerMessage = userMessage.toLowerCase().trim();
    print('🔍 [ENHANCED_AI] Lower message: $lowerMessage');
    print('🔍 [ENHANCED_AI] Message length: ${userMessage.length} chars');
    print('🔍 [ENHANCED_AI] Lower length: ${lowerMessage.length} chars');
    
    String baseType = 'creature';
    Color primaryColor = Colors.blue;
    
    // Enhanced keyword matching for all item types
    if (lowerMessage.contains('sword')) baseType = 'sword';
    else if (lowerMessage.contains('bow')) baseType = 'bow';
    else if (lowerMessage.contains('axe')) baseType = 'axe';
    else if (lowerMessage.contains('hammer')) baseType = 'hammer';
    else if (lowerMessage.contains('wand')) baseType = 'magic wand';
    else if (lowerMessage.contains('staff')) baseType = 'staff';
    else if (lowerMessage.contains('helmet')) baseType = 'helmet';
    else if (lowerMessage.contains('chestplate')) baseType = 'chestplate';
    else if (lowerMessage.contains('leggings')) baseType = 'leggings';
    else if (lowerMessage.contains('boots')) baseType = 'boots';
    else if (lowerMessage.contains('shield')) baseType = 'shield';
    else if (lowerMessage.contains('chair')) baseType = 'chair';
    else if (lowerMessage.contains('couch')) baseType = 'couch';
    else if (lowerMessage.contains('sofa')) baseType = 'couch';
    else if (lowerMessage.contains('table')) baseType = 'table';
    else if (lowerMessage.contains('desk')) baseType = 'desk';
    else if (lowerMessage.contains('bed')) baseType = 'bed';
    else if (lowerMessage.contains('lamp')) baseType = 'lamp';
    else if (lowerMessage.contains('bookshelf')) baseType = 'bookshelf';
    else if (lowerMessage.contains('cabinet')) baseType = 'cabinet';
    else if (lowerMessage.contains('dresser')) baseType = 'dresser';
    else if (lowerMessage.contains('wardrobe')) baseType = 'wardrobe';
    else if (lowerMessage.contains('stool')) baseType = 'stool';
    else if (lowerMessage.contains('bench')) baseType = 'bench';
    else if (lowerMessage.contains('car')) baseType = 'car';
    else if (lowerMessage.contains('boat')) baseType = 'boat';
    else if (lowerMessage.contains('plane')) baseType = 'plane';
    else if (lowerMessage.contains('rocket')) baseType = 'rocket';
    else if (lowerMessage.contains('spaceship')) baseType = 'spaceship';
    else if (lowerMessage.contains('house')) baseType = 'house';
    else if (lowerMessage.contains('castle')) baseType = 'castle';
    else if (lowerMessage.contains('tower')) baseType = 'tower';
    else if (lowerMessage.contains('bridge')) baseType = 'bridge';
    else if (lowerMessage.contains('pickaxe')) baseType = 'pickaxe';
    else if (lowerMessage.contains('shovel')) baseType = 'shovel';
    else if (lowerMessage.contains('hoe')) baseType = 'hoe';
    else if (lowerMessage.contains('fishing rod')) baseType = 'fishing rod';
    else if (lowerMessage.contains('flower')) baseType = 'flower';
    else if (lowerMessage.contains('plant')) baseType = 'plant';
    else if (lowerMessage.contains('statue')) baseType = 'statue';
    else if (lowerMessage.contains('painting')) baseType = 'painting';
    else if (lowerMessage.contains('dragon')) baseType = 'dragon';
    else if (lowerMessage.contains('cat')) baseType = 'cat';
    else if (lowerMessage.contains('dog')) baseType = 'dog';
    else if (lowerMessage.contains('robot')) baseType = 'robot';
    else if (lowerMessage.contains('unicorn')) baseType = 'unicorn';
    else if (lowerMessage.contains('phoenix')) baseType = 'phoenix';
    else if (lowerMessage.contains('dinosaur')) baseType = 'dinosaur';
    else if (lowerMessage.contains('monster')) baseType = 'monster';
    
    // Find FIRST color mentioned (prioritize first color in text)
    final colorMap = {
      'black': Colors.black,
      'white': Colors.white,
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'purple': Colors.purple,
      'violet': Colors.purple,
      'pink': Colors.pink,
      'orange': Colors.orange,
      'brown': Colors.brown,
      'gold': Colors.amber,
      'golden': Colors.amber,
      'amber': Colors.amber,
      'silver': Colors.grey[400]!,
      'gray': Colors.grey,
      'grey': Colors.grey,
    };

    int firstColorIndex = lowerMessage.length;

    colorMap.forEach((colorName, color) {
      final index = lowerMessage.indexOf(colorName);
      if (index != -1 && index < firstColorIndex) {
        firstColorIndex = index;
        primaryColor = color;
        print('🎨 [ENHANCED_AI] Found color: $colorName -> $color at index $index');
      }
    });
    
    print('🎨 [ENHANCED_AI] Final primary color: $primaryColor');

    // Detect glow effect
    GlowEffect glowEffect = GlowEffect.none;
    if (lowerMessage.contains('glow')) glowEffect = GlowEffect.bright;

    // Generate a name from the attributes
    String colorName = 'Blue'; // Default
    if (primaryColor == Colors.black) colorName = 'Black';
    else if (primaryColor == Colors.white) colorName = 'White';
    else if (primaryColor == Colors.red) colorName = 'Red';
    else if (primaryColor == Colors.green) colorName = 'Green';
    else if (primaryColor == Colors.yellow) colorName = 'Yellow';
    else if (primaryColor == Colors.purple) colorName = 'Purple';
    else if (primaryColor == Colors.pink) colorName = 'Pink';
    else if (primaryColor == Colors.orange) colorName = 'Orange';
    else if (primaryColor == Colors.brown) colorName = 'Brown';
    else if (primaryColor == Colors.amber) colorName = 'Golden';
    else if (primaryColor == Colors.grey) colorName = 'Gray';
    else if (primaryColor == Colors.grey[400]) colorName = 'Silver';

    String glowText = glowEffect == GlowEffect.bright ? 'Glowing ' : '';
    String customName = '$glowText$colorName ${baseType[0].toUpperCase()}${baseType.substring(1)}';

    return EnhancedCreatureAttributes(
      baseType: baseType,
      primaryColor: primaryColor,
      secondaryColor: Colors.grey,
      accentColor: Colors.white,
      size: CreatureSize.medium,
      abilities: [],
      accessories: [],
      personality: PersonalityType.friendly,
      patterns: [],
      texture: TextureType.smooth,
      glowEffect: glowEffect,
      animationStyle: CreatureAnimationStyle.natural,
      customName: customName,
      description: 'A $baseType created with AI',
    );
  }

  /// Check if API key is available
  static Future<bool> isApiKeyAvailable() async {
    final key = await _getApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Get API key status for debugging
  static Future<String> getApiKeyStatus() async {
    final key = await _getApiKey();
    if (key == null) return 'No API key found';
    return 'API key available: ${key.substring(0, 7)}...';
  }
}
