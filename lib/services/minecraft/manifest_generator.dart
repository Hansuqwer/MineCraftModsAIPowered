import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../models/minecraft/addon_metadata.dart';
import '../../models/minecraft/addon_file.dart';

/// Generates Minecraft manifest.json files for behavior and resource packs
class ManifestGenerator {
  static const _uuid = Uuid();

  /// Generate a behavior pack manifest
  static AddonFile generateBehaviorPackManifest({
    required AddonMetadata metadata,
    required String packUuid,
    required String moduleUuid,
  }) {
    final manifest = {
      'format_version': 2,
      'header': {
        'name': metadata.name,
        'description': metadata.description,
        'uuid': packUuid,
        'version': _parseVersion(metadata.version),
        'min_engine_version': [1, 21, 0],
      },
      'modules': [
        {
          'type': 'data',
          'uuid': moduleUuid,
          'version': _parseVersion(metadata.version),
        }
      ],
      if (metadata.includeScriptAPI) ..._getScriptModule(metadata),
      'dependencies': [
        if (metadata.includeScriptAPI) ..._getScriptDependencies(),
      ],
      'metadata': {
        'authors': [metadata.author],
        'product_type': 'addon',
        'generated_with': 'Crafta App',
      }
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(manifest);
    return AddonFile.json('manifest.json', jsonString);
  }

  /// Generate a resource pack manifest
  static AddonFile generateResourcePackManifest({
    required AddonMetadata metadata,
    required String packUuid,
    required String moduleUuid,
  }) {
    final manifest = {
      'format_version': 2,
      'header': {
        'name': '${metadata.name} Resources',
        'description': 'Resource pack for ${metadata.description}',
        'uuid': packUuid,
        'version': _parseVersion(metadata.version),
        'min_engine_version': [1, 21, 0],
      },
      'modules': [
        {
          'type': 'resources',
          'uuid': moduleUuid,
          'version': _parseVersion(metadata.version),
        }
      ],
      'metadata': {
        'authors': [metadata.author],
        'product_type': 'addon',
        'generated_with': 'Crafta App',
      }
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(manifest);
    return AddonFile.json('manifest.json', jsonString);
  }

  /// Generate script module definition
  static Map<String, dynamic> _getScriptModule(AddonMetadata metadata) {
    final scriptUuid = _uuid.v4();

    return {
      'modules': [
        {
          'type': 'script',
          'language': 'javascript',
          'uuid': scriptUuid,
          'version': _parseVersion(metadata.version),
          'entry': 'scripts/main.js',
        }
      ]
    };
  }

  /// Generate script API dependencies
  static List<Map<String, dynamic>> _getScriptDependencies() {
    return [
      {
        'module_name': '@minecraft/server',
        'version': '2.1.0', // Latest stable Script API version
      },
      {
        'module_name': '@minecraft/server-ui',
        'version': '2.0.0', // UI module for forms/dialogs
      }
    ];
  }

  /// Parse version string to array format [major, minor, patch]
  static List<int> _parseVersion(String version) {
    final parts = version.split('.');
    return [
      int.tryParse(parts.elementAtOrNull(0) ?? '1') ?? 1,
      int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0,
      int.tryParse(parts.elementAtOrNull(2) ?? '0') ?? 0,
    ];
  }

  /// Generate a new UUID v4
  static String generateUuid() {
    return _uuid.v4();
  }

  /// Generate language file for pack
  static AddonFile generateLanguageFile({
    required String packName,
    required String description,
    required Map<String, String> translations,
  }) {
    final buffer = StringBuffer();

    // Add pack information
    buffer.writeln('pack.name=$packName');
    buffer.writeln('pack.description=$description');
    buffer.writeln();

    // Add custom translations
    translations.forEach((key, value) {
      buffer.writeln('$key=$value');
    });

    return AddonFile.text('texts/en_US.lang', buffer.toString());
  }

  /// Generate languages.json file
  static AddonFile generateLanguagesJson() {
    final languages = ['en_US'];
    final jsonString = const JsonEncoder.withIndent('  ').convert(languages);
    return AddonFile.json('texts/languages.json', jsonString);
  }
}
