/// Metadata for a Minecraft addon package
class AddonMetadata {
  final String name;
  final String description;
  final String namespace;
  final String version;
  final String author;
  final bool includeScriptAPI;
  final bool generateSpawnEggs;

  const AddonMetadata({
    required this.name,
    required this.description,
    required this.namespace,
    this.version = '1.0.0',
    this.author = 'Crafta',
    this.includeScriptAPI = true,
    this.generateSpawnEggs = true,
  });

  /// Default metadata for Crafta addons
  factory AddonMetadata.defaultMetadata() {
    return const AddonMetadata(
      name: 'Crafta Creatures',
      description: 'AI-generated creatures from Crafta app',
      namespace: 'crafta',
    );
  }

  AddonMetadata copyWith({
    String? name,
    String? description,
    String? namespace,
    String? version,
    String? author,
    bool? includeScriptAPI,
    bool? generateSpawnEggs,
  }) {
    return AddonMetadata(
      name: name ?? this.name,
      description: description ?? this.description,
      namespace: namespace ?? this.namespace,
      version: version ?? this.version,
      author: author ?? this.author,
      includeScriptAPI: includeScriptAPI ?? this.includeScriptAPI,
      generateSpawnEggs: generateSpawnEggs ?? this.generateSpawnEggs,
    );
  }
}
