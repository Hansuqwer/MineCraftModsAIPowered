import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/enhanced_creature_attributes.dart';

/// Multiplayer Service
/// Handles collaborative creature creation between multiple users
class MultiplayerService {
  static const String _sessionKey = 'multiplayer_session';
  static const String _participantsKey = 'session_participants';
  static const String _contributionsKey = 'session_contributions';

  /// Create a new multiplayer session
  static Future<MultiplayerSession> createSession({
    required String sessionName,
    required String hostName,
    required EnhancedCreatureAttributes initialCreature,
  }) async {
    final session = MultiplayerSession(
      id: _generateSessionId(),
      name: sessionName,
      hostName: hostName,
      participants: [hostName],
      currentCreature: initialCreature,
      contributions: [],
      isActive: true,
      createdAt: DateTime.now(),
    );

    await _saveSession(session);
    return session;
  }

  /// Join an existing session
  static Future<bool> joinSession(String sessionId, String participantName) async {
    try {
      final session = await getSession(sessionId);
      if (session == null || !session.isActive) return false;

      final updatedSession = session.copyWith(
        participants: [...session.participants, participantName],
      );

      await _saveSession(updatedSession);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Leave a session
  static Future<bool> leaveSession(String sessionId, String participantName) async {
    try {
      final session = await getSession(sessionId);
      if (session == null) return false;

      final updatedParticipants = List<String>.from(session.participants);
      updatedParticipants.remove(participantName);

      final updatedSession = session.copyWith(
        participants: updatedParticipants,
        isActive: updatedParticipants.isNotEmpty,
      );

      await _saveSession(updatedSession);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Add a contribution to the session
  static Future<bool> addContribution({
    required String sessionId,
    required String participantName,
    required String contributionType,
    required String description,
    required Map<String, dynamic> changes,
  }) async {
    try {
      final session = await getSession(sessionId);
      if (session == null || !session.isActive) return false;

      final contribution = SessionContribution(
        id: _generateContributionId(),
        participantName: participantName,
        type: contributionType,
        description: description,
        changes: changes,
        timestamp: DateTime.now(),
      );

      final updatedContributions = [...session.contributions, contribution];
      final updatedSession = session.copyWith(contributions: updatedContributions);

      await _saveSession(updatedSession);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Apply a contribution to the current creature
  static Future<EnhancedCreatureAttributes?> applyContribution(
    String sessionId,
    String contributionId,
  ) async {
    try {
      final session = await getSession(sessionId);
      if (session == null) return null;

      final contribution = session.contributions.firstWhere(
        (c) => c.id == contributionId,
        orElse: () => throw Exception('Contribution not found'),
      );

      final updatedCreature = _applyChangesToCreature(session.currentCreature, contribution.changes);
      final updatedSession = session.copyWith(currentCreature: updatedCreature);

      await _saveSession(updatedSession);
      return updatedCreature;
    } catch (e) {
      return null;
    }
  }

  /// Get a session by ID
  static Future<MultiplayerSession?> getSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString('$_sessionKey$sessionId');
      
      if (sessionJson != null) {
        final sessionMap = jsonDecode(sessionJson) as Map<String, dynamic>;
        return MultiplayerSession.fromMap(sessionMap);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get all active sessions
  static Future<List<MultiplayerSession>> getActiveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_sessionKey));
      final sessions = <MultiplayerSession>[];

      for (final key in keys) {
        final sessionJson = prefs.getString(key);
        if (sessionJson != null) {
          final sessionMap = jsonDecode(sessionJson) as Map<String, dynamic>;
          final session = MultiplayerSession.fromMap(sessionMap);
          if (session.isActive) {
            sessions.add(session);
          }
        }
      }

      return sessions;
    } catch (e) {
      return [];
    }
  }

  /// Get session history for a participant
  static Future<List<MultiplayerSession>> getSessionHistory(String participantName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_sessionKey));
      final sessions = <MultiplayerSession>[];

      for (final key in keys) {
        final sessionJson = prefs.getString(key);
        if (sessionJson != null) {
          final sessionMap = jsonDecode(sessionJson) as Map<String, dynamic>;
          final session = MultiplayerSession.fromMap(sessionMap);
          if (session.participants.contains(participantName)) {
            sessions.add(session);
          }
        }
      }

      return sessions;
    } catch (e) {
      return [];
    }
  }

  /// End a session
  static Future<bool> endSession(String sessionId) async {
    try {
      final session = await getSession(sessionId);
      if (session == null) return false;

      final updatedSession = session.copyWith(isActive: false);
      await _saveSession(updatedSession);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get session statistics
  static Future<SessionStats> getSessionStats(String sessionId) async {
    try {
      final session = await getSession(sessionId);
      if (session == null) {
        return SessionStats(
          totalContributions: 0,
          activeParticipants: 0,
          sessionDuration: Duration.zero,
          mostActiveParticipant: '',
        );
      }

      final now = DateTime.now();
      final duration = now.difference(session.createdAt);
      
      final participantContributions = <String, int>{};
      for (final contribution in session.contributions) {
        participantContributions[contribution.participantName] = 
            (participantContributions[contribution.participantName] ?? 0) + 1;
      }

      final mostActiveParticipant = participantContributions.isNotEmpty
          ? participantContributions.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key
          : '';

      return SessionStats(
        totalContributions: session.contributions.length,
        activeParticipants: session.participants.length,
        sessionDuration: duration,
        mostActiveParticipant: mostActiveParticipant,
      );
    } catch (e) {
      return SessionStats(
        totalContributions: 0,
        activeParticipants: 0,
        sessionDuration: Duration.zero,
        mostActiveParticipant: '',
      );
    }
  }

  /// Save session to storage
  static Future<void> _saveSession(MultiplayerSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_sessionKey${session.id}', jsonEncode(session.toMap()));
  }

  /// Apply changes to creature attributes
  static EnhancedCreatureAttributes _applyChangesToCreature(
    EnhancedCreatureAttributes creature,
    Map<String, dynamic> changes,
  ) {
    return creature.copyWith(
      baseType: changes['baseType'] ?? creature.baseType,
      primaryColor: changes['primaryColor'] != null 
          ? Color(changes['primaryColor']) 
          : creature.primaryColor,
      secondaryColor: changes['secondaryColor'] != null 
          ? Color(changes['secondaryColor']) 
          : creature.secondaryColor,
      accentColor: changes['accentColor'] != null 
          ? Color(changes['accentColor']) 
          : creature.accentColor,
      size: changes['size'] != null 
          ? CreatureSize.values.firstWhere(
              (e) => e.name == changes['size'],
              orElse: () => creature.size,
            )
          : creature.size,
      abilities: changes['abilities'] != null 
          ? (changes['abilities'] as List).map((a) => SpecialAbility.values.firstWhere(
              (e) => e.name == a,
              orElse: () => SpecialAbility.none,
            )).toList()
          : creature.abilities,
      accessories: changes['accessories'] != null 
          ? (changes['accessories'] as List).map((a) => AccessoryType.values.firstWhere(
              (e) => e.name == a,
              orElse: () => AccessoryType.none,
            )).toList()
          : creature.accessories,
      personality: changes['personality'] != null 
          ? PersonalityType.values.firstWhere(
              (e) => e.name == changes['personality'],
              orElse: () => creature.personality,
            )
          : creature.personality,
      customName: changes['customName'] ?? creature.customName,
      description: changes['description'] ?? creature.description,
    );
  }

  /// Generate unique session ID
  static String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (9999 - 1000) * (DateTime.now().microsecond / 1000000)).round()}';
  }

  /// Generate unique contribution ID
  static String _generateContributionId() {
    return 'contrib_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (9999 - 1000) * (DateTime.now().microsecond / 1000000)).round()}';
  }
}

/// Multiplayer Session Model
class MultiplayerSession {
  final String id;
  final String name;
  final String hostName;
  final List<String> participants;
  final EnhancedCreatureAttributes currentCreature;
  final List<SessionContribution> contributions;
  final bool isActive;
  final DateTime createdAt;

  const MultiplayerSession({
    required this.id,
    required this.name,
    required this.hostName,
    required this.participants,
    required this.currentCreature,
    required this.contributions,
    required this.isActive,
    required this.createdAt,
  });

  MultiplayerSession copyWith({
    String? name,
    List<String>? participants,
    EnhancedCreatureAttributes? currentCreature,
    List<SessionContribution>? contributions,
    bool? isActive,
  }) {
    return MultiplayerSession(
      id: id,
      name: name ?? this.name,
      hostName: hostName,
      participants: participants ?? this.participants,
      currentCreature: currentCreature ?? this.currentCreature,
      contributions: contributions ?? this.contributions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'hostName': hostName,
      'participants': participants,
      'currentCreature': currentCreature.toMap(),
      'contributions': contributions.map((c) => c.toMap()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory MultiplayerSession.fromMap(Map<String, dynamic> map) {
    return MultiplayerSession(
      id: map['id'],
      name: map['name'],
      hostName: map['hostName'],
      participants: List<String>.from(map['participants']),
      currentCreature: EnhancedCreatureAttributes.fromMap(map['currentCreature']),
      contributions: (map['contributions'] as List)
          .map((c) => SessionContribution.fromMap(c))
          .toList(),
      isActive: map['isActive'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}

/// Session Contribution Model
class SessionContribution {
  final String id;
  final String participantName;
  final String type;
  final String description;
  final Map<String, dynamic> changes;
  final DateTime timestamp;

  const SessionContribution({
    required this.id,
    required this.participantName,
    required this.type,
    required this.description,
    required this.changes,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participantName': participantName,
      'type': type,
      'description': description,
      'changes': changes,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory SessionContribution.fromMap(Map<String, dynamic> map) {
    return SessionContribution(
      id: map['id'],
      participantName: map['participantName'],
      type: map['type'],
      description: map['description'],
      changes: Map<String, dynamic>.from(map['changes']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}

/// Session Statistics Model
class SessionStats {
  final int totalContributions;
  final int activeParticipants;
  final Duration sessionDuration;
  final String mostActiveParticipant;

  const SessionStats({
    required this.totalContributions,
    required this.activeParticipants,
    required this.sessionDuration,
    required this.mostActiveParticipant,
  });
}
