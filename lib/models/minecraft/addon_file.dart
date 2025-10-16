import 'dart:typed_data';

/// Represents a file in the addon package
class AddonFile {
  final String path;
  final Uint8List content;
  final AddonFileType type;

  const AddonFile({
    required this.path,
    required this.content,
    required this.type,
  });

  /// Create a JSON file
  factory AddonFile.json(String path, String jsonContent) {
    return AddonFile(
      path: path,
      content: Uint8List.fromList(jsonContent.codeUnits),
      type: AddonFileType.json,
    );
  }

  /// Create a PNG image file
  factory AddonFile.png(String path, Uint8List imageData) {
    return AddonFile(
      path: path,
      content: imageData,
      type: AddonFileType.png,
    );
  }

  /// Create a text file
  factory AddonFile.text(String path, String textContent) {
    return AddonFile(
      path: path,
      content: Uint8List.fromList(textContent.codeUnits),
      type: AddonFileType.text,
    );
  }

  /// Create a JavaScript file
  factory AddonFile.javascript(String path, String jsContent) {
    return AddonFile(
      path: path,
      content: Uint8List.fromList(jsContent.codeUnits),
      type: AddonFileType.javascript,
    );
  }
}

enum AddonFileType {
  json,
  png,
  text,
  javascript,
}
