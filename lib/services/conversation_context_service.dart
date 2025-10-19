import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing multi-turn conversation context
/// Helps Crafta remember previous conversations for more natural interactions
class ConversationContextService {
  static const String _storageKey = 'conversation_context';
  static const int _maxContextMessages = 20; // Keep last 20 exchanges
  static const int _maxSessionTime = 60; // minutes

  List<ConversationMessage> _contextMessages = [];
  DateTime? _sessionStart;
  String? _currentCreatureInProgress;

  /// Get conversation context
  List<ConversationMessage> get context => List.unmodifiable(_contextMessages);

  /// Get current session duration in minutes
  int get sessionDuration {
    if (_sessionStart == null) return 0;
    return DateTime.now().difference(_sessionStart!).inMinutes;
  }

  /// Check if we're in an active session
  bool get hasActiveSession => _sessionStart != null && sessionDuration < _maxSessionTime;

  /// Initialize context service and load previous session if recent
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contextJson = prefs.getString(_storageKey);

      if (contextJson != null) {
        final contextData = json.decode(contextJson) as Map<String, dynamic>;
        final lastSessionTime = DateTime.parse(contextData['sessionStart'] as String);

        // Check if session is still recent (within session timeout)
        final timeSinceLastSession = DateTime.now().difference(lastSessionTime).inMinutes;

        if (timeSinceLastSession < _maxSessionTime) {
          // Resume previous session
          _sessionStart = lastSessionTime;
          _currentCreatureInProgress = contextData['currentCreature'] as String?;

          final messages = contextData['messages'] as List<dynamic>;
          _contextMessages = messages
              .map((m) => ConversationMessage.fromJson(m as Map<String, dynamic>))
              .toList();

          print('Resumed conversation session: $sessionDuration minutes old, ${_contextMessages.length} messages');
        } else {
          // Session too old, start fresh
          print('Previous session expired (${timeSinceLastSession} minutes old)');
          _startNewSession();
        }
      } else {
        _startNewSession();
      }
    } catch (e) {
      print('Error loading conversation context: $e');
      _startNewSession();
    }
  }

  /// Start a new conversation session
  void _startNewSession() {
    _sessionStart = DateTime.now();
    _contextMessages.clear();
    _currentCreatureInProgress = null;
    print('Started new conversation session');
  }

  /// Add a message to the conversation context
  Future<void> addMessage({
    required String speaker, // 'user' or 'crafta'
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    final contextMessage = ConversationMessage(
      speaker: speaker,
      message: message,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    _contextMessages.add(contextMessage);

    // Keep only the most recent messages
    if (_contextMessages.length > _maxContextMessages) {
      _contextMessages.removeAt(0);
    }

    // Auto-save context
    await _saveContext();

    print('Added $speaker message to context (${_contextMessages.length} total)');
  }

  /// Add user message
  Future<void> addUserMessage(String message, {Map<String, dynamic>? metadata}) async {
    await addMessage(speaker: 'user', message: message, metadata: metadata);
  }

  /// Add Crafta response
  Future<void> addCraftaResponse(String message, {Map<String, dynamic>? metadata}) async {
    await addMessage(speaker: 'crafta', message: message, metadata: metadata);
  }

  /// Set the current creature being worked on
  Future<void> setCurrentCreature(String creatureName) async {
    _currentCreatureInProgress = creatureName;
    await _saveContext();
    print('Set current creature: $creatureName');
  }

  /// Clear current creature
  Future<void> clearCurrentCreature() async {
    _currentCreatureInProgress = null;
    await _saveContext();
    print('Cleared current creature');
  }

  /// Get current creature in progress
  String? getCurrentCreature() => _currentCreatureInProgress;

  /// Get context summary for AI prompt
  String getContextSummary() {
    if (_contextMessages.isEmpty) {
      return 'This is the beginning of a new conversation.';
    }

    final recentMessages = _contextMessages.take(5).toList();
    final summary = StringBuffer();

    summary.writeln('Previous conversation context:');
    for (final msg in recentMessages) {
      summary.writeln('${msg.speaker == 'user' ? 'Child' : 'Crafta'}: ${msg.message}');
    }

    if (_currentCreatureInProgress != null) {
      summary.writeln('\nCurrently working on: $_currentCreatureInProgress');
    }

    summary.writeln('\nSession duration: $sessionDuration minutes');

    return summary.toString();
  }

  /// Get conversation statistics
  ConversationStats getStats() {
    int userMessages = 0;
    int craftaMessages = 0;
    int totalCreatures = 0;

    for (final msg in _contextMessages) {
      if (msg.speaker == 'user') {
        userMessages++;
      } else {
        craftaMessages++;
      }

      if (msg.metadata?['creatureCreated'] == true) {
        totalCreatures++;
      }
    }

    return ConversationStats(
      totalMessages: _contextMessages.length,
      userMessages: userMessages,
      craftaMessages: craftaMessages,
      creaturesCreated: totalCreatures,
      sessionDuration: sessionDuration,
      currentCreature: _currentCreatureInProgress,
    );
  }

  /// Save conversation context to storage
  Future<void> _saveContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final contextData = {
        'sessionStart': _sessionStart?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'currentCreature': _currentCreatureInProgress,
        'messages': _contextMessages.map((m) => m.toJson()).toList(),
      };

      await prefs.setString(_storageKey, json.encode(contextData));
    } catch (e) {
      print('Error saving conversation context: $e');
    }
  }

  /// Clear all context (new session)
  Future<void> clearContext() async {
    _startNewSession();
    await _saveContext();
    print('Cleared conversation context');
  }

  /// Export context for debugging or analysis
  Map<String, dynamic> exportContext() {
    return {
      'sessionStart': _sessionStart?.toIso8601String(),
      'sessionDuration': sessionDuration,
      'currentCreature': _currentCreatureInProgress,
      'messages': _contextMessages.map((m) => m.toJson()).toList(),
      'stats': getStats().toJson(),
    };
  }
}

/// A single conversation message
class ConversationMessage {
  final String speaker; // 'user' or 'crafta'
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ConversationMessage({
    required this.speaker,
    required this.message,
    required this.timestamp,
    this.metadata,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      speaker: json['speaker'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speaker': speaker,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return '$speaker: $message (${timestamp.toLocal()})';
  }
}

/// Conversation statistics
class ConversationStats {
  final int totalMessages;
  final int userMessages;
  final int craftaMessages;
  final int creaturesCreated;
  final int sessionDuration; // minutes
  final String? currentCreature;

  ConversationStats({
    required this.totalMessages,
    required this.userMessages,
    required this.craftaMessages,
    required this.creaturesCreated,
    required this.sessionDuration,
    this.currentCreature,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalMessages': totalMessages,
      'userMessages': userMessages,
      'craftaMessages': craftaMessages,
      'creaturesCreated': creaturesCreated,
      'sessionDuration': sessionDuration,
      'currentCreature': currentCreature,
    };
  }

  @override
  String toString() {
    return 'ConversationStats(total: $totalMessages, user: $userMessages, '
        'crafta: $craftaMessages, creatures: $creaturesCreated, '
        'duration: $sessionDuration min)';
  }
}
