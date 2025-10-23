class CreationSpec {
  final String object;            // 'dragon', 'couch', 'pig', 'sword', ...
  final String theme;             // 'fire', 'ice', 'shadow', 'dragon', ...
  final List<String> colors;      // ['red','black','gold']
  final String size;              // 'small'|'medium'|'large'
  final List<String> features;    // ['wings','glowing','barks','flies','2-seater']

  const CreationSpec({
    required this.object,
    required this.theme,
    required this.colors,
    required this.size,
    required this.features,
  });

  factory CreationSpec.fromJson(Map<String, dynamic> j) => CreationSpec(
    object: (j['object'] ?? 'dragon').toString(),
    theme: (j['theme'] ?? 'fire').toString(),
    colors: (j['colors'] ?? const ['red']).cast<String>(),
    size: (j['size'] ?? 'medium').toString(),
    features: (j['features'] ?? const <String>[]).cast<String>(),
  );

  Map<String, dynamic> toJson() => {
    'object': object,
    'theme': theme,
    'colors': colors,
    'size': size,
    'features': features,
  };
}

