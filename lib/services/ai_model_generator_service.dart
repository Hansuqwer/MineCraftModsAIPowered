import 'dart:math';
import 'package:flutter/material.dart';
import '../models/enhanced_creature_attributes.dart';

/// AI Model Generator Service
/// Generates 3D models based on user requests with proper fallback
class AIModelGeneratorService {
  
  /// Generate 3D model specifications based on user request
  static Map<String, dynamic> generateModelSpecs(String userRequest) {
    print('🤖 [AI_MODEL] Analyzing user request: "$userRequest"');
    
    final request = userRequest.toLowerCase();
    
    // Extract creature type
    String creatureType = 'creature';
    if (request.contains('dragon')) {
      creatureType = 'dragon';
    } else if (request.contains('cat')) {
      creatureType = 'cat';
    } else if (request.contains('dog')) {
      creatureType = 'dog';
    } else if (request.contains('bird')) {
      creatureType = 'bird';
    } else if (request.contains('sword')) {
      creatureType = 'sword';
    } else if (request.contains('helmet')) {
      creatureType = 'helmet';
    }
    
    // Extract color
    String color = 'blue';
    if (request.contains('red')) {
      color = 'red';
    } else if (request.contains('green')) {
      color = 'green';
    } else if (request.contains('blue')) {
      color = 'blue';
    } else if (request.contains('yellow')) {
      color = 'yellow';
    } else if (request.contains('purple')) {
      color = 'purple';
    } else if (request.contains('black')) {
      color = 'black';
    } else if (request.contains('white')) {
      color = 'white';
    }
    
    // Extract material
    String material = 'basic';
    if (request.contains('metal') || request.contains('steel')) {
      material = 'metal';
    } else if (request.contains('diamond')) {
      material = 'diamond';
    } else if (request.contains('gold')) {
      material = 'gold';
    } else if (request.contains('glow') || request.contains('magic')) {
      material = 'glowing';
    }
    
    // Extract size
    String size = 'medium';
    if (request.contains('small') || request.contains('tiny')) {
      size = 'small';
    } else if (request.contains('large') || request.contains('big') || request.contains('huge')) {
      size = 'large';
    }
    
    // Extract abilities
    List<String> abilities = [];
    if (request.contains('fly') || request.contains('flying')) {
      abilities.add('flying');
    }
    if (request.contains('fire') || request.contains('flame')) {
      abilities.add('fireBreath');
    }
    if (request.contains('glow') || request.contains('glowing')) {
      abilities.add('glowing');
    }
    if (request.contains('magic') || request.contains('magical')) {
      abilities.add('magical');
    }
    
    final specs = {
      'creatureType': creatureType,
      'color': color,
      'material': material,
      'size': size,
      'abilities': abilities,
      'glow': abilities.contains('glowing') || abilities.contains('magical'),
      'scale': _getScaleFromSize(size),
    };
    
    print('🤖 [AI_MODEL] Generated specs: $specs');
    return specs;
  }
  
  /// Create basic creature attributes from user request
  static EnhancedCreatureAttributes createAttributesFromRequest(String userRequest) {
    final specs = generateModelSpecs(userRequest);
    
    return EnhancedCreatureAttributes(
      baseType: specs['creatureType'],
      primaryColor: _getColor(specs['color']),
      secondaryColor: _getColor(_getSecondaryColor(specs['color'])),
      accentColor: _getColor(specs['color']),
      size: _getSize(specs['size']),
      abilities: _parseAbilities(specs['abilities']),
      accessories: [],
      personality: PersonalityType.friendly,
      patterns: [],
      texture: TextureType.smooth,
      glowEffect: specs['glow'] ? GlowEffect.bright : GlowEffect.none,
      animationStyle: CreatureAnimationStyle.natural,
      customName: generateModelName(userRequest),
      description: 'AI-generated ${specs['creatureType']} with ${specs['color']} coloring',
    );
  }
  
  /// Get scale factor based on size
  static double _getScaleFromSize(String size) {
    switch (size) {
      case 'small':
        return 0.7;
      case 'large':
        return 1.3;
      case 'medium':
      default:
        return 1.0;
    }
  }
  
  /// Get secondary color based on primary color
  static String _getSecondaryColor(String primaryColor) {
    switch (primaryColor) {
      case 'red':
        return 'orange';
      case 'blue':
        return 'cyan';
      case 'green':
        return 'lime';
      case 'yellow':
        return 'gold';
      case 'purple':
        return 'magenta';
      case 'black':
        return 'gray';
      case 'white':
        return 'light_gray';
      default:
        return 'white';
    }
  }
  
  /// Parse abilities list
  static List<SpecialAbility> _parseAbilities(List<String> abilityStrings) {
    final abilities = <SpecialAbility>[];
    
    for (final ability in abilityStrings) {
      switch (ability) {
        case 'flying':
          abilities.add(SpecialAbility.flying);
          break;
        case 'fireBreath':
          abilities.add(SpecialAbility.fireBreath);
          break;
        case 'glowing':
          abilities.add(SpecialAbility.magic);
          break;
        case 'magical':
          abilities.add(SpecialAbility.magic);
          break;
      }
    }
    
    return abilities;
  }
  
  /// Get color from string
  static Color _getColor(String colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'orange':
        return Colors.orange;
      case 'cyan':
        return Colors.cyan;
      case 'lime':
        return Colors.lime;
      case 'gold':
        return Colors.amber;
      case 'magenta':
        return Colors.pink;
      case 'gray':
        return Colors.grey;
      case 'light_gray':
        return Colors.grey.shade300;
      default:
        return Colors.blue;
    }
  }
  
  /// Get size enum from string
  static CreatureSize _getSize(String sizeName) {
    switch (sizeName) {
      case 'small':
        return CreatureSize.small;
      case 'large':
        return CreatureSize.large;
      case 'medium':
      default:
        return CreatureSize.medium;
    }
  }
  
  /// Generate model name from request
  static String generateModelName(String userRequest) {
    final specs = generateModelSpecs(userRequest);
    final color = specs['color'];
    final creatureType = specs['creatureType'];
    
    return '${color[0].toUpperCase()}${color.substring(1)} ${creatureType[0].toUpperCase()}${creatureType.substring(1)}';
  }
}

/// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
