import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enhanced_creature_attributes.dart';

/// Google Cloud Service
/// Handles Google authentication and cloud storage for user creations
class GoogleCloudService {
  static const String _userDataKey = 'user_data';
  static const String _syncStatusKey = 'sync_status';
  
  // Firebase instances
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Google Sign-In instance
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  /// Initialize the service
  static Future<void> initialize() async {
    try {
      // Check if user is already signed in
      final user = _auth.currentUser;
      if (user != null) {
        print('✅ User already signed in: ${user.email}');
      }
    } catch (e) {
      print('⚠️ Google Cloud Service initialization error: $e');
    }
  }

  /// Sign in with Google
  static Future<GoogleSignInResult> signInWithGoogle() async {
    try {
      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return GoogleSignInResult(
          success: false,
          error: 'User cancelled sign in',
        );
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Save user data locally
        await _saveUserData(user);
        
        // Initialize user's cloud storage
        await _initializeUserCloudStorage(user);
        
        return GoogleSignInResult(
          success: true,
          user: user,
          message: 'Successfully signed in with Google!',
        );
      } else {
        return GoogleSignInResult(
          success: false,
          error: 'Failed to create Firebase user',
        );
      }
    } catch (e) {
      return GoogleSignInResult(
        success: false,
        error: 'Sign in failed: $e',
      );
    }
  }

  /// Sign out from Google
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      
      // Clear local user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      await prefs.remove(_syncStatusKey);
      
      print('✅ Successfully signed out');
    } catch (e) {
      print('⚠️ Sign out error: $e');
    }
  }

  /// Check if user is signed in
  static Future<bool> isSignedIn() async {
    try {
      final user = _auth.currentUser;
      return user != null;
    } catch (e) {
      return false;
    }
  }

  /// Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Save user data locally
  static Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'lastSignIn': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  /// Initialize user's cloud storage
  static Future<void> _initializeUserCloudStorage(User user) async {
    try {
      // Create user document in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
        'totalCreations': 0,
        'favoriteCreations': [],
        'sharedCreations': [],
      });

      // Create user's creations collection
      await _firestore.collection('users').doc(user.uid).collection('creations').doc('metadata').set({
        'totalCount': 0,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('✅ User cloud storage initialized');
    } catch (e) {
      print('⚠️ Failed to initialize cloud storage: $e');
    }
  }

  /// Save creation to cloud
  static Future<CloudSaveResult> saveCreationToCloud({
    required EnhancedCreatureAttributes attributes,
    required String name,
    required String description,
    required bool isPublic,
  }) async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        return CloudSaveResult(
          success: false,
          error: 'User not signed in',
        );
      }

      // Generate unique ID for creation
      final creationId = _firestore.collection('creations').doc().id;
      
      // Prepare creation data
      final creationData = {
        'id': creationId,
        'name': name,
        'description': description,
        'attributes': attributes.toMap(),
        'isPublic': isPublic,
        'createdAt': FieldValue.serverTimestamp(),
        'lastModified': FieldValue.serverTimestamp(),
        'authorId': user.uid,
        'authorName': user.displayName ?? 'Anonymous',
        'likes': 0,
        'downloads': 0,
        'tags': _generateTags(attributes),
      };

      // Save to user's creations
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('creations')
          .doc(creationId)
          .set(creationData);

      // If public, also save to public gallery
      if (isPublic) {
        await _firestore
            .collection('public_creations')
            .doc(creationId)
            .set(creationData);
      }

      // Update user's total creations count
      await _firestore.collection('users').doc(user.uid).update({
        'totalCreations': FieldValue.increment(1),
        'lastActive': FieldValue.serverTimestamp(),
      });

      // Update local sync status
      await _updateSyncStatus(creationId, true);

      return CloudSaveResult(
        success: true,
        creationId: creationId,
        message: 'Creation saved to cloud successfully!',
      );
    } catch (e) {
      return CloudSaveResult(
        success: false,
        error: 'Failed to save creation: $e',
      );
    }
  }

  /// Load user's creations from cloud
  static Future<List<CloudCreation>> loadUserCreations() async {
    try {
      final user = getCurrentUser();
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('creations')
          .where('id', isNotEqualTo: 'metadata')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CloudCreation(
          id: data['id'],
          name: data['name'],
          description: data['description'],
          attributes: EnhancedCreatureAttributes.fromMap(data['attributes']),
          isPublic: data['isPublic'] ?? false,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          lastModified: (data['lastModified'] as Timestamp).toDate(),
          authorId: data['authorId'],
          authorName: data['authorName'],
          likes: data['likes'] ?? 0,
          downloads: data['downloads'] ?? 0,
          tags: List<String>.from(data['tags'] ?? []),
        );
      }).toList();
    } catch (e) {
      print('⚠️ Failed to load user creations: $e');
      return [];
    }
  }

  /// Load public creations from cloud
  static Future<List<CloudCreation>> loadPublicCreations({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('public_creations')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CloudCreation(
          id: data['id'],
          name: data['name'],
          description: data['description'],
          attributes: EnhancedCreatureAttributes.fromMap(data['attributes']),
          isPublic: data['isPublic'] ?? false,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          lastModified: (data['lastModified'] as Timestamp).toDate(),
          authorId: data['authorId'],
          authorName: data['authorName'],
          likes: data['likes'] ?? 0,
          downloads: data['downloads'] ?? 0,
          tags: List<String>.from(data['tags'] ?? []),
        );
      }).toList();
    } catch (e) {
      print('⚠️ Failed to load public creations: $e');
      return [];
    }
  }

  /// Delete creation from cloud
  static Future<CloudDeleteResult> deleteCreation(String creationId) async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        return CloudDeleteResult(
          success: false,
          error: 'User not signed in',
        );
      }

      // Delete from user's creations
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('creations')
          .doc(creationId)
          .delete();

      // Delete from public gallery if it exists
      await _firestore
          .collection('public_creations')
          .doc(creationId)
          .delete();

      // Update user's total creations count
      await _firestore.collection('users').doc(user.uid).update({
        'totalCreations': FieldValue.increment(-1),
        'lastActive': FieldValue.serverTimestamp(),
      });

      return CloudDeleteResult(
        success: true,
        message: 'Creation deleted successfully!',
      );
    } catch (e) {
      return CloudDeleteResult(
        success: false,
        error: 'Failed to delete creation: $e',
      );
    }
  }

  /// Sync local creations with cloud
  static Future<CloudSyncResult> syncWithCloud() async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        return CloudSyncResult(
          success: false,
          error: 'User not signed in',
        );
      }

      // Load local creations (this would need to be implemented based on your local storage)
      final localCreations = await _loadLocalCreations();
      
      // Load cloud creations
      final cloudCreations = await loadUserCreations();
      
      // Compare and sync
      final syncResults = <String>[];
      
      for (final localCreation in localCreations) {
        final cloudCreation = cloudCreations.firstWhere(
          (c) => c.id == localCreation.id,
          orElse: () => CloudCreation.empty(),
        );
        
        if (cloudCreation.id.isEmpty) {
          // Local creation not in cloud, upload it
          final result = await saveCreationToCloud(
            attributes: localCreation.attributes,
            name: localCreation.name,
            description: localCreation.description,
            isPublic: localCreation.isPublic,
          );
          
          if (result.success) {
            syncResults.add('Uploaded: ${localCreation.name}');
          }
        } else if (localCreation.lastModified.isAfter(cloudCreation.lastModified)) {
          // Local creation is newer, update cloud
          final result = await _updateCloudCreation(localCreation);
          if (result.success) {
            syncResults.add('Updated: ${localCreation.name}');
          }
        }
      }

      return CloudSyncResult(
        success: true,
        message: 'Sync completed successfully!',
        details: syncResults,
      );
    } catch (e) {
      return CloudSyncResult(
        success: false,
        error: 'Sync failed: $e',
      );
    }
  }

  /// Update cloud creation
  static Future<CloudUpdateResult> _updateCloudCreation(CloudCreation creation) async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        return CloudUpdateResult(
          success: false,
          error: 'User not signed in',
        );
      }

      final creationData = {
        'name': creation.name,
        'description': creation.description,
        'attributes': creation.attributes.toMap(),
        'isPublic': creation.isPublic,
        'lastModified': FieldValue.serverTimestamp(),
        'tags': creation.tags,
      };

      // Update in user's creations
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('creations')
          .doc(creation.id)
          .update(creationData);

      // Update in public gallery if public
      if (creation.isPublic) {
        await _firestore
            .collection('public_creations')
            .doc(creation.id)
            .update(creationData);
      }

      return CloudUpdateResult(
        success: true,
        message: 'Creation updated successfully!',
      );
    } catch (e) {
      return CloudUpdateResult(
        success: false,
        error: 'Failed to update creation: $e',
      );
    }
  }

  /// Load local creations (placeholder - implement based on your local storage)
  static Future<List<CloudCreation>> _loadLocalCreations() async {
    // This would need to be implemented based on your local storage system
    // For now, return empty list
    return [];
  }

  /// Generate tags for creation
  static List<String> _generateTags(EnhancedCreatureAttributes attributes) {
    final tags = <String>[];
    
    // Add base type tag
    tags.add(attributes.baseType.toLowerCase());
    
    // Add color tags
    tags.add(_getColorTag(attributes.primaryColor));
    if (attributes.secondaryColor != attributes.primaryColor) {
      tags.add(_getColorTag(attributes.secondaryColor));
    }
    
    // Add size tag
    tags.add(attributes.size.name.toLowerCase());
    
    // Add ability tags
    for (final ability in attributes.abilities) {
      if (ability != SpecialAbility.none) {
        tags.add(ability.name.toLowerCase());
      }
    }
    
    // Add personality tag
    if (attributes.personality != PersonalityType.friendly) {
      tags.add(attributes.personality.name.toLowerCase());
    }
    
    return tags;
  }

  /// Get color tag
  static String _getColorTag(Color color) {
    if (color == Colors.red) return 'red';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.green) return 'green';
    if (color == Colors.yellow) return 'yellow';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.pink) return 'pink';
    if (color == Colors.cyan) return 'cyan';
    if (color == Colors.brown) return 'brown';
    if (color == Colors.grey) return 'grey';
    if (color == Colors.black) return 'black';
    if (color == Colors.white) return 'white';
    return 'custom';
  }

  /// Update sync status
  static Future<void> _updateSyncStatus(String creationId, bool synced) async {
    final prefs = await SharedPreferences.getInstance();
    final syncStatus = prefs.getString(_syncStatusKey);
    
    Map<String, dynamic> statusMap = {};
    if (syncStatus != null) {
      statusMap = jsonDecode(syncStatus);
    }
    
    statusMap[creationId] = {
      'synced': synced,
      'lastSync': DateTime.now().millisecondsSinceEpoch,
    };
    
    await prefs.setString(_syncStatusKey, jsonEncode(statusMap));
  }

  /// Get sync status
  static Future<Map<String, dynamic>> getSyncStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final syncStatus = prefs.getString(_syncStatusKey);
    
    if (syncStatus != null) {
      return jsonDecode(syncStatus);
    }
    
    return {};
  }
}

/// Google Sign-In Result
class GoogleSignInResult {
  final bool success;
  final User? user;
  final String? message;
  final String? error;

  GoogleSignInResult({
    required this.success,
    this.user,
    this.message,
    this.error,
  });
}

/// Cloud Save Result
class CloudSaveResult {
  final bool success;
  final String? creationId;
  final String? message;
  final String? error;

  CloudSaveResult({
    required this.success,
    this.creationId,
    this.message,
    this.error,
  });
}

/// Cloud Delete Result
class CloudDeleteResult {
  final bool success;
  final String? message;
  final String? error;

  CloudDeleteResult({
    required this.success,
    this.message,
    this.error,
  });
}

/// Cloud Sync Result
class CloudSyncResult {
  final bool success;
  final String? message;
  final String? error;
  final List<String>? details;

  CloudSyncResult({
    required this.success,
    this.message,
    this.error,
    this.details,
  });
}

/// Cloud Update Result
class CloudUpdateResult {
  final bool success;
  final String? message;
  final String? error;

  CloudUpdateResult({
    required this.success,
    this.message,
    this.error,
  });
}

/// Cloud Creation Model
class CloudCreation {
  final String id;
  final String name;
  final String description;
  final EnhancedCreatureAttributes attributes;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime lastModified;
  final String authorId;
  final String authorName;
  final int likes;
  final int downloads;
  final List<String> tags;

  CloudCreation({
    required this.id,
    required this.name,
    required this.description,
    required this.attributes,
    required this.isPublic,
    required this.createdAt,
    required this.lastModified,
    required this.authorId,
    required this.authorName,
    required this.likes,
    required this.downloads,
    required this.tags,
  });

  CloudCreation.empty() : 
    id = '',
    name = '',
    description = '',
    attributes = EnhancedCreatureAttributes(
      baseType: '',
      customName: '',
      primaryColor: Colors.red,
      secondaryColor: Colors.blue,
      accentColor: Colors.green,
      size: CreatureSize.medium,
      personality: PersonalityType.friendly,
      abilities: [],
      accessories: [],
      patterns: [],
      texture: TextureType.smooth,
      glowEffect: GlowEffect.none,
      animationStyle: CreatureAnimationStyle.natural,
      description: '',
    ),
    isPublic = false,
    createdAt = DateTime.now(),
    lastModified = DateTime.now(),
    authorId = '',
    authorName = '',
    likes = 0,
    downloads = 0,
    tags = [];
}
