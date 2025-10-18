import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'minecraft_mod_generator.dart';
import 'local_storage_service.dart';

/// Enhanced export service with comprehensive file management
class EnhancedExportService {
  static const String _exportsKey = 'crafta_exports';
  static const String _maxExports = 'max_exports';
  static const int _defaultMaxExports = 50;

  /// Export creature as Minecraft mod
  static Future<ExportResult> exportCreature({
    required Map<String, dynamic> creatureData,
    required String creatureName,
    String? description,
  }) async {
    try {
      // Generate mod file
      final modFile = await MinecraftModGenerator.generateMod(
        creatureData: creatureData,
        creatureName: creatureName,
      );

      // Create export record
      final exportRecord = ExportRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        creatureName: creatureName,
        fileName: modFile.path.split('/').last,
        filePath: modFile.path,
        fileSize: await modFile.length(),
        createdAt: DateTime.now(),
        description: description ?? 'AI-Generated Creature',
        creatureData: creatureData,
        status: ExportStatus.completed,
      );

      // Save export record
      await _saveExportRecord(exportRecord);

      // Clean up old exports if needed
      await _cleanupOldExports();

      return ExportResult.success(exportRecord);
    } catch (e) {
      return ExportResult.error('Failed to export creature: $e');
    }
  }

  /// Get all exports
  static Future<List<ExportRecord>> getAllExports() async {
    try {
      final exports = await LocalStorageService.loadData(_exportsKey);
      if (exports == null) return [];

      final List<dynamic> exportList = exports['exports'] ?? [];
      return exportList.map((e) => ExportRecord.fromMap(e)).toList();
    } catch (e) {
      print('Error loading exports: $e');
      return [];
    }
  }

  /// Get export by ID
  static Future<ExportRecord?> getExportById(String id) async {
    final exports = await getAllExports();
    try {
      return exports.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Delete export
  static Future<bool> deleteExport(String id) async {
    try {
      final export = await getExportById(id);
      if (export == null) return false;

      // Delete file
      final file = File(export.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from records
      final exports = await getAllExports();
      exports.removeWhere((e) => e.id == id);
      await _saveExportRecords(exports);

      return true;
    } catch (e) {
      print('Error deleting export: $e');
      return false;
    }
  }

  /// Share export
  static Future<bool> shareExport(String id) async {
    try {
      final export = await getExportById(id);
      if (export == null) return false;

      final file = File(export.filePath);
      if (!await file.exists()) return false;

      await Share.shareXFiles(
        [XFile(export.filePath)],
        text: 'Check out my AI-generated Minecraft creature: ${export.creatureName}',
        subject: 'Crafta Creature: ${export.creatureName}',
      );

      return true;
    } catch (e) {
      print('Error sharing export: $e');
      return false;
    }
  }

  /// Get export statistics
  static Future<ExportStatistics> getExportStatistics() async {
    final exports = await getAllExports();
    final totalSize = exports.fold<int>(0, (sum, export) => sum + export.fileSize);
    final completedExports = exports.where((e) => e.status == ExportStatus.completed).length;
    final failedExports = exports.where((e) => e.status == ExportStatus.failed).length;

    return ExportStatistics(
      totalExports: exports.length,
      completedExports: completedExports,
      failedExports: failedExports,
      totalSize: totalSize,
      averageSize: exports.isNotEmpty ? totalSize / exports.length : 0,
    );
  }

  /// Clean up old exports
  static Future<void> _cleanupOldExports() async {
    final maxExports = await LocalStorageService.loadData(_maxExports);
    final maxCount = maxExports?['value'] ?? _defaultMaxExports;

    final exports = await getAllExports();
    if (exports.length <= maxCount) return;

    // Sort by creation date (oldest first)
    exports.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Delete oldest exports
    final toDelete = exports.take(exports.length - maxCount).toList();
    for (final export in toDelete) {
      await deleteExport(export.id);
    }
  }

  /// Save export record
  static Future<void> _saveExportRecord(ExportRecord record) async {
    final exports = await getAllExports();
    exports.add(record);
    await _saveExportRecords(exports);
  }

  /// Save export records
  static Future<void> _saveExportRecords(List<ExportRecord> exports) async {
    final data = {
      'exports': exports.map((e) => e.toMap()).toList(),
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    };
    await LocalStorageService.saveData(_exportsKey, data);
  }

  /// Set maximum number of exports
  static Future<void> setMaxExports(int maxExports) async {
    final data = {
      'value': maxExports,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await LocalStorageService.saveData(_maxExports, data);
  }

  /// Get maximum number of exports
  static Future<int> getMaxExports() async {
    final data = await LocalStorageService.loadData(_maxExports);
    return data?['value'] ?? _defaultMaxExports;
  }

  /// Export all creatures as a collection
  static Future<ExportResult> exportCollection({
    required List<ExportRecord> exports,
    required String collectionName,
  }) async {
    try {
      // Create collection directory
      final tempDir = await getTemporaryDirectory();
      final collectionDir = Directory('${tempDir.path}/crafta_collection_${DateTime.now().millisecondsSinceEpoch}');
      await collectionDir.create(recursive: true);

      // Copy all mod files to collection
      for (final export in exports) {
        final sourceFile = File(export.filePath);
        if (await sourceFile.exists()) {
          final destFile = File('${collectionDir.path}/${export.fileName}');
          await sourceFile.copy(destFile.path);
        }
      }

      // Create collection manifest
      final manifest = {
        'name': collectionName,
        'version': '1.0.0',
        'description': 'Crafta AI-Generated Creature Collection',
        'creatures': exports.map((e) => {
          'name': e.creatureName,
          'fileName': e.fileName,
          'description': e.description,
          'createdAt': e.createdAt.toIso8601String(),
        }).toList(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      final manifestFile = File('${collectionDir.path}/collection_manifest.json');
      await manifestFile.writeAsString(manifest.toString());

      // Create zip file
      final collectionFile = File('${collectionDir.path}/../${collectionName.replaceAll(' ', '_')}_collection.zip');
      // Note: In a real implementation, you'd use a zip library here

      // Cleanup
      await collectionDir.delete(recursive: true);

      return ExportResult.success(ExportRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        creatureName: collectionName,
        fileName: collectionFile.path.split('/').last,
        filePath: collectionFile.path,
        fileSize: await collectionFile.length(),
        createdAt: DateTime.now(),
        description: 'Creature Collection',
        creatureData: {},
        status: ExportStatus.completed,
      ));
    } catch (e) {
      return ExportResult.error('Failed to export collection: $e');
    }
  }
}

/// Export record model
class ExportRecord {
  final String id;
  final String creatureName;
  final String fileName;
  final String filePath;
  final int fileSize;
  final DateTime createdAt;
  final String description;
  final Map<String, dynamic> creatureData;
  final ExportStatus status;

  ExportRecord({
    required this.id,
    required this.creatureName,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.createdAt,
    required this.description,
    required this.creatureData,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creatureName': creatureName,
      'fileName': fileName,
      'filePath': filePath,
      'fileSize': fileSize,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'description': description,
      'creatureData': creatureData,
      'status': status.toString(),
    };
  }

  factory ExportRecord.fromMap(Map<String, dynamic> map) {
    return ExportRecord(
      id: map['id'] ?? '',
      creatureName: map['creatureName'] ?? '',
      fileName: map['fileName'] ?? '',
      filePath: map['filePath'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      description: map['description'] ?? '',
      creatureData: Map<String, dynamic>.from(map['creatureData'] ?? {}),
      status: ExportStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => ExportStatus.pending,
      ),
    );
  }

  String get formattedSize {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Export status enum
enum ExportStatus {
  pending,
  processing,
  completed,
  failed,
}

/// Export result model
class ExportResult {
  final bool success;
  final String? error;
  final ExportRecord? record;

  ExportResult.success(this.record) : success = true, error = null;
  ExportResult.error(this.error) : success = false, record = null;
}

/// Export statistics model
class ExportStatistics {
  final int totalExports;
  final int completedExports;
  final int failedExports;
  final int totalSize;
  final double averageSize;

  ExportStatistics({
    required this.totalExports,
    required this.completedExports,
    required this.failedExports,
    required this.totalSize,
    required this.averageSize,
  });

  String get formattedTotalSize {
    if (totalSize < 1024) return '${totalSize}B';
    if (totalSize < 1024 * 1024) return '${(totalSize / 1024).toStringAsFixed(1)}KB';
    return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get formattedAverageSize {
    if (averageSize < 1024) return '${averageSize.toStringAsFixed(1)}B';
    if (averageSize < 1024 * 1024) return '${(averageSize / 1024).toStringAsFixed(1)}KB';
    return '${(averageSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
