import 'addon_file.dart';

/// Represents a Minecraft Behavior Pack
class BehaviorPack {
  final String uuid;
  final String moduleUuid;
  final AddonFile manifest;
  final List<AddonFile> entities;
  final List<AddonFile> scripts;
  final List<AddonFile> texts;
  final AddonFile? packIcon;

  const BehaviorPack({
    required this.uuid,
    required this.moduleUuid,
    required this.manifest,
    required this.entities,
    required this.scripts,
    required this.texts,
    this.packIcon,
  });

  /// Get all files in the behavior pack
  List<AddonFile> get allFiles {
    return [
      manifest,
      ...entities,
      ...scripts,
      ...texts,
      if (packIcon != null) packIcon!,
    ];
  }

  /// Get file count
  int get fileCount => allFiles.length;
}
