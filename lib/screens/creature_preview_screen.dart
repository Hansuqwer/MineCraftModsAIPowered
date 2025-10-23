import 'package:flutter/material.dart';
import '../preview/crafta_cinematic_preview.dart';
import '../ai/schema.dart';
import '../services/tts_service.dart';
import '../services/quick_minecraft_export_service.dart';
import '../services/minecraft_launcher_service.dart';

class CreaturePreviewScreen extends StatefulWidget {
  final Map<String, dynamic> creatureAttributes;
  final String creatureName;

  const CreaturePreviewScreen({
    super.key,
    required this.creatureAttributes,
    required this.creatureName,
  });

  @override
  State<CreaturePreviewScreen> createState() => _CreaturePreviewScreenState();
}

class _CreaturePreviewScreenState extends State<CreaturePreviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _sparkleController;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _sparkleAnimation;
  
  final TTSService _ttsService = TTSService();
  bool _isPlayingSound = false;

  @override
  void initState() {
    super.initState();
    print('DEBUG: CreaturePreviewScreen initialized with attributes: ${widget.creatureAttributes}');
    print('DEBUG: Creature name: ${widget.creatureName}');
    _initializeAnimations();
    _initializeTTS();
    _playCreatureSound();
  }

  void _initializeAnimations() {
    // Celebration animation
    _celebrationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _celebrationAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    // Sparkle animation
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

  void _playCreatureSound() async {
    if (_isPlayingSound) return;
    
    _isPlayingSound = true;
    final creatureType = widget.creatureAttributes['creatureType'] ?? 'creature';
    await _ttsService.playCreatureSound(creatureType);
    
    // Play celebration sound after creature sound
    await Future.delayed(const Duration(seconds: 2));
    await _ttsService.playCelebrationSound();
    
    _isPlayingSound = false;
  }

  // Removed Firebase image generation - now using Babylon.js 3D previews

  @override
  void dispose() {
    _celebrationController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0), // Crafta cream background
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B9D), // Crafta pink
        title: const Text(
          'Your Creation!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
                // Celebration Header
                Container(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _celebrationAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _celebrationAnimation.value,
                            child: const Icon(
                              Icons.celebration,
                              size: 60,
                              color: Color(0xFFFF6B9D),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Amazing! Your ${widget.creatureName} is ready!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Look at what you created!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // View Toggle (2D/3D/Enhanced)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      const Text(
                        'View:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                          // Simplified to single 3D preview only
                          _buildViewButton('3D Preview', true, () {
                            // Single 3D preview mode
                          }),
                        ],
                      ),
                    ],
                  ),
                ),

                // Creature Preview
                Container(
                  height: 400,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _sparkleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_sparkleAnimation.value * 0.1),
                          child: _build3DPreview(),
                        );
                      },
                    ),
                  ),
                ),

                // Item Details
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getDetailsTitle(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildDetailRow('Name', widget.creatureName),
                      _buildDetailRow('Type', widget.creatureAttributes['creatureType'] ?? 'Unknown'),
                      _buildDetailRow('Color', widget.creatureAttributes['color'] ?? 'Unknown'),
                      _buildDetailRow('Size', widget.creatureAttributes['size'] ?? 'Normal'),
                      
                      if (widget.creatureAttributes['effects'] != null && 
                          (widget.creatureAttributes['effects'] as List).isNotEmpty)
                        _buildDetailRow('Effects', (widget.creatureAttributes['effects'] as List).join(', ')),
                      
                      if (widget.creatureAttributes['behavior'] != null)
                        _buildDetailRow('Behavior', widget.creatureAttributes['behavior']),
                      
                      if (widget.creatureAttributes['abilities'] != null && 
                          (widget.creatureAttributes['abilities'] as List).isNotEmpty)
                        _buildDetailRow('Abilities', (widget.creatureAttributes['abilities'] as List).join(', ')),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action Button (Export only)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/complete',
                          arguments: {
                            'creatureName': widget.creatureName,
                            'creatureType': widget.creatureAttributes['creatureType'],
                            'creatureAttributes': widget.creatureAttributes,
                          },
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Export'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B9D),
                        foregroundColor: Colors.white,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
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
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  String _getCreatureDescription() {
    final effects = widget.creatureAttributes['effects'] as List<String>? ?? [];
    final abilities = widget.creatureAttributes['abilities'] as List<String>? ?? [];

    String description = '${widget.creatureAttributes['color']} ${widget.creatureAttributes['creatureType']}';

    if (effects.isNotEmpty) {
      description += ' with ${effects.join(' and ')}';
    }

    if (abilities.isNotEmpty) {
      description += ' that can ${abilities.join(' and ')}';
    }

    return description;
  }

  // NEW: World Selector Dialog for Direct Minecraft Export
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

  // NEW: Quick Export to Minecraft
  Future<void> _quickExportToMinecraft(String worldType) async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⏳ Preparing your creation for Minecraft...'),
        duration: Duration(seconds: 5),
      ),
    );

    try {
      // Step 1: Export to .mcpack file (with PHASE 0.2 routing)
      print('📦 Starting quick export with type detection...');
      final mcpackPath = await QuickMinecraftExportService.quickExportCreatureWithRouting(
        creatureAttributes: widget.creatureAttributes,
        creatureName: widget.creatureName,
        worldType: worldType,
      );

      print('✅ Export complete: $mcpackPath');

      // Step 2: Validate .mcpack file
      final isValid = await QuickMinecraftExportService.validateMcpackFile(mcpackPath);
      if (!isValid) {
        throw Exception('.mcpack file validation failed');
      }

      // Step 3: Check if Minecraft installed
      final isMinecraftInstalled = await MinecraftLauncherService.isMinecraftInstalled();

      if (isMinecraftInstalled) {
        // Step 4: Launch Minecraft
        print('🚀 Launching Minecraft...');
        await MinecraftLauncherService.launchMinecraftWithAddon(
          mcpackPath,
          worldType,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Launching Minecraft...'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Minecraft not installed - show instructions
        // Show success message with file location
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ File saved to Downloads: ${mcpackPath.split('/').last}'),
            duration: const Duration(seconds: 8),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'More Info',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Import Addon to Minecraft'),
                    content: Text(
                      MinecraftLauncherService.getMissingMinecraftInstructions(),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Get the appropriate details title based on item type
  String _getDetailsTitle() {
    final itemType = widget.creatureAttributes['creatureType']?.toString().toLowerCase() ?? '';
    
    // Armor items
    if (itemType.contains('helmet') || itemType.contains('chestplate') || 
        itemType.contains('leggings') || itemType.contains('boots') || 
        itemType.contains('armor')) {
      return 'Armor Details';
    }
    
    // Weapons
    if (itemType.contains('sword') || itemType.contains('bow') || 
        itemType.contains('axe') || itemType.contains('hammer') || 
        itemType.contains('wand') || itemType.contains('staff') || 
        itemType.contains('shield')) {
      return 'Weapon Details';
    }
    
    // Furniture
    if (itemType.contains('chair') || itemType.contains('table') || 
        itemType.contains('bed') || itemType.contains('lamp') || 
        itemType.contains('bookshelf')) {
      return 'Furniture Details';
    }
    
    // Vehicles
    if (itemType.contains('car') || itemType.contains('boat') || 
        itemType.contains('plane') || itemType.contains('rocket') || 
        itemType.contains('spaceship')) {
      return 'Vehicle Details';
    }
    
    // Buildings
    if (itemType.contains('house') || itemType.contains('castle') || 
        itemType.contains('tower') || itemType.contains('bridge')) {
      return 'Building Details';
    }
    
    // Tools
    if (itemType.contains('pickaxe') || itemType.contains('shovel') || 
        itemType.contains('hoe') || itemType.contains('fishing rod')) {
      return 'Tool Details';
    }
    
    // Creatures (default)
    return 'Creature Details';
  }

  Widget _build3DPreview() {
    // Use Babylon.js 3D preview instead of Firebase image generation
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildCinematicPreview(),
      ),
    );
  }

  Widget _buildCinematicPreview() {
    // Convert creature attributes to CreationSpec
    final spec = CreationSpec(
      object: widget.creatureAttributes['baseType'] ?? 'dragon',
      theme: widget.creatureAttributes['primaryColor'] ?? 'red',
      colors: [
        widget.creatureAttributes['primaryColor'] ?? 'red',
        widget.creatureAttributes['secondaryColor'] ?? 'black',
      ],
      size: widget.creatureAttributes['size'] ?? 'medium',
      features: widget.creatureAttributes['abilities'] ?? [],
    );

    return GestureDetector(
      onTap: () => _showFullScreenPreview(spec),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Placeholder for now - will be replaced with actual image
              Container(
                color: Colors.blue[50],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 64, color: Colors.blue),
                      SizedBox(height: 16),
                      Text(
                        'Cinematic Preview',
                        style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Tap to view full screen',
                        style: TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Tap to expand',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenPreview(CreationSpec spec) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CraftaCinematicPreview(
          title: 'Your ${spec.theme} ${spec.object}',
          image: const AssetImage('assets/images/default_placeholder.png'),
        ),
      ),
    );
  }

  IconData _getCreatureIcon() {
    final type = widget.creatureAttributes['creatureType']?.toString().toLowerCase() ?? '';
    if (type.contains('dragon')) return Icons.pets;
    if (type.contains('sword')) return Icons.sports_martial_arts;
    if (type.contains('chair') || type.contains('couch')) return Icons.chair;
    if (type.contains('table')) return Icons.table_restaurant;
    if (type.contains('helmet')) return Icons.sports_motorsports;
    return Icons.auto_awesome;
  }

  Color _getCreatureColor() {
    final color = widget.creatureAttributes['color']?.toString().toLowerCase() ?? 'blue';
    switch (color) {
      case 'black': return Colors.black;
      case 'white': return Colors.white;
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'yellow': return Colors.yellow;
      case 'purple': return Colors.purple;
      case 'pink': return Colors.pink;
      case 'orange': return Colors.orange;
      case 'brown': return Colors.brown;
      case 'gold': case 'golden': return Colors.amber;
      case 'silver': return Colors.grey;
      default: return Colors.blue;
    }
  }

  Widget _buildViewButton(String label, bool isSelected, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey[400]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF666666),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}