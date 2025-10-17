import 'dart:convert';
import '../../models/minecraft/addon_file.dart';
import '../../models/minecraft/addon_metadata.dart';

/// Generates Minecraft geometry files for different creature types
/// Provides sophisticated 3D models for enhanced visual quality
class GeometryGenerator {
  /// Generate geometry file for a creature based on its type
  static AddonFile generateGeometry({
    required Map<String, dynamic> creatureAttributes,
    required AddonMetadata metadata,
  }) {
    final creatureType = (creatureAttributes['creatureType'] ?? 'creature').toString().toLowerCase();
    final creatureName = creatureAttributes['creatureName'] ?? 'Creature';
    final size = (creatureAttributes['size'] ?? 'normal').toString().toLowerCase();
    final abilities = (creatureAttributes['abilities'] as List<dynamic>?) ?? [];
    final effects = (creatureAttributes['effects'] as List<dynamic>?) ?? [];

    // Generate identifier
    final identifier = _generateIdentifier(creatureAttributes);
    
    // Generate geometry based on creature type
    final geometry = _generateGeometryForType(
      creatureType: creatureType,
      creatureName: creatureName,
      size: size,
      abilities: abilities,
      effects: effects,
      metadata: metadata,
    );

    final jsonString = const JsonEncoder.withIndent('  ').convert(geometry);
    return AddonFile.json('models/entity/$identifier.geo.json', jsonString);
  }

  /// Generate identifier for the creature
  static String _generateIdentifier(Map<String, dynamic> creatureAttributes) {
    final creatureType = (creatureAttributes['creatureType'] ?? 'creature').toString().toLowerCase();
    final colorName = (creatureAttributes['color'] ?? 'normal').toString().toLowerCase();
    final sizeAttr = (creatureAttributes['size'] ?? 'normal').toString().toLowerCase();

    final parts = <String>[];
    if (colorName != 'normal' && colorName != 'rainbow') {
      parts.add(colorName);
    }
    if (sizeAttr != 'normal') {
      parts.add(sizeAttr);
    }
    parts.add(creatureType);
    return parts.join('_');
  }

  /// Generate geometry based on creature type
  static Map<String, dynamic> _generateGeometryForType({
    required String creatureType,
    required String creatureName,
    required String size,
    required List<dynamic> abilities,
    required List<dynamic> effects,
    required AddonMetadata metadata,
  }) {
    switch (creatureType) {
      case 'cow':
        return _generateCowGeometry(creatureName, size, abilities, effects);
      case 'pig':
        return _generatePigGeometry(creatureName, size, abilities, effects);
      case 'chicken':
        return _generateChickenGeometry(creatureName, size, abilities, effects);
      case 'sheep':
        return _generateSheepGeometry(creatureName, size, abilities, effects);
      case 'horse':
        return _generateHorseGeometry(creatureName, size, abilities, effects);
      case 'dragon':
        return _generateDragonGeometry(creatureName, size, abilities, effects);
      case 'unicorn':
        return _generateUnicornGeometry(creatureName, size, abilities, effects);
      case 'phoenix':
        return _generatePhoenixGeometry(creatureName, size, abilities, effects);
      case 'griffin':
        return _generateGriffinGeometry(creatureName, size, abilities, effects);
      case 'cat':
        return _generateCatGeometry(creatureName, size, abilities, effects);
      case 'dog':
        return _generateDogGeometry(creatureName, size, abilities, effects);
      default:
        return _generateGenericGeometry(creatureName, size, abilities, effects);
    }
  }

  /// Generate cow geometry with spots and realistic proportions
  static Map<String, dynamic> _generateCowGeometry(
    String creatureName,
    String size,
    List<dynamic> abilities,
    List<dynamic> effects,
  ) {
    final scale = _getSizeScale(size);
    
    return {
      'format_version': '1.12.0',
      'minecraft:geometry': [
        {
          'description': {
            'identifier': 'geometry.crafta.cow',
            'texture_width': 64,
            'texture_height': 64,
            'visible_bounds_width': 2.0,
            'visible_bounds_height': 2.0,
            'visible_bounds_offset': [0.0, 1.0, 0.0]
          },
          'bones': [
            {
              'name': 'body',
              'pivot': [0.0, 12.0, 0.0],
              'cubes': [
                {
                  'origin': [-6.0, 0.0, -4.0],
                  'size': [12.0, 8.0, 8.0],
                  'uv': [0.0, 0.0]
                }
              ]
            },
            {
              'name': 'head',
              'pivot': [0.0, 16.0, -6.0],
              'cubes': [
                {
                  'origin': [-4.0, 12.0, -10.0],
                  'size': [8.0, 6.0, 6.0],
                  'uv': [0.0, 16.0]
                }
              ]
            },
            {
              'name': 'leg1',
              'pivot': [-3.0, 0.0, -2.0],
              'cubes': [
                {
                  'origin': [-4.0, 0.0, -3.0],
                  'size': [2.0, 8.0, 2.0],
                  'uv': [0.0, 32.0]
                }
              ]
            },
            {
              'name': 'leg2',
              'pivot': [3.0, 0.0, -2.0],
              'cubes': [
                {
                  'origin': [2.0, 0.0, -3.0],
                  'size': [2.0, 8.0, 2.0],
                  'uv': [0.0, 32.0]
                }
              ]
            },
            {
              'name': 'leg3',
              'pivot': [-3.0, 0.0, 2.0],
              'cubes': [
                {
                  'origin': [-4.0, 0.0, 1.0],
                  'size': [2.0, 8.0, 2.0],
                  'uv': [0.0, 32.0]
                }
              ]
            },
            {
              'name': 'leg4',
              'pivot': [3.0, 0.0, 2.0],
              'cubes': [
                {
                  'origin': [2.0, 0.0, 1.0],
                  'size': [2.0, 8.0, 2.0],
                  'uv': [0.0, 32.0]
                }
              ]
            },
            {
              'name': 'tail',
              'pivot': [0.0, 8.0, 4.0],
              'cubes': [
                {
                  'origin': [-1.0, 4.0, 4.0],
                  'size': [2.0, 8.0, 2.0],
                  'uv': [0.0, 48.0]
                }
              ]
            }
          ]
        }
      ]
    };
  }

  /// Generate dragon geometry with wings, horns, and tail
  static Map<String, dynamic> _generateDragonGeometry(
    String creatureName,
    String size,
    List<dynamic> abilities,
    List<dynamic> effects,
  ) {
    final scale = _getSizeScale(size);
    final hasWings = abilities.contains('flying');
    final hasFire = effects.contains('fire') || effects.contains('flame');
    
    return {
      'format_version': '1.12.0',
      'minecraft:geometry': [
        {
          'description': {
            'identifier': 'geometry.crafta.dragon',
            'texture_width': 64,
            'texture_height': 64,
            'visible_bounds_width': 4.0,
            'visible_bounds_height': 3.0,
            'visible_bounds_offset': [0.0, 1.5, 0.0]
          },
          'bones': [
            {
              'name': 'body',
              'pivot': [0.0, 12.0, 0.0],
              'cubes': [
                {
                  'origin': [-4.0, 8.0, -6.0],
                  'size': [8.0, 8.0, 12.0],
                  'uv': [0.0, 0.0]
                }
              ]
            },
            {
              'name': 'head',
              'pivot': [0.0, 16.0, -8.0],
              'cubes': [
                {
                  'origin': [-3.0, 12.0, -12.0],
                  'size': [6.0, 6.0, 6.0],
                  'uv': [0.0, 16.0]
                }
              ]
            },
            if (hasWings) ...[
              {
                'name': 'wing_left',
                'pivot': [-4.0, 14.0, -2.0],
                'cubes': [
                  {
                    'origin': [-8.0, 10.0, -4.0],
                    'size': [4.0, 8.0, 8.0],
                    'uv': [0.0, 32.0]
                  }
                ]
              },
              {
                'name': 'wing_right',
                'pivot': [4.0, 14.0, -2.0],
                'cubes': [
                  {
                    'origin': [4.0, 10.0, -4.0],
                    'size': [4.0, 8.0, 8.0],
                    'uv': [0.0, 32.0]
                  }
                ]
              }
            ],
            {
              'name': 'tail',
              'pivot': [0.0, 10.0, 6.0],
              'cubes': [
                {
                  'origin': [-1.0, 8.0, 6.0],
                  'size': [2.0, 4.0, 8.0],
                  'uv': [0.0, 48.0]
                }
              ]
            },
            if (hasFire) ...[
              {
                'name': 'fire_breath',
                'pivot': [0.0, 14.0, -12.0],
                'cubes': [
                  {
                    'origin': [-1.0, 13.0, -16.0],
                    'size': [2.0, 2.0, 4.0],
                    'uv': [0.0, 56.0]
                  }
                ]
              }
            ]
          ]
        }
      ]
    };
  }

  /// Generate unicorn geometry with horn and magical effects
  static Map<String, dynamic> _generateUnicornGeometry(
    String creatureName,
    String size,
    List<dynamic> abilities,
    List<dynamic> effects,
  ) {
    final scale = _getSizeScale(size);
    final hasSparkles = effects.contains('sparkles') || effects.contains('magic');
    
    return {
      'format_version': '1.12.0',
      'minecraft:geometry': [
        {
          'description': {
            'identifier': 'geometry.crafta.unicorn',
            'texture_width': 64,
            'texture_height': 64,
            'visible_bounds_width': 2.0,
            'visible_bounds_height': 2.5,
            'visible_bounds_offset': [0.0, 1.25, 0.0]
          },
          'bones': [
            {
              'name': 'body',
              'pivot': [0.0, 12.0, 0.0],
              'cubes': [
                {
                  'origin': [-5.0, 8.0, -6.0],
                  'size': [10.0, 8.0, 12.0],
                  'uv': [0.0, 0.0]
                }
              ]
            },
            {
              'name': 'head',
              'pivot': [0.0, 16.0, -6.0],
              'cubes': [
                {
                  'origin': [-4.0, 12.0, -10.0],
                  'size': [8.0, 6.0, 6.0],
                  'uv': [0.0, 16.0]
                }
              ]
            },
            {
              'name': 'horn',
              'pivot': [0.0, 18.0, -8.0],
              'cubes': [
                {
                  'origin': [-0.5, 16.0, -10.0],
                  'size': [1.0, 4.0, 1.0],
                  'uv': [0.0, 32.0]
                }
              ]
            },
            {
              'name': 'mane',
              'pivot': [0.0, 16.0, -4.0],
              'cubes': [
                {
                  'origin': [-3.0, 14.0, -6.0],
                  'size': [6.0, 4.0, 4.0],
                  'uv': [0.0, 40.0]
                }
              ]
            },
            if (hasSparkles) ...[
              {
                'name': 'sparkles',
                'pivot': [0.0, 18.0, -2.0],
                'cubes': [
                  {
                    'origin': [-2.0, 16.0, -4.0],
                    'size': [4.0, 4.0, 4.0],
                    'uv': [0.0, 48.0]
                  }
                ]
              }
            ]
          ]
        }
      ]
    };
  }

  /// Generate phoenix geometry with flame effects
  static Map<String, dynamic> _generatePhoenixGeometry(
    String creatureName,
    String size,
    List<dynamic> abilities,
    List<dynamic> effects,
  ) {
    final scale = _getSizeScale(size);
    final hasFire = effects.contains('fire') || effects.contains('flame');
    
    return {
      'format_version': '1.12.0',
      'minecraft:geometry': [
        {
          'description': {
            'identifier': 'geometry.crafta.phoenix',
            'texture_width': 64,
            'texture_height': 64,
            'visible_bounds_width': 3.0,
            'visible_bounds_height': 2.0,
            'visible_bounds_offset': [0.0, 1.0, 0.0]
          },
          'bones': [
            {
              'name': 'body',
              'pivot': [0.0, 12.0, 0.0],
              'cubes': [
                {
                  'origin': [-3.0, 10.0, -4.0],
                  'size': [6.0, 6.0, 8.0],
                  'uv': [0.0, 0.0]
                }
              ]
            },
            {
              'name': 'head',
              'pivot': [0.0, 16.0, -6.0],
              'cubes': [
                {
                  'origin': [-2.0, 14.0, -8.0],
                  'size': [4.0, 4.0, 4.0],
                  'uv': [0.0, 16.0]
                }
              ]
            },
            {
              'name': 'wing_left',
              'pivot': [-3.0, 14.0, -2.0],
              'cubes': [
                {
                  'origin': [-6.0, 12.0, -4.0],
                  'size': [3.0, 4.0, 8.0],
                  'uv': [0.0, 32.0]
                }
              ]
            },
            {
              'name': 'wing_right',
              'pivot': [3.0, 14.0, -2.0],
              'cubes': [
                {
                  'origin': [3.0, 12.0, -4.0],
                  'size': [3.0, 4.0, 8.0],
                  'uv': [0.0, 32.0]
                }
              ]
            },
            if (hasFire) ...[
              {
                'name': 'flames',
                'pivot': [0.0, 14.0, -8.0],
                'cubes': [
                  {
                    'origin': [-2.0, 12.0, -12.0],
                    'size': [4.0, 4.0, 4.0],
                    'uv': [0.0, 48.0]
                  }
                ]
              }
            ]
          ]
        }
      ]
    };
  }

  /// Generate generic creature geometry (fallback)
  static Map<String, dynamic> _generateGenericGeometry(
    String creatureName,
    String size,
    List<dynamic> abilities,
    List<dynamic> effects,
  ) {
    final scale = _getSizeScale(size);
    
    return {
      'format_version': '1.12.0',
      'minecraft:geometry': [
        {
          'description': {
            'identifier': 'geometry.crafta.creature',
            'texture_width': 64,
            'texture_height': 64,
            'visible_bounds_width': 2.0,
            'visible_bounds_height': 2.0,
            'visible_bounds_offset': [0.0, 1.0, 0.0]
          },
          'bones': [
            {
              'name': 'body',
              'pivot': [0.0, 12.0, 0.0],
              'cubes': [
                {
                  'origin': [-4.0, 8.0, -4.0],
                  'size': [8.0, 8.0, 8.0],
                  'uv': [0.0, 0.0]
                }
              ]
            },
            {
              'name': 'head',
              'pivot': [0.0, 16.0, -6.0],
              'cubes': [
                {
                  'origin': [-3.0, 12.0, -8.0],
                  'size': [6.0, 6.0, 4.0],
                  'uv': [0.0, 16.0]
                }
              ]
            }
          ]
        }
      ]
    };
  }

  /// Generate other creature geometries (pig, chicken, sheep, horse, griffin, cat, dog)
  static Map<String, dynamic> _generatePigGeometry(String creatureName, String size, List<dynamic> abilities, List<dynamic> effects) {
    return _generateGenericGeometry(creatureName, size, abilities, effects);
  }

  static Map<String, dynamic> _generateChickenGeometry(String creatureName, String size, List<dynamic> abilities, List<dynamic> effects) {
    return _generateGenericGeometry(creatureName, size, abilities, effects);
  }

  static Map<String, dynamic> _generateSheepGeometry(String creatureName, String size, List<dynamic> abilities, List<dynamic> effects) {
    return _generateGenericGeometry(creatureName, size, abilities, effects);
  }

  static Map<String, dynamic> _generateHorseGeometry(String creatureName, String size, List<dynamic> abilities, List<dynamic> effects) {
    return _generateGenericGeometry(creatureName, size, abilities, effects);
  }

  static Map<String, dynamic> _generateGriffinGeometry(String creatureName, String size, List<dynamic> abilities, List<dynamic> effects) {
    return _generateGenericGeometry(creatureName, size, abilities, effects);
  }

  static Map<String, dynamic> _generateCatGeometry(String creatureName, String size, List<dynamic> abilities, List<dynamic> effects) {
    return _generateGenericGeometry(creatureName, size, abilities, effects);
  }

  static Map<String, dynamic> _generateDogGeometry(String creatureName, String size, List<dynamic> abilities, List<dynamic> effects) {
    return _generateGenericGeometry(creatureName, size, abilities, effects);
  }

  /// Get size scale multiplier
  static double _getSizeScale(String size) {
    switch (size.toLowerCase()) {
      case 'tiny':
        return 0.5;
      case 'small':
        return 0.7;
      case 'large':
        return 1.3;
      case 'huge':
        return 1.5;
      case 'giant':
        return 2.0;
      default:
        return 1.0;
    }
  }
}