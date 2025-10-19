import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';
import '../models/enhanced_creature_attributes.dart';
import 'ai_animation_service.dart';

/// AI-Powered Minecraft Export Service
/// Based on Bedrock Wiki: https://wiki.bedrock.dev/
class AIMinecraftExportService {
  final AIAnimationService _animationService = AIAnimationService();
  
  /// Export AI-created item to Minecraft Bedrock format
  /// Based on Bedrock Wiki structure
  Future<bool> exportAICreatedItem({
    required EnhancedCreatureAttributes itemAttributes,
    required String itemName,
    String? customDescription,
  }) async {
    try {
      print('📦 Starting export for: $itemName');
      print('   Type: ${itemAttributes.baseType}');
      print('   Size: ${itemAttributes.size}');
      print('   Color: ${itemAttributes.primaryColor}');
      
      // Create export directory structure
      final exportDir = Directory('exports/${itemName.toLowerCase().replaceAll(' ', '_')}');
      print('📁 Export directory: ${exportDir.path}');
      
      if (await exportDir.exists()) {
        print('🗑️ Removing existing export directory');
        await exportDir.delete(recursive: true);
      }
      
      print('📁 Creating export directory...');
      await exportDir.create(recursive: true);
      print('✅ Export directory created');
      
      // Generate Bedrock-compatible files
      print('📄 Creating manifest...');
      await _createManifest(exportDir, itemName);
      
      print('📄 Creating item definition...');
      await _createItemDefinition(exportDir, itemAttributes, itemName);
      
      print('📄 Creating entity definition...');
      await _createEntityDefinition(exportDir, itemAttributes, itemName);
      
      print('📄 Creating animation files...');
      await _createAnimationFiles(exportDir, itemAttributes, itemName);
      
      print('📄 Creating texture files...');
      await _createTextureFiles(exportDir, itemAttributes, itemName);
      
      // Create .mcpack file
      print('📦 Creating .mcpack file...');
      await _createMcpackFile(exportDir, itemName);
      
      print('✅ Export completed successfully!');
      return true;
    } catch (e) {
      print('❌ Error exporting AI item: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return false;
    }
  }
  
  /// Create manifest.json based on Bedrock Wiki format
  Future<void> _createManifest(Directory exportDir, String itemName) async {
    final manifest = {
      'format_version': 2,
      'header': {
        'description': 'AI-Generated $itemName by Crafta',
        'name': 'Crafta AI $itemName',
        'uuid': _generateUUID(),
        'version': [1, 0, 0],
        'min_engine_version': [1, 20, 0]
      },
      'modules': [
        {
          'type': 'data',
          'uuid': _generateUUID(),
          'version': [1, 0, 0]
        },
        {
          'type': 'resources',
          'uuid': _generateUUID(),
          'version': [1, 0, 0]
        }
      ]
    };
    
    final manifestFile = File(path.join(exportDir.path, 'manifest.json'));
    await manifestFile.writeAsString(jsonEncode(manifest));
  }
  
  /// Create item definition based on Bedrock Wiki item format
  Future<void> _createItemDefinition(
    Directory exportDir, 
    EnhancedCreatureAttributes attributes, 
    String itemName
  ) async {
    final itemDef = {
      'format_version': '1.20.0',
      'minecraft:item': {
        'description': {
          'identifier': 'crafta:${itemName.toLowerCase().replaceAll(' ', '_')}',
          'menu_category': {
            'category': _getItemCategory(attributes.baseType),
            'group': 'itemGroup.name.tools'
          }
        },
        'components': {
          'minecraft:icon': {
            'texture': '${itemName.toLowerCase().replaceAll(' ', '_')}_icon'
          },
          'minecraft:display_name': {
            'value': itemName
          },
          'minecraft:max_stack_size': 1,
          'minecraft:hand_equipped': true,
          'minecraft:durability': _getDurability(attributes),
          'minecraft:damage': _getDamage(attributes),
          'minecraft:enchantable': {
            'slot': 'main_hand',
            'value': 10
          }
        }
      }
    };
    
    final itemsDir = Directory(path.join(exportDir.path, 'items'));
    await itemsDir.create(recursive: true);
    
    final itemFile = File(path.join(itemsDir.path, '${itemName.toLowerCase().replaceAll(' ', '_')}.json'));
    await itemFile.writeAsString(jsonEncode(itemDef));
  }
  
  /// Create entity definition for creatures
  Future<void> _createEntityDefinition(
    Directory exportDir,
    EnhancedCreatureAttributes attributes,
    String itemName
  ) async {
    if (!_isCreature(attributes.baseType)) return;
    
    final entityDef = {
      'format_version': '1.20.0',
      'minecraft:entity': {
        'description': {
          'identifier': 'crafta:${itemName.toLowerCase().replaceAll(' ', '_')}',
          'is_spawnable': true,
          'is_summonable': true,
          'is_experimental': false
        },
        'component_groups': {
          'crafta:ai_enhanced': {
            'minecraft:behavior.float': {},
            'minecraft:behavior.panic': {
              'speed_multiplier': 1.25
            },
            'minecraft:behavior.random_look_around': {},
            'minecraft:behavior.wander': {
              'priority': 7,
              'speed_multiplier': 1.0
            }
          }
        },
        'components': {
          'minecraft:type_family': {'family': ['crafta', 'ai_generated']},
          'minecraft:collision_box': _getCollisionBox(attributes.size),
          'minecraft:health': {'value': _getHealth(attributes)},
          'minecraft:movement': {'value': _getMovementSpeed(attributes)},
          'minecraft:jump.static': {},
          'minecraft:navigation.walk': {
            'can_path_over_water': attributes.abilities.contains(SpecialAbility.swimming),
            'can_sink': !attributes.abilities.contains(SpecialAbility.swimming)
          }
        }
      }
    };
    
    final entitiesDir = Directory(path.join(exportDir.path, 'entities'));
    await entitiesDir.create(recursive: true);
    
    final entityFile = File(path.join(entitiesDir.path, '${itemName.toLowerCase().replaceAll(' ', '_')}.json'));
    await entityFile.writeAsString(jsonEncode(entityDef));
  }
  
  /// Create animation files based on AI animation service
  Future<void> _createAnimationFiles(
    Directory exportDir,
    EnhancedCreatureAttributes attributes,
    String itemName
  ) async {
    final animationsDir = Directory(path.join(exportDir.path, 'animations'));
    await animationsDir.create(recursive: true);
    
    // Generate AI-powered animations
    final animationContent = {
      'format_version': '1.20.0',
      'animations': {
        'animation.${itemName.toLowerCase().replaceAll(' ', '_')}.idle': {
          'anim_time_update': _animationService.generateAnimationFunction(
            animationType: 'bob',
            speed: 100.0,
            pitch: 5.0,
          ),
          'loop': true,
          'bones': {
            'root': {
              'position': [0, 0, 0],
              'rotation': [0, 0, 0]
            }
          }
        }
      }
    };
    
    final animationFile = File(path.join(animationsDir.path, '${itemName.toLowerCase().replaceAll(' ', '_')}.animation.json'));
    await animationFile.writeAsString(jsonEncode(animationContent));
  }
  
  /// Create texture files based on item attributes
  Future<void> _createTextureFiles(
    Directory exportDir,
    EnhancedCreatureAttributes attributes,
    String itemName
  ) async {
    final texturesDir = Directory(path.join(exportDir.path, 'textures'));
    await texturesDir.create(recursive: true);
    
    // Generate texture atlas
    final textureAtlas = {
      'resource_pack_name': 'Crafta AI Items',
      'texture_name': 'atlas.terrain',
      'texture_data': {
        '${itemName.toLowerCase().replaceAll(' ', '_')}_icon': {
          'textures': 'textures/items/${itemName.toLowerCase().replaceAll(' ', '_')}'
        }
      }
    };
    
    final atlasFile = File(path.join(texturesDir.path, 'texture_list.json'));
    await atlasFile.writeAsString(jsonEncode(textureAtlas));
  }
  
  // Helper methods
  String _generateUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replaceAllMapped(
      RegExp(r'[xy]'),
      (match) {
        final r = (DateTime.now().millisecondsSinceEpoch + (match.start * 1000)) % 16;
        final v = match.group(0) == 'x' ? r : (r & 0x3 | 0x8);
        return v.toRadixString(16);
      },
    );
  }
  
  String _getItemCategory(String baseType) {
    switch (baseType.toLowerCase()) {
      case 'sword':
      case 'bow':
        return 'combat';
      case 'pickaxe':
      case 'axe':
      case 'shovel':
      case 'hoe':
        return 'tools';
      case 'helmet':
      case 'chestplate':
      case 'boots':
        return 'armor';
      default:
        return 'misc';
    }
  }
  
  int _getDurability(EnhancedCreatureAttributes attributes) {
    if (attributes.baseType.contains('diamond')) return 1561;
    if (attributes.baseType.contains('iron')) return 250;
    if (attributes.baseType.contains('gold')) return 32;
    if (attributes.baseType.contains('stone')) return 131;
    return 59; // Wood
  }
  
  double _getDamage(EnhancedCreatureAttributes attributes) {
    if (attributes.baseType.contains('diamond')) return 7.0;
    if (attributes.baseType.contains('iron')) return 6.0;
    if (attributes.baseType.contains('stone')) return 4.0;
    if (attributes.baseType.contains('gold')) return 4.0;
    return 2.0; // Wood
  }
  
  bool _isCreature(String baseType) {
    return ['cow', 'pig', 'chicken', 'sheep', 'horse', 'cat', 'dog', 'dragon', 'unicorn'].contains(baseType.toLowerCase());
  }
  
  Map<String, dynamic> _getCollisionBox(CreatureSize size) {
    switch (size) {
      case CreatureSize.tiny:
        return {'width': 0.4, 'height': 0.4};
      case CreatureSize.small:
        return {'width': 0.6, 'height': 0.6};
      case CreatureSize.medium:
        return {'width': 0.8, 'height': 0.8};
      case CreatureSize.large:
        return {'width': 1.0, 'height': 1.0};
      case CreatureSize.giant:
        return {'width': 1.2, 'height': 1.2};
    }
  }
  
  int _getHealth(EnhancedCreatureAttributes attributes) {
    switch (attributes.size) {
      case CreatureSize.tiny: return 5;
      case CreatureSize.small: return 10;
      case CreatureSize.medium: return 20;
      case CreatureSize.large: return 30;
      case CreatureSize.giant: return 50;
    }
  }
  
  double _getMovementSpeed(EnhancedCreatureAttributes attributes) {
    if (attributes.abilities.contains(SpecialAbility.superSpeed)) return 0.3;
    if (attributes.abilities.contains(SpecialAbility.flying)) return 0.25;
    return 0.2; // Default
  }
  
  /// Create .mcpack file from export directory
  Future<void> _createMcpackFile(Directory exportDir, String itemName) async {
    try {
      final mcpackPath = '${itemName.toLowerCase().replaceAll(' ', '_')}.mcpack';
      final mcpackFile = File(mcpackPath);
      print('📦 Creating .mcpack file: $mcpackPath');
      
      // Create a ZIP archive of the export directory
      final archive = Archive();
      print('📁 Adding files to archive...');
      
      int fileCount = 0;
      // Add all files from export directory to archive
      await for (final entity in exportDir.list(recursive: true)) {
        if (entity is File) {
          final relativePath = path.relative(entity.path, from: exportDir.path);
          final fileData = await entity.readAsBytes();
          archive.addFile(ArchiveFile(relativePath, fileData.length, fileData));
          fileCount++;
          print('   Added: $relativePath');
        }
      }
      
      print('📦 Added $fileCount files to archive');
      
      // Write the ZIP archive as .mcpack file
      print('📦 Encoding ZIP archive...');
      final zipData = ZipEncoder().encode(archive);
      if (zipData != null) {
        print('📦 Writing .mcpack file...');
        await mcpackFile.writeAsBytes(zipData);
        print('✅ Created .mcpack file: $mcpackPath (${zipData.length} bytes)');
      } else {
        print('❌ Failed to create .mcpack file - ZIP encoding failed');
      }
    } catch (e) {
      print('❌ Error creating .mcpack file: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }
}
