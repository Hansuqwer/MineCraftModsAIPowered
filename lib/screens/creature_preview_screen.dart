import 'package:flutter/material.dart';
import '../widgets/creature_preview.dart';
import '../widgets/creature_3d_preview.dart';
import '../widgets/enhanced_creature_preview.dart';
import '../services/tts_service.dart';
import '../services/quick_minecraft_export_service.dart';
import '../services/minecraft_launcher_service.dart';
import '../services/firebase_image_service.dart';
import 'dart:convert';

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
  bool _is3DView = false;
  bool _isEnhancedView = false;
  String? _generatedImageBase64;
  bool _isGeneratingImage = false;
  bool _imageGenerationFailed = false;

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

  Future<void> _generate3DImage() async {
    if (_generatedImageBase64 != null) return; // Already generated
    
    setState(() {
      _isGeneratingImage = true;
      _imageGenerationFailed = false;
    });

    try {
      print('🎨 [3D_PREVIEW] Generating 3D image for: ${widget.creatureName}');
      print('🔍 [3D_PREVIEW] Attributes: ${widget.creatureAttributes}');
      
      // Add timeout to prevent infinite loading
      final imageBase64 = await FirebaseImageService.generateMinecraftImage(
        creatureAttributes: widget.creatureAttributes,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏰ [3D_PREVIEW] Image generation timed out after 30 seconds');
          return null;
        },
      );

      if (mounted) {
        setState(() {
          _generatedImageBase64 = imageBase64;
          _isGeneratingImage = false;
          _imageGenerationFailed = imageBase64 == null;
        });
        
        if (imageBase64 != null) {
          print('✅ [3D_PREVIEW] Image generated successfully');
        } else {
          print('⚠️ [3D_PREVIEW] Image generation failed - no data returned');
        }
      }
    } catch (e) {
      print('❌ [3D_PREVIEW] Error generating image: $e');
      if (mounted) {
        setState(() {
          _isGeneratingImage = false;
          _imageGenerationFailed = true;
        });
      }
    }
  }

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
                          _buildViewButton('2D', !_is3DView && !_isEnhancedView, () {
                            setState(() {
                              _is3DView = false;
                              _isEnhancedView = false;
                            });
                          }),
                          _buildViewButton('3D', _is3DView, () {
                            setState(() {
                              _is3DView = true;
                              _isEnhancedView = false;
                            });
                          }),
                          _buildViewButton('Enhanced', _isEnhancedView, () {
                            setState(() {
                              _is3DView = false;
                              _isEnhancedView = true;
                            });
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
                          child: _isEnhancedView
                              ? EnhancedCreaturePreview(
                                  creatureAttributes: widget.creatureAttributes,
                                  size: 300,
                                  isAnimated: true,
                                  enableInteraction: true,
                                  enableAdvancedEffects: true,
                                )
                              : _is3DView
                                  ? _build3DPreview()
                                  : CreaturePreview(
                                      creatureAttributes: widget.creatureAttributes,
                                      size: 300,
                                      isAnimated: true,
                                    ),
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
    // Generate image when switching to 3D view
    if (_is3DView && _generatedImageBase64 == null && !_isGeneratingImage) {
      _generate3DImage();
    }

    if (_isGeneratingImage) {
      return Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating 3D preview...'),
          ],
        ),
      );
    }

    if (_imageGenerationFailed || _generatedImageBase64 == null) {
      return Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[100]!,
              Colors.purple[100]!,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCreatureIcon(),
              size: 80,
              color: _getCreatureColor(),
            ),
            const SizedBox(height: 16),
            Text(
              widget.creatureName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '3D Preview\n(Image generation unavailable)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show the generated image
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
        child: Image.memory(
          base64Decode(_generatedImageBase64!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ [3D_PREVIEW] Error displaying image: $error');
            return Container(
              color: Colors.grey[200],
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Failed to load image'),
                ],
              ),
            );
          },
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