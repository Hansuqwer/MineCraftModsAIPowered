import 'package:flutter/material.dart';
import '../services/ai_content_generator.dart';
import '../services/3d_model_generator.dart';
// 3D preview removed - using cinematic preview instead
import '../services/ai_minecraft_export_service.dart';
import '../services/tts_service.dart';

/// AI Creation Screen - Complete voice-to-3D pipeline
class AICreationScreen extends StatefulWidget {
  const AICreationScreen({super.key});

  @override
  State<AICreationScreen> createState() => _AICreationScreenState();
}

class _AICreationScreenState extends State<AICreationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final TTSService _ttsService = TTSService();
  
  ModelBlueprint? _currentBlueprint;
  bool _isProcessing = false;
  bool _isGenerating = false;
  bool _isExporting = false;
  String _statusMessage = '';
  
  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTTS();
  }

  void _initializeAnimations() {
    _celebrationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _celebrationAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeTTS() async {
    await _ttsService.initialize();
  }

  Future<void> _processInput(String input) async {
    if (input.trim().isEmpty) return;
    
    setState(() {
      _isProcessing = true;
      _statusMessage = '🧠 AI is thinking...';
    });

    try {
      // Process with AI
      final blueprint = await AIContentGenerator.processInput(input);
      
      setState(() {
        _currentBlueprint = blueprint;
        _isProcessing = false;
        _statusMessage = '✅ AI created your ${blueprint.object}!';
      });

      // Play success sound
      await _ttsService.speak('Amazing! Your ${blueprint.object} is ready!');
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = '❌ Error: $e';
      });
    }
  }

  Future<void> _exportToMinecraft() async {
    if (_currentBlueprint == null) return;
    
    setState(() {
      _isExporting = true;
      _statusMessage = '📦 Exporting to Minecraft...';
    });

    try {
      final exportService = AIMinecraftExportService();
      final result = await exportService.exportCreature(
        _currentBlueprint!.toMap(),
        _currentBlueprint!.object,
      );
      
      setState(() {
        _isExporting = false;
        _statusMessage = '✅ Exported to: $result';
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 ${_currentBlueprint!.object} exported to Minecraft!'),
          ),
        );
      }
      
    } catch (e) {
      setState(() {
        _isExporting = false;
        _statusMessage = '❌ Export failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text(
          'AI Creation Studio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
        actions: [
          if (_currentBlueprint != null)
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: _isExporting ? null : _exportToMinecraft,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input section
            _buildInputSection(),
            const SizedBox(height: 24),
            
            // Status section
            if (_statusMessage.isNotEmpty) _buildStatusSection(),
            
            // 3D Preview section
            if (_currentBlueprint != null) _buildPreviewSection(),
            
            // Blueprint details
            if (_currentBlueprint != null) _buildBlueprintSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎨 What would you like to create?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Describe your idea and AI will build it for you!',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'e.g., "I want a couch with a dragon cover"',
              hintStyle: const TextStyle(color: Colors.white60),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : () => _processInput(_textController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF667eea),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isProcessing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('AI is thinking...'),
                      ],
                    )
                  : const Text(
                      '🎨 Create with AI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _statusMessage.contains('❌') 
            ? Colors.red.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _statusMessage.contains('❌') 
              ? Colors.red.withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _statusMessage.contains('❌') ? Icons.error : Icons.check_circle,
            color: _statusMessage.contains('❌') ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: _statusMessage.contains('❌') ? Colors.red : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎮 3D Preview',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '3D Preview Removed',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  'Using Cinematic Preview Mode',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlueprintSection() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 AI Blueprint',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildBlueprintItem('Object', _currentBlueprint!.object),
          _buildBlueprintItem('Theme', _currentBlueprint!.theme),
          _buildBlueprintItem('Colors', _currentBlueprint!.colorScheme.join(', ')),
          _buildBlueprintItem('Material', _currentBlueprint!.material),
          _buildBlueprintItem('Size', _currentBlueprint!.size),
          if (_currentBlueprint!.specialFeatures.isNotEmpty)
            _buildBlueprintItem('Features', _currentBlueprint!.specialFeatures.join(', ')),
          const SizedBox(height: 16),
          Text(
            _currentBlueprint!.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlueprintItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }
}
