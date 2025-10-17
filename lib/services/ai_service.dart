import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'offline_ai_service.dart';
import 'connectivity_service.dart';
import 'local_storage_service.dart';
import 'content_moderation_service.dart';
import 'ollama_ai_service.dart';
import 'huggingface_ai_service.dart';
import 'groq_ai_service.dart';
import 'api_key_manager.dart';
import 'swedish_ai_service.dart';
import 'language_service.dart';
import 'debug_service.dart';

/// Exception for content moderation violations
class ContentModerationException implements Exception {
  final String message;
  ContentModerationException(this.message);
  
  @override
  String toString() => 'ContentModerationException: $message';
}

/// Exception for AI service errors
class AIServiceException implements Exception {
  final String message;
  final String? service;
  AIServiceException(this.message, [this.service]);
  
  @override
  String toString() => 'AIServiceException${service != null ? ' ($service)' : ''}: $message';
}

/// Exception for network connectivity issues
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class AIService {
  /// Get API key from environment variables
  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String _baseUrl = 'https://api.openai.com/v1';

  /// Offline AI service for when network is unavailable
  final OfflineAIService _offlineService = OfflineAIService();

  /// Connectivity service
  final ConnectivityService _connectivityService = ConnectivityService();

  /// Local storage service
  final LocalStorageService _storageService = LocalStorageService();
  
  /// Free AI services
  final OllamaAIService _ollamaService = OllamaAIService();
  final HuggingFaceAIService _huggingFaceService = HuggingFaceAIService();
  final GroqAIService _groqService = GroqAIService();

  /// Check if API key is configured
  bool get isConfigured => _apiKey.isNotEmpty && _apiKey != 'YOUR_OPENAI_API_KEY';
  
  /// Check if user needs to set up AI services
  Future<bool> needsSetup() async {
    final hasAnyKeys = await APIKeyManager.hasAnyAPIKeys();
    return !hasAnyKeys;
  }
  
  /// Get recommended setup for new users
  Future<List<String>> getRecommendedSetup() async {
    return APIKeyManager.getRecommendedSetupOrder();
  }
  
  /// Send a message to AI and get Crafta's response with improved error handling
  /// Tries free APIs first, then OpenAI, then offline mode
  Future<String> getCraftaResponse(String userMessage, {int age = 6}) async {
    try {
      // Check current language setting
      final currentLocale = await LanguageService.getCurrentLanguage();
      final isSwedish = currentLocale.languageCode == 'sv';
      
      // If Swedish, use Swedish AI service
      if (isSwedish) {
        print('🇸🇪 Using Swedish AI service');
        return SwedishAIService.getSwedishResponse(userMessage, age: age);
      }
      
      // First, check cache for recent response
      final cachedResponse = await _storageService.getCachedAPIResponse(
        userMessage,
        maxAge: const Duration(hours: 1),
      );

      if (cachedResponse != null) {
        print('✅ Using cached response');
        return cachedResponse;
      }

      // Check connectivity
      final isConnected = await _connectivityService.checkConnectivity();

    if (!isConnected) {
      print('📡 No internet - using offline mode');
      return _offlineService.getOfflineResponse(userMessage, age: age);
    }

    // Try free AI services first (no installation needed)
    print('🆓 Trying free AI services...');
    
    // 1. Try Groq (fast and free - no installation needed)
    try {
      final groqResponse = await _groqService.getCraftaResponse(userMessage, age: age);
      if (groqResponse.isNotEmpty && !groqResponse.contains('offline')) {
        print('✅ Using Groq response');
        await _storageService.cacheAPIResponse(userMessage, groqResponse);
        return groqResponse;
      }
    } catch (e) {
      print('🔄 Groq failed: $e');
    }
    
    // 2. Try Hugging Face (free tier - no installation needed)
    try {
      final hfResponse = await _huggingFaceService.getCraftaResponse(userMessage, age: age);
      if (hfResponse.isNotEmpty && !hfResponse.contains('offline')) {
        print('✅ Using Hugging Face response');
        await _storageService.cacheAPIResponse(userMessage, hfResponse);
        return hfResponse;
      }
    } catch (e) {
      print('🔄 Hugging Face failed: $e');
    }
    
    // 3. Try Ollama (local AI - requires installation)
    try {
      final ollamaResponse = await _ollamaService.getCraftaResponse(userMessage, age: age);
      if (ollamaResponse.isNotEmpty && !ollamaResponse.contains('offline')) {
        print('✅ Using Ollama response');
        await _storageService.cacheAPIResponse(userMessage, ollamaResponse);
        return ollamaResponse;
      }
    } catch (e) {
      print('🔄 Ollama failed: $e');
    }
    
    // 4. Try OpenAI (if configured)
    if (isConfigured) {
      print('💰 Trying OpenAI...');
      try {
        final openaiResponse = await _getOpenAIResponse(userMessage, age);
        if (openaiResponse.isNotEmpty) {
          print('✅ Using OpenAI response');
          await _storageService.cacheAPIResponse(userMessage, openaiResponse);
          return openaiResponse;
        }
      } catch (e) {
        print('🔄 OpenAI failed: $e');
      }
    }
    
    // 5. Fallback to offline mode
    print('📱 All AI services failed, using offline mode');
    return _offlineService.getOfflineResponse(userMessage, age: age);
    
    } catch (e) {
      print('❌ AI Service Error: $e');
      
      // Handle specific error types
      if (e is NetworkException) {
        print('🌐 Network error - using offline mode');
        return _offlineService.getOfflineResponse(userMessage, age: age);
      } else if (e is AIServiceException) {
        print('🤖 AI service error - using offline mode');
        return _offlineService.getOfflineResponse(userMessage, age: age);
      } else if (e is ContentModerationException) {
        print('🛡️ Content moderation violation');
        return 'I can\'t help with that request. Let\'s try creating something else!';
      } else {
        print('❌ Unexpected error - using offline mode');
        return _offlineService.getOfflineResponse(userMessage, age: age);
      }
    }
  }
  
  /// Get OpenAI response (separate method)
  Future<String> _getOpenAIResponse(String userMessage, int age) async {
    const String _baseUrl = 'https://api.openai.com/v1';
    
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
        final aiResponse = data['choices'][0]['message']['content'] as String;

        // Cache successful response
        await _storageService.cacheAPIResponse(userMessage, aiResponse);

        return aiResponse;
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
    } on SocketException {
      print('📡 Network error - using offline mode');
      return _offlineService.getOfflineResponse(userMessage, age: age);
    } on TimeoutException {
      print('⚠️ Request timeout - trying offline mode');
      return _offlineService.getOfflineResponse(userMessage, age: age);
    } catch (e) {
      print('❌ AI Service Error: $e - falling back to offline mode');
      return _offlineService.getOfflineResponse(userMessage, age: age);
    }
  }

  /// Check if currently online
  Future<bool> isOnline() async {
    return await _connectivityService.checkConnectivity();
  }

  /// Get offline service for direct access
  OfflineAIService get offlineService => _offlineService;

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
  Future<Map<String, dynamic>> parseCreatureRequest(String userMessage) async {
    // Content moderation check
    if (!(await ContentModerationService.validateUserInput(userMessage))) {
      throw ContentModerationException(
        ContentModerationService.getModerationReason(userMessage)
      );
    }

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
    if (RegExp(r'\bfox\b').hasMatch(message)) creatureType = 'fox';
    if (RegExp(r'\bwolf\b').hasMatch(message)) creatureType = 'wolf';
    if (RegExp(r'\bbear\b').hasMatch(message)) creatureType = 'bear';
    if (RegExp(r'\brabbit\b').hasMatch(message)) creatureType = 'rabbit';
    if (RegExp(r'\bsquirrel\b').hasMatch(message)) creatureType = 'squirrel';
    if (RegExp(r'\bdeer\b').hasMatch(message)) creatureType = 'deer';
    if (RegExp(r'\bcow\b').hasMatch(message)) creatureType = 'cow';
    if (RegExp(r'\bpig\b').hasMatch(message)) creatureType = 'pig';
    if (message.contains('chicken')) creatureType = 'chicken';
    if (message.contains('sheep')) creatureType = 'sheep';
    if (message.contains('horse')) creatureType = 'horse';
    if (RegExp(r'\bcat\b').hasMatch(message)) creatureType = 'cat';
    if (RegExp(r'\bdog\b').hasMatch(message)) creatureType = 'dog';
    
    // Swedish creature names
    if (message.contains('räv')) creatureType = 'fox';
    if (message.contains('varg')) creatureType = 'wolf';
    if (message.contains('björn')) creatureType = 'bear';
    if (message.contains('kanin')) creatureType = 'rabbit';
    if (message.contains('ekorre')) creatureType = 'squirrel';
    if (message.contains('hjort')) creatureType = 'deer';
    if (message.contains('ko')) creatureType = 'cow';
    if (message.contains('gris')) creatureType = 'pig';
    if (message.contains('höna')) creatureType = 'chicken';
    if (message.contains('får')) creatureType = 'sheep';
    if (message.contains('häst')) creatureType = 'horse';
    if (message.contains('katt')) creatureType = 'cat';
    if (message.contains('hund')) creatureType = 'dog';

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
    
    // Furniture and home items
    if (message.contains('couch') || message.contains('sofa')) creatureType = 'couch';
    if (message.contains('chair')) creatureType = 'chair';
    if (message.contains('table')) creatureType = 'table';
    if (message.contains('bed')) creatureType = 'bed';
    
    // Dragon furniture (special cases)
    String? dragonTheme;
    List<String>? dragonEffects;
    
    if (message.contains('dragon couch') || message.contains('dragon sofa')) {
      creatureType = 'couch';
      dragonTheme = 'dragon';
      dragonEffects = ['dragon', 'fire', 'sparkles'];
    }
    if (message.contains('dragon chair')) {
      creatureType = 'chair';
      dragonTheme = 'dragon';
      dragonEffects = ['dragon', 'wings', 'scales'];
    }
    if (message.contains('dragon table')) {
      creatureType = 'table';
      dragonTheme = 'dragon';
      dragonEffects = ['dragon', 'head', 'scales'];
    }
    if (message.contains('dragon bed')) {
      creatureType = 'bed';
      dragonTheme = 'dragon';
      dragonEffects = ['dragon', 'scales', 'magic'];
    }
    if (message.contains('desk')) creatureType = 'desk';
    if (message.contains('bookshelf')) creatureType = 'bookshelf';
    if (message.contains('lamp')) creatureType = 'lamp';
    if (message.contains('lamp') && message.contains('floor')) creatureType = 'floor_lamp';
    if (message.contains('lamp') && message.contains('table')) creatureType = 'table_lamp';
    if (message.contains('cabinet')) creatureType = 'cabinet';
    if (message.contains('dresser')) creatureType = 'dresser';
    if (message.contains('wardrobe')) creatureType = 'wardrobe';
    if (message.contains('shelf')) creatureType = 'shelf';
    if (message.contains('stool')) creatureType = 'stool';
    if (message.contains('bench')) creatureType = 'bench';
    if (message.contains('ottoman')) creatureType = 'ottoman';
    if (message.contains('armchair')) creatureType = 'armchair';
    if (message.contains('recliner')) creatureType = 'recliner';
    if (message.contains('rocking chair')) creatureType = 'rocking_chair';
    if (message.contains('dining table')) creatureType = 'dining_table';
    if (message.contains('coffee table')) creatureType = 'coffee_table';
    if (message.contains('nightstand')) creatureType = 'nightstand';
    if (message.contains('dresser')) creatureType = 'dresser';
    if (message.contains('chest')) creatureType = 'chest';
    if (message.contains('trunk')) creatureType = 'trunk';
    if (message.contains('mirror')) creatureType = 'mirror';
    if (message.contains('rug')) creatureType = 'rug';
    if (message.contains('carpet')) creatureType = 'carpet';
    if (message.contains('curtain')) creatureType = 'curtain';
    if (message.contains('blinds')) creatureType = 'blinds';
    if (message.contains('plant')) creatureType = 'plant';
    if (message.contains('flower pot')) creatureType = 'flower_pot';
    if (message.contains('vase')) creatureType = 'vase';
    if (message.contains('clock')) creatureType = 'clock';
    if (message.contains('picture') || message.contains('painting')) creatureType = 'picture';
    if (message.contains('frame')) creatureType = 'frame';
    
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
    if (RegExp(r'\bfly\b|\bflies\b|\bflying\b').hasMatch(message)) effects.add('flies');
    if (message.contains('wings') || message.contains('wing')) effects.add('wings');
    if (message.contains('legs') || message.contains('leg')) effects.add('legs');
    if (message.contains('two legs')) effects.add('two legs');
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
    
    // Apply dragon theme and effects if specified
    if (dragonTheme != null) {
      effects.addAll(dragonEffects ?? []);
    }
    
    final attributes = {
      'creatureType': creatureType,
      'color': color,
      'effects': effects,
      'size': size,
      'behavior': behavior,
      'abilities': abilities,
      'theme': dragonTheme,
      'originalMessage': userMessage,
      'timestamp': DateTime.now().toIso8601String(),
      'complexity': _calculateComplexity(effects, abilities),
    };
    
    print('🔍 Parsed attributes for "$userMessage": $attributes');
    
    return attributes;
  }

  /// Generate suggestions after creature creation
  String generateCreationSuggestions(Map<String, dynamic> attributes) {
    final creatureType = attributes['creatureType']?.toString().toLowerCase() ?? 'creature';
    final color = attributes['color']?.toString().toLowerCase() ?? 'rainbow';
    final effects = (attributes['effects'] as List<dynamic>?) ?? [];
    
    // Generate contextual suggestions based on what was created
    if (_isFurniture(creatureType)) {
      return _generateFurnitureSuggestions(creatureType, color, effects);
    } else {
      return _generateCreatureSuggestions(creatureType, color, effects);
    }
  }

  /// Generate suggestions for furniture
  String _generateFurnitureSuggestions(String furnitureType, String color, List<dynamic> effects) {
    final suggestions = <String>[];
    
    // Suggest complementary furniture
    if (furnitureType == 'couch' || furnitureType == 'sofa') {
      suggestions.add('Do you want me to craft a matching $color table too?');
      suggestions.add('Should I make some $color chairs to go with your couch?');
    } else if (furnitureType == 'chair') {
      suggestions.add('Would you like a $color table to go with your chair?');
      suggestions.add('Should I craft a matching $color couch?');
    } else if (furnitureType == 'table') {
      suggestions.add('Do you want some $color chairs around your table?');
      suggestions.add('Should I make a $color lamp for your table?');
    } else if (furnitureType == 'bed') {
      suggestions.add('Would you like a $color nightstand next to your bed?');
      suggestions.add('Should I craft a $color dresser for your room?');
    } else if (furnitureType == 'throne') {
      suggestions.add('Would you like a $color crown to go with your throne?');
      suggestions.add('Should I create a $color royal court around your throne?');
      suggestions.add('How about a $color scepter for your throne?');
    } else if (furnitureType == 'bookshelf') {
      suggestions.add('Would you like a $color desk to go with your bookshelf?');
      suggestions.add('Should I create a $color reading chair?');
      suggestions.add('How about a $color lamp for your bookshelf?');
    } else if (furnitureType == 'lamp') {
      suggestions.add('Would you like a $color table for your lamp?');
      suggestions.add('Should I create a $color nightstand?');
      suggestions.add('How about a $color bookshelf to go with your lamp?');
    } else if (furnitureType == 'chest') {
      suggestions.add('Would you like a $color key for your chest?');
      suggestions.add('Should I create a $color treasure room?');
      suggestions.add('How about a $color lock for your chest?');
    } else if (furnitureType == 'barrel') {
      suggestions.add('Would you like a $color cellar for your barrel?');
      suggestions.add('Should I create a $color storage room?');
      suggestions.add('How about a $color label for your barrel?');
    } else if (furnitureType == 'shelf') {
      suggestions.add('Would you like a $color display case?');
      suggestions.add('Should I create a $color trophy shelf?');
      suggestions.add('How about a $color book collection?');
    }
    
    // Suggest room themes
    if (effects.contains('dragon')) {
      suggestions.add('Would you like me to make your whole room dragon-themed?');
    } else if (effects.contains('sparkles')) {
      suggestions.add('Should I make everything sparkly in your room?');
    }
    
    return suggestions.isNotEmpty ? suggestions.first : 'Would you like me to craft something else?';
  }

  /// Generate suggestions for creatures
  String _generateCreatureSuggestions(String creatureType, String color, List<dynamic> effects) {
    final suggestions = <String>[];
    
    // Suggest friends for the creature
    if (creatureType == 'cat') {
      suggestions.add('Would you like me to create a $color dog to be friends with your cat?');
      suggestions.add('Should I make a $color mouse for your cat to play with?');
      suggestions.add('How about a $color bird for your cat to watch?');
      suggestions.add('Would you like a $color fish tank for your cat?');
    } else if (creatureType == 'dog') {
      suggestions.add('Should I create a $color cat to be friends with your dog?');
      suggestions.add('Would you like a $color ball for your dog to play with?');
      suggestions.add('How about a $color bone for your dog?');
    } else if (creatureType == 'dragon') {
      suggestions.add('Would you like me to create a $color castle for your dragon?');
      suggestions.add('Should I make a $color treasure chest for your dragon?');
      suggestions.add('How about a $color knight to protect your dragon?');
    } else if (creatureType == 'unicorn') {
      suggestions.add('Would you like a $color rainbow for your unicorn?');
      suggestions.add('Should I create a $color fairy to be friends with your unicorn?');
      suggestions.add('How about a $color magical forest for your unicorn?');
    } else if (creatureType == 'bird') {
      suggestions.add('Would you like me to create a $color nest for your bird?');
      suggestions.add('Should I make a $color tree for your bird to sit in?');
      suggestions.add('How about a $color birdhouse for your bird?');
    } else if (creatureType == 'fish') {
      suggestions.add('Would you like a $color aquarium for your fish?');
      suggestions.add('Should I create a $color coral reef for your fish?');
      suggestions.add('How about a $color treasure chest in your fish tank?');
    } else if (creatureType == 'fox') {
      suggestions.add('Would you like a $color den for your fox?');
      suggestions.add('Should I create a $color forest for your fox to play in?');
      suggestions.add('How about a $color friend for your fox?');
    } else if (creatureType == 'wolf') {
      suggestions.add('Would you like a $color pack of wolves?');
      suggestions.add('Should I create a $color mountain for your wolf?');
      suggestions.add('How about a $color moon for your wolf to howl at?');
    } else if (creatureType == 'bear') {
      suggestions.add('Would you like a $color cave for your bear?');
      suggestions.add('Should I create a $color forest for your bear?');
      suggestions.add('How about a $color honey pot for your bear?');
    } else if (creatureType == 'rabbit') {
      suggestions.add('Would you like a $color burrow for your rabbit?');
      suggestions.add('Should I create a $color garden for your rabbit?');
      suggestions.add('How about a $color carrot patch for your rabbit?');
    } else if (creatureType == 'squirrel') {
      suggestions.add('Would you like a $color tree for your squirrel?');
      suggestions.add('Should I create a $color nut stash for your squirrel?');
      suggestions.add('How about a $color forest for your squirrel?');
    } else if (creatureType == 'deer') {
      suggestions.add('Would you like a $color forest for your deer?');
      suggestions.add('Should I create a $color meadow for your deer?');
      suggestions.add('How about a $color stream for your deer?');
    } else {
      // Generic suggestions for other creatures
      suggestions.add('Would you like me to create a $color friend for your $creatureType?');
      suggestions.add('Should I make a $color home for your $creatureType?');
      suggestions.add('How about a $color toy for your $creatureType?');
    }
    
    // Suggest based on effects
    if (effects.contains('wings')) {
      suggestions.add('Would you like me to create a $color sky for your flying $creatureType?');
    }
    if (effects.contains('fire')) {
      suggestions.add('Should I make a $color volcano for your fire $creatureType?');
    }
    if (effects.contains('ice')) {
      suggestions.add('Would you like a $color ice palace for your ice $creatureType?');
    }
    if (effects.contains('sparkles')) {
      suggestions.add('Should I create a $color magical garden for your sparkly $creatureType?');
    }
    
    return suggestions.isNotEmpty ? suggestions.first : 'Would you like me to create something else?';
  }

  /// Check if the creature type is furniture
  bool _isFurniture(String creatureType) {
    const furnitureTypes = [
      'couch', 'sofa', 'chair', 'table', 'bed', 'desk', 'bookshelf',
      'lamp', 'floor_lamp', 'table_lamp', 'cabinet', 'dresser', 'wardrobe',
      'shelf', 'stool', 'bench', 'ottoman', 'armchair', 'recliner',
      'rocking_chair', 'dining_table', 'coffee_table', 'nightstand',
      'chest', 'trunk', 'mirror', 'rug', 'carpet', 'curtain', 'blinds',
      'plant', 'flower_pot', 'vase', 'clock', 'picture', 'frame'
    ];
    return furnitureTypes.contains(creatureType.toLowerCase());
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
