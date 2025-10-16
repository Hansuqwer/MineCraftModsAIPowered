import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/minecraft/addon_metadata.dart';
import '../../models/minecraft/addon_package.dart';
import '../../models/minecraft/addon_file.dart';
import '../../models/minecraft/behavior_pack.dart';
import '../../models/minecraft/resource_pack.dart';
import 'manifest_generator.dart';
import 'entity_behavior_generator.dart';
import 'entity_client_generator.dart';
import 'geometry_generator.dart';
import 'texture_generator.dart';

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

    // Generate scripts if enabled
    final scripts = metadata.includeScriptAPI
        ? [_generateMainScript(metadata)]
        : <AddonFile>[];

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

    final scripts = metadata.includeScriptAPI
        ? [_generateMainScript(metadata)]
        : <AddonFile>[];

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
    final creatureType = (creature['creatureType'] ?? 'creature').toString().toLowerCase();
    final geometry = GeometryGenerator.generateGeometry(
      creatureType: creatureType,
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
        'entity.${metadata.namespace}:$creatureType.name': creatureName,
        if (metadata.generateSpawnEggs)
          'item.spawn_egg.entity.${metadata.namespace}:$creatureType.name': '$creatureName Spawn Egg',
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
          creatureType: creatureType,
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

    // Save to temporary directory
    final tempDir = await getTemporaryDirectory();
    final fileName = '${addon.metadata.name.replaceAll(' ', '_')}.mcpack';
    final filePath = path.join(tempDir.path, fileName);

    final file = File(filePath);
    await file.writeAsBytes(zipData);

    return filePath;
  }

  /// Export and share the addon via system share dialog
  static Future<void> exportAndShare(AddonPackage addon) async {
    final filePath = await saveAsMcpack(addon);

    await Share.shareXFiles(
      [XFile(filePath)],
      subject: '${addon.metadata.name} - Crafta Creatures',
      text: 'Install this addon in Minecraft Bedrock Edition!',
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
