import 'dart:math';

/// AI Animation Service for generating Minecraft Bedrock animations
/// Based on Bedrock Wiki: https://wiki.bedrock.dev/visuals/math-based-animations
class AIAnimationService {
  
  /// Generate animation function for AI-created items
  /// Uses Bedrock Wiki animation patterns
  String generateAnimationFunction({
    required String animationType,
    double base = 0.0,
    double offset = 0.0,
    double speed = 150.0,
    double pitch = 15.0,
  }) {
    switch (animationType.toLowerCase()) {
      case 'bob':
        return 'Base + Math.sin((q.life_time + $offset) * $speed) * $pitch';
      case 'sway':
        return 'Base + Math.cos((q.life_time + $offset) * $speed) * $pitch';
      case 'rotate':
        return 'Base + (q.life_time + $offset) * $speed';
      case 'pulse':
        return 'Base + Math.sin((q.life_time + $offset) * $speed) * $pitch + $base';
      case 'glow':
        return 'Base + Math.sin((q.life_time + $offset) * $speed) * 0.5 + 0.5';
      default:
        return 'Base + Math.sin((q.life_time + $offset) * $speed) * $pitch';
    }
  }
  
  /// Generate perfect loop animation timing
  /// Based on Bedrock Wiki speed/time correlation table
  Map<String, double> generatePerfectLoop({
    int group = 1,
    double multiplier = 1.0,
  }) {
    final baseValues = {
      1: {'speed': 150.0, 'time': 2.4},
      2: {'speed': 100.0, 'time': 3.6},
    };
    
    final base = baseValues[group] ?? baseValues[1]!;
    return {
      'speed': base['speed']! * multiplier,
      'time': base['time']! * multiplier,
    };
  }
  
  /// Generate animation for specific item types
  String generateItemAnimation(String itemType, String material) {
    switch (itemType.toLowerCase()) {
      case 'sword':
        return _generateSwordAnimation(material);
      case 'pickaxe':
        return _generatePickaxeAnimation(material);
      case 'helmet':
        return _generateHelmetAnimation(material);
      case 'creature':
        return _generateCreatureAnimation(material);
      default:
        return generateAnimationFunction(animationType: 'bob');
    }
  }
  
  String _generateSwordAnimation(String material) {
    if (material.contains('diamond') || material.contains('netherite')) {
      return 'Base + Math.sin((q.life_time + 0.5) * 150) * 5'; // Subtle glow
    }
    return 'Base + Math.sin((q.life_time + 0.0) * 100) * 2'; // Basic bob
  }
  
  String _generatePickaxeAnimation(String material) {
    if (material.contains('gold') || material.contains('diamond')) {
      return 'Base + Math.sin((q.life_time + 0.3) * 120) * 3'; // Mining motion
    }
    return 'Base + Math.sin((q.life_time + 0.0) * 80) * 1.5'; // Basic swing
  }
  
  String _generateHelmetAnimation(String material) {
    if (material.contains('emissive') || material.contains('glow')) {
      return 'Base + Math.sin((q.life_time + 0.0) * 200) * 0.3'; // Subtle glow
    }
    return 'Base'; // Static for most helmets
  }
  
  String _generateCreatureAnimation(String material) {
    return 'Base + Math.sin((q.life_time + 0.5) * 150) * 15'; // Walking motion
  }
  
  /// Generate animation speed multiplier
  /// Based on Bedrock Wiki animation speed control
  String generateSpeedControl(double speedMultiplier) {
    return '${speedMultiplier} * q.delta_time + q.anim_time';
  }
}
