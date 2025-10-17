import 'dart:math' as math;

/// Service for mapping Crafta attributes to Minecraft components
class BehaviorMappingService {
  /// Map Crafta attributes to Minecraft behavior components
  static Map<String, dynamic> mapToMinecraftComponents(
    Map<String, dynamic> craftaAttributes,
  ) {
    final creatureType = (craftaAttributes['creatureType'] ?? 'cow').toString().toLowerCase();
    final color = (craftaAttributes['color'] ?? 'normal').toString().toLowerCase();
    final size = (craftaAttributes['size'] ?? 'normal').toString().toLowerCase();
    final abilities = (craftaAttributes['abilities'] as List<dynamic>?) ?? [];
    final effects = (craftaAttributes['effects'] as List<dynamic>?) ?? [];

    // Base components for all creatures
    final components = <String, dynamic>{
      'minecraft:type_family': {
        'family': ['monster', 'creature']
      },
      'minecraft:collision_box': {
        'width': _getCollisionWidth(size),
        'height': _getCollisionHeight(size),
      },
      'minecraft:movement': {
        'value': 0.25
      },
      'minecraft:navigation.walk': {
        'can_path_over_water': true,
        'can_sink': false,
        'can_walk': true,
        'can_swim': abilities.contains('swimming'),
      },
      'minecraft:jump.static': {},
      'minecraft:can_climb': {
        'value': abilities.contains('climbing')
      },
      'minecraft:pushable': {
        'value': true
      },
      'minecraft:breathable': {
        'total_supply': 15,
        'suffocate_time': 0,
        'breathes_air': true,
        'breathes_water': abilities.contains('swimming'),
      },
      'minecraft:health': {
        'value': _getHealthValue(size, creatureType),
        'max': _getHealthValue(size, creatureType),
      },
      'minecraft:attack': {
        'damage': _getAttackDamage(creatureType, abilities),
        'range': _getAttackRange(creatureType),
      },
      'minecraft:behavior.nearest_attackable_target': {
        'priority': 2,
        'entity_types': [
          {
            'filters': {
              'test': 'is_family',
              'subject': 'other',
              'value': 'player'
            }
          }
        ],
        'must_see': true,
        'reselect_targets': true,
        'within_radius': 16.0
      },
      'minecraft:behavior.hurt_by_target': {
        'priority': 1,
        'alert_same_type': true
      },
      'minecraft:behavior.look_at_player': {
        'priority': 7,
        'look_distance': 6.0,
        'probability': 0.02
      },
      'minecraft:behavior.random_look_around': {
        'priority': 9
      },
      'minecraft:behavior.random_stroll': {
        'priority': 7,
        'speed_multiplier': 1.0
      },
      'minecraft:behavior.panic': {
        'priority': 1,
        'speed_multiplier': 1.25
      },
      'minecraft:behavior.float': {
        'priority': 0
      },
      'minecraft:behavior.swim': {
        'priority': 0
      },
    };

    // Add creature-specific components
    _addCreatureSpecificComponents(components, creatureType, abilities, effects);
    
    // Add ability-based components
    _addAbilityComponents(components, abilities);
    
    // Add effect-based components
    _addEffectComponents(components, effects);
    
    // Add size-based components
    _addSizeComponents(components, size);
    
    // Add color-based components
    _addColorComponents(components, color);

    return components;
  }

  /// Add creature-specific components
  static void _addCreatureSpecificComponents(
    Map<String, dynamic> components,
    String creatureType,
    List<dynamic> abilities,
    List<dynamic> effects,
  ) {
    switch (creatureType) {
      case 'dragon':
        components['minecraft:type_family'] = {
          'family': ['monster', 'dragon', 'hostile']
        };
        components['minecraft:behavior.dragon_charge_player'] = {
          'priority': 2,
          'speed_multiplier': 1.0
        };
        components['minecraft:behavior.dragon_scanning'] = {
          'priority': 1
        };
        if (abilities.contains('flying')) {
          components['minecraft:behavior.dragon_fly'] = {
            'priority': 0
          };
        }
        break;
        
      case 'unicorn':
        components['minecraft:type_family'] = {
          'family': ['monster', 'unicorn', 'magical']
        };
        components['minecraft:behavior.unicorn_heal'] = {
          'priority': 3,
          'heal_amount': 2.0
        };
        if (abilities.contains('flying')) {
          components['minecraft:behavior.unicorn_fly'] = {
            'priority': 0
          };
        }
        break;
        
      case 'phoenix':
        components['minecraft:type_family'] = {
          'family': ['monster', 'phoenix', 'fire']
        };
        components['minecraft:behavior.phoenix_rebirth'] = {
          'priority': 1,
          'rebirth_time': 5.0
        };
        if (abilities.contains('flying')) {
          components['minecraft:behavior.phoenix_fly'] = {
            'priority': 0
          };
        }
        break;
        
      case 'cow':
        components['minecraft:type_family'] = {
          'family': ['monster', 'cow', 'passive']
        };
        components['minecraft:behavior.breed'] = {
          'priority': 2,
          'speed_multiplier': 1.0
        };
        components['minecraft:behavior.follow_parent'] = {
          'priority': 6,
          'speed_multiplier': 1.0
        };
        break;
        
      case 'pig':
        components['minecraft:type_family'] = {
          'family': ['monster', 'pig', 'passive']
        };
        components['minecraft:behavior.breed'] = {
          'priority': 2,
          'speed_multiplier': 1.0
        };
        components['minecraft:behavior.follow_parent'] = {
          'priority': 6,
          'speed_multiplier': 1.0
        };
        break;
        
      case 'chicken':
        components['minecraft:type_family'] = {
          'family': ['monster', 'chicken', 'passive']
        };
        components['minecraft:behavior.breed'] = {
          'priority': 2,
          'speed_multiplier': 1.0
        };
        components['minecraft:behavior.follow_parent'] = {
          'priority': 6,
          'speed_multiplier': 1.0
        };
        break;
        
      case 'sheep':
        components['minecraft:type_family'] = {
          'family': ['monster', 'sheep', 'passive']
        };
        components['minecraft:behavior.breed'] = {
          'priority': 2,
          'speed_multiplier': 1.0
        };
        components['minecraft:behavior.follow_parent'] = {
          'priority': 6,
          'speed_multiplier': 1.0
        };
        break;
        
      case 'horse':
        components['minecraft:type_family'] = {
          'family': ['monster', 'horse', 'passive']
        };
        components['minecraft:behavior.breed'] = {
          'priority': 2,
          'speed_multiplier': 1.0
        };
        components['minecraft:behavior.follow_parent'] = {
          'priority': 6,
          'speed_multiplier': 1.0
        };
        break;
        
      case 'cat':
        components['minecraft:type_family'] = {
          'family': ['monster', 'cat', 'passive']
        };
        components['minecraft:behavior.breed'] = {
          'priority': 2,
          'speed_multiplier': 1.0
        };
        components['minecraft:behavior.follow_parent'] = {
          'priority': 6,
          'speed_multiplier': 1.0
        };
        break;
        
      case 'dog':
        components['minecraft:type_family'] = {
          'family': ['monster', 'dog', 'passive']
        };
        components['minecraft:behavior.breed'] = {
          'priority': 2,
          'speed_multiplier': 1.0
        };
        components['minecraft:behavior.follow_parent'] = {
          'priority': 6,
          'speed_multiplier': 1.0
        };
        break;
    }
  }

  /// Add ability-based components
  static void _addAbilityComponents(
    Map<String, dynamic> components,
    List<dynamic> abilities,
  ) {
    for (final ability in abilities) {
      final abilityStr = ability.toString().toLowerCase();
      
      switch (abilityStr) {
        case 'flying':
          components['minecraft:behavior.fly'] = {
            'priority': 0,
            'speed_multiplier': 1.0
          };
          components['minecraft:behavior.fly_wander'] = {
            'priority': 1,
            'speed_multiplier': 1.0
          };
          break;
          
        case 'swimming':
          components['minecraft:behavior.swim'] = {
            'priority': 0
          };
          components['minecraft:behavior.swim_wander'] = {
            'priority': 1,
            'speed_multiplier': 1.0
          };
          break;
          
        case 'climbing':
          components['minecraft:behavior.climb'] = {
            'priority': 0
          };
          break;
          
        case 'fire_breath':
          components['minecraft:behavior.fire_breath'] = {
            'priority': 2,
            'damage': 3.0,
            'range': 5.0
          };
          break;
          
        case 'ice_breath':
          components['minecraft:behavior.ice_breath'] = {
            'priority': 2,
            'damage': 2.0,
            'range': 5.0,
            'slowness_duration': 5.0
          };
          break;
          
        case 'healing':
          components['minecraft:behavior.heal_others'] = {
            'priority': 3,
            'heal_amount': 2.0,
            'range': 3.0
          };
          break;
          
        case 'teleportation':
          components['minecraft:behavior.teleport'] = {
            'priority': 1,
            'max_range': 10.0
          };
          break;
          
        case 'invisibility':
          components['minecraft:behavior.invisible'] = {
            'priority': 0
          };
          break;
          
        case 'speed':
          components['minecraft:movement'] = {
            'value': 0.5
          };
          break;
          
        case 'strength':
          components['minecraft:attack'] = {
            'damage': (components['minecraft:attack']['damage'] as double) * 1.5,
            'range': (components['minecraft:attack']['range'] as double) * 1.2,
          };
          break;
      }
    }
  }

  /// Add effect-based components
  static void _addEffectComponents(
    Map<String, dynamic> components,
    List<dynamic> effects,
  ) {
    for (final effect in effects) {
      final effectStr = effect.toString().toLowerCase();
      
      switch (effectStr) {
        case 'fire':
          components['minecraft:behavior.fire_aura'] = {
            'priority': 1,
            'damage': 1.0,
            'range': 2.0
          };
          break;
          
        case 'ice':
          components['minecraft:behavior.ice_aura'] = {
            'priority': 1,
            'damage': 1.0,
            'range': 2.0,
            'slowness_duration': 3.0
          };
          break;
          
        case 'poison':
          components['minecraft:behavior.poison_aura'] = {
            'priority': 1,
            'damage': 1.0,
            'range': 2.0,
            'poison_duration': 5.0
          };
          break;
          
        case 'lightning':
          components['minecraft:behavior.lightning_aura'] = {
            'priority': 1,
            'damage': 3.0,
            'range': 3.0
          };
          break;
          
        case 'magic':
          components['minecraft:behavior.magic_aura'] = {
            'priority': 1,
            'damage': 2.0,
            'range': 3.0,
            'effects': ['levitation', 'slowness']
          };
          break;
          
        case 'sparkles':
          components['minecraft:behavior.sparkle_aura'] = {
            'priority': 1,
            'range': 5.0,
            'particle_count': 10
          };
          break;
          
        case 'glow':
          components['minecraft:behavior.glow'] = {
            'priority': 0,
            'brightness': 0.8
          };
          break;
          
        case 'rainbow':
          components['minecraft:behavior.rainbow_aura'] = {
            'priority': 1,
            'range': 5.0,
            'color_cycle_speed': 2.0
          };
          break;
      }
    }
  }

  /// Add size-based components
  static void _addSizeComponents(
    Map<String, dynamic> components,
    String size,
  ) {
    final sizeMultiplier = _getSizeMultiplier(size);
    
    // Update collision box
    components['minecraft:collision_box'] = {
      'width': _getCollisionWidth(size),
      'height': _getCollisionHeight(size),
    };
    
    // Update movement speed
    components['minecraft:movement'] = {
      'value': 0.25 * sizeMultiplier
    };
    
    // Update health
    components['minecraft:health'] = {
      'value': _getHealthValue(size, 'generic'),
      'max': _getHealthValue(size, 'generic'),
    };
    
    // Update attack damage
    components['minecraft:attack'] = {
      'damage': _getAttackDamage('generic', []) * sizeMultiplier,
      'range': _getAttackRange('generic') * sizeMultiplier,
    };
  }

  /// Add color-based components
  static void _addColorComponents(
    Map<String, dynamic> components,
    String color,
  ) {
    switch (color.toLowerCase()) {
      case 'fire':
      case 'red':
        components['minecraft:behavior.fire_immunity'] = {
          'priority': 0
        };
        break;
        
      case 'ice':
      case 'blue':
        components['minecraft:behavior.ice_immunity'] = {
          'priority': 0
        };
        break;
        
      case 'poison':
      case 'green':
        components['minecraft:behavior.poison_immunity'] = {
          'priority': 0
        };
        break;
        
      case 'lightning':
      case 'yellow':
        components['minecraft:behavior.lightning_immunity'] = {
          'priority': 0
        };
        break;
        
      case 'magic':
      case 'purple':
        components['minecraft:behavior.magic_immunity'] = {
          'priority': 0
        };
        break;
        
      case 'rainbow':
        components['minecraft:behavior.rainbow_immunity'] = {
          'priority': 0
        };
        break;
    }
  }

  /// Get collision width based on size
  static double _getCollisionWidth(String size) {
    switch (size.toLowerCase()) {
      case 'tiny': return 0.4;
      case 'small': return 0.6;
      case 'large': return 1.2;
      case 'huge': return 1.6;
      case 'giant': return 2.0;
      default: return 0.8;
    }
  }

  /// Get collision height based on size
  static double _getCollisionHeight(String size) {
    switch (size.toLowerCase()) {
      case 'tiny': return 0.4;
      case 'small': return 0.6;
      case 'large': return 1.2;
      case 'huge': return 1.6;
      case 'giant': return 2.0;
      default: return 0.8;
    }
  }

  /// Get health value based on size and creature type
  static double _getHealthValue(String size, String creatureType) {
    double baseHealth = 10.0;
    
    // Creature type modifiers
    switch (creatureType.toLowerCase()) {
      case 'dragon': baseHealth = 50.0; break;
      case 'phoenix': baseHealth = 30.0; break;
      case 'unicorn': baseHealth = 20.0; break;
      case 'cow': baseHealth = 10.0; break;
      case 'pig': baseHealth = 10.0; break;
      case 'chicken': baseHealth = 4.0; break;
      case 'sheep': baseHealth = 8.0; break;
      case 'horse': baseHealth = 20.0; break;
      case 'cat': baseHealth = 10.0; break;
      case 'dog': baseHealth = 20.0; break;
    }
    
    // Size modifiers
    final sizeMultiplier = _getSizeMultiplier(size);
    return baseHealth * sizeMultiplier;
  }

  /// Get attack damage based on creature type and abilities
  static double _getAttackDamage(String creatureType, List<dynamic> abilities) {
    double baseDamage = 2.0;
    
    // Creature type modifiers
    switch (creatureType.toLowerCase()) {
      case 'dragon': baseDamage = 8.0; break;
      case 'phoenix': baseDamage = 6.0; break;
      case 'unicorn': baseDamage = 4.0; break;
      case 'cow': baseDamage = 2.0; break;
      case 'pig': baseDamage = 2.0; break;
      case 'chicken': baseDamage = 1.0; break;
      case 'sheep': baseDamage = 2.0; break;
      case 'horse': baseDamage = 4.0; break;
      case 'cat': baseDamage = 2.0; break;
      case 'dog': baseDamage = 3.0; break;
    }
    
    // Ability modifiers
    if (abilities.contains('strength')) {
      baseDamage *= 1.5;
    }
    if (abilities.contains('fire_breath')) {
      baseDamage += 2.0;
    }
    if (abilities.contains('ice_breath')) {
      baseDamage += 1.0;
    }
    
    return baseDamage;
  }

  /// Get attack range based on creature type
  static double _getAttackRange(String creatureType) {
    switch (creatureType.toLowerCase()) {
      case 'dragon': return 3.0;
      case 'phoenix': return 2.5;
      case 'unicorn': return 2.0;
      case 'cow': return 1.0;
      case 'pig': return 1.0;
      case 'chicken': return 1.0;
      case 'sheep': return 1.0;
      case 'horse': return 1.5;
      case 'cat': return 1.0;
      case 'dog': return 1.0;
      default: return 1.0;
    }
  }

  /// Get size multiplier
  static double _getSizeMultiplier(String size) {
    switch (size.toLowerCase()) {
      case 'tiny': return 0.5;
      case 'small': return 0.7;
      case 'large': return 1.3;
      case 'huge': return 1.5;
      case 'giant': return 2.0;
      default: return 1.0;
    }
  }

  /// Get Minecraft entity type from Crafta creature type
  static String getMinecraftEntityType(String craftaType) {
    switch (craftaType.toLowerCase()) {
      case 'dragon': return 'minecraft:dragon';
      case 'unicorn': return 'minecraft:horse';
      case 'phoenix': return 'minecraft:chicken';
      case 'cow': return 'minecraft:cow';
      case 'pig': return 'minecraft:pig';
      case 'chicken': return 'minecraft:chicken';
      case 'sheep': return 'minecraft:sheep';
      case 'horse': return 'minecraft:horse';
      case 'cat': return 'minecraft:cat';
      case 'dog': return 'minecraft:wolf';
      default: return 'minecraft:cow';
    }
  }

  /// Get Minecraft spawn egg color
  static String getMinecraftSpawnEggColor(String color) {
    switch (color.toLowerCase()) {
      case 'red': return 'FF0000';
      case 'blue': return '0000FF';
      case 'green': return '00FF00';
      case 'yellow': return 'FFFF00';
      case 'purple': return '800080';
      case 'orange': return 'FFA500';
      case 'pink': return 'FFC0CB';
      case 'brown': return '8B4513';
      case 'black': return '000000';
      case 'white': return 'FFFFFF';
      case 'grey': return '808080';
      case 'rainbow': return 'FF00FF';
      default: return 'FFFFFF';
    }
  }
}


