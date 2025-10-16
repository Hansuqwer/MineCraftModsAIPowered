import 'behavior_pack.dart';
import 'resource_pack.dart';
import 'addon_metadata.dart';
import 'addon_file.dart';

/// Complete Minecraft addon package containing both BP and RP
class AddonPackage {
  final AddonMetadata metadata;
  final BehaviorPack behaviorPack;
  final ResourcePack resourcePack;
  final DateTime createdAt;

  const AddonPackage({
    required this.metadata,
    required this.behaviorPack,
    required this.resourcePack,
    required this.createdAt,
  });

  /// Get all files from both packs
  List<AddonFile> get allFiles {
    return [
      ...behaviorPack.allFiles,
      ...resourcePack.allFiles,
    ];
  }

  /// Get total file count
  int get totalFileCount => behaviorPack.fileCount + resourcePack.fileCount;

  /// Get estimated size in bytes
  int get estimatedSizeBytes {
    return allFiles.fold(0, (sum, file) => sum + file.content.length);
  }

  /// Get human-readable size
  String get readableSize {
    final sizeInKB = estimatedSizeBytes / 1024;
    if (sizeInKB < 1024) {
      return '${sizeInKB.toStringAsFixed(1)} KB';
    }
    final sizeInMB = sizeInKB / 1024;
    return '${sizeInMB.toStringAsFixed(1)} MB';
  }
}
