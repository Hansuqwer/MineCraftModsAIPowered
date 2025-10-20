import 'dart:io';
import 'minecraft/minecraft_export_service.dart';
import '../models/minecraft/addon_metadata.dart';

/// Quick Minecraft Export Service
/// Simplified export flow that bypasses multiple screens
/// Directly generates .mcpack file from creature attributes
class QuickMinecraftExportService {
  /// Quick export creature to Minecraft
  /// Returns path to generated .mcpack file
  static Future<String> quickExportCreature({
    required Map<String, dynamic> creatureAttributes,
    required String creatureName,
    required String worldType, // 'new' or 'existing'
  }) async {
    try {
      print('🎮 [QUICK EXPORT] Starting export for: $creatureName (world: $worldType)');

      // Generate addon and save as .mcpack
      final mcpackPath = await _generateAndSaveAddon(creatureAttributes, creatureName);

      print('✅ [QUICK EXPORT] Export complete: $mcpackPath');
      return mcpackPath;
    } catch (e) {
      print('❌ [QUICK EXPORT] Error: $e');
      rethrow;
    }
  }

  /// Generate addon package using existing MinecraftExportService
  static Future<String> _generateAndSaveAddon(
    Map<String, dynamic> creatureAttributes,
    String creatureName,
  ) async {
    try {
      print('📦 [QUICK EXPORT] Using MinecraftExportService to generate addon...');

      // Create metadata
      final color = creatureAttributes['color'] as String? ?? 'green';
      final creatureType = creatureAttributes['creatureType'] as String? ?? 'creature';

      final metadata = AddonMetadata(
        name: creatureName,
        description: 'AI-generated $color $creatureType',
        namespace: 'crafta_quick',
      );

      // Use existing export service
      final addon = await MinecraftExportService.exportCreature(
        creatureAttributes: creatureAttributes,
        metadata: metadata,
      );

      print('✅ [QUICK EXPORT] Addon generated, saving as .mcpack...');

      // Save the addon and get the path
      final mcpackPath = await MinecraftExportService.saveAsMcpack(addon);

      return mcpackPath;
    } catch (e) {
      print('❌ [QUICK EXPORT] Error generating addon: $e');
      rethrow;
    }
  }

  /// Check if .mcpack file exists and is valid
  static Future<bool> validateMcpackFile(String mcpackPath) async {
    try {
      final file = File(mcpackPath);
      if (!await file.exists()) {
        print('❌ [QUICK EXPORT] .mcpack file not found: $mcpackPath');
        return false;
      }

      final size = await file.length();
      if (size == 0) {
        print('❌ [QUICK EXPORT] .mcpack file is empty');
        return false;
      }

      print('✅ [QUICK EXPORT] .mcpack file valid: $mcpackPath ($size bytes)');
      return true;
    } catch (e) {
      print('❌ [QUICK EXPORT] Error validating .mcpack: $e');
      return false;
    }
  }
}
