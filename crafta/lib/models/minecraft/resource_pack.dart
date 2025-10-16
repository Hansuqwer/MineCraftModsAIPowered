import 'addon_file.dart';

/// Represents a Minecraft Resource Pack
class ResourcePack {
  final String uuid;
  final String moduleUuid;
  final AddonFile manifest;
  final List<AddonFile> entityClients;
  final List<AddonFile> textures;
  final List<AddonFile> models;
  final List<AddonFile> animations;
  final List<AddonFile> animationControllers;
  final List<AddonFile> renderControllers;
  final List<AddonFile> texts;
  final AddonFile? packIcon;

  const ResourcePack({
    required this.uuid,
    required this.moduleUuid,
    required this.manifest,
    required this.entityClients,
    required this.textures,
    required this.models,
    required this.animations,
    required this.animationControllers,
    required this.renderControllers,
    required this.texts,
    this.packIcon,
  });

  /// Get all files in the resource pack
  List<AddonFile> get allFiles {
    return [
      manifest,
      ...entityClients,
      ...textures,
      ...models,
      ...animations,
      ...animationControllers,
      ...renderControllers,
      ...texts,
      if (packIcon != null) packIcon!,
    ];
  }

  /// Get file count
  int get fileCount => allFiles.length;
}
