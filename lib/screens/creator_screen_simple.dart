import 'package:flutter/material.dart';
import '../services/enhanced_item_creation_service.dart';
import '../services/enhanced_ai_service.dart';
import '../models/enhanced_creature_attributes.dart';
import '../models/item_type.dart';
import '../theme/minecraft_theme.dart';

/// Simplified Creator Screen - Basic implementation without problematic services
class CreatorScreenSimple extends StatefulWidget {
  final ItemType? itemType;
  final ItemMaterialType? material;

  const CreatorScreenSimple({
    super.key,
    this.itemType,
    this.material,
  });

  @override
  State<CreatorScreenSimple> createState() => _CreatorScreenSimpleState();
}

class _CreatorScreenSimpleState extends State<CreatorScreenSimple> {
  final TextEditingController _textController = TextEditingController();
  late ItemType _selectedItemType;
  Map<String, dynamic>? _currentItem;

  @override
  void initState() {
    super.initState();
    _selectedItemType = widget.itemType ?? ItemType.creature;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final text = _textController.text;
    if (text.isEmpty) return;

    print('🎨 [CREATOR] User requested: "$text"');
    print('🎨 [CREATOR] Item type: $_selectedItemType');

    // Show loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Generate prompt for the AI based on item type and user input
      final prompt = EnhancedItemCreationService.generatePromptForItemType(
        itemType: _selectedItemType,
        userInput: text,
      );

      print('🤖 [CREATOR] Calling AI with prompt...');

      // Call AI service to parse the request
      final aiResponse = await EnhancedAIService.parseEnhancedCreatureRequest(prompt);

      print('✅ [CREATOR] AI returned response');
      print('🔍 [CREATOR] Base type: ${aiResponse.baseType}');
      print('🔍 [CREATOR] Custom name: ${aiResponse.customName}');
      print('🔍 [CREATOR] Primary color: ${aiResponse.primaryColor}');
      print('🔍 [CREATOR] Size: ${aiResponse.size}');

      // Use toMap() method for proper conversion
      _currentItem = aiResponse.toMap();

      // Add item type for routing
      _currentItem!['itemType'] = _selectedItemType.toString().split('.').last;

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Navigate to preview screen
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/creature-preview',
          arguments: {
            'creatureAttributes': _currentItem,
            'creatureName': _currentItem!['customName'],
          },
        );
      }
    } catch (e) {
      print('❌ [CREATOR] Error creating item: $e');

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show kid-friendly error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Icon(
                    Icons.help_outline,
                    size: 64,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),

                  // Kid-friendly message
                  Text(
                    'Oops! I need help!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Please ask a parent or grown-up to help set up the AI.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    '(They need to add an API key in Settings)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.all(16),
                          ),
                          child: const Text('OK', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/parent-settings');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.all(16),
                          ),
                          child: const Text(
                            'Get Parent',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinecraftTheme.grassGreen,
      appBar: AppBar(
        title: const Text('Create Something Amazing!'),
        backgroundColor: MinecraftTheme.deepStone,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Item type display
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _selectedItemType.emoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create a ${_selectedItemType.displayName}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5A5A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedItemType.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Input field
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Describe your ${_selectedItemType.displayName.toLowerCase()}...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.create),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Create button
              ElevatedButton.icon(
                onPressed: _handleCreate,
                icon: const Icon(Icons.check),
                label: const Text('Create'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF98D8C8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
