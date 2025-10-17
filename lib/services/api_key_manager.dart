import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages API keys for different AI services
class APIKeyManager {
  static const String _groqKey = 'groq_api_key';
  static const String _huggingfaceKey = 'huggingface_api_key';
  static const String _openaiKey = 'openai_api_key';
  
  /// Get stored API key for a service
  static Future<String?> getAPIKey(String service) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${service}_api_key');
  }
  
  /// Store API key for a service
  static Future<void> setAPIKey(String service, String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${service}_api_key', key);
  }
  
  /// Check if user has configured any API keys
  static Future<bool> hasAnyAPIKeys() async {
    final groq = await getAPIKey('groq');
    final hf = await getAPIKey('huggingface');
    final openai = await getAPIKey('openai');
    
    return groq != null || hf != null || openai != null;
  }
  
  /// Get setup status for all services
  static Future<Map<String, bool>> getSetupStatus() async {
    return {
      'groq': (await getAPIKey('groq')) != null,
      'huggingface': (await getAPIKey('huggingface')) != null,
      'openai': (await getAPIKey('openai')) != null,
      'ollama': false, // Always false, requires local installation
    };
  }
  
  /// Get setup instructions for a service
  static String getSetupInstructions(String service) {
    switch (service) {
      case 'groq':
        return '''
Groq Setup (Free & Fast):
1. Go to https://console.groq.com/keys
2. Create a free account
3. Generate a new API key
4. Paste it in the app

Free Tier: 14,400 requests/day
''';
      case 'huggingface':
        return '''
Hugging Face Setup (Free):
1. Go to https://huggingface.co/settings/tokens
2. Create a free account
3. Generate a new token
4. Paste it in the app

Free Tier: 1,000 requests/month
''';
      case 'openai':
        return '''
OpenAI Setup (Paid):
1. Go to https://platform.openai.com/api-keys
2. Create an account
3. Add payment method
4. Generate an API key
5. Paste it in the app

Cost: ~\$0.002 per request
''';
      case 'ollama':
        return '''
Ollama Setup (Free Local AI):
1. Download from https://ollama.ai/download
2. Install and run Ollama
3. Open terminal and run: ollama pull llama2
4. Restart the app

Runs locally on your device
''';
      default:
        return 'Unknown service';
    }
  }
  
  /// Get recommended setup order for new users
  static List<String> getRecommendedSetupOrder() {
    return [
      'groq',        // Fastest and most generous free tier
      'huggingface', // Good free tier
      'ollama',      // Free local option
      'openai',      // Paid but most reliable
    ];
  }
}
