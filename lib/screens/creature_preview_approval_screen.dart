import 'package:flutter/material.dart';
import '../widgets/creature_preview.dart';
import '../services/tts_service.dart';
import '../services/enhanced_ai_service.dart';
import '../services/quick_minecraft_export_service.dart';
import '../services/minecraft_launcher_service.dart';

/// PHASE E: Creature Preview & Approval Screen
/// Shows 3D preview and asks user for approval before export
/// User can approve to export or request changes for AI regeneration
class CreaturePreviewApprovalScreen extends StatefulWidget {
  final Map<String, dynamic> creatureAttributes;
  final String creatureName;

  const CreaturePreviewApprovalScreen({
    super.key,
    required this.creatureAttributes,
    required this.creatureName,
  });

  @override
  State<CreaturePreviewApprovalScreen> createState() =>
      _CreaturePreviewApprovalScreenState();
}

class _CreaturePreviewApprovalScreenState
    extends State<CreaturePreviewApprovalScreen> with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnimation;

  final TTSService _ttsService = TTSService();
  bool _isLoading = false;
  int _generationAttempt = 1;

  @override
  void initState() {
    super.initState();
    print(
        '🎨 [PHASE E] Preview approval screen initialized for: ${widget.creatureName}');
    _initializeAnimations();
    _initializeTTS();
    _announcePreview();
  }

  void _initializeAnimations() {
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeTTS() async {
    await _ttsService.initialize();
  }

  void _announcePreview() async {
    // Welcome the user and ask about the creature
    await Future.delayed(const Duration(milliseconds: 500));
    await _ttsService.speak(
      'Here is your ${widget.creatureName}! Do you like it?',
    );
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0), // Crafta cream background
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B9D), // Crafta pink
        title: Text(
          _generationAttempt == 1
              ? 'Do You Like It?'
              : 'Let\'s Try Again! 🎨',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Title and description
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      Text(
                        '✨ ${widget.creatureName} ✨',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _generationAttempt == 1
                            ? 'This is what the AI created for you!'
                            : 'Here\'s the improved version!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_generationAttempt > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Attempt $_generationAttempt',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.amber[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),


                // Creature Preview
                Container(
                  height: 350,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF6B9D),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Creating your ${widget.creatureName}...',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          )
                        : AnimatedBuilder(
                            animation: _sparkleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (_sparkleAnimation.value * 0.05),
                                child: CreaturePreview(
                                  creatureAttributes:
                                      widget.creatureAttributes,
                                  size: 280,
                                  isAnimated: true,
                                ),
                              );
                            },
                          ),
                  ),
                ),

                // Creature Details (collapsible)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Details:',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Color',
                          widget.creatureAttributes['color'] ?? 'Mystery'),
                      _buildDetailRow('Type',
                          widget.creatureAttributes['creatureType'] ?? 'Creature'),
                      if (widget.creatureAttributes['size'] != null)
                        _buildDetailRow('Size',
                            widget.creatureAttributes['size'].toString()),
                      if (widget.creatureAttributes['abilities'] != null &&
                          (widget.creatureAttributes['abilities'] as List?)
                              ?.isNotEmpty ==
                              true)
                        _buildDetailRow(
                          'Abilities',
                          (widget.creatureAttributes['abilities'] as List)
                              .join(', '),
                        ),
                    ],
                  ),
                ),

                // Action Buttons
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      // YES - Approve and Export
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleApprovalYes,
                          icon: const Icon(Icons.check_circle, size: 24),
                          label: const Text(
                            'Yes! I Love It! 💚',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00AA00),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // NO - Make Changes
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleModificationRequest,
                          icon: const Icon(Icons.edit, size: 24),
                          label: const Text(
                            'Make Changes 🎨',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Go Back Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _isLoading ? Colors.grey : Colors.grey[400]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// User approved the creature - proceed to export
  Future<void> _handleApprovalYes() async {
    print('✅ [PHASE E] User approved creature: ${widget.creatureName}');

    await _ttsService.speak(
      'Great! Let\'s get it into Minecraft!',
    );

    // Navigate to export/world selector
    if (!mounted) return;
    _showWorldSelectorDialog();
  }

  /// User requested changes - ask what to modify
  Future<void> _handleModificationRequest() async {
    print('🎨 [PHASE E] User wants to modify creature: ${widget.creatureName}');

    await _ttsService.speak(
      'What would you like to change? Tell me!',
    );

    if (!mounted) return;

    // Show dialog for modification request
    _showModificationDialog();
  }

  /// Show dialog to get modification request from user
  void _showModificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📝 What would you like to change?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tell me what you\'d like different about your ${widget.creatureName}!',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Examples:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Make it bigger\n• Change the color to red\n• Add wings\n• Make it purple with stripes',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startModificationVoiceCapture();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
            ),
            child: const Text('Listen for Changes 🎤'),
          ),
        ],
      ),
    );
  }

  /// Capture voice input for modification request
  Future<void> _startModificationVoiceCapture() async {
    print('🎤 [PHASE E] Starting voice capture for modifications...');

    // TODO: Call KidVoiceService to capture voice input
    // For now, show a simple text input dialog as placeholder

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => _ModificationInputDialog(
        creatureName: widget.creatureName,
        onModificationSubmitted: _regenerateWithModifications,
      ),
    );
  }

  /// Regenerate creature with user's requested modifications
  Future<void> _regenerateWithModifications(String modificationRequest) async {
    print(
        '🔄 [PHASE E] Regenerating with modifications: $modificationRequest');

    setState(() {
      _isLoading = true;
      _generationAttempt++;
    });

    try {
      // Ask AI to modify the creature based on user request
      final modifiedAttributes =
          await _modifyCreatureWithAI(modificationRequest);

      if (!mounted) return;

      // Update the creature attributes
      setState(() {
        widget.creatureAttributes.clear();
        widget.creatureAttributes.addAll(modifiedAttributes);
        _isLoading = false;
      });

      // Announce the modification
      await _ttsService.speak(
        'Here\'s the new version! Do you like this better?',
      );

      print('✅ [PHASE E] Creature regenerated successfully');
    } catch (e) {
      print('❌ [PHASE E] Error regenerating creature: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Could not modify creature: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      await _ttsService.speak(
        'Oops! Let me try again.',
      );
    }
  }

  /// Call AI to modify creature based on user request
  Future<Map<String, dynamic>> _modifyCreatureWithAI(
      String modificationRequest) async {
    try {
      print('🤖 [PHASE E] Calling AI to modify creature...');
      print('   Current attributes: ${widget.creatureAttributes}');
      print('   Modification request: $modificationRequest');

      // Build a prompt for the AI
      final currentDescription = _buildCreatureDescription();
      final modificationPrompt =
          'Current: $currentDescription\n\nModify as requested: $modificationRequest';

      // Call EnhancedAIService to parse the modification
      final newAttributes = await EnhancedAIService
          .parseEnhancedCreatureRequest(modificationPrompt);

      print('✅ [PHASE E] AI returned modified attributes');

      // Handle EnhancedCreatureAttributes object by extracting properties
      // Always treat as EnhancedCreatureAttributes since that's what the service returns
      return {
        'baseType': newAttributes.baseType?.toString() ?? 'creature',
        'color': _extractColorString(newAttributes.primaryColor),
        'creatureType': newAttributes.baseType ?? 'creature',
        'size': newAttributes.size?.toString() ?? 'medium',
        'effects': [],
        'abilities': newAttributes.abilities?.map((a) => a.toString()).toList() ?? [],
      };
    } catch (e) {
      print('❌ [PHASE E] Error in AI modification: $e');
      rethrow;
    }
  }

  /// Extract color string from Color object
  String _extractColorString(dynamic color) {
    if (color == null) return 'blue';
    if (color is String) return color;

    // If it's a Color object, convert to string
    final colorStr = color.toString();
    if (colorStr.contains('red')) return 'red';
    if (colorStr.contains('blue')) return 'blue';
    if (colorStr.contains('green')) return 'green';
    if (colorStr.contains('yellow')) return 'yellow';
    if (colorStr.contains('purple')) return 'purple';
    if (colorStr.contains('pink')) return 'pink';
    if (colorStr.contains('orange')) return 'orange';

    return 'blue';
  }

  /// Build a human-readable description of current creature
  String _buildCreatureDescription() {
    final color = widget.creatureAttributes['color'] ?? 'unknown';
    final type = widget.creatureAttributes['creatureType'] ?? 'creature';
    final size = widget.creatureAttributes['size'] ?? 'medium';

    return 'A $size $color $type';
  }

  /// Show world selector dialog for export
  void _showWorldSelectorDialog() {
    String selectedWorld = 'new'; // Default: create new world

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('🎮 Where to Play?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('📝 Create New World'),
                    subtitle: const Text('Start fresh with your creation'),
                    value: 'new',
                    groupValue: selectedWorld,
                    onChanged: (String? value) {
                      setState(() {
                        selectedWorld = value ?? 'new';
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('🏠 Use Existing World'),
                    subtitle: const Text('Add to your current world'),
                    value: 'existing',
                    groupValue: selectedWorld,
                    onChanged: (String? value) {
                      setState(() {
                        selectedWorld = value ?? 'new';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _quickExportToMinecraft(selectedWorld);
                  },
                  icon: const Icon(Icons.play_circle_fill),
                  label: const Text('Export & Play'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00AA00),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Export to Minecraft with routing
  Future<void> _quickExportToMinecraft(String worldType) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⏳ Preparing your creation for Minecraft...'),
        duration: Duration(seconds: 5),
      ),
    );

    try {
      print('📦 Starting quick export with type detection...');
      final mcpackPath =
          await QuickMinecraftExportService.quickExportCreatureWithRouting(
        creatureAttributes: widget.creatureAttributes,
        creatureName: widget.creatureName,
        worldType: worldType,
      );

      print('✅ Export complete: $mcpackPath');

      final isValid =
          await QuickMinecraftExportService.validateMcpackFile(mcpackPath);
      if (!isValid) {
        throw Exception('.mcpack file validation failed');
      }

      final isMinecraftInstalled =
          await MinecraftLauncherService.isMinecraftInstalled();

      if (isMinecraftInstalled) {
        print('🚀 Launching Minecraft...');
        await MinecraftLauncherService.launchMinecraftWithAddon(
          mcpackPath,
          worldType,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Launching Minecraft...'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );

        await _ttsService.speak(
          'Have fun in Minecraft!',
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('⚠️ Minecraft not detected. File saved to Downloads.'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'More Info',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Import Addon to Minecraft'),
                    content: Text(
                      MinecraftLauncherService
                          .getMissingMinecraftInstructions(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

/// Dialog for user to input modification request
class _ModificationInputDialog extends StatefulWidget {
  final String creatureName;
  final Function(String) onModificationSubmitted;

  const _ModificationInputDialog({
    required this.creatureName,
    required this.onModificationSubmitted,
  });

  @override
  State<_ModificationInputDialog> createState() =>
      _ModificationInputDialogState();
}

class _ModificationInputDialogState extends State<_ModificationInputDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('📝 What should I change?'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'E.g., "Make it bigger and red"',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: const Icon(Icons.edit),
        ),
        maxLines: 3,
        textInputAction: TextInputAction.done,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isNotEmpty) {
              Navigator.pop(context);
              widget.onModificationSubmitted(text);
            }
          },
          icon: const Icon(Icons.check),
          label: const Text('Apply Changes'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9800),
          ),
        ),
      ],
    );
  }
}
