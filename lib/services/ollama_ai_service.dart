import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'offline_ai_service.dart';

/// Ollama AI Service - Free local AI
/// Runs AI models locally on your device
class OllamaAIService {
  static const String _baseUrl = 'http://localhost:11434';
  static const String _model = 'llama2'; // or 'mistral', 'codellama', etc.
  
  /// Offline fallback service
  final OfflineAIService _offlineService = OfflineAIService();
  
  /// Check if Ollama is running
  Future<bool> isOllamaRunning() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tags'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 2));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Get Crafta's response using Ollama
  Future<String> getCraftaResponse(String userMessage, {int age = 6}) async {
    // Check if Ollama is running
    final isRunning = await isOllamaRunning();
    
    if (!isRunning) {
      print('🔄 Ollama not running, using offline mode');
      return _offlineService.getOfflineResponse(userMessage, age: age);
    }
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _model,
          'prompt': _getCraftaPrompt(userMessage, age),
          'stream': false,
          'options': {
            'temperature': 0.7,
            'top_p': 0.9,
            'max_tokens': 150,
          }
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['response'] as String;
        
        // Clean up the response
        return _cleanResponse(aiResponse);
      } else {
        print('⚠️ Ollama error: ${response.statusCode}');
        return _offlineService.getOfflineResponse(userMessage, age: age);
      }
    } catch (e) {
      print('🔄 Ollama error: $e, using offline mode');
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
  
  /// Install Ollama (for setup instructions)
  static String getInstallInstructions() {
    if (Platform.isWindows) {
      return '''
Windows Setup:
1. Download Ollama from https://ollama.ai/download
2. Install and run Ollama
3. Open Command Prompt and run: ollama pull llama2
4. Restart the app
''';
    } else if (Platform.isMacOS) {
      return '''
macOS Setup:
1. Download Ollama from https://ollama.ai/download
2. Install and run Ollama
3. Open Terminal and run: ollama pull llama2
4. Restart the app
''';
    } else {
      return '''
Linux Setup:
1. Run: curl -fsSL https://ollama.ai/install.sh | sh
2. Run: ollama pull llama2
3. Restart the app
''';
    }
  }
}


