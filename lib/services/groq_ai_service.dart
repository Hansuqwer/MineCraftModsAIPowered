import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'offline_ai_service.dart';
import 'secure_api_key_manager.dart';
import 'error_handling_service.dart';

/// Groq AI Service - Fast and free cloud AI
/// Uses Groq API with free tier (14,400 requests/day)
class GroqAIService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const String _model = 'llama2-70b-4096'; // Fast model
  
  /// Offline fallback service
  final OfflineAIService _offlineService = OfflineAIService();
  
  /// Get Crafta's response using Groq
  Future<String> getCraftaResponse(String userMessage, {int age = 6}) async {
    try {
      // Get API key securely
      final apiKey = await SecureAPIKeyManager.getAPIKey('GROQ_API_KEY');
      if (apiKey == null) {
        print('⚠️ Groq API key not configured, using offline mode');
        return _offlineService.getOfflineResponse(userMessage, age: age);
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': _getSystemPrompt(age),
            },
            {
              'role': 'user',
              'content': userMessage,
            },
          ],
          'max_tokens': 150,
          'temperature': 0.7,
          'top_p': 0.9,
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'] as String;
        
        return _cleanResponse(aiResponse);
      } else if (response.statusCode == 429) {
        ErrorHandlingService().handleAIError('Rate limit exceeded', context: 'Groq API');
        return 'Let\'s take a little break and try again soon!';
      } else {
        ErrorHandlingService().handleAIError('HTTP ${response.statusCode}', context: 'Groq API');
        return _offlineService.getOfflineResponse(userMessage, age: age);
      }
    } catch (e) {
      ErrorHandlingService().handleAIError(e, context: 'Groq API');
      return _offlineService.getOfflineResponse(userMessage, age: age);
    }
  }
  
  /// Get system prompt for Crafta
  String _getSystemPrompt(int age) {
    return '''
You are Crafta, a friendly AI assistant that helps kids create creatures and furniture for Minecraft. 

You are talking to a $age-year-old child. Be enthusiastic, creative, and age-appropriate. Keep responses under 100 words. Focus on what they want to create and be encouraging.

Examples:
- "I want a dragon" → "Wow! A dragon sounds amazing! What color should it be?"
- "I want a couch" → "Great idea! A couch for your Minecraft house! What color would you like?"
- "I want a rainbow unicorn" → "A rainbow unicorn! That's so magical! Let me create that for you!"
''';
  }
  
  /// Clean up AI response
  String _cleanResponse(String response) {
    // Remove any "Crafta:" prefixes
    response = response.replaceAll(RegExp(r'^Crafta:\s*'), '');
    
    // Remove any trailing punctuation issues
    response = response.trim();
    
    // Ensure it ends with proper punctuation
    if (!response.endsWith('.') && !response.endsWith('!') && !response.endsWith('?')) {
      response += '!';
    }
    
    return response;
  }
  
  /// Get setup instructions
  static String getSetupInstructions() {
    return '''
Groq Setup:
1. Go to https://console.groq.com/keys
2. Create a free account
3. Generate a new API key
4. Replace YOUR_GROQ_API_KEY in the code
5. Restart the app

Free Tier: 14,400 requests/day (very generous!)
''';
  }
}
