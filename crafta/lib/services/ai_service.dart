import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey = 'YOUR_OPENAI_API_KEY'; // Replace with actual key
  static const String _baseUrl = 'https://api.openai.com/v1';
  
  /// Send a message to GPT-4o-mini and get Crafta's response
  Future<String> getCraftaResponse(String userMessage) async {
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
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'Hmm, I didn\'t quite catch that. Can you tell me again?';
      }
    } catch (e) {
      print('AI Service Error: $e');
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
    
    // Determine creature type
    String creatureType = 'cow'; // default
    if (message.contains('pig')) creatureType = 'pig';
    if (message.contains('chicken')) creatureType = 'chicken';
    
    // Determine color
    String color = 'rainbow'; // default
    if (message.contains('pink')) color = 'pink';
    if (message.contains('blue')) color = 'blue';
    if (message.contains('gold')) color = 'gold';
    
    // Determine effects
    List<String> effects = [];
    if (message.contains('sparkle')) effects.add('sparkles');
    if (message.contains('glow')) effects.add('glows');
    if (message.contains('fly')) effects.add('flies');
    
    // Determine size
    String size = 'normal'; // default
    if (message.contains('tiny') || message.contains('small')) size = 'tiny';
    if (message.contains('huge') || message.contains('big') || message.contains('large')) size = 'big';
    
    return {
      'creatureType': creatureType,
      'color': color,
      'effects': effects,
      'size': size,
      'originalMessage': userMessage,
    };
  }
}
