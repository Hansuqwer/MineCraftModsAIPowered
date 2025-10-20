import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../models/minecraft/addon_file.dart';
import '../../models/minecraft/addon_metadata.dart';
import '../../widgets/procedural_creature_renderer.dart';

/// Generates Minecraft textures from Crafta's procedural renderer
class TextureGenerator {
  /// Generate texture PNG from creature attributes
  static Future<AddonFile> generateTexture({
    required Map<String, dynamic> creatureAttributes,
    required AddonMetadata metadata,
  }) async {
    final creatureType = (creatureAttributes['creatureType'] ?? 'creature').toString().toLowerCase();

    // Extract color - handle both string names and actual Flutter Color objects
    final colorInput = creatureAttributes['color'] ?? creatureAttributes['primaryColor'] ?? 'normal';
    final Color extractedColor = _extractColorFromInput(colorInput);
    final colorName = _getColorName(extractedColor);

    final sizeAttr = (creatureAttributes['size'] ?? 'normal').toString().toLowerCase();

    // Generate identifier
    final parts = <String>[];
    if (colorName != 'normal' && colorName != 'rainbow') {
      parts.add(colorName);
    }
    if (sizeAttr != 'normal') {
      parts.add(sizeAttr);
    }
    parts.add(creatureType);
    final identifier = parts.join('_');

    // Generate texture from procedural renderer
    try {
      final textureData = await generateTextureFromRenderer(
        creatureAttributes: creatureAttributes,
        size: 64, // Standard Minecraft texture size
      );
      return AddonFile.png('textures/entity/$identifier.png', textureData);
    } catch (e) {
      // Fallback to simple texture if renderer fails
      print('⚠️ [TEXTURE] Procedural renderer failed, using solid color texture: $e');
      final textureData = await _generateSimpleTexture(
        color: extractedColor,
        size: 64,
      );
      return AddonFile.png('textures/entity/$identifier.png', textureData);
    }
  }

  /// Extract Color from various input formats
  static Color _extractColorFromInput(dynamic input) {
    if (input is Color) {
      print('✅ [TEXTURE] Using Flutter Color directly: $input');
      return input;
    }

    if (input is String) {
      final color = _getColorFromName(input.toLowerCase());
      print('✅ [TEXTURE] Extracted color from string "$input": $color');
      return color;
    }

    print('⚠️ [TEXTURE] Unknown color input type: ${input.runtimeType}, defaulting to blue');
    return Colors.blue;
  }

  /// Get color name from Flutter Color for identifier
  static String _getColorName(Color color) {
    if (color == Colors.red) return 'red';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.green) return 'green';
    if (color == Colors.yellow) return 'yellow';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.pink) return 'pink';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.brown) return 'brown';
    if (color == Colors.black87 || color == Colors.black) return 'black';
    if (color == Colors.white) return 'white';
    if (color == Colors.grey) return 'grey';
    if (color == Colors.amber.shade600) return 'gold';
    if (color == Colors.grey.shade400) return 'silver';
    return 'normal';
  }

  /// Generate a simple solid color texture (MVP version)
  static Future<Uint8List> _generateSimpleTexture({
    required Color color,
    required int size,
  }) async {
    try {
      print('🎨 [TEXTURE] Generating simple texture (${size}x$size) with color: $color');

      // Create an image using the image package
      final image = img.Image(width: size, height: size, numChannels: 4);

      // Extract RGB components properly from Flutter Color
      final r = color.red;    // 0-255
      final g = color.green;  // 0-255
      final b = color.blue;   // 0-255
      final a = color.alpha;  // 0-255

      print('   RGB components: R=$r, G=$g, B=$b, A=$a');

      // Fill with color
      for (int y = 0; y < size; y++) {
        for (int x = 0; x < size; x++) {
          image.setPixelRgba(x, y, r, g, b, a);
        }
      }

      // Add some simple shading (darker bottom half) for depth
      for (int y = size ~/ 2; y < size; y++) {
        for (int x = 0; x < size; x++) {
          final darkerR = (r * 0.7).round();
          final darkerG = (g * 0.7).round();
          final darkerB = (b * 0.7).round();
          image.setPixelRgba(x, y, darkerR, darkerG, darkerB, a);
        }
      }

      // Add top-half highlight for dimension
      for (int y = 0; y < size ~/ 4; y++) {
        for (int x = 0; x < size; x++) {
          final lighterR = ((r + 255) ~/ 2).clamp(0, 255);
          final lighterG = ((g + 255) ~/ 2).clamp(0, 255);
          final lighterB = ((b + 255) ~/ 2).clamp(0, 255);
          image.setPixelRgba(x, y, lighterR, lighterG, lighterB, a);
        }
      }

      // Encode as PNG
      final encoded = img.encodePng(image);
      print('✅ [TEXTURE] Generated PNG texture: ${encoded.length} bytes');
      return Uint8List.fromList(encoded);
    } catch (e) {
      print('❌ [TEXTURE] Error generating simple texture: $e');
      // Return a fallback 1x1 red pixel if everything fails
      final image = img.Image(width: 1, height: 1, numChannels: 4);
      image.setPixelRgba(0, 0, 255, 0, 0, 255);
      return Uint8List.fromList(img.encodePng(image));
    }
  }

  /// Export texture from ProceduralCreatureRenderer (Advanced version)
  /// This captures the actual rendered creature
  static Future<Uint8List> generateTextureFromRenderer({
    required Map<String, dynamic> creatureAttributes,
    required int size,
  }) async {
    // Create a PictureRecorder to capture the rendering
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Create custom painter
    final painter = CreaturePainter(
      creatureAttributes: creatureAttributes,
      animationValue: 0.5, // Static pose
    );

    // Paint the creature
    painter.paint(canvas, Size(size.toDouble(), size.toDouble()));

    // Convert to image
    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to generate texture from renderer');
    }

    return byteData.buffer.asUint8List();
  }

  /// Get color from name
  static Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'orange':
        return Colors.orange;
      case 'brown':
        return Colors.brown;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return Colors.grey[400]!;
      case 'rainbow':
        return Colors.red; // Use red as base for rainbow
      default:
        return Colors.grey;
    }
  }

  /// Generate a UV-mapped texture for a specific geometry
  /// (Advanced feature for future implementation)
  static Future<Uint8List> generateUVMappedTexture({
    required Map<String, dynamic> creatureAttributes,
    required String geometryType,
  }) async {
    // TODO: Implement UV mapping based on geometry
    // This would create proper textures that map to the 3D model's UV coordinates
    throw UnimplementedError('UV mapping not yet implemented');
  }

  /// Create a texture atlas from multiple textures
  /// (For future optimization)
  static Future<Uint8List> createTextureAtlas({
    required List<Uint8List> textures,
    required int atlasSize,
  }) async {
    // TODO: Combine multiple textures into one atlas
    throw UnimplementedError('Texture atlas not yet implemented');
  }
}
