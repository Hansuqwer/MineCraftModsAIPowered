import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

/// Enhanced Minecraft mod generator with comprehensive creature data
class MinecraftModGenerator {
  static const String _modNamespace = 'crafta_creatures';
  static const String _modVersion = '1.0.0';
  static const String _minEngineVersion = '1.20.0';

  /// Generate a complete Minecraft mod from creature data
  static Future<File> generateMod({
    required Map<String, dynamic> creatureData,
    required String creatureName,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final modDir = Directory('${tempDir.path}/crafta_mod_${DateTime.now().millisecondsSinceEpoch}');
    await modDir.create(recursive: true);

    // Generate manifest
    await _generateManifest(modDir, creatureName);
    
    // Generate entity behavior
    await _generateEntityBehavior(modDir, creatureData, creatureName);
    
    // Generate entity resource
    await _generateEntityResource(modDir, creatureData, creatureName);
    
    // Generate textures
    await _generateTextures(modDir, creatureData, creatureName);
    
    // Generate animations
    await _generateAnimations(modDir, creatureData, creatureName);
    
    // Generate spawn rules
    await _generateSpawnRules(modDir, creatureData, creatureName);
    
    // Generate loot table
    await _generateLootTable(modDir, creatureData, creatureName);
    
    // Generate trading
    await _generateTrading(modDir, creatureData, creatureName);
    
    // Create .mcpack file
    final mcpackFile = await _createMcpackFile(modDir, creatureName);
    
    // Cleanup
    await modDir.delete(recursive: true);
    
    return mcpackFile;
  }

  /// Generate mod manifest
  static Future<void> _generateManifest(Directory modDir, String creatureName) async {
    final manifest = {
      'format_version': 2,
      'header': {
        'description': 'Crafta AI-Generated Creature: $creatureName',
        'name': 'Crafta Creatures - $creatureName',
        'uuid': _generateUUID(),
        'version': [1, 0, 0],
        'min_engine_version': [1, 20, 0]
      },
      'modules': [
        {
          'description': 'Crafta AI-Generated Creature: $creatureName',
          'language': 'javascript',
          'type': 'data',
          'uuid': _generateUUID(),
          'version': [1, 0, 0]
        }
      ]
    };

    final manifestFile = File('${modDir.path}/manifest.json');
    await manifestFile.writeAsString(jsonEncode(manifest));
  }

  /// Generate entity behavior file
  static Future<void> _generateEntityBehavior(Directory modDir, Map<String, dynamic> creatureData, String creatureName) async {
    final behaviorDir = Directory('${modDir.path}/entities');
    await behaviorDir.create(recursive: true);

    final entityId = _sanitizeName(creatureName);
    final displayName = creatureData['name'] ?? creatureName;
    final description = creatureData['description'] ?? 'A magical creature created by Crafta AI';
    
    final behavior = {
      'format_version': '1.20.0',
      'minecraft:entity': {
        'description': {
          'identifier': 'crafta_creatures:$entityId',
          'is_spawnable': true,
          'is_summonable': true,
          'is_experimental': false,
          'animations': {
            'walk': 'animation.$entityId.walk',
            'idle': 'animation.$entityId.idle',
            'attack': 'animation.$entityId.attack',
            'death': 'animation.$entityId.death'
          },
          'scripts': {
            'animate': ['walk', 'idle', 'attack', 'death']
          }
        },
        'component_groups': {
          'movement': {
            'minecraft:navigation.walk': {
              'can_path_over_water': true,
              'can_sink': false,
              'can_swim': true,
              'can_walk': true,
              'can_breach': true,
              'avoid_water': false,
              'avoid_damage_blocks': true
            },
            'minecraft:movement': {
              'value': 0.25
            },
            'minecraft:jump.static': {
              'jump_power': 0.5
            }
          },
          'health': {
            'minecraft:health': {
              'value': creatureData['health'] ?? 20,
              'max': creatureData['maxHealth'] ?? 20
            }
          },
          'combat': {
            'minecraft:attack': {
              'damage': creatureData['attackDamage'] ?? 2
            },
            'minecraft:behavior.melee_attack': {
              'priority': 2,
              'speed_multiplier': 1.0
            }
          },
          'ai': {
            'minecraft:behavior.float': {
              'priority': 0
            },
            'minecraft:behavior.panic': {
              'priority': 1,
              'speed_multiplier': 1.25
            },
            'minecraft:behavior.avoid_mob_type': {
              'priority': 2,
              'entity_types': [
                {
                  'filters': {
                    'test': 'is_family',
                    'subject': 'other',
                    'value': 'monster'
                  }
                }
              ],
              'max_dist': 8.0,
              'walk_speed_multiplier': 1.0,
              'sprint_speed_multiplier': 1.0
            },
            'minecraft:behavior.random_look_around': {
              'priority': 9
            },
            'minecraft:behavior.look_at_player': {
              'priority': 8,
              'look_distance': 6.0,
              'probability': 0.02
            }
          }
        },
        'components': {
          'minecraft:type_family': {
            'family': ['crafta_creature', entityId]
          },
          'minecraft:collision_box': {
            'width': creatureData['width'] ?? 0.6,
            'height': creatureData['height'] ?? 1.8
          },
          'minecraft:can_climb': {},
          'minecraft:pushable': {
            'is_pushable': true,
            'is_pushable_by_piston': true
          },
          'minecraft:breathable': {
            'total_supply': 15,
            'suffocate_time': 0,
            'inhale_time': 0,
            'breathes_air': true,
            'breathes_water': false
          },
          'minecraft:nameable': {
            'always_show': false,
            'allow_name_tag_renaming': true,
            'requires_direct_power': false
          },
          'minecraft:leashable': {
            'soft_distance': 4.0,
            'hard_distance': 6.0,
            'max_distance': 10.0
          }
        },
        'component_groups': {
          'movement': {
            'minecraft:navigation.walk': {
              'can_path_over_water': true,
              'can_sink': false,
              'can_swim': true,
              'can_walk': true,
              'can_breach': true,
              'avoid_water': false,
              'avoid_damage_blocks': true
            },
            'minecraft:movement': {
              'value': creatureData['movementSpeed'] ?? 0.25
            },
            'minecraft:jump.static': {
              'jump_power': creatureData['jumpPower'] ?? 0.5
            }
          }
        }
      }
    };

    final behaviorFile = File('${behaviorDir.path}/$entityId.json');
    await behaviorFile.writeAsString(jsonEncode(behavior));
  }

  /// Generate entity resource file
  static Future<void> _generateEntityResource(Directory modDir, Map<String, dynamic> creatureData, String creatureName) async {
    final resourceDir = Directory('${modDir.path}/entity');
    await resourceDir.create(recursive: true);

    final entityId = _sanitizeName(creatureName);
    final displayName = creatureData['name'] ?? creatureName;
    
    final resource = {
      'format_version': '1.20.0',
      'minecraft:client_entity': {
        'description': {
          'identifier': 'crafta_creatures:$entityId',
          'materials': {
            'default': 'entity_alphatest'
          },
          'textures': {
            'default': 'textures/entity/$entityId'
          },
          'geometry': {
            'default': 'geometry.$entityId'
          },
          'animations': {
            'walk': 'animation.$entityId.walk',
            'idle': 'animation.$entityId.idle',
            'attack': 'animation.$entityId.attack',
            'death': 'animation.$entityId.death'
          },
          'scripts': {
            'animate': ['walk', 'idle', 'attack', 'death']
          },
          'render_controllers': ['controller.render.$entityId']
        }
      }
    };

    final resourceFile = File('${resourceDir.path}/$entityId.json');
    await resourceFile.writeAsString(jsonEncode(resource));
  }

  /// Generate creature textures
  static Future<void> _generateTextures(Directory modDir, Map<String, dynamic> creatureData, String creatureName) async {
    final textureDir = Directory('${modDir.path}/textures/entity');
    await textureDir.create(recursive: true);

    final entityId = _sanitizeName(creatureName);
    final primaryColor = creatureData['primaryColor'] ?? '#FF6B6B';
    final secondaryColor = creatureData['secondaryColor'] ?? '#4ECDC4';
    
    // Generate a simple colored texture based on creature data
    final textureData = _generateTextureData(primaryColor, secondaryColor, creatureData);
    
    final textureFile = File('${textureDir.path}/$entityId.png');
    await textureFile.writeAsBytes(textureData);
  }

  /// Generate creature animations
  static Future<void> _generateAnimations(Directory modDir, Map<String, dynamic> creatureData, String creatureName) async {
    final animationDir = Directory('${modDir.path}/animations');
    await animationDir.create(recursive: true);

    final entityId = _sanitizeName(creatureName);
    
    final animations = {
      'format_version': '1.20.0',
      'animations': {
        'animation.$entityId.walk': {
          'loop': true,
          'animation_length': 1.0,
          'bones': {
            'root': {
              'rotation': {
                '0.0': [0, 0, 0],
                '0.5': [0, 5, 0],
                '1.0': [0, 0, 0]
              }
            },
            'leg1': {
              'rotation': {
                '0.0': [0, 0, 0],
                '0.25': [30, 0, 0],
                '0.75': [-30, 0, 0],
                '1.0': [0, 0, 0]
              }
            },
            'leg2': {
              'rotation': {
                '0.0': [0, 0, 0],
                '0.25': [-30, 0, 0],
                '0.75': [30, 0, 0],
                '1.0': [0, 0, 0]
              }
            }
          }
        },
        'animation.$entityId.idle': {
          'loop': true,
          'animation_length': 2.0,
          'bones': {
            'root': {
              'rotation': {
                '0.0': [0, 0, 0],
                '1.0': [0, 2, 0],
                '2.0': [0, 0, 0]
              }
            }
          }
        },
        'animation.$entityId.attack': {
          'loop': false,
          'animation_length': 0.5,
          'bones': {
            'root': {
              'rotation': {
                '0.0': [0, 0, 0],
                '0.25': [0, 0, 15],
                '0.5': [0, 0, 0]
              }
            }
          }
        },
        'animation.$entityId.death': {
          'loop': false,
          'animation_length': 1.0,
          'bones': {
            'root': {
              'rotation': {
                '0.0': [0, 0, 0],
                '1.0': [0, 0, 90]
              }
            }
          }
        }
      }
    };

    final animationFile = File('${animationDir.path}/$entityId.animation.json');
    await animationFile.writeAsString(jsonEncode(animations));
  }

  /// Generate spawn rules
  static Future<void> _generateSpawnRules(Directory modDir, Map<String, dynamic> creatureData, String creatureName) async {
    final spawnDir = Directory('${modDir.path}/spawn_rules');
    await spawnDir.create(recursive: true);

    final entityId = _sanitizeName(creatureName);
    
    final spawnRules = {
      'format_version': '1.20.0',
      'minecraft:spawn_rules': {
        'description': {
          'identifier': 'crafta_creatures:$entityId',
          'population_control': 'passive'
        },
        'conditions': [
          {
            'minecraft:spawns_on_surface': {},
            'minecraft:brightness_filter': {
              'min': 0,
              'max': 15,
              'adjust_for_weather': true
            },
            'minecraft:difficulty_filter': {
              'min': 'easy',
              'max': 'hard'
            },
            'minecraft:weight': {
              'default': 10
            },
            'minecraft:herd': {
              'min_size': 1,
              'max_size': 3
            },
            'minecraft:permute_type': 1,
            'minecraft:biome_filter': {
              'test': 'has_biome_tag',
              'value': 'plains'
            }
          }
        ]
      }
    };

    final spawnFile = File('${spawnDir.path}/$entityId.json');
    await spawnFile.writeAsString(jsonEncode(spawnRules));
  }

  /// Generate loot table
  static Future<void> _generateLootTable(Directory modDir, Map<String, dynamic> creatureData, String creatureName) async {
    final lootDir = Directory('${modDir.path}/loot_tables/entities');
    await lootDir.create(recursive: true);

    final entityId = _sanitizeName(creatureName);
    
    final lootTable = {
      'pools': [
        {
          'rolls': 1,
          'entries': [
            {
              'type': 'item',
              'name': 'minecraft:leather',
              'weight': 1,
              'functions': [
                {
                  'function': 'set_count',
                  'count': {
                    'min': 0,
                    'max': 2
                  }
                }
              ]
            }
          ]
        }
      ]
    };

    final lootFile = File('${lootDir.path}/$entityId.json');
    await lootFile.writeAsString(jsonEncode(lootTable));
  }

  /// Generate trading
  static Future<void> _generateTrading(Directory modDir, Map<String, dynamic> creatureData, String creatureName) async {
    final tradingDir = Directory('${modDir.path}/trading');
    await tradingDir.create(recursive: true);

    final entityId = _sanitizeName(creatureName);
    
    final trading = {
      'tiers': [
        {
          'trades': [
            {
              'wants': [
                {
                  'item': 'minecraft:wheat',
                  'quantity': {
                    'min': 1,
                    'max': 3
                  }
                }
              ],
              'gives': [
                {
                  'item': 'minecraft:emerald',
                  'quantity': 1
                }
              ]
            }
          ]
        }
      ]
    };

    final tradingFile = File('${tradingDir.path}/$entityId.json');
    await tradingFile.writeAsString(jsonEncode(trading));
  }

  /// Create .mcpack file
  static Future<File> _createMcpackFile(Directory modDir, String creatureName) async {
    final archive = Archive();
    
    // Add all files to archive
    await for (final entity in modDir.list(recursive: true)) {
      if (entity is File) {
        final relativePath = entity.path.substring(modDir.path.length + 1);
        final fileData = await entity.readAsBytes();
        archive.addFile(ArchiveFile(relativePath, fileData.length, fileData));
      }
    }

    // Create .mcpack file
    final documentsDir = await getApplicationDocumentsDirectory();
    final mcpackFile = File('${documentsDir.path}/crafta_${_sanitizeName(creatureName)}_${DateTime.now().millisecondsSinceEpoch}.mcpack');
    
    final zipData = ZipEncoder().encode(archive);
    await mcpackFile.writeAsBytes(zipData!);
    
    return mcpackFile;
  }

  /// Generate texture data (simplified)
  static List<int> _generateTextureData(String primaryColor, String secondaryColor, Map<String, dynamic> creatureData) {
    // This is a simplified texture generator
    // In a real implementation, you'd generate actual PNG data
    return List.generate(64 * 64 * 4, (index) => index % 4 == 3 ? 255 : 128);
  }

  /// Sanitize name for Minecraft identifiers
  static String _sanitizeName(String name) {
    return name.toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  /// Generate UUID for mod files
  static String _generateUUID() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return '${random.toString().padLeft(8, '0')}-0000-4000-8000-${random.toString().padLeft(12, '0')}';
  }
}
