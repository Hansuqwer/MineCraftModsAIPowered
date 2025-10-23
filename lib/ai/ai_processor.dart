import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../ai/schema.dart';
import '../preview/crafta_cinematic_preview.dart';
import '../services/minecraft_image_service.dart';
import '../tts/encouragement_manager.dart';

class AiProcessor extends StatefulWidget {
  const AiProcessor({super.key});

  @override
  State<AiProcessor> createState() => _AiProcessorState();
}

class _AiProcessorState extends State<AiProcessor> {
  bool _loading = false;
  String _lastText = '';

  // 🔁 Your existing AI endpoint that returns CreationSpec-like JSON
  final _aiTextEndpoint = Uri.parse('https://api.crafta.ai/create_spec');
  // 🖼️ Image generator endpoint (replace with your API)
  final _imageEndpoint = Uri.parse('https://api.crafta.ai/generate_minecraft_image');
  late final MinecraftImageService _imgService;

  @override
  void initState() {
    super.initState();
    _imgService = MinecraftImageService(_imageEndpoint);
    EncouragementManager().init(); // voice ready
  }

  Future<void> _sendToAi(String prompt) async {
    if (prompt.trim().isEmpty) return;
    setState(() => _loading = true);

    try {
      // 1) Text → spec
      final r = await http.post(_aiTextEndpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'prompt': prompt}));
      CreationSpec spec;
      if (r.statusCode == 200) {
        spec = CreationSpec.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
      } else {
        // Fallback if AI is down
        spec = CreationSpec(
          object: 'dragon', theme: 'fire',
          colors: const ['red','black','gold'],
          size: 'medium', features: const ['glowing'],
        );
      }

      // 2) Spec → image
      final file = await _imgService.generateAndCache(spec);

      // 3) Preview + encouragement
      if (!mounted) return;
      await EncouragementManager().celebrate();

      final title = _titleFromSpec(spec);

      if (file != null) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => CraftaCinematicPreview(
            title: title,
            image: FileImage(file),
          ),
        ));
      } else {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => CraftaCinematicPreview(
            title: '$title (placeholder)',
            image: const AssetImage('assets/images/default_placeholder.png'),
          ),
        ));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI error: $e')),
      );
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => const CraftaCinematicPreview(
          title: 'Preview (offline)',
          image: AssetImage('assets/images/default_placeholder.png'),
        ),
      ));
    } finally {
      setState(() => _loading = false);
    }
  }

  String _titleFromSpec(CreationSpec s) {
    final color = s.colors.isNotEmpty ? s.colors.first : '';
    return 'Your ${s.theme} ${color.isNotEmpty ? "$color " : ""}${s.object}';
    // e.g., "Your fire red dragon"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6F1FF),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🎨 Crafta – AI Creator",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Type: a two-seat couch with a dragon cover…",
                  border: OutlineInputBorder(),
                  filled: true, fillColor: Colors.white,
                ),
                onChanged: (v) => _lastText = v,
                onSubmitted: _sendToAi,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loading ? null : () => _sendToAi(_lastText),
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Create"),
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

