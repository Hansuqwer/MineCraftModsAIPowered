import 'dart:convert';
import '../../models/minecraft/addon_file.dart';
import '../../models/minecraft/addon_metadata.dart';
import '../behavior_mapping_service.dart';

/// Generates Minecraft entity behavior files from Crafta creature data
class EntityBehaviorGenerator {
  /// Generate entity behavior file (server-side)
  static AddonFile generateEntityBehavior({
    required Map<String, dynamic> creatureAttributes,
    required AddonMetadata metadata,
  }) {
    final creatureType = (creatureAttributes['creatureType'] ?? 'creature').toString().toLowerCase();
    final colorName = (creatureAttributes['color'] ?? 'normal').toString().toLowerCase();
    final sizeAttr = (creatureAttributes['size'] ?? 'normal').toString().toLowerCase();
    final effects = (creatureAttributes['effects'] as List<dynamic>?) ?? [];
    final abilities = (creatureAttributes['abilities'] as List<dynamic>?) ?? [];

    // Generate identifier
    final identifier = _generateIdentifier(metadata.namespace, creatureType, colorName, sizeAttr);

    // Generate entity behavior JSON
    final entity = {
      'format_version': '1.21.70',
      'minecraft:entity': {
        'description': {
          'identifier': identifier,
          'is_summonable': true,
          'is_spawnable': metadata.generateSpawnEggs,
          'is_experimental': false,
        },
        'components': BehaviorMappingService.mapToMinecraftComponents(creatureAttributes),
      }
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(entity);
    final fileName = 'entities/${identifier.replaceAll(':', '_')}.se.json';
    return AddonFile.json(fileName, jsonString);
  }

  /// Generate unique identifier
  static String _generateIdentifier(
    String namespace,
    String type,
    String color,
    String size,
  ) {
    final parts = <String>[];

    // Add color if not normal
    if (color != 'normal' && color != 'rainbow') {
      parts.add(color);
    }

    // Add size if not normal
    if (size != 'normal') {
      parts.add(size);
    }

    // Add type
    parts.add(type);

    return '$namespace:${parts.join('_')}';
  }

  /// Calculate health based on size and type
  static int _calculateHealth(String size, String type) {
    int baseHealth = 20; // Default

    // Adjust by type
    switch (type) {
      case 'dragon':
      case 'phoenix':
      case 'griffin':
        baseHealth = 40; // Mythical creatures are stronger
        break;
      case 'cow':
      case 'pig':
      case 'sheep':
        baseHealth = 10; // Passive animals
        break;
      case 'horse':
        baseHealth = 15;
        break;
      case 'cat':
      case 'chicken':
        baseHealth = 8;
        break;
    }

    // Adjust by size
    switch (size) {
      case 'tiny':
        return (baseHealth * 0.7).round();
      case 'giant':
        return (baseHealth * 1.5).round();
      default:
        return baseHealth;
    }
  }

  /// Calculate movement speed
  static double _calculateSpeed(String size, String type, List<dynamic> abilities) {
    double baseSpeed = 0.2; // Default walking speed

    // Adjust by type
    if (abilities.contains('fast') || abilities.contains('flying')) {
      baseSpeed = 0.3;
    }

    // Adjust by size
    switch (size) {
      case 'tiny':
        return baseSpeed * 0.8;
      case 'giant':
        return baseSpeed * 0.6;
      default:
        return baseSpeed;
    }
  }

  /// Get collision box based on size
  static Map<String, dynamic> _getCollisionBox(String size) {
    switch (size) {
      case 'tiny':
        return {'width': 0.5, 'height': 1.0};
      case 'giant':
        return {'width': 1.5, 'height': 3.0};
      default:
        return {'width': 0.8, 'height': 1.8};
    }
  }

  /// Get size scale value
  static Map<String, dynamic> _getSizeScale(String size) {
    switch (size) {
      case 'tiny':
        return {'value': 0.7};
      case 'giant':
        return {'value': 1.5};
      default:
        return {'value': 1.0};
    }
  }

  /// Get movement components based on abilities
  static Map<String, dynamic> _getMovementComponents(
    List<dynamic> abilities,
    String type,
  ) {
    // Check for flying
    final canFly = abilities.contains('flying') ||
        abilities.contains('wings') ||
        type == 'dragon' ||
        type == 'phoenix' ||
        type == 'griffin';

    if (canFly) {
      return {
        'minecraft:movement.fly': {},
        'minecraft:navigation.fly': {
          'can_path_over_water': true,
          'can_path_from_air': true,
        },
      };
    }

    // Default to basic walking
    return {
      'minecraft:movement.basic': {},
    };
  }

  /// Get ability-specific components
  static Map<String, dynamic> _getAbilityComponents(
    List<dynamic> abilities,
    List<dynamic> effects,
  ) {
    final components = <String, dynamic>{};

    // Fire immunity for fire-related creatures
    if (abilities.contains('fire_breathing') ||
        abilities.contains('fire') ||
        effects.contains('fire')) {
      components['minecraft:fire_immune'] = true;
    }

    // Water breathing for aquatic creatures
    if (abilities.contains('swimming') || abilities.contains('water_breathing')) {
      components['minecraft:breathe_water'] = true;
      components['minecraft:movement.amphibious'] = {};
    }

    return components;
  }

  /// Generate a simple idle entity (for testing)
  static AddonFile generateSimpleEntity({
    required String namespace,
    required String entityName,
  }) {
    final identifier = '$namespace:$entityName';

    final entity = {
      'format_version': '1.21.70',
      'minecraft:entity': {
        'description': {
          'identifier': identifier,
          'is_summonable': true,
          'is_spawnable': true,
        },
        'components': {
          'minecraft:type_family': {'family': ['$namespace\_creature']},
          'minecraft:health': {'value': 20, 'max': 20},
          'minecraft:movement': {'value': 0.2},
          'minecraft:collision_box': {'width': 0.8, 'height': 1.8},
          'minecraft:physics': {},
          'minecraft:jump.static': {},
          'minecraft:movement.basic': {},
          'minecraft:navigation.walk': {
            'can_walk': true,
            'can_pass_doors': true,
          },
          'minecraft:behavior.random_stroll': {'priority': 6},
          'minecraft:behavior.random_look_around': {'priority': 7},
        }
      }
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(entity);
    return AddonFile.json('entities/${entityName}.se.json', jsonString);
  }
}
