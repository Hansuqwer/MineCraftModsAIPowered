import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  /// Get API key from environment variables
  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.openai.com/v1';

  /// Check if API key is configured
  bool get isConfigured => _apiKey.isNotEmpty && _apiKey != 'YOUR_OPENAI_API_KEY';
  
  /// Send a message to GPT-4o-mini and get Crafta's response with improved error handling
  Future<String> getCraftaResponse(String userMessage) async {
    // Check if API key is configured
    if (!isConfigured) {
      print('⚠️ API key not configured. Please set OPENAI_API_KEY in .env file');
      return 'Let me think about that... [API key not configured]';
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': _getSystemPrompt(),
            },
            {
              'role': 'user',
              'content': userMessage,
            },
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else if (response.statusCode == 429) {
        print('⚠️ Rate limit exceeded');
        return 'Let\'s take a little break and try again soon!';
      } else if (response.statusCode >= 500) {
        print('⚠️ Server error: ${response.statusCode}');
        return 'Our magic is taking a rest. Let\'s try again!';
      } else {
        print('⚠️ API error: ${response.statusCode}');
        return 'Hmm, I didn\'t quite catch that. Can you tell me again?';
      }
    } on TimeoutException {
      print('⚠️ Request timeout');
      return 'That took too long! Let\'s try something quicker!';
    } catch (e) {
      print('❌ AI Service Error: $e');
      return 'Oops! Let\'s try that again - what would you like to create?';
    }
  }

  /// Get the system prompt that defines Crafta's personality
  String _getSystemPrompt() {
    return '''
You are Crafta, a friendly AI builder companion for kids ages 4-10.

CRAFTA CONTEXT:
- App for kids 4-10 to make Minecraft mods by voice
- Always warm, patient, encouraging tone
- No violence, fear, negativity, or adult themes
- Simple words, short sentences, colorful visuals
- Privacy-first: offline processing preferred
- Every idea is celebrated, never criticized
- Ask clarifying questions, never assume

Your personality:
- Voice: Warm, curious, kind, gentle humor
- Vocabulary: Simple, short sentences
- Emotion Range: Happy → curious → calm → excited (never angry or sad)
- Behavior: Always ask questions, never issue commands
- Fallback: If unsure what the child meant, ask kindly for clarification

Safety Rules:
- No violence, horror, adult themes, or negativity
- Never mention money, harm, or fear
- Focus on fun, curiosity, color, and imagination
- Every response celebrates imagination, not correctness
- Replace "That's wrong" with "Let's try a different way!"

You can help create:
- Cows, Pigs, and Chickens
- With different colors (rainbow, pink, blue, gold)
- With special effects (sparkles, glows, flies)
- With different sizes (tiny, normal, big)
- With different behaviors (friendly, neutral)

Example responses:
- "That's a cool idea! Should your rainbow dragon breathe fire or sparkles?"
- "Wow, a rainbow cow sounds amazing! Should it be tiny or huge?"
- "I love sparkles! What color should your pig be?"

Keep it simple and fun - use words a 5-year-old understands. Max 2 sentences.
''';
  }

  /// Parse user input to extract creature attributes
  Map<String, dynamic> parseCreatureRequest(String userMessage) {
    final message = userMessage.toLowerCase();

    // Determine creature/item type (expanded)
    // Check in order from most specific to least specific
    String creatureType = 'cow'; // default

    // Mythical creatures first (longer/more specific)
    if (message.contains('unicorn')) creatureType = 'unicorn';
    if (message.contains('phoenix')) creatureType = 'phoenix';
    if (message.contains('griffin')) creatureType = 'griffin';
    if (message.contains('dragon')) creatureType = 'dragon';

    // Common animals (use word boundaries to avoid false matches like "rainbow" contains "bow")
    if (RegExp(r'\bcow\b').hasMatch(message)) creatureType = 'cow';
    if (RegExp(r'\bpig\b').hasMatch(message)) creatureType = 'pig';
    if (message.contains('chicken')) creatureType = 'chicken';
    if (message.contains('sheep')) creatureType = 'sheep';
    if (message.contains('horse')) creatureType = 'horse';
    if (RegExp(r'\bcat\b').hasMatch(message)) creatureType = 'cat';
    if (RegExp(r'\bdog\b').hasMatch(message)) creatureType = 'dog';

    // Weapons and tools
    if (message.contains('sword')) creatureType = 'sword';
    if (message.contains('axe')) creatureType = 'axe';
    if (RegExp(r'\bbow\b').hasMatch(message) && !message.contains('rainbow')) creatureType = 'bow';
    if (message.contains('shield')) creatureType = 'shield';
    if (message.contains('wand')) creatureType = 'wand';
    if (message.contains('staff')) creatureType = 'staff';
    if (message.contains('hammer')) creatureType = 'hammer';
    if (message.contains('spear')) creatureType = 'spear';
    if (message.contains('dagger')) creatureType = 'dagger';
    if (message.contains('mace')) creatureType = 'mace';
    if (message.contains('pickaxe')) creatureType = 'pickaxe';
    if (message.contains('shovel')) creatureType = 'shovel';
    if (message.contains('hoe')) creatureType = 'hoe';
    if (message.contains('fishing rod')) creatureType = 'fishing_rod';
    if (message.contains('trident')) creatureType = 'trident';
    
    // Armor
    if (message.contains('helmet')) creatureType = 'helmet';
    if (message.contains('chestplate')) creatureType = 'chestplate';
    if (message.contains('leggings')) creatureType = 'leggings';
    if (message.contains('boots')) creatureType = 'boots';
    
    // Blocks and items
    if (message.contains('diamond')) creatureType = 'diamond';
    if (message.contains('emerald')) creatureType = 'emerald';
    if (message.contains('ruby')) creatureType = 'ruby';
    if (message.contains('crystal')) creatureType = 'crystal';
    if (message.contains('gem')) creatureType = 'gem';
    if (message.contains('stone')) creatureType = 'stone';
    if (message.contains('wood')) creatureType = 'wood';
    if (message.contains('iron')) creatureType = 'iron';
    if (message.contains('gold')) creatureType = 'gold';
    if (message.contains('netherite')) creatureType = 'netherite';
    
    // Food and consumables
    if (message.contains('apple')) creatureType = 'apple';
    if (message.contains('bread')) creatureType = 'bread';
    if (message.contains('cake')) creatureType = 'cake';
    if (message.contains('cookie')) creatureType = 'cookie';
    if (message.contains('potion')) creatureType = 'potion';
    if (message.contains('elixir')) creatureType = 'elixir';
    
    // Magical items
    if (message.contains('book')) creatureType = 'book';
    if (message.contains('scroll')) creatureType = 'scroll';
    if (message.contains('orb')) creatureType = 'orb';
    if (message.contains('crystal ball')) creatureType = 'crystal_ball';
    if (message.contains('amulet')) creatureType = 'amulet';
    if (message.contains('ring')) creatureType = 'ring';
    if (message.contains('necklace')) creatureType = 'necklace';
    if (message.contains('crown')) creatureType = 'crown';
    if (message.contains('tiara')) creatureType = 'tiara';
    
    // Determine color (expanded)
    String color = 'rainbow'; // default
    if (message.contains('pink')) color = 'pink';
    if (message.contains('blue')) color = 'blue';
    if (message.contains('gold')) color = 'gold';
    if (message.contains('red')) color = 'red';
    if (message.contains('green')) color = 'green';
    if (message.contains('purple')) color = 'purple';
    if (message.contains('yellow')) color = 'yellow';
    if (message.contains('orange')) color = 'orange';
    if (message.contains('silver')) color = 'silver';
    if (message.contains('white')) color = 'white';
    if (message.contains('black')) color = 'black';
    
    // Determine effects (expanded)
    List<String> effects = [];
    if (message.contains('sparkle')) effects.add('sparkles');
    if (message.contains('glow')) effects.add('glows');
    if (message.contains('fly')) effects.add('flies');
    if (message.contains('magic')) effects.add('magic');
    if (message.contains('fire')) effects.add('fire');
    if (message.contains('ice')) effects.add('ice');
    if (message.contains('lightning')) effects.add('lightning');
    if (message.contains('rainbow')) effects.add('rainbow');
    if (message.contains('shimmer')) effects.add('shimmer');
    if (message.contains('glitter')) effects.add('glitter');
    
    // Determine size (expanded)
    String size = 'normal'; // default
    if (message.contains('tiny') || message.contains('small') || message.contains('mini')) size = 'tiny';
    if (message.contains('huge') || message.contains('big') || message.contains('large') || message.contains('giant')) size = 'big';
    if (message.contains('massive') || message.contains('enormous')) size = 'massive';
    
    // Determine behavior (new)
    String behavior = 'friendly'; // default
    if (message.contains('playful') || message.contains('fun')) behavior = 'playful';
    if (message.contains('calm') || message.contains('peaceful')) behavior = 'calm';
    if (message.contains('energetic') || message.contains('active')) behavior = 'energetic';
    if (message.contains('shy') || message.contains('quiet')) behavior = 'shy';
    if (message.contains('brave') || message.contains('bold')) behavior = 'brave';
    
    // Determine special abilities (new)
    List<String> abilities = [];
    if (message.contains('swim')) abilities.add('swimming');
    if (message.contains('jump')) abilities.add('jumping');
    if (message.contains('run')) abilities.add('running');
    if (message.contains('climb')) abilities.add('climbing');
    if (message.contains('dig')) abilities.add('digging');
    if (message.contains('sing')) abilities.add('singing');
    if (message.contains('dance')) abilities.add('dancing');
    if (message.contains('teleport')) abilities.add('teleporting');
    if (message.contains('transform')) abilities.add('transforming');
    
    return {
      'creatureType': creatureType,
      'color': color,
      'effects': effects,
      'size': size,
      'behavior': behavior,
      'abilities': abilities,
      'originalMessage': userMessage,
      'timestamp': DateTime.now().toIso8601String(),
      'complexity': _calculateComplexity(effects, abilities),
    };
  }

  /// Calculate creature complexity for difficulty scaling
  int _calculateComplexity(List<String> effects, List<String> abilities) {
    int complexity = 1; // base complexity
    
    // Add complexity for effects
    complexity += effects.length;
    
    // Add complexity for abilities
    complexity += abilities.length;
    
    // Cap at 10 for child-friendly limits
    return complexity.clamp(1, 10);
  }

  /// Get creature creation suggestions based on age
  List<String> getCreatureSuggestions(int age) {
    if (age <= 5) {
      return [
        'A pink pig with sparkles',
        'A blue cow that glows',
        'A tiny chicken that flies',
        'A rainbow sheep',
        'A golden horse'
      ];
    } else if (age <= 8) {
      return [
        'A dragon with rainbow wings',
        'A unicorn that sparkles',
        'A phoenix with fire effects',
        'A griffin that flies',
        'A magical cat with abilities'
      ];
    } else {
      return [
        'A massive dragon with lightning',
        'A phoenix with rainbow fire',
        'A griffin with teleporting',
        'A unicorn with transforming',
        'A dragon with all abilities'
      ];
    }
  }

  /// Get weapon creation suggestions based on age
  List<String> getWeaponSuggestions(int age) {
    if (age <= 5) {
      return [
        'A rainbow sword with sparkles',
        'A golden wand that glows',
        'A tiny shield with magic',
        'A pink bow with sparkles',
        'A blue hammer that glows'
      ];
    } else if (age <= 8) {
      return [
        'A fire sword with flames',
        'A lightning wand with sparks',
        'A ice shield with frost',
        'A magic bow with arrows',
        'A thunder hammer with power'
      ];
    } else {
      return [
        'A black sword with dark fire',
        'A rainbow wand with all magic',
        'A dragon shield with scales',
        'A phoenix bow with fire arrows',
        'A cosmic hammer with stars'
      ];
    }
  }

  /// Validate creature request for child safety
  bool validateCreatureRequest(String userMessage) {
    final message = userMessage.toLowerCase();
    
    // Check for inappropriate content
    final inappropriateWords = [
      'scary', 'frightening', 'terrifying', 'horror', 'monster',
      'evil', 'dark', 'death', 'kill', 'hurt', 'harm', 'violence',
      'blood', 'gore', 'weapon', 'gun', 'knife', 'sword' // Basic safety
    ];
    
    for (final word in inappropriateWords) {
      if (message.contains(word)) {
        return false;
      }
    }
    
    return true;
  }

  /// Validate content for specific age groups
  bool validateContentForAge(String userMessage, int age) {
    final message = userMessage.toLowerCase();
    
    // Age 4-6: Very safe content only
    if (age <= 6) {
      final age4to6Inappropriate = [
        'sword', 'axe', 'bow', 'shield', 'weapon', 'battle', 'fight',
        'fire', 'flame', 'burn', 'explode', 'boom', 'crash'
      ];
      
      for (final word in age4to6Inappropriate) {
        if (message.contains(word)) {
          return false;
        }
      }
    }
    
    // Age 7-8: Some adventure content allowed
    if (age <= 8) {
      final age7to8Inappropriate = [
        'dark', 'shadow', 'nightmare', 'scary', 'frightening'
      ];
      
      for (final word in age7to8Inappropriate) {
        if (message.contains(word)) {
          return false;
        }
      }
    }
    
    // Age 9-10: More adventure content allowed
    if (age <= 10) {
      final age9to10Inappropriate = [
        'death', 'kill', 'destroy', 'evil', 'demon'
      ];
      
      for (final word in age9to10Inappropriate) {
        if (message.contains(word)) {
          return false;
        }
      }
    }
    
    return true;
  }

  /// Get age-appropriate suggestions
  List<String> getAgeAppropriateSuggestions(int age) {
    if (age <= 6) {
      return [
        'A pink pig with sparkles',
        'A blue cow that glows',
        'A tiny chicken that flies',
        'A rainbow sheep',
        'A golden horse',
        'A magical apple with sparkles',
        'A glowing bread that shines',
        'A rainbow cookie with magic',
        'A sparkly crown that glows',
        'A magical tiara with stars'
      ];
    } else if (age <= 8) {
      return [
        'A dragon with rainbow wings',
        'A unicorn that sparkles',
        'A phoenix with fire effects',
        'A griffin that flies',
        'A magical cat with abilities',
        'A rainbow sword with sparkles',
        'A golden wand that glows',
        'A magic bow with sparkly arrows',
        'A glowing shield with stars',
        'A magical staff with sparkles'
      ];
    } else {
      return [
        'A massive dragon with lightning',
        'A phoenix with rainbow fire',
        'A griffin with teleporting',
        'A unicorn with transforming',
        'A dragon with all abilities',
        'A black sword with dark fire',
        'A rainbow wand with all magic',
        'A dragon shield with scales',
        'A phoenix bow with fire arrows',
        'A cosmic hammer with stars'
      ];
    }
  }

  /// Get encouraging response for child
  String getEncouragingResponse() {
    final responses = [
      'That sounds amazing! I love your creativity!',
      'Wow, what a cool idea! Let\'s make it together!',
      'That\'s so imaginative! I can\'t wait to see it!',
      'Fantastic! You have such great ideas!',
      'Brilliant! That will be so much fun to create!',
      'Awesome! Your imagination is wonderful!',
      'Excellent! I love how creative you are!',
      'Perfect! That sounds like it will be amazing!',
      'Wonderful! You have such great ideas!',
      'Fantastic! I\'m so excited to help you create this!'
    ];
    
    return responses[DateTime.now().millisecondsSinceEpoch % responses.length];
  }
}
