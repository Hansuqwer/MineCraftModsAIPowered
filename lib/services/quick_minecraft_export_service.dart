import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'minecraft/minecraft_export_service.dart';
import 'minecraft/manifest_generator.dart';
import 'minecraft/entity_behavior_generator.dart';
import 'minecraft/entity_client_generator.dart';
import 'minecraft/geometry_generator.dart';
import 'minecraft/texture_generator.dart';

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
      print('🎮 [QUICK EXPORT] Starting export for: $creatureName');

      // 1. Generate addon package with all files
      print('📦 [QUICK EXPORT] Generating addon package...');
      final addon = await _generateAddonPackage(creatureAttributes, creatureName);

      // 2. Create .mcpack file (ZIP format)
      print('📦 [QUICK EXPORT] Creating .mcpack file...');
      final mcpackPath = await _createMcpackFile(addon, creatureName);

      print('✅ [QUICK EXPORT] Export complete: $mcpackPath');
      return mcpackPath;
    } catch (e) {
      print('❌ [QUICK EXPORT] Error: $e');
      rethrow;
    }
  }

  /// Generate addon package with all required files
  static Future<Map<String, String>> _generateAddonPackage(
    Map<String, dynamic> creatureAttributes,
    String creatureName,
  ) async {
    final files = <String, String>{};

    try {
      // Get creature color for texture
      final color = creatureAttributes['primaryColor'] as String? ?? 'green';
      final creatureType = creatureAttributes['creatureType'] as String? ?? 'creature';

      // Generate manifest.json
      print('📄 [QUICK EXPORT] Generating manifest...');
      final manifest = ManifestGenerator.generateManifest(
        name: creatureName,
        description: 'AI-generated $color $creatureType',
      );
      files['manifest.json'] = manifest;

      // Generate behavior pack JSON
      print('📄 [QUICK EXPORT] Generating behavior pack...');
      final behavior = EntityBehaviorGenerator.generateBehavior(
        entityType: creatureType,
        name: creatureName,
      );
      files['entity_behavior.json'] = behavior;

      // Generate client pack JSON
      print('📄 [QUICK EXPORT] Generating client pack...');
      final client = EntityClientGenerator.generateClient(
        entityType: creatureType,
        color: color,
      );
      files['entity_client.json'] = client;

      // Generate geometry JSON
      print('📄 [QUICK EXPORT] Generating geometry...');
      final geometry = GeometryGenerator.generateGeometry(
        entityType: creatureType,
        size: creatureAttributes['size'] ?? 'medium',
      );
      files['geometry.json'] = geometry;

      // Generate texture (WITH COLOR!)
      print('🎨 [QUICK EXPORT] Generating texture with color: $color...');
      final textureBase64 = await TextureGenerator.generateTexture(
        color: _parseColor(color),
        entityType: creatureType,
      );
      files['texture.png.base64'] = textureBase64;

      print('✅ [QUICK EXPORT] All addon files generated');
      return files;
    } catch (e) {
      print('❌ [QUICK EXPORT] Error generating addon: $e');
      rethrow;
    }
  }

  /// Create .mcpack file (ZIP archive)
  static Future<String> _createMcpackFile(
    Map<String, String> files,
    String creatureName,
  ) async {
    try {
      // Create archive
      final archive = Archive();

      for (final entry in files.entries) {
        if (entry.key == 'texture.png.base64') {
          // Decode base64 texture to binary
          final decodedBytes = base64Decode(entry.value);
          archive.addFile(ArchiveFile(
            'texture.png',
            decodedBytes.length,
            decodedBytes,
          ));
        } else {
          // Add JSON files as text
          archive.addFile(ArchiveFile(
            entry.key,
            entry.value.length,
            utf8.encode(entry.value),
          ));
        }
      }

      // Encode archive to ZIP bytes
      final zipEncoder = ZipEncoder();
      final zipBytes = zipEncoder.encode(archive)!;

      // Save to Downloads folder
      final downloadDir = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();

      final sanitizedName = creatureName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      final mcpackPath = '${downloadDir.path}/$sanitizedName.mcpack';

      final file = File(mcpackPath);
      await file.writeAsBytes(zipBytes);

      print('✅ [QUICK EXPORT] .mcpack file saved: $mcpackPath');
      return mcpackPath;
    } catch (e) {
      print('❌ [QUICK EXPORT] Error creating .mcpack file: $e');
      rethrow;
    }
  }

  /// Parse color string to Flutter Color integer
  static int _parseColor(String colorString) {
    final colorMap = {
      'red': 0xFFFF0000,
      'green': 0xFF00FF00,
      'blue': 0xFF0000FF,
      'yellow': 0xFFFFFF00,
      'purple': 0xFFFF00FF,
      'cyan': 0xFF00FFFF,
      'orange': 0xFFFF8800,
      'pink': 0xFFFF1493,
      'white': 0xFFFFFFFF,
      'black': 0xFF000000,
      'gray': 0xFF808080,
    };

    return colorMap[colorString.toLowerCase()] ?? 0xFF00FF00; // Default: green
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
