import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Achievement Service
/// Manages user achievements and progress tracking
class AchievementService {
  static const String _achievementsKey = 'user_achievements';
  static const String _progressKey = 'user_progress';
  static const String _statsKey = 'user_stats';

  /// Get all available achievements
  static List<Achievement> getAllAchievements() {
    return [
      // Creation Achievements
      Achievement(
        id: 'first_creature',
        title: 'First Creation',
        description: 'Created your first creature!',
        icon: '🎉',
        color: Colors.blue,
        category: AchievementCategory.creation,
        requirement: 1,
        requirementType: RequirementType.creaturesCreated,
        reward: 'Welcome to Crafta!',
      ),
      Achievement(
        id: 'creature_master',
        title: 'Creature Master',
        description: 'Created 10 different creatures',
        icon: '🐉',
        color: Colors.purple,
        category: AchievementCategory.creation,
        requirement: 10,
        requirementType: RequirementType.creaturesCreated,
        reward: 'Creature Creator Badge',
      ),
      Achievement(
        id: 'dragon_master',
        title: 'Dragon Master',
        description: 'Created 5 dragons',
        icon: '🐲',
        color: Colors.red,
        category: AchievementCategory.creation,
        requirement: 5,
        requirementType: RequirementType.dragonsCreated,
        reward: 'Dragon Tamer Badge',
      ),
      Achievement(
        id: 'colorful_creator',
        title: 'Colorful Creator',
        description: 'Used 10 different colors in creations',
        icon: '🌈',
        color: Colors.orange,
        category: AchievementCategory.creation,
        requirement: 10,
        requirementType: RequirementType.colorsUsed,
        reward: 'Rainbow Artist Badge',
      ),

      // Voice Achievements
      Achievement(
        id: 'voice_master',
        title: 'Voice Master',
        description: 'Used voice commands 50 times',
        icon: '🎤',
        color: Colors.green,
        category: AchievementCategory.voice,
        requirement: 50,
        requirementType: RequirementType.voiceCommands,
        reward: 'Voice Commander Badge',
      ),
      Achievement(
        id: 'clear_speaker',
        title: 'Clear Speaker',
        description: 'Successfully used voice 10 times in a row',
        icon: '🗣️',
        color: Colors.teal,
        category: AchievementCategory.voice,
        requirement: 10,
        requirementType: RequirementType.voiceStreak,
        reward: 'Clear Communication Badge',
      ),

      // Export Achievements
      Achievement(
        id: 'minecraft_exporter',
        title: 'Minecraft Exporter',
        description: 'Exported your first creature to Minecraft',
        icon: '📦',
        color: Colors.brown,
        category: AchievementCategory.export,
        requirement: 1,
        requirementType: RequirementType.creaturesExported,
        reward: 'Minecraft Integration Badge',
      ),
      Achievement(
        id: 'export_expert',
        title: 'Export Expert',
        description: 'Exported 5 creatures to Minecraft',
        icon: '🚀',
        color: Colors.indigo,
        category: AchievementCategory.export,
        requirement: 5,
        requirementType: RequirementType.creaturesExported,
        reward: 'Export Master Badge',
      ),

      // Social Achievements
      Achievement(
        id: 'sharing_star',
        title: 'Sharing Star',
        description: 'Shared your first creation',
        icon: '⭐',
        color: Colors.yellow,
        category: AchievementCategory.social,
        requirement: 1,
        requirementType: RequirementType.creaturesShared,
        reward: 'Sharing Champion Badge',
      ),
      Achievement(
        id: 'community_helper',
        title: 'Community Helper',
        description: 'Shared 10 creations with the community',
        icon: '🤝',
        color: Colors.pink,
        category: AchievementCategory.social,
        requirement: 10,
        requirementType: RequirementType.creaturesShared,
        reward: 'Community Hero Badge',
      ),

      // Learning Achievements
      Achievement(
        id: 'tutorial_graduate',
        title: 'Tutorial Graduate',
        description: 'Completed the tutorial',
        icon: '🎓',
        color: Colors.cyan,
        category: AchievementCategory.learning,
        requirement: 1,
        requirementType: RequirementType.tutorialCompleted,
        reward: 'Tutorial Master Badge',
      ),
      Achievement(
        id: 'feature_explorer',
        title: 'Feature Explorer',
        description: 'Used all major app features',
        icon: '🔍',
        color: Colors.deepPurple,
        category: AchievementCategory.learning,
        requirement: 1,
        requirementType: RequirementType.featuresUsed,
        reward: 'Feature Expert Badge',
      ),

      // Special Achievements
      Achievement(
        id: 'night_owl',
        title: 'Night Owl',
        description: 'Created something after 10 PM',
        icon: '🦉',
        color: Colors.deepOrange,
        category: AchievementCategory.special,
        requirement: 1,
        requirementType: RequirementType.nightCreatures,
        reward: 'Night Creator Badge',
      ),
      Achievement(
        id: 'perfectionist',
        title: 'Perfectionist',
        description: 'Modified a creature 5 times',
        icon: '✨',
        color: Colors.amber,
        category: AchievementCategory.special,
        requirement: 5,
        requirementType: RequirementType.creatureModifications,
        reward: 'Perfectionist Badge',
      ),
    ];
  }

  /// Get user's current progress
  static Future<UserProgress> getUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_progressKey);
    
    if (progressJson != null) {
      final progressMap = jsonDecode(progressJson) as Map<String, dynamic>;
      return UserProgress.fromMap(progressMap);
    }
    
    return UserProgress();
  }

  /// Update user progress
  static Future<void> updateProgress(RequirementType type, int increment) async {
    final progress = await getUserProgress();
    progress.updateProgress(type, increment);
    await _saveProgress(progress);
    await _checkAchievements(progress);
  }

  /// Get user's achievements
  static Future<List<Achievement>> getUserAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString(_achievementsKey);
    
    if (achievementsJson != null) {
      final achievementsList = jsonDecode(achievementsJson) as List<dynamic>;
      return achievementsList.map((json) => Achievement.fromMap(json)).toList();
    }
    
    return [];
  }

  /// Check if user has a specific achievement
  static Future<bool> hasAchievement(String achievementId) async {
    final achievements = await getUserAchievements();
    return achievements.any((achievement) => achievement.id == achievementId);
  }

  /// Award an achievement to the user
  static Future<void> awardAchievement(Achievement achievement) async {
    final achievements = await getUserAchievements();
    
    if (!achievements.any((a) => a.id == achievement.id)) {
      achievements.add(achievement);
      await _saveAchievements(achievements);
      
      // Show achievement notification
      _showAchievementNotification(achievement);
    }
  }

  /// Get user statistics
  static Future<UserStats> getUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);
    
    if (statsJson != null) {
      final statsMap = jsonDecode(statsJson) as Map<String, dynamic>;
      return UserStats.fromMap(statsMap);
    }
    
    return UserStats();
  }

  /// Update user statistics
  static Future<void> updateStats(String statName, int increment) async {
    final stats = await getUserStats();
    stats.updateStat(statName, increment);
    await _saveStats(stats);
  }

  /// Get achievements by category
  static Future<Map<AchievementCategory, List<Achievement>>> getAchievementsByCategory() async {
    final allAchievements = getAllAchievements();
    final userAchievements = await getUserAchievements();
    final userAchievementIds = userAchievements.map((a) => a.id).toSet();
    
    final Map<AchievementCategory, List<Achievement>> categorized = {};
    
    for (final achievement in allAchievements) {
      final isUnlocked = userAchievementIds.contains(achievement.id);
      final displayAchievement = achievement.copyWith(isUnlocked: isUnlocked);
      
      categorized.putIfAbsent(achievement.category, () => []).add(displayAchievement);
    }
    
    return categorized;
  }

  /// Get achievement progress for a specific achievement
  static Future<AchievementProgress> getAchievementProgress(Achievement achievement) async {
    final progress = await getUserProgress();
    final currentValue = progress.getProgress(achievement.requirementType);
    final isUnlocked = currentValue >= achievement.requirement;
    final progressPercentage = (currentValue / achievement.requirement).clamp(0.0, 1.0);
    
    return AchievementProgress(
      achievement: achievement,
      currentValue: currentValue,
      targetValue: achievement.requirement,
      progressPercentage: progressPercentage,
      isUnlocked: isUnlocked,
    );
  }

  /// Check for new achievements
  static Future<void> _checkAchievements(UserProgress progress) async {
    final allAchievements = getAllAchievements();
    final userAchievements = await getUserAchievements();
    final userAchievementIds = userAchievements.map((a) => a.id).toSet();
    
    for (final achievement in allAchievements) {
      if (!userAchievementIds.contains(achievement.id)) {
        final currentValue = progress.getProgress(achievement.requirementType);
        if (currentValue >= achievement.requirement) {
          await awardAchievement(achievement);
        }
      }
    }
  }

  /// Save progress to storage
  static Future<void> _saveProgress(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(progress.toMap()));
  }

  /// Save achievements to storage
  static Future<void> _saveAchievements(List<Achievement> achievements) async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = achievements.map((a) => a.toMap()).toList();
    await prefs.setString(_achievementsKey, jsonEncode(achievementsJson));
  }

  /// Save stats to storage
  static Future<void> _saveStats(UserStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, jsonEncode(stats.toMap()));
  }

  /// Show achievement notification
  static void _showAchievementNotification(Achievement achievement) {
    // This would typically show a notification or popup
    // For now, we'll just log it in debug mode
    assert(() {
      print('🏆 ACHIEVEMENT UNLOCKED: ${achievement.title}');
      print('   ${achievement.description}');
      print('   Reward: ${achievement.reward}');
      return true;
    }());
  }

  /// Reset all progress (for testing)
  static Future<void> resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_achievementsKey);
    await prefs.remove(_progressKey);
    await prefs.remove(_statsKey);
  }
}

/// Achievement Model
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final Color color;
  final AchievementCategory category;
  final int requirement;
  final RequirementType requirementType;
  final String reward;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.requirement,
    required this.requirementType,
    required this.reward,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      color: color,
      category: category,
      requirement: requirement,
      requirementType: requirementType,
      reward: reward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'color': color.value,
      'category': category.name,
      'requirement': requirement,
      'requirementType': requirementType.name,
      'reward': reward,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      icon: map['icon'],
      color: Color(map['color']),
      category: AchievementCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => AchievementCategory.creation,
      ),
      requirement: map['requirement'],
      requirementType: RequirementType.values.firstWhere(
        (e) => e.name == map['requirementType'],
        orElse: () => RequirementType.creaturesCreated,
      ),
      reward: map['reward'],
      isUnlocked: map['isUnlocked'] ?? false,
      unlockedAt: map['unlockedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['unlockedAt'])
          : null,
    );
  }
}

/// Achievement Categories
enum AchievementCategory {
  creation,
  voice,
  export,
  social,
  learning,
  special,
}

/// Requirement Types
enum RequirementType {
  creaturesCreated,
  dragonsCreated,
  colorsUsed,
  voiceCommands,
  voiceStreak,
  creaturesExported,
  creaturesShared,
  tutorialCompleted,
  featuresUsed,
  nightCreatures,
  creatureModifications,
}

/// User Progress Model
class UserProgress {
  final Map<RequirementType, int> _progress;

  UserProgress({Map<RequirementType, int>? progress}) 
      : _progress = progress ?? {};

  void updateProgress(RequirementType type, int increment) {
    _progress[type] = (_progress[type] ?? 0) + increment;
  }

  int getProgress(RequirementType type) {
    return _progress[type] ?? 0;
  }

  Map<String, dynamic> toMap() {
    final progressMap = <String, dynamic>{};
    for (final entry in _progress.entries) {
      progressMap[entry.key.name] = entry.value;
    }
    return progressMap;
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    final progress = <RequirementType, int>{};
    for (final entry in map.entries) {
      final type = RequirementType.values.firstWhere(
        (e) => e.name == entry.key,
        orElse: () => RequirementType.creaturesCreated,
      );
      progress[type] = entry.value as int;
    }
    return UserProgress(progress: progress);
  }
}

/// User Stats Model
class UserStats {
  final Map<String, int> _stats;

  UserStats({Map<String, int>? stats}) : _stats = stats ?? {};

  void updateStat(String statName, int increment) {
    _stats[statName] = (_stats[statName] ?? 0) + increment;
  }

  int getStat(String statName) {
    return _stats[statName] ?? 0;
  }

  Map<String, dynamic> toMap() {
    return Map<String, dynamic>.from(_stats);
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(stats: Map<String, int>.from(map));
  }
}

/// Achievement Progress Model
class AchievementProgress {
  final Achievement achievement;
  final int currentValue;
  final int targetValue;
  final double progressPercentage;
  final bool isUnlocked;

  const AchievementProgress({
    required this.achievement,
    required this.currentValue,
    required this.targetValue,
    required this.progressPercentage,
    required this.isUnlocked,
  });
}
