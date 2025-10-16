import 'dart:convert';
import '../../models/minecraft/addon_file.dart';
import '../../models/minecraft/addon_metadata.dart';

/// Generates Minecraft entity client files (resource pack)
class EntityClientGenerator {
  /// Generate entity client file
  static AddonFile generateEntityClient({
    required Map<String, dynamic> creatureAttributes,
    required AddonMetadata metadata,
  }) {
    final creatureType = (creatureAttributes['creatureType'] ?? 'creature').toString().toLowerCase();
    final colorName = (creatureAttributes['color'] ?? 'normal').toString().toLowerCase();
    final sizeAttr = (creatureAttributes['size'] ?? 'normal').toString().toLowerCase();
    final effects = (creatureAttributes['effects'] as List<dynamic>?) ?? [];

    // Generate identifier (must match behavior pack)
    final identifier = _generateIdentifier(metadata.namespace, creatureType, colorName, sizeAttr);
    final shortName = identifier.replaceAll(':', '_');

    // Determine material based on effects
    final material = _getMaterial(effects);

    final entityClient = {
      'format_version': '1.10.0',
      'minecraft:client_entity': {
        'description': {
          'identifier': identifier,
          'materials': {
            'default': material,
          },
          'textures': {
            'default': 'textures/entity/$shortName',
          },
          'geometry': {
            'default': 'geometry.${metadata.namespace}.$creatureType',
          },
          'animations': {
            'idle': 'animation.${metadata.namespace}.$shortName.idle',
            'move': 'animation.${metadata.namespace}.$shortName.move',
            'idle_controller': 'controller.animation.${metadata.namespace}.$shortName',
          },
          'scripts': {
            'animate': ['idle_controller']
          },
          if (metadata.generateSpawnEggs)
            'spawn_egg': _getSpawnEggConfig(colorName, creatureAttributes),
          'render_controllers': ['controller.render.${metadata.namespace}.$shortName'],
        }
      }
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(entityClient);
    return AddonFile.json('entity/$shortName.ce.json', jsonString);
  }

  /// Generate render controller
  static AddonFile generateRenderController({
    required Map<String, dynamic> creatureAttributes,
    required AddonMetadata metadata,
  }) {
    final creatureType = (creatureAttributes['creatureType'] ?? 'creature').toString().toLowerCase();
    final colorName = (creatureAttributes['color'] ?? 'normal').toString().toLowerCase();
    final sizeAttr = (creatureAttributes['size'] ?? 'normal').toString().toLowerCase();

    final identifier = _generateIdentifier(metadata.namespace, creatureType, colorName, sizeAttr);
    final shortName = identifier.replaceAll(':', '_');

    final renderController = {
      'format_version': '1.10.0',
      'render_controllers': {
        'controller.render.${metadata.namespace}.$shortName': {
          'geometry': 'Geometry.default',
          'materials': [
            {'*': 'Material.default'}
          ],
          'textures': ['Texture.default'],
        }
      }
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(renderController);
    return AddonFile.json('render_controllers/$shortName.rc.json', jsonString);
  }

  /// Generate animation controller
  static AddonFile generateAnimationController({
    required Map<String, dynamic> creatureAttributes,
    required AddonMetadata metadata,
  }) {
    final creatureType = (creatureAttributes['creatureType'] ?? 'creature').toString().toLowerCase();
    final colorName = (creatureAttributes['color'] ?? 'normal').toString().toLowerCase();
    final sizeAttr = (creatureAttributes['size'] ?? 'normal').toString().toLowerCase();

    final identifier = _generateIdentifier(metadata.namespace, creatureType, colorName, sizeAttr);
    final shortName = identifier.replaceAll(':', '_');

    final animationController = {
      'format_version': '1.12.0',
      'animation_controllers': {
        'controller.animation.${metadata.namespace}.$shortName': {
          'initial_state': 'standing',
          'states': {
            'standing': {
              'blend_transition': 0.2,
              'animations': ['idle'],
              'transitions': [
                {
                  'moving': 'query.modified_move_speed > 0.1',
                }
              ],
            },
            'moving': {
              'blend_transition': 0.2,
              'animations': ['move'],
              'transitions': [
                {
                  'standing': 'query.modified_move_speed < 0.1',
                }
              ],
            },
          }
        }
      }
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(animationController);
    return AddonFile.json('animation_controllers/$shortName.ac.json', jsonString);
  }

  /// Generate simple animations
  static AddonFile generateAnimations({
    required Map<String, dynamic> creatureAttributes,
    required AddonMetadata metadata,
  }) {
    final creatureType = (creatureAttributes['creatureType'] ?? 'creature').toString().toLowerCase();
    final colorName = (creatureAttributes['color'] ?? 'normal').toString().toLowerCase();
    final sizeAttr = (creatureAttributes['size'] ?? 'normal').toString().toLowerCase();

    final identifier = _generateIdentifier(metadata.namespace, creatureType, colorName, sizeAttr);
    final shortName = identifier.replaceAll(':', '_');

    final animations = {
      'format_version': '1.8.0',
      'animations': {
        'animation.${metadata.namespace}.$shortName.idle': {
          'loop': true,
          'animation_length': 3.0,
          'bones': {
            'body': {
              'position': {
                '0.0': [0, 0, 0],
                '1.5': [0, 1, 0],
                '3.0': [0, 0, 0],
              }
            }
          }
        },
        'animation.${metadata.namespace}.$shortName.move': {
          'loop': true,
          'animation_length': 1.0,
          'bones': {
            'body': {
              'rotation': {
                '0.0': [5, 0, 0],
                '0.5': [10, 0, 0],
                '1.0': [5, 0, 0],
              }
            }
          }
        }
      }
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(animations);
    return AddonFile.json('animations/$shortName.a.json', jsonString);
  }

  /// Generate identifier (same as behavior pack)
  static String _generateIdentifier(
    String namespace,
    String type,
    String color,
    String size,
  ) {
    final parts = <String>[];

    if (color != 'normal' && color != 'rainbow') {
      parts.add(color);
    }

    if (size != 'normal') {
      parts.add(size);
    }

    parts.add(type);

    return '$namespace:${parts.join('_')}';
  }

  /// Get material based on effects
  static String _getMaterial(List<dynamic> effects) {
    if (effects.contains('sparkles') || effects.contains('glow')) {
      return 'entity_emissive'; // Glowing material
    }
    if (effects.contains('transparent') || effects.contains('ghost')) {
      return 'entity_alphatest'; // Transparent material
    }
    return 'entity'; // Default solid material
  }

  /// Get spawn egg configuration
  static Map<String, dynamic> _getSpawnEggConfig(
    String colorName,
    Map<String, dynamic> creatureAttributes,
  ) {
    final baseColor = _getHexColor(colorName);
    final overlayColor = _getSecondaryHexColor(colorName);

    return {
      'base_color': baseColor,
      'overlay_color': overlayColor,
    };
  }

  /// Convert color name to hex
  static String _getHexColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return '#FF0000';
      case 'blue':
        return '#0000FF';
      case 'green':
        return '#00FF00';
      case 'yellow':
        return '#FFFF00';
      case 'purple':
        return '#800080';
      case 'pink':
        return '#FFC0CB';
      case 'orange':
        return '#FFA500';
      case 'brown':
        return '#8B4513';
      case 'black':
        return '#000000';
      case 'white':
        return '#FFFFFF';
      case 'gold':
        return '#FFD700';
      case 'silver':
        return '#C0C0C0';
      case 'rainbow':
        return '#FF6B6B'; // Use red as base for rainbow
      default:
        return '#888888'; // Gray default
    }
  }

  /// Get secondary color for spawn egg overlay
  static String _getSecondaryHexColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'rainbow':
        return '#FFD700'; // Gold overlay for rainbow
      case 'red':
        return '#8B0000'; // Dark red
      case 'blue':
        return '#000080'; // Dark blue
      case 'green':
        return '#006400'; // Dark green
      default:
        return '#FFFFFF'; // White default
    }
  }
}
