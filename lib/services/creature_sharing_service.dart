import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service for sharing creatures via cloud with share codes
class CreatureSharingService {
  static const String _baseUrl = 'https://api.crafta.app'; // Placeholder URL
  static const String _storageKey = 'crafta_shared_creatures';
  
  /// Share a creature and get a share code
  static Future<String> shareCreature({
    required Map<String, dynamic> creatureAttributes,
    required String creatureName,
    String? description,
    bool isPublic = true,
  }) async {
    try {
      // Generate unique share code
      final shareCode = _generateShareCode();
      
      // Prepare creature data
      final creatureData = {
        'id': shareCode,
        'name': creatureName,
        'description': description ?? 'AI-generated creature from Crafta',
        'attributes': creatureAttributes,
        'isPublic': isPublic,
        'createdAt': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
      
      // Store locally first
      await _storeCreatureLocally(shareCode, creatureData);
      
      // Upload to cloud (simulated for now)
      await _uploadToCloud(shareCode, creatureData);
      
      return shareCode;
    } catch (e) {
      print('Error sharing creature: $e');
      throw Exception('Failed to share creature: $e');
    }
  }
  
  /// Load a creature by share code
  static Future<Map<String, dynamic>> loadCreature(String shareCode) async {
    try {
      // Check local storage first
      final localCreature = await _getCreatureLocally(shareCode);
      if (localCreature != null) {
        return localCreature;
      }
      
      // Download from cloud
      final cloudCreature = await _downloadFromCloud(shareCode);
      if (cloudCreature != null) {
        // Store locally for future use
        await _storeCreatureLocally(shareCode, cloudCreature);
        return cloudCreature;
      }
      
      throw Exception('Creature not found');
    } catch (e) {
      print('Error loading creature: $e');
      throw Exception('Failed to load creature: $e');
    }
  }
  
  /// Get all locally stored creatures
  static Future<List<Map<String, dynamic>>> getLocalCreatures() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final creaturesJson = prefs.getString(_storageKey);
      
      if (creaturesJson == null) {
        return [];
      }
      
      final List<dynamic> creaturesList = jsonDecode(creaturesJson);
      return creaturesList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting local creatures: $e');
      return [];
    }
  }
  
  /// Delete a local creature
  static Future<void> deleteLocalCreature(String shareCode) async {
    try {
      final creatures = await getLocalCreatures();
      creatures.removeWhere((creature) => creature['id'] == shareCode);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(creatures));
    } catch (e) {
      print('Error deleting local creature: $e');
    }
  }
  
  /// Search for public creatures
  static Future<List<Map<String, dynamic>>> searchPublicCreatures({
    String? query,
    String? creatureType,
    int limit = 20,
  }) async {
    try {
      // Simulate cloud search (in real implementation, this would call an API)
      final publicCreatures = await _getPublicCreatures();
      
      List<Map<String, dynamic>> filtered = publicCreatures;
      
      // Filter by query
      if (query != null && query.isNotEmpty) {
        filtered = filtered.where((creature) {
          final name = creature['name']?.toString().toLowerCase() ?? '';
          final description = creature['description']?.toString().toLowerCase() ?? '';
          return name.contains(query.toLowerCase()) || 
                 description.contains(query.toLowerCase());
        }).toList();
      }
      
      // Filter by creature type
      if (creatureType != null && creatureType.isNotEmpty) {
        filtered = filtered.where((creature) {
          final attributes = creature['attributes'] as Map<String, dynamic>?;
          final type = attributes?['creatureType']?.toString().toLowerCase();
          return type == creatureType.toLowerCase();
        }).toList();
      }
      
      // Limit results
      if (filtered.length > limit) {
        filtered = filtered.take(limit).toList();
      }
      
      return filtered;
    } catch (e) {
      print('Error searching public creatures: $e');
      return [];
    }
  }
  
  /// Get trending creatures
  static Future<List<Map<String, dynamic>>> getTrendingCreatures({int limit = 10}) async {
    try {
      final publicCreatures = await _getPublicCreatures();
      
      // Sort by creation date (newest first) and take limit
      publicCreatures.sort((a, b) {
        final dateA = DateTime.parse(a['createdAt'] ?? '1970-01-01');
        final dateB = DateTime.parse(b['createdAt'] ?? '1970-01-01');
        return dateB.compareTo(dateA);
      });
      
      return publicCreatures.take(limit).toList();
    } catch (e) {
      print('Error getting trending creatures: $e');
      return [];
    }
  }
  
  /// Generate a unique share code with better uniqueness
  static String _generateShareCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = math.Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Use timestamp for better uniqueness
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += chars[random.nextInt(chars.length)];
    }
    
    // Add timestamp-based suffix for uniqueness
    final timeStr = timestamp.toString().substring(timestamp.toString().length - 2);
    code += timeStr;
    
    return code;
  }
  
  /// Store creature locally
  static Future<void> _storeCreatureLocally(String shareCode, Map<String, dynamic> creatureData) async {
    try {
      final creatures = await getLocalCreatures();
      
      // Remove existing creature with same ID
      creatures.removeWhere((creature) => creature['id'] == shareCode);
      
      // Add new creature
      creatures.add(creatureData);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(creatures));
    } catch (e) {
      print('Error storing creature locally: $e');
    }
  }
  
  /// Get creature from local storage
  static Future<Map<String, dynamic>?> _getCreatureLocally(String shareCode) async {
    try {
      final creatures = await getLocalCreatures();
      return creatures.firstWhere(
        (creature) => creature['id'] == shareCode,
        orElse: () => <String, dynamic>{},
      );
    } catch (e) {
      print('Error getting creature locally: $e');
      return null;
    }
  }
  
  /// Upload creature to cloud (simulated)
  static Future<void> _uploadToCloud(String shareCode, Map<String, dynamic> creatureData) async {
    try {
      // In a real implementation, this would upload to a cloud service
      // For now, we'll simulate the upload
      print('Uploading creature $shareCode to cloud...');
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('Creature $shareCode uploaded successfully');
    } catch (e) {
      print('Error uploading to cloud: $e');
      throw Exception('Failed to upload to cloud');
    }
  }
  
  /// Download creature from cloud (simulated)
  static Future<Map<String, dynamic>?> _downloadFromCloud(String shareCode) async {
    try {
      // In a real implementation, this would download from a cloud service
      // For now, we'll simulate the download
      print('Downloading creature $shareCode from cloud...');
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return null to indicate creature not found in cloud
      // In real implementation, this would return the creature data
      return null;
    } catch (e) {
      print('Error downloading from cloud: $e');
      return null;
    }
  }
  
  /// Get public creatures (simulated)
  static Future<List<Map<String, dynamic>>> _getPublicCreatures() async {
    // In a real implementation, this would fetch from a cloud service
    // For now, we'll return some sample data
    return [
      {
        'id': 'SAMPLE001',
        'name': 'Rainbow Dragon',
        'description': 'A magical rainbow dragon with sparkles',
        'attributes': {
          'creatureType': 'dragon',
          'color': 'rainbow',
          'size': 'large',
          'effects': ['sparkles', 'magic'],
          'abilities': ['flying', 'fire_breath']
        },
        'isPublic': true,
        'createdAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'version': '1.0',
      },
      {
        'id': 'SAMPLE002',
        'name': 'Golden Unicorn',
        'description': 'A beautiful golden unicorn with magical powers',
        'attributes': {
          'creatureType': 'unicorn',
          'color': 'golden',
          'size': 'normal',
          'effects': ['sparkles', 'magic'],
          'abilities': ['flying', 'healing']
        },
        'isPublic': true,
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'version': '1.0',
      },
      {
        'id': 'SAMPLE003',
        'name': 'Tiny Blue Cow',
        'description': 'A cute tiny blue cow perfect for farms',
        'attributes': {
          'creatureType': 'cow',
          'color': 'blue',
          'size': 'tiny',
          'effects': [],
          'abilities': ['milk_production']
        },
        'isPublic': true,
        'createdAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'version': '1.0',
      },
    ];
  }
  
  /// Validate share code format
  static bool isValidShareCode(String shareCode) {
    if (shareCode.length != 8) return false;
    return RegExp(r'^[A-Z0-9]+$').hasMatch(shareCode);
  }
  
  /// Get share URL for a creature
  static String getShareUrl(String shareCode) {
    return 'https://crafta.app/share/$shareCode';
  }
  
  /// Get share text for a creature
  static String getShareText(String creatureName, String shareCode) {
    return 'Check out my $creatureName created with Crafta! Share code: $shareCode\n\nDownload Crafta: https://crafta.app';
  }
  
  /// Get detailed share text with description
  static String getDetailedShareText(String creatureName, String shareCode, String? description) {
    final baseText = 'Check out my $creatureName created with Crafta!';
    final descText = description != null && description.isNotEmpty ? '\n$description' : '';
    return '$baseText$descText\n\nShare code: $shareCode\nDownload Crafta: https://crafta.app';
  }
  
  /// Get share data for external sharing
  static Map<String, dynamic> getShareData(String creatureName, String shareCode, String? description) {
    return {
      'text': getDetailedShareText(creatureName, shareCode, description),
      'url': getShareUrl(shareCode),
      'subject': 'My $creatureName from Crafta',
      'title': 'Share $creatureName',
    };
  }
  
  /// Get QR code data for sharing
  static String getQRCodeData(String shareCode) {
    return getShareUrl(shareCode);
  }
  
  /// Get social media share text
  static String getSocialShareText(String creatureName, String shareCode, String platform) {
    switch (platform.toLowerCase()) {
      case 'twitter':
        return 'Check out my $creatureName created with Crafta! $shareCode #Crafta #Minecraft';
      case 'facebook':
        return 'I created an amazing $creatureName with Crafta! Share code: $shareCode';
      case 'instagram':
        return 'Created this $creatureName with Crafta! $shareCode #Crafta #Minecraft #Creativity';
      case 'tiktok':
        return 'Check out my $creatureName! $shareCode #Crafta #Minecraft #Creativity';
      default:
        return getDetailedShareText(creatureName, shareCode, null);
    }
  }
}
