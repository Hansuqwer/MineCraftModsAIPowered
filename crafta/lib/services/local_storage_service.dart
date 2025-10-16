import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Local storage service for caching data offline
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  /// Storage keys
  static const String _creaturesKey = 'creatures';
  static const String _conversationsKey = 'conversations';
  static const String _settingsKey = 'settings';
  static const String _cacheKey = 'api_cache';

  /// Get application documents directory
  Future<Directory> get _documentsDir async {
    return await getApplicationDocumentsDirectory();
  }

  /// Get file for key
  Future<File> _getFile(String key) async {
    final dir = await _documentsDir;
    return File('${dir.path}/$key.json');
  }

  /// Save data to local storage
  Future<bool> saveData(String key, Map<String, dynamic> data) async {
    try {
      final file = await _getFile(key);
      final jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);
      return true;
    } catch (e) {
      print('Error saving data for key $key: $e');
      return false;
    }
  }

  /// Load data from local storage
  Future<Map<String, dynamic>?> loadData(String key) async {
    try {
      final file = await _getFile(key);

      if (!await file.exists()) {
        return null;
      }

      final jsonString = await file.readAsString();
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error loading data for key $key: $e');
      return null;
    }
  }

  /// Delete data from local storage
  Future<bool> deleteData(String key) async {
    try {
      final file = await _getFile(key);

      if (await file.exists()) {
        await file.delete();
      }

      return true;
    } catch (e) {
      print('Error deleting data for key $key: $e');
      return false;
    }
  }

  /// Check if data exists
  Future<bool> hasData(String key) async {
    try {
      final file = await _getFile(key);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Save creature to local storage
  Future<bool> saveCreature(Map<String, dynamic> creature) async {
    try {
      final creatures = await loadCreatures();
      creatures.add(creature);

      return await saveData(_creaturesKey, {
        'creatures': creatures,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving creature: $e');
      return false;
    }
  }

  /// Load all creatures
  Future<List<Map<String, dynamic>>> loadCreatures() async {
    try {
      final data = await loadData(_creaturesKey);

      if (data == null || !data.containsKey('creatures')) {
        return [];
      }

      final creatures = data['creatures'] as List;
      return creatures.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error loading creatures: $e');
      return [];
    }
  }

  /// Get creature by ID
  Future<Map<String, dynamic>?> getCreature(String id) async {
    try {
      final creatures = await loadCreatures();
      return creatures.firstWhere(
        (c) => c['id'] == id,
        orElse: () => {},
      );
    } catch (e) {
      print('Error getting creature: $e');
      return null;
    }
  }

  /// Delete creature by ID
  Future<bool> deleteCreature(String id) async {
    try {
      final creatures = await loadCreatures();
      creatures.removeWhere((c) => c['id'] == id);

      return await saveData(_creaturesKey, {
        'creatures': creatures,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error deleting creature: $e');
      return false;
    }
  }

  /// Save conversation history
  Future<bool> saveConversation(Map<String, dynamic> conversation) async {
    try {
      final conversations = await loadConversations();
      conversations.add(conversation);

      // Keep only last 50 conversations
      if (conversations.length > 50) {
        conversations.removeRange(0, conversations.length - 50);
      }

      return await saveData(_conversationsKey, {
        'conversations': conversations,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving conversation: $e');
      return false;
    }
  }

  /// Load conversation history
  Future<List<Map<String, dynamic>>> loadConversations() async {
    try {
      final data = await loadData(_conversationsKey);

      if (data == null || !data.containsKey('conversations')) {
        return [];
      }

      final conversations = data['conversations'] as List;
      return conversations.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error loading conversations: $e');
      return [];
    }
  }

  /// Clear conversation history
  Future<bool> clearConversations() async {
    return await deleteData(_conversationsKey);
  }

  /// Save app settings
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    return await saveData(_settingsKey, settings);
  }

  /// Load app settings
  Future<Map<String, dynamic>?> loadSettings() async {
    return await loadData(_settingsKey);
  }

  /// Cache API response
  Future<bool> cacheAPIResponse(String key, String response) async {
    try {
      final cache = await _loadCache();
      cache[key] = {
        'response': response,
        'timestamp': DateTime.now().toIso8601String(),
      };

      return await saveData(_cacheKey, cache);
    } catch (e) {
      print('Error caching API response: $e');
      return false;
    }
  }

  /// Get cached API response
  Future<String?> getCachedAPIResponse(String key, {Duration maxAge = const Duration(hours: 1)}) async {
    try {
      final cache = await _loadCache();

      if (!cache.containsKey(key)) {
        return null;
      }

      final entry = cache[key];
      final timestamp = DateTime.parse(entry['timestamp'] as String);

      // Check if cache is still valid
      if (DateTime.now().difference(timestamp) > maxAge) {
        return null;
      }

      return entry['response'] as String;
    } catch (e) {
      print('Error getting cached response: $e');
      return null;
    }
  }

  /// Load cache
  Future<Map<String, dynamic>> _loadCache() async {
    final data = await loadData(_cacheKey);
    return data ?? {};
  }

  /// Clear cache
  Future<bool> clearCache() async {
    return await deleteData(_cacheKey);
  }

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final creatures = await loadCreatures();
      final conversations = await loadConversations();
      final cache = await _loadCache();

      return {
        'creatures': creatures.length,
        'conversations': conversations.length,
        'cached_responses': cache.length,
        'has_settings': await hasData(_settingsKey),
      };
    } catch (e) {
      print('Error getting storage stats: $e');
      return {};
    }
  }

  /// Clear all data
  Future<bool> clearAll() async {
    try {
      await deleteData(_creaturesKey);
      await deleteData(_conversationsKey);
      await deleteData(_settingsKey);
      await deleteData(_cacheKey);
      return true;
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }

  /// Export all data as JSON
  Future<String?> exportAllData() async {
    try {
      final data = {
        'creatures': await loadCreatures(),
        'conversations': await loadConversations(),
        'settings': await loadSettings(),
        'exportDate': DateTime.now().toIso8601String(),
      };

      return jsonEncode(data);
    } catch (e) {
      print('Error exporting data: $e');
      return null;
    }
  }

  /// Import data from JSON
  Future<bool> importData(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (data.containsKey('creatures')) {
        await saveData(_creaturesKey, {'creatures': data['creatures']});
      }

      if (data.containsKey('conversations')) {
        await saveData(_conversationsKey, {'conversations': data['conversations']});
      }

      if (data.containsKey('settings')) {
        await saveSettings(data['settings'] as Map<String, dynamic>);
      }

      return true;
    } catch (e) {
      print('Error importing data: $e');
      return false;
    }
  }
}
