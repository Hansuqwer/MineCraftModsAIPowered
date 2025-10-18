import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enhanced_creature_attributes.dart';
import 'google_cloud_service.dart';

/// Community Service
/// Handles community features, sharing, and creature gallery
class CommunityService {
  static const String _favoritesKey = 'favorite_creations';
  static const String _recentViewsKey = 'recent_views';
  static const String _userStatsKey = 'user_stats';
  
  // Firebase instances
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Share a creation to the community
  static Future<CommunityShareResult> shareCreation({
    required String creationId,
    required String title,
    required String description,
    required List<String> tags,
    required bool isPublic,
  }) async {
    try {
      final user = GoogleCloudService.getCurrentUser();
      if (user == null) {
        return CommunityShareResult(
          success: false,
          error: 'User not signed in',
        );
      }

      // Get creation data
      final creationDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('creations')
          .doc(creationId)
          .get();

      if (!creationDoc.exists) {
        return CommunityShareResult(
          success: false,
          error: 'Creation not found',
        );
      }

      final creationData = creationDoc.data()!;
      
      // Prepare community data
      final communityData = {
        'id': creationId,
        'title': title,
        'description': description,
        'tags': tags,
        'isPublic': isPublic,
        'authorId': user.uid,
        'authorName': user.displayName ?? 'Anonymous',
        'authorPhoto': user.photoURL,
        'creationData': creationData,
        'likes': 0,
        'downloads': 0,
        'views': 0,
        'shares': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'featured': false,
        'trending': false,
        'verified': false,
      };

      // Save to community gallery
      await _firestore
          .collection('community_creations')
          .doc(creationId)
          .set(communityData);

      // Update user's creation to mark as shared
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('creations')
          .doc(creationId)
          .update({
        'isPublic': isPublic,
        'sharedAt': FieldValue.serverTimestamp(),
      });

      // Update user stats
      await _updateUserStats(user.uid, 'sharedCreations', 1);

      return CommunityShareResult(
        success: true,
        creationId: creationId,
        message: 'Creation shared to community successfully!',
      );
    } catch (e) {
      return CommunityShareResult(
        success: false,
        error: 'Failed to share creation: $e',
      );
    }
  }

  /// Get featured creations
  static Future<List<CommunityCreation>> getFeaturedCreations({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('community_creations')
          .where('featured', isEqualTo: true)
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return _parseCommunityCreations(snapshot);
    } catch (e) {
      print('⚠️ Failed to load featured creations: $e');
      return [];
    }
  }

  /// Get trending creations
  static Future<List<CommunityCreation>> getTrendingCreations({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('community_creations')
          .where('trending', isEqualTo: true)
          .where('isPublic', isEqualTo: true)
          .orderBy('likes', descending: true)
          .limit(limit)
          .get();

      return _parseCommunityCreations(snapshot);
    } catch (e) {
      print('⚠️ Failed to load trending creations: $e');
      return [];
    }
  }

  /// Get recent creations
  static Future<List<CommunityCreation>> getRecentCreations({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('community_creations')
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return _parseCommunityCreations(snapshot);
    } catch (e) {
      print('⚠️ Failed to load recent creations: $e');
      return [];
    }
  }

  /// Search creations by tags or keywords
  static Future<List<CommunityCreation>> searchCreations({
    required String query,
    List<String>? tags,
    int limit = 20,
  }) async {
    try {
      Query queryRef = _firestore
          .collection('community_creations')
          .where('isPublic', isEqualTo: true);

      // Add tag filters if provided
      if (tags != null && tags.isNotEmpty) {
        queryRef = queryRef.where('tags', arrayContainsAny: tags);
      }

      final snapshot = await queryRef
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final creations = _parseCommunityCreations(snapshot);
      
      // Filter by search query
      return creations.where((creation) {
        final searchText = '${creation.title} ${creation.description} ${creation.tags.join(' ')}'.toLowerCase();
        return searchText.contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      print('⚠️ Failed to search creations: $e');
      return [];
    }
  }

  /// Like a creation
  static Future<CommunityActionResult> likeCreation(String creationId) async {
    try {
      final user = GoogleCloudService.getCurrentUser();
      if (user == null) {
        return CommunityActionResult(
          success: false,
          error: 'User not signed in',
        );
      }

      // Check if already liked
      final likeDoc = await _firestore
          .collection('community_creations')
          .doc(creationId)
          .collection('likes')
          .doc(user.uid)
          .get();

      if (likeDoc.exists) {
        return CommunityActionResult(
          success: false,
          error: 'Already liked this creation',
        );
      }

      // Add like
      await _firestore
          .collection('community_creations')
          .doc(creationId)
          .collection('likes')
          .doc(user.uid)
          .set({
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'likedAt': FieldValue.serverTimestamp(),
      });

      // Update like count
      await _firestore
          .collection('community_creations')
          .doc(creationId)
          .update({
        'likes': FieldValue.increment(1),
      });

      // Update user stats
      await _updateUserStats(user.uid, 'likesGiven', 1);

      return CommunityActionResult(
        success: true,
        message: 'Creation liked successfully!',
      );
    } catch (e) {
      return CommunityActionResult(
        success: false,
        error: 'Failed to like creation: $e',
      );
    }
  }

  /// Unlike a creation
  static Future<CommunityActionResult> unlikeCreation(String creationId) async {
    try {
      final user = GoogleCloudService.getCurrentUser();
      if (user == null) {
        return CommunityActionResult(
          success: false,
          error: 'User not signed in',
        );
      }

      // Remove like
      await _firestore
          .collection('community_creations')
          .doc(creationId)
          .collection('likes')
          .doc(user.uid)
          .delete();

      // Update like count
      await _firestore
          .collection('community_creations')
          .doc(creationId)
          .update({
        'likes': FieldValue.increment(-1),
      });

      return CommunityActionResult(
        success: true,
        message: 'Creation unliked successfully!',
      );
    } catch (e) {
      return CommunityActionResult(
        success: false,
        error: 'Failed to unlike creation: $e',
      );
    }
  }

  /// Download a creation
  static Future<CommunityDownloadResult> downloadCreation(String creationId) async {
    try {
      final user = GoogleCloudService.getCurrentUser();
      if (user == null) {
        return CommunityDownloadResult(
          success: false,
          error: 'User not signed in',
        );
      }

      // Get creation data
      final creationDoc = await _firestore
          .collection('community_creations')
          .doc(creationId)
          .get();

      if (!creationDoc.exists) {
        return CommunityDownloadResult(
          success: false,
          error: 'Creation not found',
        );
      }

      final creationData = creationDoc.data()!;
      
      // Save to user's downloads
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('downloads')
          .doc(creationId)
          .set({
        'creationId': creationId,
        'downloadedAt': FieldValue.serverTimestamp(),
        'originalAuthorId': creationData['authorId'],
        'originalAuthorName': creationData['authorName'],
      });

      // Update download count
      await _firestore
          .collection('community_creations')
          .doc(creationId)
          .update({
        'downloads': FieldValue.increment(1),
      });

      // Update user stats
      await _updateUserStats(user.uid, 'downloads', 1);

      return CommunityDownloadResult(
        success: true,
        creationData: creationData,
        message: 'Creation downloaded successfully!',
      );
    } catch (e) {
      return CommunityDownloadResult(
        success: false,
        error: 'Failed to download creation: $e',
      );
    }
  }

  /// Add creation to favorites
  static Future<CommunityActionResult> addToFavorites(String creationId) async {
    try {
      final user = GoogleCloudService.getCurrentUser();
      if (user == null) {
        return CommunityActionResult(
          success: false,
          error: 'User not signed in',
        );
      }

      // Add to favorites
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(creationId)
          .set({
        'creationId': creationId,
        'favoritedAt': FieldValue.serverTimestamp(),
      });

      // Update local favorites
      await _addToLocalFavorites(creationId);

      return CommunityActionResult(
        success: true,
        message: 'Added to favorites!',
      );
    } catch (e) {
      return CommunityActionResult(
        success: false,
        error: 'Failed to add to favorites: $e',
      );
    }
  }

  /// Remove creation from favorites
  static Future<CommunityActionResult> removeFromFavorites(String creationId) async {
    try {
      final user = GoogleCloudService.getCurrentUser();
      if (user == null) {
        return CommunityActionResult(
          success: false,
          error: 'User not signed in',
        );
      }

      // Remove from favorites
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(creationId)
          .delete();

      // Update local favorites
      await _removeFromLocalFavorites(creationId);

      return CommunityActionResult(
        success: true,
        message: 'Removed from favorites!',
      );
    } catch (e) {
      return CommunityActionResult(
        success: false,
        error: 'Failed to remove from favorites: $e',
      );
    }
  }

  /// Get user's favorites
  static Future<List<CommunityCreation>> getUserFavorites() async {
    try {
      final user = GoogleCloudService.getCurrentUser();
      if (user == null) return [];

      final favoritesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .orderBy('favoritedAt', descending: true)
          .get();

      final favoriteIds = favoritesSnapshot.docs.map((doc) => doc.id).toList();
      
      if (favoriteIds.isEmpty) return [];

      // Get creation details
      final creations = <CommunityCreation>[];
      for (final id in favoriteIds) {
        final creationDoc = await _firestore
            .collection('community_creations')
            .doc(id)
            .get();
        
        if (creationDoc.exists) {
          creations.add(_parseCommunityCreation(creationDoc));
        }
      }

      return creations;
    } catch (e) {
      print('⚠️ Failed to load user favorites: $e');
      return [];
    }
  }

  /// Get user's downloads
  static Future<List<CommunityCreation>> getUserDownloads() async {
    try {
      final user = GoogleCloudService.getCurrentUser();
      if (user == null) return [];

      final downloadsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('downloads')
          .orderBy('downloadedAt', descending: true)
          .get();

      final downloadIds = downloadsSnapshot.docs.map((doc) => doc.id).toList();
      
      if (downloadIds.isEmpty) return [];

      // Get creation details
      final creations = <CommunityCreation>[];
      for (final id in downloadIds) {
        final creationDoc = await _firestore
            .collection('community_creations')
            .doc(id)
            .get();
        
        if (creationDoc.exists) {
          creations.add(_parseCommunityCreation(creationDoc));
        }
      }

      return creations;
    } catch (e) {
      print('⚠️ Failed to load user downloads: $e');
      return [];
    }
  }

  /// Get user's community stats
  static Future<CommunityUserStats> getUserStats() async {
    try {
      final user = GoogleCloudService.getCurrentUser();
      if (user == null) {
        return CommunityUserStats.empty();
      }

      final statsDoc = await _firestore
          .collection('user_stats')
          .doc(user.uid)
          .get();

      if (statsDoc.exists) {
        final data = statsDoc.data()!;
        return CommunityUserStats(
          sharedCreations: data['sharedCreations'] ?? 0,
          likesReceived: data['likesReceived'] ?? 0,
          downloadsReceived: data['downloadsReceived'] ?? 0,
          likesGiven: data['likesGiven'] ?? 0,
          downloads: data['downloads'] ?? 0,
          favorites: data['favorites'] ?? 0,
        );
      }

      return CommunityUserStats.empty();
    } catch (e) {
      print('⚠️ Failed to load user stats: $e');
      return CommunityUserStats.empty();
    }
  }

  /// Parse community creations from Firestore snapshot
  static List<CommunityCreation> _parseCommunityCreations(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) => _parseCommunityCreation(doc)).toList();
  }

  /// Parse single community creation
  static CommunityCreation _parseCommunityCreation(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityCreation(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      authorPhoto: data['authorPhoto'],
      creationData: data['creationData'],
      likes: data['likes'] ?? 0,
      downloads: data['downloads'] ?? 0,
      views: data['views'] ?? 0,
      shares: data['shares'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      featured: data['featured'] ?? false,
      trending: data['trending'] ?? false,
      verified: data['verified'] ?? false,
    );
  }

  /// Update user statistics
  static Future<void> _updateUserStats(String userId, String statType, int increment) async {
    try {
      await _firestore
          .collection('user_stats')
          .doc(userId)
          .update({
        statType: FieldValue.increment(increment),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('⚠️ Failed to update user stats: $e');
    }
  }

  /// Add to local favorites
  static Future<void> _addToLocalFavorites(String creationId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    if (!favorites.contains(creationId)) {
      favorites.add(creationId);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  /// Remove from local favorites
  static Future<void> _removeFromLocalFavorites(String creationId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    favorites.remove(creationId);
    await prefs.setStringList(_favoritesKey, favorites);
  }
}

/// Community Creation Model
class CommunityCreation {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final String authorId;
  final String authorName;
  final String? authorPhoto;
  final Map<String, dynamic> creationData;
  final int likes;
  final int downloads;
  final int views;
  final int shares;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final bool featured;
  final bool trending;
  final bool verified;

  CommunityCreation({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.authorId,
    required this.authorName,
    this.authorPhoto,
    required this.creationData,
    required this.likes,
    required this.downloads,
    required this.views,
    required this.shares,
    required this.createdAt,
    required this.lastUpdated,
    required this.featured,
    required this.trending,
    required this.verified,
  });
}

/// Community User Stats Model
class CommunityUserStats {
  final int sharedCreations;
  final int likesReceived;
  final int downloadsReceived;
  final int likesGiven;
  final int downloads;
  final int favorites;

  CommunityUserStats({
    required this.sharedCreations,
    required this.likesReceived,
    required this.downloadsReceived,
    required this.likesGiven,
    required this.downloads,
    required this.favorites,
  });

  CommunityUserStats.empty() : 
    sharedCreations = 0,
    likesReceived = 0,
    downloadsReceived = 0,
    likesGiven = 0,
    downloads = 0,
    favorites = 0;
}

/// Community Share Result
class CommunityShareResult {
  final bool success;
  final String? creationId;
  final String? message;
  final String? error;

  CommunityShareResult({
    required this.success,
    this.creationId,
    this.message,
    this.error,
  });
}

/// Community Action Result
class CommunityActionResult {
  final bool success;
  final String? message;
  final String? error;

  CommunityActionResult({
    required this.success,
    this.message,
    this.error,
  });
}

/// Community Download Result
class CommunityDownloadResult {
  final bool success;
  final Map<String, dynamic>? creationData;
  final String? message;
  final String? error;

  CommunityDownloadResult({
    required this.success,
    this.creationData,
    this.message,
    this.error,
  });
}
