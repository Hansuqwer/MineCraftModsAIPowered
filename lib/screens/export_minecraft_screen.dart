import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/minecraft/minecraft_export_service.dart';
import '../models/minecraft/addon_metadata.dart';
import '../models/minecraft/addon_package.dart';
import '../models/item_type.dart';
import '../widgets/creature_preview.dart';
import '../widgets/legal_disclaimer.dart';

/// Mobile-optimized screen for exporting creatures to Minecraft
class ExportMinecraftScreen extends StatefulWidget {
  final Map<String, dynamic> creatureAttributes;
  final String creatureName;

  const ExportMinecraftScreen({
    Key? key,
    required this.creatureAttributes,
    required this.creatureName,
  }) : super(key: key);

  @override
  State<ExportMinecraftScreen> createState() => _ExportMinecraftScreenState();
}

class _ExportMinecraftScreenState extends State<ExportMinecraftScreen> {
  bool _isExporting = false;
  bool _includeScriptAPI = true;
  bool _generateSpawnEggs = true;
  late TextEditingController _addonNameController;
  late TextEditingController _addonDescriptionController;
  AddonPackage? _generatedAddon;
  String? _exportError;

  @override
  void initState() {
    super.initState();
    _addonNameController = TextEditingController(text: '${widget.creatureName} Addon');
    _addonDescriptionController = TextEditingController(text: 'AI-generated ${widget.creatureName} from Crafta');
  }

  @override
  void dispose() {
    _addonNameController.dispose();
    _addonDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Export to Minecraft'),
        backgroundColor: const Color(0xFF98D8C8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Creature Preview
            _buildCreaturePreview(),
            const SizedBox(height: 24),
            
            // Export Settings
            _buildExportSettings(),
            const SizedBox(height: 24),
            
            // Export Button
            _buildExportButton(),
            const SizedBox(height: 16),
            
            // Export Results
            if (_generatedAddon != null) _buildExportResults(),
            if (_exportError != null) _buildErrorDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreaturePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pets, color: Color(0xFF98D8C8)),
              const SizedBox(width: 8),
              Text(
                'Your Creature',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D5A5A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CreaturePreview(
            creatureAttributes: widget.creatureAttributes,
            size: 120,
          ),
          const SizedBox(height: 12),
          _buildCreatureAttributes(),
        ],
      ),
    );
  }

  Widget _buildCreatureAttributes() {
    final attributes = widget.creatureAttributes;
    return Column(
      children: [
        _buildAttributeRow('Name', attributes['creatureName'] ?? 'Unknown'),
        _buildAttributeRow('Type', attributes['creatureType'] ?? 'creature'),
        _buildAttributeRow('Color', attributes['color'] ?? 'normal'),
        _buildAttributeRow('Size', attributes['size'] ?? 'normal'),
        if (attributes['abilities'] != null && (attributes['abilities'] as List).isNotEmpty)
          _buildAttributeRow('Abilities', (attributes['abilities'] as List).join(', ')),
        if (attributes['effects'] != null && (attributes['effects'] as List).isNotEmpty)
          _buildAttributeRow('Effects', (attributes['effects'] as List).join(', ')),
      ],
    );
  }

  Widget _buildAttributeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D5A5A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings, color: Color(0xFF98D8C8)),
              const SizedBox(width: 8),
              Text(
                'Export Settings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D5A5A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _addonNameController,
            decoration: InputDecoration(
              labelText: 'Addon Name',
              hintText: 'My Amazing Creature',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addonDescriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Describe your creature addon',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.description),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          
          // Legal disclaimer
          const CompactLegalDisclaimer(),
          
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  title: const Text('Include Script API'),
                  subtitle: const Text('Add custom commands'),
                  value: _includeScriptAPI,
                  onChanged: (value) => setState(() => _includeScriptAPI = value),
                  activeColor: const Color(0xFF98D8C8),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  title: const Text('Generate Spawn Eggs'),
                  subtitle: const Text('Creature spawn eggs'),
                  value: _generateSpawnEggs,
                  onChanged: (value) => setState(() => _generateSpawnEggs = value),
                  activeColor: const Color(0xFF98D8C8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isExporting ? null : _exportToMinecraft,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF98D8C8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 2,
        ),
        child: _isExporting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Generating Addon...'),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text(
                    'Export to Minecraft',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildExportResults() {
    if (_generatedAddon == null) return const SizedBox.shrink();

    final preview = MinecraftExportService.getExportPreview(_generatedAddon!);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600),
              const SizedBox(width: 8),
              Text(
                'Export Successful!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPreviewRow('Addon Name', preview['addon_name']),
          _buildPreviewRow('File Count', '${preview['file_count']} files'),
          _buildPreviewRow('Size', preview['estimated_size']),
          _buildPreviewRow('Creatures', '${preview['creature_count']} creature(s)'),
          if (preview['has_scripts'] == true)
            _buildPreviewRow('Scripts', 'Custom commands included'),
          if (preview['has_spawn_eggs'] == true)
            _buildPreviewRow('Spawn Eggs', 'Creature spawn eggs included'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareAddon(_generatedAddon!),
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _downloadAddon(_generatedAddon!),
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade600,
                    side: BorderSide(color: Colors.green.shade600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D5A5A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _exportError!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToMinecraft() async {
    setState(() {
      _isExporting = true;
      _exportError = null;
    });

    try {
      final metadata = AddonMetadata(
        name: _addonNameController.text.isEmpty ? 'Crafta Item' : _addonNameController.text,
        description: _addonDescriptionController.text.isEmpty
          ? 'AI-generated item from Crafta'
          : _addonDescriptionController.text,
        namespace: 'crafta',
        includeScriptAPI: _includeScriptAPI,
        generateSpawnEggs: _generateSpawnEggs,
      );

      // Detect if this is a creature or an item
      final itemTypeStr = widget.creatureAttributes['itemType'] as String?;
      final ItemType? itemType = itemTypeStr != null ? _parseItemType(itemTypeStr) : null;

      final AddonPackage addon;

      if (itemType == null || itemType == ItemType.creature) {
        // Export as creature (original behavior)
        addon = await MinecraftExportService.exportCreature(
          creatureAttributes: widget.creatureAttributes,
          metadata: metadata,
        );
      } else {
        // Export as item (weapon, armor, tool, furniture, etc.)
        addon = await MinecraftExportService.exportItem(
          itemAttributes: widget.creatureAttributes,
          itemType: itemType,
          metadata: metadata,
        );
      }

      setState(() {
        _generatedAddon = addon;
        _isExporting = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Minecraft addon generated successfully!'),
          backgroundColor: Colors.green.shade600,
        ),
      );
    } catch (e) {
      setState(() {
        _exportError = 'Failed to generate addon: $e';
        _isExporting = false;
      });
    }
  }

  /// Parse string to ItemType enum
  ItemType? _parseItemType(String itemTypeStr) {
    switch (itemTypeStr.toLowerCase()) {
      case 'weapon':
        return ItemType.weapon;
      case 'armor':
        return ItemType.armor;
      case 'furniture':
        return ItemType.furniture;
      case 'tool':
        return ItemType.tool;
      case 'decoration':
        return ItemType.decoration;
      case 'vehicle':
        return ItemType.vehicle;
      case 'creature':
        return ItemType.creature;
      default:
        return null;
    }
  }

  Future<void> _shareAddon(AddonPackage addon) async {
    try {
      final filePath = await MinecraftExportService.saveAsMcpack(addon);
      await MinecraftExportService.exportAndShare(addon);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Addon shared successfully!'),
          backgroundColor: Color(0xFF98D8C8),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share addon: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  Future<void> _downloadAddon(AddonPackage addon) async {
    try {
      final filePath = await MinecraftExportService.saveAsMcpack(addon);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Addon saved to: $filePath'),
          backgroundColor: const Color(0xFF98D8C8),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download addon: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }
}