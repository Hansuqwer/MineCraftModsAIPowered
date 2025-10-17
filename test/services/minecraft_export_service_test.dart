import 'package:flutter_test/flutter_test.dart';
import 'package:crafta/services/minecraft/minecraft_export_service.dart';
import 'package:crafta/models/minecraft/addon_metadata.dart';
import '../test_setup.dart';

void main() {
  group('Minecraft Export Service Tests', () {
    setUpAll(() async {
      await setupTests();
    });

    test('Single creature export should create valid addon package', () async {
      // Arrange
      final testCreature = {
        'creatureName': 'Rainbow Dragon',
        'creatureType': 'dragon',
        'color': 'rainbow',
        'size': 'giant',
        'abilities': ['flying', 'fire_breathing'],
        'effects': ['sparkles', 'glow'],
      };

      final metadata = AddonMetadata.defaultMetadata().copyWith(
        name: 'Rainbow Dragon Addon',
        description: 'A magical rainbow dragon from Crafta',
      );

      // Act
      final addon = await MinecraftExportService.exportCreature(
        creatureAttributes: testCreature,
        metadata: metadata,
      );

      // Assert
      expect(addon, isNotNull);
      expect(addon.metadata.name, equals('Rainbow Dragon Addon'));
      expect(addon.metadata.namespace, equals('crafta'));
      expect(addon.behaviorPack.entities, hasLength(1));
      expect(addon.resourcePack.entityClients, hasLength(1));
      expect(addon.totalFileCount, greaterThan(0));
      expect(addon.readableSize, isA<String>());
    });

    test('Multiple creatures export should create valid addon package', () async {
      // Arrange
      final testCreatures = [
        {
          'creatureName': 'Rainbow Dragon',
          'creatureType': 'dragon',
          'color': 'rainbow',
          'size': 'giant',
          'abilities': ['flying', 'fire_breathing'],
          'effects': ['sparkles', 'glow'],
        },
        {
          'creatureName': 'Tiny Unicorn',
          'creatureType': 'unicorn',
          'color': 'pink',
          'size': 'tiny',
          'abilities': ['flying'],
          'effects': ['sparkles'],
        },
        {
          'creatureName': 'Fire Cow',
          'creatureType': 'cow',
          'color': 'red',
          'size': 'normal',
          'abilities': ['fire_breathing'],
          'effects': ['fire'],
        },
      ];

      final metadata = AddonMetadata.defaultMetadata().copyWith(
        name: 'Crafta Creature Collection',
        description: 'A collection of AI-generated creatures',
      );

      // Act
      final addon = await MinecraftExportService.exportMultipleCreatures(
        creaturesList: testCreatures,
        metadata: metadata,
      );

      // Assert
      expect(addon, isNotNull);
      expect(addon.metadata.name, equals('Crafta Creature Collection'));
      expect(addon.behaviorPack.entities, hasLength(3));
      expect(addon.resourcePack.entityClients, hasLength(3));
      expect(addon.totalFileCount, greaterThan(0));
    });

    test('Export preview should return valid information', () async {
      // Arrange
      final testCreature = {
        'creatureName': 'Test Dragon',
        'creatureType': 'dragon',
        'color': 'blue',
        'size': 'normal',
        'abilities': ['flying'],
        'effects': [],
      };

      final addon = await MinecraftExportService.exportCreature(
        creatureAttributes: testCreature,
        metadata: AddonMetadata.defaultMetadata(),
      );

      // Act
      final preview = MinecraftExportService.getExportPreview(addon);

      // Assert
      expect(preview, isNotNull);
      expect(preview['addon_name'], isA<String>());
      expect(preview['file_count'], isA<int>());
      expect(preview['creature_count'], isA<int>());
      expect(preview['has_scripts'], isA<bool>());
      expect(preview['has_spawn_eggs'], isA<bool>());
      expect(preview['namespace'], equals('crafta'));
    });

    test('Behavior pack should contain valid entity files', () async {
      // Arrange
      final testCreature = {
        'creatureName': 'Flying Cow',
        'creatureType': 'cow',
        'color': 'white',
        'size': 'normal',
        'abilities': ['flying'],
        'effects': [],
      };

      // Act
      final addon = await MinecraftExportService.exportCreature(
        creatureAttributes: testCreature,
        metadata: AddonMetadata.defaultMetadata(),
      );

      // Assert
      expect(addon.behaviorPack.entities, hasLength(1));
      
      final entityFile = addon.behaviorPack.entities.first;
      final entityContent = String.fromCharCodes(entityFile.content);
      
      expect(entityContent, contains('crafta:'));
      expect(entityContent, contains('minecraft:health'));
      expect(entityContent, contains('minecraft:movement'));
      expect(entityContent, contains('minecraft:movement.fly'));
    });

    test('Resource pack should contain valid client files', () async {
      // Arrange
      final testCreature = {
        'creatureName': 'Sparkle Unicorn',
        'creatureType': 'unicorn',
        'color': 'pink',
        'size': 'normal',
        'abilities': [],
        'effects': ['sparkles'],
      };

      // Act
      final addon = await MinecraftExportService.exportCreature(
        creatureAttributes: testCreature,
        metadata: AddonMetadata.defaultMetadata(),
      );

      // Assert
      expect(addon.resourcePack.entityClients, hasLength(1));
      
      final clientFile = addon.resourcePack.entityClients.first;
      final clientContent = String.fromCharCodes(clientFile.content);
      
      expect(clientContent, contains('textures/entity/'));
      expect(clientContent, contains('geometry.crafta.'));
      expect(clientContent, contains('spawn_egg'));
    });

    test('Addon package should have correct file structure', () async {
      // Arrange
      final testCreature = {
        'creatureName': 'Test Creature',
        'creatureType': 'cow',
        'color': 'brown',
        'size': 'normal',
        'abilities': [],
        'effects': [],
      };

      // Act
      final addon = await MinecraftExportService.exportCreature(
        creatureAttributes: testCreature,
        metadata: AddonMetadata.defaultMetadata(),
      );

      // Assert
      // Check behavior pack files
      expect(addon.behaviorPack.manifest, isNotNull);
      expect(addon.behaviorPack.entities, isNotEmpty);
      expect(addon.behaviorPack.texts, isNotEmpty);
      
      // Check resource pack files
      expect(addon.resourcePack.manifest, isNotNull);
      expect(addon.resourcePack.entityClients, isNotEmpty);
      expect(addon.resourcePack.textures, isNotEmpty);
      expect(addon.resourcePack.models, isNotEmpty);
      expect(addon.resourcePack.animations, isNotEmpty);
      expect(addon.resourcePack.animationControllers, isNotEmpty);
      expect(addon.resourcePack.renderControllers, isNotEmpty);
      expect(addon.resourcePack.texts, isNotEmpty);
    });

    test('Creature attributes should map to correct Minecraft components', () async {
      // Arrange
      final flyingCreature = {
        'creatureName': 'Flying Dragon',
        'creatureType': 'dragon',
        'color': 'red',
        'size': 'giant',
        'abilities': ['flying', 'fire_breathing'],
        'effects': ['fire'],
      };

      // Act
      final addon = await MinecraftExportService.exportCreature(
        creatureAttributes: flyingCreature,
        metadata: AddonMetadata.defaultMetadata(),
      );

      // Assert
      final entityFile = addon.behaviorPack.entities.first;
      final entityContent = String.fromCharCodes(entityFile.content);
      
      // Should have flying movement
      expect(entityContent, contains('minecraft:movement.fly'));
      expect(entityContent, contains('minecraft:navigation.fly'));
      
      // Should have fire immunity
      expect(entityContent, contains('minecraft:fire_immune'));
      
      // Should have giant size scale
      expect(entityContent, contains('minecraft:scale'));
    });
  });
}


