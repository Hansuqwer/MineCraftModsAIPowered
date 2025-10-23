import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './api_key_service.dart';

/// AI Content Generator - Converts natural language to structured 3D model descriptions
class AIContentGenerator {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  /// Process natural language input and return structured model description
  static Future<ModelBlueprint> processInput(String userInput) async {
    print('🧠 [AI_CONTENT] Processing: "$userInput"');

    try {
      // Get API key
      final apiKeyService = ApiKeyService();
      final apiKey = await apiKeyService.getApiKey();
      
      if (apiKey == null || apiKey.isEmpty) {
        print('⚠️ [AI_CONTENT] No API key, using fallback');
        return _getFallbackBlueprint(userInput);
      }

      // Make API call
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
              'content': _getSystemPrompt(),
            },
            {
              'role': 'user',
              'content': userInput,
            },
          ],
          'temperature': 0.3,
          'max_tokens': 500,
          'response_format': {'type': 'json_object'},
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        print('✅ [AI_CONTENT] AI response received');
        return _parseAIResponse(content, userInput);
      } else {
        print('❌ [AI_CONTENT] API error: ${response.statusCode}');
        return _getFallbackBlueprint(userInput);
      }
    } catch (e) {
      print('❌ [AI_CONTENT] Error: $e');
      return _getFallbackBlueprint(userInput);
    }
  }

  static String _getSystemPrompt() {
    return '''
You are a 3D model generator for Minecraft-style creations. Convert natural language into structured JSON.

Output ONLY valid JSON with this exact structure:
{
  "object": "string",           // Main object type: "couch", "sword", "dragon", "chair", "table", "house", "car"
  "theme": "string",            // Visual theme: "dragon", "ocean", "fairy", "space", "medieval", "modern"
  "color_scheme": ["string"],   // Array of colors: ["red", "blue", "gold"]
  "material": "string",         // Material type: "wood", "metal", "leather", "stone", "crystal"
  "style": "string",            // Style: "minecraft_blocky", "smooth", "detailed"
  "size": "string",             // Size: "small", "medium", "large", "giant"
  "special_features": ["string"], // Special features: ["glowing", "flying", "magical", "ancient"]
  "description": "string"       // One-sentence description
}

EXAMPLES:

Input: "I want a couch with a dragon cover"
Output:
{
  "object": "couch",
  "theme": "dragon",
  "color_scheme": ["red", "black", "gold"],
  "material": "leather",
  "style": "minecraft_blocky",
  "size": "medium",
  "special_features": ["glowing"],
  "description": "A red leather couch with dragon-themed covers and glowing accents"
}

Input: "Make me a magical sword"
Output:
{
  "object": "sword",
  "theme": "magical",
  "color_scheme": ["blue", "silver", "purple"],
  "material": "crystal",
  "style": "detailed",
  "size": "medium",
  "special_features": ["glowing", "magical"],
  "description": "A magical crystal sword with blue and purple glowing effects"
}

Input: "Create a flying dragon"
Output:
{
  "object": "dragon",
  "theme": "dragon",
  "color_scheme": ["red", "gold", "black"],
  "material": "scales",
  "style": "detailed",
  "size": "large",
  "special_features": ["flying", "glowing"],
  "description": "A large red dragon with golden scales and glowing eyes"
}

Remember: ONLY JSON output, nothing else!
''';
  }

  static ModelBlueprint _parseAIResponse(String content, String userInput) {
    try {
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      
      if (jsonStart == -1 || jsonEnd == 0) {
        throw Exception('No JSON found in response');
      }

      final jsonString = content.substring(jsonStart, jsonEnd);
      final data = jsonDecode(jsonString);

      return ModelBlueprint(
        object: data['object'] ?? 'creature',
        theme: data['theme'] ?? 'basic',
        colorScheme: List<String>.from(data['color_scheme'] ?? ['blue']),
        material: data['material'] ?? 'basic',
        style: data['style'] ?? 'minecraft_blocky',
        size: data['size'] ?? 'medium',
        specialFeatures: List<String>.from(data['special_features'] ?? []),
        description: data['description'] ?? 'AI-generated creation',
      );
    } catch (e) {
      print('❌ [AI_CONTENT] Parse error: $e');
      return _getFallbackBlueprint(userInput);
    }
  }

  static ModelBlueprint _getFallbackBlueprint(String userInput) {
    final lower = userInput.toLowerCase();
    
    String object = 'creature';
    String theme = 'basic';
    List<String> colorScheme = ['blue'];
    String material = 'basic';
    List<String> specialFeatures = [];

    // Detect object type
    if (lower.contains('couch') || lower.contains('sofa')) {
      object = 'couch';
    } else if (lower.contains('sword') || lower.contains('weapon')) {
      object = 'sword';
    } else if (lower.contains('dragon')) {
      object = 'dragon';
    } else if (lower.contains('chair')) {
      object = 'chair';
    } else if (lower.contains('table')) {
      object = 'table';
    } else if (lower.contains('house') || lower.contains('home')) {
      object = 'house';
    } else if (lower.contains('car') || lower.contains('vehicle')) {
      object = 'car';
    }

    // Detect theme
    if (lower.contains('dragon')) {
      theme = 'dragon';
      colorScheme = ['red', 'black', 'gold'];
    } else if (lower.contains('magic') || lower.contains('magical')) {
      theme = 'magical';
      colorScheme = ['blue', 'purple', 'silver'];
      specialFeatures.add('glowing');
    } else if (lower.contains('ocean') || lower.contains('sea')) {
      theme = 'ocean';
      colorScheme = ['blue', 'cyan', 'white'];
    }

    // Detect colors
    if (lower.contains('red')) {
      colorScheme = ['red', 'darkred', 'gold'];
    } else if (lower.contains('blue')) {
      colorScheme = ['blue', 'lightblue', 'white'];
    } else if (lower.contains('green')) {
      colorScheme = ['green', 'darkgreen', 'gold'];
    }

    // Detect special features
    if (lower.contains('glow') || lower.contains('glowing')) {
      specialFeatures.add('glowing');
    }
    if (lower.contains('fly') || lower.contains('flying')) {
      specialFeatures.add('flying');
    }
    if (lower.contains('magic') || lower.contains('magical')) {
      specialFeatures.add('magical');
    }

    return ModelBlueprint(
      object: object,
      theme: theme,
      colorScheme: colorScheme,
      material: material,
      style: 'minecraft_blocky',
      size: 'medium',
      specialFeatures: specialFeatures,
      description: 'AI-generated $object with $theme theme',
    );
  }
}

/// Structured model description for 3D generation
class ModelBlueprint {
  final String object;
  final String theme;
  final List<String> colorScheme;
  final String material;
  final String style;
  final String size;
  final List<String> specialFeatures;
  final String description;

  ModelBlueprint({
    required this.object,
    required this.theme,
    required this.colorScheme,
    required this.material,
    required this.style,
    required this.size,
    required this.specialFeatures,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'object': object,
      'theme': theme,
      'colorScheme': colorScheme,
      'material': material,
      'style': style,
      'size': size,
      'specialFeatures': specialFeatures,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'ModelBlueprint(object: $object, theme: $theme, colors: $colorScheme, features: $specialFeatures)';
  }
}
