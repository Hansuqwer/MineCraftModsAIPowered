import 'package:flutter/material.dart';
import '../services/enhanced_item_creation_service.dart';
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

    // Parse the response into item attributes
    _currentItem = EnhancedItemCreationService.parseItemResponse(
      '{}',
      _selectedItemType,
    );

    // Add default name and description
    _currentItem!['customName'] = text.isNotEmpty ? text : 'My ${_selectedItemType.displayName}';
    _currentItem!['itemType'] = _selectedItemType.toString().split('.').last;

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
