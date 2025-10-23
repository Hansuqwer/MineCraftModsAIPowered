import 'schema.dart';

/// Minimal, deterministic prompt builder for "Minecraft-style" look.
/// You can tune adjectives without changing the contract elsewhere.
String buildMinecraftImagePrompt(CreationSpec spec) {
  final colorStr = spec.colors.isNotEmpty ? spec.colors.join(' and ') : 'default colors';
  final seats = spec.features.firstWhere(
    (f) => f.contains('seat') || f.contains('seater'),
    orElse: () => '',
  );

  final features = [
    ...spec.features.where((f) => !f.contains('seat') && !f.contains('seater')),
    spec.theme,
    spec.size,
  ].where((e) => e.trim().isNotEmpty).toList();

  final featureStr = features.isEmpty ? '' : ' with ' + features.join(', ');

  // Examples:
  // "Minecraft-style render of a two-seat couch with a dragon cover, dark red color, pixel-art voxel look"
  // "Minecraft-style render of an orange pig that flies and barks, pixel-art voxel look"
  final subject = spec.object.toLowerCase() == 'couch' && spec.theme.contains('dragon')
      ? 'a ${seats.isNotEmpty ? seats.replaceAll('-', ' ') : 'two-seat'} couch with a dragon cover'
      : 'a ${spec.object}';

  return 'Minecraft-style render of $subject$featureStr, $colorStr colors, pixel-art voxel look, clean bright lighting, isolated background, high fidelity to Minecraft aesthetic';
}

