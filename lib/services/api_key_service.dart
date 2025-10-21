import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service for managing OpenAI API keys securely
///
/// Stores API keys in secure storage and provides validation
class ApiKeyService {
  static final ApiKeyService _instance = ApiKeyService._internal();
  factory ApiKeyService() => _instance;
  ApiKeyService._internal();

  // Secure storage instance
  final _storage = const FlutterSecureStorage();

  // Storage keys
  static const String _apiKeyStorageKey = 'openai_api_key';
  static const String _apiProviderStorageKey = 'ai_provider'; // openai, groq, etc.

  // Cached values
  String? _cachedApiKey;
  String? _cachedProvider;

  /// Save API key to secure storage
  ///
  /// [key] - The OpenAI API key
  /// [provider] - The AI provider (default: 'openai')
  Future<void> saveApiKey(String key, {String provider = 'openai'}) async {
    try {
      await _storage.write(key: _apiKeyStorageKey, value: key);
      await _storage.write(key: _apiProviderStorageKey, value: provider);

      // Update cache
      _cachedApiKey = key;
      _cachedProvider = provider;

      print('✅ [API_KEY_SERVICE] API key saved successfully');
    } catch (e) {
      print('❌ [API_KEY_SERVICE] Error saving API key: $e');
      rethrow;
    }
  }

  /// Load API key from secure storage
  ///
  /// Returns null if no key is stored
  Future<String?> getApiKey() async {
    try {
      final key = await _storage.read(key: _apiKeyStorageKey);
      _cachedApiKey = key;

      if (key != null && key.isNotEmpty) {
        print('✅ [API_KEY_SERVICE] API key loaded from storage: ${key.substring(0, 7)}...');
        return key;
      } else {
        print('⚠️ [API_KEY_SERVICE] No API key found in storage');
        return null;
      }
    } catch (e) {
      print('❌ [API_KEY_SERVICE] Error loading API key: $e');
      return null;
    }
  }

  /// Get the current AI provider
  ///
  /// Returns 'openai' by default
  Future<String> getProvider() async {
    // Return cached value if available
    if (_cachedProvider != null) {
      return _cachedProvider!;
    }

    try {
      final provider = await _storage.read(key: _apiProviderStorageKey);
      _cachedProvider = provider ?? 'openai';
      return _cachedProvider!;
    } catch (e) {
      print('❌ [API_KEY_SERVICE] Error loading provider: $e');
      return 'openai';
    }
  }

  /// Remove API key from secure storage
  Future<void> removeApiKey() async {
    try {
      await _storage.delete(key: _apiKeyStorageKey);
      await _storage.delete(key: _apiProviderStorageKey);

      // Clear cache
      _cachedApiKey = null;
      _cachedProvider = null;

      print('✅ [API_KEY_SERVICE] API key removed');
    } catch (e) {
      print('❌ [API_KEY_SERVICE] Error removing API key: $e');
      rethrow;
    }
  }

  /// Check if an API key exists in storage
  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Validate an OpenAI API key by making a test request
  ///
  /// [key] - The API key to validate
  /// Returns true if the key is valid, false otherwise
  Future<bool> validateApiKey(String key) async {
    if (key.isEmpty) {
      print('❌ [API_KEY_SERVICE] Empty API key provided');
      return false;
    }

    // Basic format check for OpenAI keys
    if (!key.startsWith('sk-')) {
      print('❌ [API_KEY_SERVICE] Invalid key format (should start with sk-)');
      return false;
    }

    try {
      print('🔍 [API_KEY_SERVICE] Validating API key...');

      // Make a minimal API call to test the key
      final response = await http.get(
        Uri.parse('https://api.openai.com/v1/models'),
        headers: {
          'Authorization': 'Bearer $key',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('✅ [API_KEY_SERVICE] API key is valid');
        return true;
      } else if (response.statusCode == 401) {
        print('❌ [API_KEY_SERVICE] API key is invalid (401 Unauthorized)');
        return false;
      } else {
        print('⚠️ [API_KEY_SERVICE] Unexpected response: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ [API_KEY_SERVICE] Error validating API key: $e');
      return false;
    }
  }

  /// Get API key status information
  ///
  /// Returns a map with status details:
  /// - hasKey: bool
  /// - keyPrefix: String (first 7 chars)
  /// - provider: String
  Future<Map<String, dynamic>> getKeyStatus() async {
    final hasKey = await hasApiKey();
    final key = await getApiKey();
    final provider = await getProvider();

    String keyPrefix = '';
    if (key != null && key.length > 7) {
      keyPrefix = '${key.substring(0, 7)}...';
    }

    return {
      'hasKey': hasKey,
      'keyPrefix': keyPrefix,
      'provider': provider,
    };
  }

  /// Clear the cache (useful for testing)
  void clearCache() {
    _cachedApiKey = null;
    _cachedProvider = null;
  }
}
