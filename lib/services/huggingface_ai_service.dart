import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'offline_ai_service.dart';

/// Hugging Face AI Service - Free cloud AI
/// Uses Hugging Face Inference API with free tier
class HuggingFaceAIService {
  static const String _baseUrl = 'https://api-inference.huggingface.co/models';
  static const String _model = 'microsoft/DialoGPT-medium'; // Free model
  static const String _apiKey = 'YOUR_HUGGINGFACE_API_KEY'; // Get from https://huggingface.co/settings/tokens
  
  /// Offline fallback service
  final OfflineAIService _offlineService = OfflineAIService();
  
  /// Get Crafta's response using Hugging Face
  Future<String> getCraftaResponse(String userMessage, {int age = 6}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$_model'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'inputs': _getCraftaPrompt(userMessage, age),
          'parameters': {
            'max_length': 150,
            'temperature': 0.7,
            'top_p': 0.9,
            'do_sample': true,
          }
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is List && data.isNotEmpty) {
          final generatedText = data[0]['generated_text'] as String;
          return _cleanResponse(generatedText);
        } else {
          return _offlineService.getOfflineResponse(userMessage, age: age);
        }
      } else if (response.statusCode == 429) {
        print('⚠️ Hugging Face rate limit exceeded');
        return 'Let\'s take a little break and try again soon!';
      } else {
        print('⚠️ Hugging Face error: ${response.statusCode}');
        return _offlineService.getOfflineResponse(userMessage, age: age);
      }
    } catch (e) {
      print('🔄 Hugging Face error: $e, using offline mode');
      return _offlineService.getOfflineResponse(userMessage, age: age);
    }
  }
  
  /// Get system prompt for Crafta
  String _getCraftaPrompt(String userMessage, int age) {
    return '''
You are Crafta, a friendly AI assistant that helps kids create creatures and furniture for Minecraft. 

User (age $age): $userMessage

Crafta: [Respond as Crafta - be enthusiastic, creative, and age-appropriate. Keep responses under 100 words. Focus on what they want to create and be encouraging.]''';
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
Hugging Face Setup:
1. Go to https://huggingface.co/settings/tokens
2. Create a free account
3. Generate a new token
4. Replace YOUR_HUGGINGFACE_API_KEY in the code
5. Restart the app

Free Tier: 1,000 requests/month
''';
  }
}


