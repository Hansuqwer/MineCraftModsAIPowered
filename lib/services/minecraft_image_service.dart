import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../ai/schema.dart';
import '../ai/prompt_builder.dart';

/// Replace with your own generator endpoint.
/// Expected to accept JSON { prompt: string } and return { url: string } or raw image bytes.
/// For now this supports both: a) JSON with `url`, or b) raw bytes response.
class MinecraftImageService {
  final Uri endpoint; // e.g. Uri.parse('https://your-image-api/generate');

  const MinecraftImageService(this.endpoint);

  Future<File?> generateAndCache(CreationSpec spec) async {
    try {
      final prompt = buildMinecraftImagePrompt(spec);
      final cacheName = _safeName('${spec.object}_${spec.theme}_${spec.size}_${spec.colors.join("_")}_${spec.features.join("_")}');
      final dir = await getTemporaryDirectory();
      final out = File('${dir.path}/$cacheName.png');
      if (await out.exists()) return out;

      final res = await http.post(
        endpoint,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        // Try JSON { url: ... } first
        try {
          final j = jsonDecode(res.body);
          if (j is Map && j['url'] is String) {
            final imgRes = await http.get(Uri.parse(j['url']));
            if (imgRes.statusCode == 200) {
              await out.writeAsBytes(imgRes.bodyBytes);
              return out;
            }
          }
        } catch (_) {
          // not JSON; maybe it's raw PNG bytes
        }

        // Otherwise treat as bytes (API returns image directly)
        await out.writeAsBytes(res.bodyBytes);
        return out;
      }
    } catch (_) {}
    return null;
  }

  String _safeName(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .substring(0, s.length.clamp(0, 100));
}

