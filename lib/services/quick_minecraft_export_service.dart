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

      // Normalize creature attributes to ensure all required fields are present
      final normalizedAttrs = _normalizeAttributes(creatureAttributes);

      // Extract color info for description
      final color = normalizedAttrs['color'] as String? ?? 'creature';
      final creatureType = normalizedAttrs['creatureType'] as String? ?? 'creature';

      print('✅ [QUICK EXPORT] Normalized attributes:');
      print('   - Color: $color');
      print('   - CreatureType: $creatureType');

      final metadata = AddonMetadata(
        name: creatureName,
        description: 'AI-generated $color $creatureType',
        namespace: 'crafta_quick',
      );

      // Use existing export service
      final addon = await MinecraftExportService.exportCreature(
        creatureAttributes: normalizedAttrs,
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

  /// Normalize creature attributes to ensure all fields are present
  static Map<String, dynamic> _normalizeAttributes(Map<String, dynamic> attrs) {
    final normalized = Map<String, dynamic>.from(attrs);

    // Ensure 'color' field exists as a string
    if (normalized['color'] == null) {
      // Try to extract from primaryColor
      final primaryColor = normalized['primaryColor'];
      if (primaryColor is String) {
        normalized['color'] = primaryColor;
        print('✅ [QUICK EXPORT] Set color from primaryColor string: ${normalized['color']}');
      } else if (primaryColor != null) {
        // If it's a Flutter Color or something else, convert to string
        normalized['color'] = 'green'; // Default
        print('⚠️ [QUICK EXPORT] primaryColor is not string, defaulting to green');
      } else {
        normalized['color'] = 'green';
        print('⚠️ [QUICK EXPORT] No color found, defaulting to green');
      }
    }

    // Ensure required fields have defaults
    normalized['creatureType'] ??= 'creature';
    normalized['size'] ??= 'normal';
    normalized['effects'] ??= [];

    print('📋 [QUICK EXPORT] Final normalized attributes keys: ${normalized.keys.toList()}');

    return normalized;
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
