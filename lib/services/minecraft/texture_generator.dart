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
    final colorName = (creatureAttributes['color'] ?? 'normal').toString().toLowerCase();
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

    // For MVP: Generate a simple colored texture
    // TODO: Export from ProceduralCreatureRenderer
    final textureData = await _generateSimpleTexture(
      color: _getColorFromName(colorName),
      size: 64, // Standard Minecraft texture size
    );

    return AddonFile.png('textures/entity/$identifier.png', textureData);
  }

  /// Generate a simple solid color texture (MVP version)
  static Future<Uint8List> _generateSimpleTexture({
    required Color color,
    required int size,
  }) async {
    // Create an image using the image package
    final image = img.Image(width: size, height: size);

    // Fill with color
    final imgColor = img.ColorRgba8(
      color.red,
      color.green,
      color.blue,
      color.alpha,
    );

    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        image.setPixel(x, y, imgColor);
      }
    }

    // Add some simple shading (darker bottom half)
    for (int y = size ~/ 2; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final darkerColor = img.ColorRgba8(
          (color.red * 0.7).round(),
          (color.green * 0.7).round(),
          (color.blue * 0.7).round(),
          color.alpha,
        );
        image.setPixel(x, y, darkerColor);
      }
    }

    // Encode as PNG
    return Uint8List.fromList(img.encodePng(image));
  }

  /// Export texture from ProceduralCreatureRenderer (Advanced version)
  /// This would capture the actual rendered creature
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
