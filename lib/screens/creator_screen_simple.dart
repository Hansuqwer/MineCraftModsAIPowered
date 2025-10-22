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

  /// Convert Flutter Color to string name
  String _colorToString(Color color) {
    if (color == Colors.black || color.value == Colors.black.value) return 'black';
    if (color == Colors.blue || color.value == Colors.blue.value) return 'blue';
    if (color == Colors.red || color.value == Colors.red.value) return 'red';
    if (color == Colors.green || color.value == Colors.green.value) return 'green';
    if (color == Colors.yellow || color.value == Colors.yellow.value) return 'yellow';
    if (color == Colors.purple || color.value == Colors.purple.value) return 'purple';
    if (color == Colors.pink || color.value == Colors.pink.value) return 'pink';
    if (color == Colors.orange || color.value == Colors.orange.value) return 'orange';
    if (color == Colors.white || color.value == Colors.white.value) return 'white';
    if (color == Colors.brown || color.value == 0xFF795548) return 'brown';
    if (color == Colors.grey || color.value == Colors.grey.value) return 'gray';
    if (color == Colors.amber || color.value == Colors.amber.value) return 'golden';
    if (color == Colors.amber.shade600 || color.value == 0xFFFFD700) return 'golden';
    return 'blue'; // Default
  }

  Future<void> _handleCreate() async {
    final text = _textController.text;
    if (text.isEmpty) return;

    print('🎨 [CREATOR] User requested: "$text"');
    print('🎨 [CREATOR] Item type: $_selectedItemType');
    
    // Test color mapping
    EnhancedAIService.testColorMapping();

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

      // Convert to map with proper field names for preview screen
      _currentItem = {
        // Field names expected by creature_preview_approval_screen.dart
        'creatureType': aiResponse.baseType,  // Preview expects 'creatureType'
        'color': _colorToString(aiResponse.primaryColor),  // Preview expects 'color' as string
        'baseType': aiResponse.baseType,
        'customName': aiResponse.customName,
        'size': aiResponse.size.name,
        'abilities': aiResponse.abilities.map((a) => a.name).toList(),
        'accessories': aiResponse.accessories.map((a) => a.name).toList(),
        'primaryColor': aiResponse.primaryColor.value,
        'secondaryColor': aiResponse.secondaryColor.value,
        'itemType': _selectedItemType.toString().split('.').last,
      };

      print('🔍 [CREATOR] Mapped creatureType: ${_currentItem!['creatureType']}');
      print('🔍 [CREATOR] Mapped color: ${_currentItem!['color']}');
      print('🔍 [CREATOR] Full _currentItem map: $_currentItem');

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Generic creation header
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
                    // Magic wand icon
                    Text(
                      '✨',
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'What do you want to create?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5A5A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'I can create anything! Dragons, swords, chairs, castles... just tell me!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Input field with microphone
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'blue sword, red dragon, gold castle...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.create),
                      ),
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Microphone button
                  Container(
                    height: 90,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.mic, size: 40, color: Colors.white),
                      onPressed: () {
                        // TODO: Add voice input functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎤 Voice input coming soon! For now, please type.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Create button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: _handleCreate,
                  icon: const Icon(Icons.auto_awesome, size: 28),
                  label: const Text('Create!', style: TextStyle(fontSize: 22)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF98D8C8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
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
