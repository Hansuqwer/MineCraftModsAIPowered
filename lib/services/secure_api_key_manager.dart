import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure API Key Manager
/// Handles API keys securely using environment variables and secure storage
class SecureAPIKeyManager {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Initialize the key manager
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  /// Get API key with fallback to secure storage
  static Future<String?> getAPIKey(String keyName) async {
    try {
      // First try environment variables (development)
      final envKey = dotenv.env[keyName];
      if (envKey != null && envKey.isNotEmpty && !envKey.contains('your_')) {
        return envKey;
      }

      // Fallback to secure storage (production)
      final secureKey = await _storage.read(key: keyName);
      if (secureKey != null && secureKey.isNotEmpty) {
        return secureKey;
      }

      return null;
    } catch (e) {
      // Log error in production, use debug print in development
      assert(() {
        print('Error getting API key $keyName: $e');
        return true;
      }());
      return null;
    }
  }

  /// Store API key securely
  static Future<void> storeAPIKey(String keyName, String apiKey) async {
    try {
      await _storage.write(key: keyName, value: apiKey);
    } catch (e) {
      // Log error in production, use debug print in development
      assert(() {
        print('Error storing API key $keyName: $e');
        return true;
      }());
    }
  }

  /// Check if API key is available
  static Future<bool> hasAPIKey(String keyName) async {
    final key = await getAPIKey(keyName);
    return key != null && key.isNotEmpty && !key.contains('your_');
  }

  /// Get all available API keys
  static Future<Map<String, String?>> getAllAPIKeys() async {
    final keys = <String, String?>{};
    
    final keyNames = [
      'OPENAI_API_KEY',
      'GROQ_API_KEY', 
      'HUGGINGFACE_API_KEY',
    ];

    for (final keyName in keyNames) {
      keys[keyName] = await getAPIKey(keyName);
    }

    return keys;
  }

  /// Validate API key format
  static bool isValidAPIKey(String keyName, String? apiKey) {
    if (apiKey == null || apiKey.isEmpty || apiKey.contains('your_')) {
      return false;
    }

    switch (keyName) {
      case 'OPENAI_API_KEY':
        return apiKey.startsWith('sk-');
      case 'GROQ_API_KEY':
        return apiKey.startsWith('gsk_');
      case 'HUGGINGFACE_API_KEY':
        return apiKey.startsWith('hf_');
      default:
        return apiKey.length > 10;
    }
  }

  /// Get API key status for UI
  static Future<Map<String, APIKeyStatus>> getAPIKeyStatus() async {
    final status = <String, APIKeyStatus>{};
    final keys = await getAllAPIKeys();

    for (final entry in keys.entries) {
      final keyName = entry.key;
      final apiKey = entry.value;

      if (apiKey == null || apiKey.isEmpty) {
        status[keyName] = APIKeyStatus.notSet;
      } else if (apiKey.contains('your_')) {
        status[keyName] = APIKeyStatus.placeholder;
      } else if (!isValidAPIKey(keyName, apiKey)) {
        status[keyName] = APIKeyStatus.invalid;
      } else {
        status[keyName] = APIKeyStatus.valid;
      }
    }

    return status;
  }

  /// Clear all stored API keys
  static Future<void> clearAllKeys() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      // Log error in production, use debug print in development
      assert(() {
        print('Error clearing API keys: $e');
        return true;
      }());
    }
  }
}

/// API Key Status enum
enum APIKeyStatus {
  notSet,
  placeholder,
  invalid,
  valid,
}

/// Extension for APIKeyStatus
extension APIKeyStatusExtension on APIKeyStatus {
  String get displayName {
    switch (this) {
      case APIKeyStatus.notSet:
        return 'Not Set';
      case APIKeyStatus.placeholder:
        return 'Placeholder';
      case APIKeyStatus.invalid:
        return 'Invalid';
      case APIKeyStatus.valid:
        return 'Valid';
    }
  }

  String get description {
    switch (this) {
      case APIKeyStatus.notSet:
        return 'API key not configured';
      case APIKeyStatus.placeholder:
        return 'Please set your API key';
      case APIKeyStatus.invalid:
        return 'API key format is invalid';
      case APIKeyStatus.valid:
        return 'API key is ready to use';
    }
  }

  bool get isReady => this == APIKeyStatus.valid;
}
