import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

import '../../models/minecraft/addon_metadata.dart';
import '../../models/minecraft/addon_package.dart';
import '../../models/minecraft/addon_file.dart';
import 'simple_script_api_generator.dart';
import 'geometry_generator.dart';
import '../../models/minecraft/behavior_pack.dart';
import '../../models/minecraft/resource_pack.dart';
import 'manifest_generator.dart';
import 'entity_behavior_generator.dart';
import 'entity_client_generator.dart';
import 'geometry_generator.dart';
import 'texture_generator.dart';
import '../behavior_mapping_service.dart';

/// Main service for exporting Crafta creatures as Minecraft addons
class MinecraftExportService {
  /// Export a single creature as a complete addon
  static Future<AddonPackage> exportCreature({
    required Map<String, dynamic> creatureAttributes,
    AddonMetadata? metadata,
  }) async {
    final meta = metadata ?? AddonMetadata.defaultMetadata();

    // Generate UUIDs for packs
    final bpUuid = ManifestGenerator.generateUuid();
    final bpModuleUuid = ManifestGenerator.generateUuid();
    final rpUuid = ManifestGenerator.generateUuid();
    final rpModuleUuid = ManifestGenerator.generateUuid();

    // Generate behavior pack
    final behaviorPack = await _generateBehaviorPack(
      creature: creatureAttributes,
      metadata: meta,
      packUuid: bpUuid,
      moduleUuid: bpModuleUuid,
    );

    // Generate resource pack
    final resourcePack = await _generateResourcePack(
      creature: creatureAttributes,
      metadata: meta,
      packUuid: rpUuid,
      moduleUuid: rpModuleUuid,
    );

    return AddonPackage(
      metadata: meta,
      behaviorPack: behaviorPack,
      resourcePack: resourcePack,
      createdAt: DateTime.now(),
    );
  }

  /// Export multiple creatures as a single addon
  static Future<AddonPackage> exportMultipleCreatures({
    required List<Map<String, dynamic>> creaturesList,
    AddonMetadata? metadata,
  }) async {
    final meta = metadata ?? AddonMetadata.defaultMetadata();

    // Generate UUIDs for packs
    final bpUuid = ManifestGenerator.generateUuid();
    final bpModuleUuid = ManifestGenerator.generateUuid();
    final rpUuid = ManifestGenerator.generateUuid();
    final rpModuleUuid = ManifestGenerator.generateUuid();

    // Generate behavior pack with multiple entities
    final behaviorPack = await _generateBehaviorPackMulti(
      creatures: creaturesList,
      metadata: meta,
      packUuid: bpUuid,
      moduleUuid: bpModuleUuid,
    );

    // Generate resource pack with multiple entities
    final resourcePack = await _generateResourcePackMulti(
      creatures: creaturesList,
      metadata: meta,
      packUuid: rpUuid,
      moduleUuid: rpModuleUuid,
    );

    return AddonPackage(
      metadata: meta,
      behaviorPack: behaviorPack,
      resourcePack: resourcePack,
      createdAt: DateTime.now(),
    );
  }

  /// Generate behavior pack for a single creature
  static Future<BehaviorPack> _generateBehaviorPack({
    required Map<String, dynamic> creature,
    required AddonMetadata metadata,
    required String packUuid,
    required String moduleUuid,
  }) async {
    // Generate manifest
    final manifest = ManifestGenerator.generateBehaviorPackManifest(
      metadata: metadata,
      packUuid: packUuid,
      moduleUuid: moduleUuid,
    );

    // Generate entity behavior
    final entityBehavior = EntityBehaviorGenerator.generateEntityBehavior(
      creatureAttributes: creature,
      metadata: metadata,
    );

    // Generate Script API files if enabled
    final scriptFiles = <AddonFile>[];
    if (metadata.includeScriptAPI) {
      scriptFiles.addAll([
        SimpleScriptAPIGenerator.generateMainScript(),
        SimpleScriptAPIGenerator.generateSummonScript(creature),
        SimpleScriptAPIGenerator.generateListScript(creature),
        SimpleScriptAPIGenerator.generateInfoScript(creature),
      ]);
    }

    // Generate language file
    final creatureName = creature['creatureName'] ?? 'Creature';
    final creatureType = (creature['creatureType'] ?? 'creature').toString().toLowerCase();
    final languageFile = ManifestGenerator.generateLanguageFile(
      packName: metadata.name,
      description: metadata.description,
      translations: {
        'entity.${metadata.namespace}:$creatureType.name': creatureName,
      },
    );

    final languagesJson = ManifestGenerator.generateLanguagesJson();

    // Use the generated script files
    final scripts = scriptFiles;

    return BehaviorPack(
      uuid: packUuid,
      moduleUuid: moduleUuid,
      manifest: manifest,
      entities: [entityBehavior],
      scripts: scripts,
      texts: [languageFile, languagesJson],
      packIcon: null, // TODO: Add pack icon
    );
  }

  /// Generate behavior pack for multiple creatures
  static Future<BehaviorPack> _generateBehaviorPackMulti({
    required List<Map<String, dynamic>> creatures,
    required AddonMetadata metadata,
    required String packUuid,
    required String moduleUuid,
  }) async {
    final manifest = ManifestGenerator.generateBehaviorPackManifest(
      metadata: metadata,
      packUuid: packUuid,
      moduleUuid: moduleUuid,
    );

    // Generate entity behaviors for all creatures
    final entities = creatures.map((creature) {
      return EntityBehaviorGenerator.generateEntityBehavior(
        creatureAttributes: creature,
        metadata: metadata,
      );
    }).toList();

    // Generate Script API files if enabled
    final scripts = <AddonFile>[];
    if (metadata.includeScriptAPI) {
      // Generate scripts for the first creature (main commands)
      final scriptFiles = [
        SimpleScriptAPIGenerator.generateMainScript(),
        SimpleScriptAPIGenerator.generateSummonScript(creatures.first),
        SimpleScriptAPIGenerator.generateListScript(creatures.first),
        SimpleScriptAPIGenerator.generateInfoScript(creatures.first),
      ];
      scripts.addAll(scriptFiles);
    }

    // Generate translations for all creatures
    final translations = <String, String>{};
    for (final creature in creatures) {
      final creatureName = creature['creatureName'] ?? 'Creature';
      final creatureType = (creature['creatureType'] ?? 'creature').toString().toLowerCase();
      translations['entity.${metadata.namespace}:$creatureType.name'] = creatureName;
    }

    final languageFile = ManifestGenerator.generateLanguageFile(
      packName: metadata.name,
      description: metadata.description,
      translations: translations,
    );

    final languagesJson = ManifestGenerator.generateLanguagesJson();

    return BehaviorPack(
      uuid: packUuid,
      moduleUuid: moduleUuid,
      manifest: manifest,
      entities: entities,
      scripts: scripts,
      texts: [languageFile, languagesJson],
    );
  }

  /// Generate resource pack for a single creature
  static Future<ResourcePack> _generateResourcePack({
    required Map<String, dynamic> creature,
    required AddonMetadata metadata,
    required String packUuid,
    required String moduleUuid,
  }) async {
    final manifest = ManifestGenerator.generateResourcePackManifest(
      metadata: metadata,
      packUuid: packUuid,
      moduleUuid: moduleUuid,
    );

    // Generate entity client files
    final entityClient = EntityClientGenerator.generateEntityClient(
      creatureAttributes: creature,
      metadata: metadata,
    );

    final renderController = EntityClientGenerator.generateRenderController(
      creatureAttributes: creature,
      metadata: metadata,
    );

    final animationController = EntityClientGenerator.generateAnimationController(
      creatureAttributes: creature,
      metadata: metadata,
    );

    final animations = EntityClientGenerator.generateAnimations(
      creatureAttributes: creature,
      metadata: metadata,
    );

    // Generate geometry
    final geometry = GeometryGenerator.generateGeometry(
      creatureAttributes: creature,
      metadata: metadata,
    );

    // Generate texture
    final texture = await TextureGenerator.generateTexture(
      creatureAttributes: creature,
      metadata: metadata,
    );

    // Language files
    final creatureName = creature['creatureName'] ?? 'Creature';
    final languageFile = ManifestGenerator.generateLanguageFile(
      packName: '${metadata.name} Resources',
      description: 'Resource pack for ${metadata.description}',
      translations: {
        'entity.${metadata.namespace}:${creature['creatureType']}.name': creatureName,
        if (metadata.generateSpawnEggs)
          'item.spawn_egg.entity.${metadata.namespace}:${creature['creatureType']}.name': '$creatureName Spawn Egg',
      },
    );

    final languagesJson = ManifestGenerator.generateLanguagesJson();

    return ResourcePack(
      uuid: packUuid,
      moduleUuid: moduleUuid,
      manifest: manifest,
      entityClients: [entityClient],
      textures: [texture],
      models: [geometry],
      animations: [animations],
      animationControllers: [animationController],
      renderControllers: [renderController],
      texts: [languageFile, languagesJson],
    );
  }

  /// Generate resource pack for multiple creatures
  static Future<ResourcePack> _generateResourcePackMulti({
    required List<Map<String, dynamic>> creatures,
    required AddonMetadata metadata,
    required String packUuid,
    required String moduleUuid,
  }) async {
    final manifest = ManifestGenerator.generateResourcePackManifest(
      metadata: metadata,
      packUuid: packUuid,
      moduleUuid: moduleUuid,
    );

    // Generate files for each creature
    final entityClients = <AddonFile>[];
    final renderControllers = <AddonFile>[];
    final animationControllers = <AddonFile>[];
    final animationsList = <AddonFile>[];
    final models = <AddonFile>[];
    final textures = <AddonFile>[];
    final translations = <String, String>{};

    // Track unique creature types for geometry generation
    final processedTypes = <String>{};

    for (final creature in creatures) {
      final creatureType = (creature['creatureType'] ?? 'creature').toString().toLowerCase();

      // Generate entity files
      entityClients.add(EntityClientGenerator.generateEntityClient(
        creatureAttributes: creature,
        metadata: metadata,
      ));

      renderControllers.add(EntityClientGenerator.generateRenderController(
        creatureAttributes: creature,
        metadata: metadata,
      ));

      animationControllers.add(EntityClientGenerator.generateAnimationController(
        creatureAttributes: creature,
        metadata: metadata,
      ));

      animationsList.add(EntityClientGenerator.generateAnimations(
        creatureAttributes: creature,
        metadata: metadata,
      ));

      // Generate geometry only once per type
      if (!processedTypes.contains(creatureType)) {
        models.add(GeometryGenerator.generateGeometry(
          creatureAttributes: creature,
          metadata: metadata,
        ));
        processedTypes.add(creatureType);
      }

      // Generate texture
      textures.add(await TextureGenerator.generateTexture(
        creatureAttributes: creature,
        metadata: metadata,
      ));

      // Add translations
      final creatureName = creature['creatureName'] ?? 'Creature';
      translations['entity.${metadata.namespace}:$creatureType.name'] = creatureName;
      if (metadata.generateSpawnEggs) {
        translations['item.spawn_egg.entity.${metadata.namespace}:$creatureType.name'] =
            '$creatureName Spawn Egg';
      }
    }

    final languageFile = ManifestGenerator.generateLanguageFile(
      packName: '${metadata.name} Resources',
      description: 'Resource pack for ${metadata.description}',
      translations: translations,
    );

    final languagesJson = ManifestGenerator.generateLanguagesJson();

    return ResourcePack(
      uuid: packUuid,
      moduleUuid: moduleUuid,
      manifest: manifest,
      entityClients: entityClients,
      textures: textures,
      models: models,
      animations: animationsList,
      animationControllers: animationControllers,
      renderControllers: renderControllers,
      texts: [languageFile, languagesJson],
    );
  }

  /// Generate main.js script file
  static AddonFile _generateMainScript(AddonMetadata metadata) {
    final script = '''
import { world, system } from "@minecraft/server";

// Crafta Creatures Script API
// Generated by Crafta App

world.afterEvents.worldLoad.subscribe(() => {
  world.sendMessage("§6[Crafta] §eCreatures addon loaded!");
  world.sendMessage("§7Created with Crafta App");
});

// Log when creatures are spawned
world.afterEvents.entitySpawn.subscribe((event) => {
  const entity = event.entity;
  if (entity.typeId.startsWith("${metadata.namespace}:")) {
    console.log(\`Spawned Crafta creature: \${entity.typeId}\`);
  }
});
''';

    return AddonFile.javascript('scripts/main.js', script);
  }

  /// Save addon package as .mcpack file and return the file path
  static Future<String> saveAsMcpack(AddonPackage addon) async {
    final archive = Archive();

    // Add behavior pack files
    for (final file in addon.behaviorPack.allFiles) {
      archive.addFile(ArchiveFile(
        'behavior_packs/${addon.metadata.name}_BP/${file.path}',
        file.content.length,
        file.content,
      ));
    }

    // Add resource pack files
    for (final file in addon.resourcePack.allFiles) {
      archive.addFile(ArchiveFile(
        'resource_packs/${addon.metadata.name}_RP/${file.path}',
        file.content.length,
        file.content,
      ));
    }

    // Encode as ZIP
    final zipData = ZipEncoder().encode(archive);
    if (zipData == null) {
      throw Exception('Failed to create ZIP archive');
    }

    // Save to Downloads directory for easy access
    Directory? downloadsDir;
    String downloadsPath;
    
    try {
      // Try to get Downloads directory
      downloadsDir = await getExternalStorageDirectory();
      if (downloadsDir != null) {
        downloadsPath = path.join(downloadsDir.path, 'Download');
      } else {
        // Fallback to app documents directory
        downloadsDir = await getApplicationDocumentsDirectory();
        downloadsPath = path.join(downloadsDir.path, 'Downloads');
      }
    } catch (e) {
      // Fallback to app documents directory
      downloadsDir = await getApplicationDocumentsDirectory();
      downloadsPath = path.join(downloadsDir.path, 'Downloads');
    }
    
    // Create Downloads directory if it doesn't exist
    final dir = Directory(downloadsPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    final fileName = '${addon.metadata.name.replaceAll(' ', '_')}.mcpack';
    final filePath = path.join(downloadsPath, fileName);

    final file = File(filePath);
    await file.writeAsBytes(zipData);
    
    print('✅ MCPack saved successfully: $filePath');
    print('📁 File size: ${zipData.length} bytes');
    print('📂 Directory: $downloadsPath');

    return filePath;
  }

  /// Export and share the addon via system share dialog
  static Future<void> exportAndShare(AddonPackage addon) async {
    try {
      print('🚀 Starting export process for: ${addon.metadata.name}');
      
      final filePath = await saveAsMcpack(addon);
      
      print('📤 Sharing file: $filePath');
      
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: '${addon.metadata.name} - Crafta Creatures',
        text: 'Install this addon in Minecraft Bedrock Edition!',
      );
      
      print('✅ Export and share completed successfully');
    } catch (e) {
      print('❌ Export failed: $e');
      rethrow;
    }
  }

  /// Show child-friendly world creation dialog
  static Future<void> showWorldCreationDialog(BuildContext context, AddonPackage addon) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFF98D8C8),
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Your Creature is Ready!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What would you like to do with your ${addon.metadata.name}?',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Create New World Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _createNewWorld(context, addon);
                  },
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  label: const Text(
                    'Create a New World',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF98D8C8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Add to Existing World Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _addToExistingWorld(context, addon);
                  },
                  icon: const Icon(Icons.folder_open, color: Color(0xFF98D8C8)),
                  label: const Text(
                    'Add to Existing World',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF98D8C8),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Color(0xFF98D8C8), width: 2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Create new world with the addon
  static Future<void> _createNewWorld(BuildContext context, AddonPackage addon) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF98D8C8)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Creating your new world...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Adding ${addon.metadata.name} to your world!',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );

    // Simulate world creation process
    await Future.delayed(const Duration(seconds: 2));

    // Close loading dialog
    Navigator.of(context).pop();

    // Show success dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'World Created!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your new world is ready!',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${addon.metadata.name} is now in your world!',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF98D8C8),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Awesome!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF98D8C8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Add to existing world
  static Future<void> _addToExistingWorld(BuildContext context, AddonPackage addon) async {
    // Show instructions for adding to existing world
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.folder_open,
                color: Color(0xFF98D8C8),
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Add to Your World',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'To add ${addon.metadata.name} to your existing world:',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Open Minecraft\n2. Go to your world\n3. Click "Settings"\n4. Click "Behavior Packs"\n5. Click "My Packs"\n6. Select your creature!',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Got it!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF98D8C8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Get export preview information
  static Map<String, dynamic> getExportPreview(AddonPackage addon) {
    final creatureType = addon.behaviorPack.entities.first.path
        .split('/')
        .last
        .replaceAll('.se.json', '');

    return {
      'addon_name': addon.metadata.name,
      'file_count': addon.totalFileCount,
      'estimated_size': addon.readableSize,
      'creature_count': addon.behaviorPack.entities.length,
      'has_scripts': addon.behaviorPack.scripts.isNotEmpty,
      'has_spawn_eggs': addon.metadata.generateSpawnEggs,
      'namespace': addon.metadata.namespace,
      'created_at': addon.createdAt.toIso8601String(),
    };
  }
}
