import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/creature_sharing_service.dart';
import '../widgets/creature_preview.dart';
import '../widgets/legal_disclaimer.dart';
import '../widgets/qr_code_generator.dart';

/// Screen for sharing and discovering creatures
class CreatureSharingScreen extends StatefulWidget {
  final Map<String, dynamic>? creatureAttributes;
  final String? creatureName;

  const CreatureSharingScreen({
    super.key,
    this.creatureAttributes,
    this.creatureName,
  });

  @override
  State<CreatureSharingScreen> createState() => _CreatureSharingScreenState();
}

class _CreatureSharingScreenState extends State<CreatureSharingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  List<Map<String, dynamic>> _localCreatures = [];
  List<Map<String, dynamic>> _publicCreatures = [];
  List<Map<String, dynamic>> _trendingCreatures = [];
  bool _isLoading = false;
  String _selectedCreatureType = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final local = await CreatureSharingService.getLocalCreatures();
      final trending = await CreatureSharingService.getTrendingCreatures();
      
      setState(() {
        _localCreatures = local;
        _trendingCreatures = trending;
        _publicCreatures = trending; // For now, use trending as public
      });
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Creatures'),
        backgroundColor: const Color(0xFF98D8C8),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.share), text: 'Share'),
            Tab(icon: Icon(Icons.cloud), text: 'Discover'),
            Tab(icon: Icon(Icons.history), text: 'My Creatures'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildShareTab(),
          _buildDiscoverTab(),
          _buildMyCreaturesTab(),
        ],
      ),
    );
  }

  Widget _buildShareTab() {
    if (widget.creatureAttributes == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No creature to share',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Create a creature first to share it',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Creature preview
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: CreaturePreview(
              creatureAttributes: widget.creatureAttributes!,
              size: 200,
              isAnimated: false,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Creature name
          Text(
            widget.creatureName ?? 'My Creature',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description field
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'Describe your creature...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
          ),
          
          const SizedBox(height: 16),
          
          // Privacy setting
          SwitchListTile(
            title: const Text('Make Public'),
            subtitle: const Text('Allow others to discover your creature'),
            value: true,
            onChanged: (value) {
              // Handle privacy setting
            },
            activeColor: const Color(0xFF98D8C8),
          ),
          
          const SizedBox(height: 16),
          
          // Legal disclaimer
          const CompactLegalDisclaimer(),
          
          const SizedBox(height: 24),
          
          // Share button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _shareCreature,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF98D8C8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 8,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Share Creature',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // External sharing options
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showQRCode(),
                  icon: const Icon(Icons.qr_code),
                  label: const Text('QR Code'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF98D8C8),
                    side: const BorderSide(color: Color(0xFF98D8C8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showExternalSharingOptions(),
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF98D8C8),
                    side: const BorderSide(color: Color(0xFF98D8C8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search creatures...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _searchCreatures();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => _searchCreatures(),
          ),
        ),
        
        // Filter chips
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFilterChip('All', 'all'),
              _buildFilterChip('Dragons', 'dragon'),
              _buildFilterChip('Unicorns', 'unicorn'),
              _buildFilterChip('Cows', 'cow'),
              _buildFilterChip('Furniture', 'couch'),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Creatures list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildCreaturesList(_publicCreatures),
        ),
      ],
    );
  }

  Widget _buildMyCreaturesTab() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.history, color: Color(0xFF98D8C8)),
              const SizedBox(width: 8),
              const Text(
                'My Shared Creatures',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
        
        // Creatures list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildCreaturesList(_localCreatures, isLocal: true),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedCreatureType == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCreatureType = value);
          _searchCreatures();
        },
        selectedColor: const Color(0xFF98D8C8).withOpacity(0.3),
        checkmarkColor: const Color(0xFF98D8C8),
      ),
    );
  }

  Widget _buildCreaturesList(List<Map<String, dynamic>> creatures, {bool isLocal = false}) {
    if (creatures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLocal ? Icons.history : Icons.cloud,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isLocal ? 'No shared creatures yet' : 'No creatures found',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              isLocal 
                  ? 'Share your first creature to see it here'
                  : 'Try a different search term',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: creatures.length,
      itemBuilder: (context, index) {
        final creature = creatures[index];
        return _buildCreatureCard(creature, isLocal: isLocal);
      },
    );
  }

  Widget _buildCreatureCard(Map<String, dynamic> creature, {bool isLocal = false}) {
    final attributes = creature['attributes'] as Map<String, dynamic>? ?? {};
    final name = creature['name'] ?? 'Unknown Creature';
    final description = creature['description'] ?? '';
    final shareCode = creature['id'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Creature preview
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: CreaturePreview(
                    creatureAttributes: attributes,
                    size: 60,
                    isAnimated: false,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Creature info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (description.isNotEmpty)
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Share code: $shareCode',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Actions
                PopupMenuButton<String>(
                  onSelected: (value) => _handleCreatureAction(value, creature),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'load',
                      child: Row(
                        children: [
                          Icon(Icons.download),
                          SizedBox(width: 8),
                          Text('Load'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share),
                          SizedBox(width: 8),
                          Text('Share'),
                        ],
                      ),
                    ),
                    if (isLocal)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                  child: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareCreature() async {
    if (widget.creatureAttributes == null) return;

    setState(() => _isLoading = true);

    try {
      final shareCode = await CreatureSharingService.shareCreature(
        creatureAttributes: widget.creatureAttributes!,
        creatureName: widget.creatureName ?? 'My Creature',
        description: _descriptionController.text.isEmpty 
            ? null 
            : _descriptionController.text,
        isPublic: true,
      );

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Creature Shared!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Your creature has been shared successfully!'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Share code: $shareCode',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: shareCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share code copied!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _shareToExternal(shareCode);
                },
                child: const Text('Share'),
              ),
            ],
          ),
        );
      }

      // Refresh data
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing creature: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchCreatures() async {
    setState(() => _isLoading = true);

    try {
      final results = await CreatureSharingService.searchPublicCreatures(
        query: _searchController.text.isEmpty ? null : _searchController.text,
        creatureType: _selectedCreatureType == 'all' ? null : _selectedCreatureType,
      );

      setState(() => _publicCreatures = results);
    } catch (e) {
      print('Error searching creatures: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleCreatureAction(String action, Map<String, dynamic> creature) {
    switch (action) {
      case 'load':
        _loadCreature(creature);
        break;
      case 'share':
        _shareCreatureToExternal(creature);
        break;
      case 'delete':
        _deleteCreature(creature);
        break;
    }
  }

  void _loadCreature(Map<String, dynamic> creature) {
    // Navigate back to creator with loaded creature
    Navigator.pop(context, creature);
  }

  void _shareCreatureToExternal(Map<String, dynamic> creature) {
    final shareCode = creature['id'] ?? '';
    final name = creature['name'] ?? 'Creature';
    _shareToExternal(shareCode, name);
  }

  void _shareToExternal(String shareCode, [String? name]) {
    final shareText = CreatureSharingService.getShareText(
      name ?? 'My Creature',
      shareCode,
    );
    
    Share.share(shareText);
  }

  void _deleteCreature(Map<String, dynamic> creature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Creature'),
        content: const Text('Are you sure you want to delete this creature?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await CreatureSharingService.deleteLocalCreature(creature['id']);
              await _loadData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showQRCode() {
    if (widget.creatureAttributes == null) return;
    
    // Generate a temporary share code for QR code
    final tempShareCode = 'TEMP${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    
    showDialog(
      context: context,
      builder: (context) => QRCodeDialog(
        shareCode: tempShareCode,
        creatureName: widget.creatureName ?? 'My Creature',
      ),
    );
  }

  void _showExternalSharingOptions() {
    if (widget.creatureAttributes == null) return;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Share ${widget.creatureName ?? 'Creature'}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Social media options
            _buildSocialShareOption('Twitter', Icons.alternate_email, Colors.blue),
            _buildSocialShareOption('Facebook', Icons.facebook, Colors.indigo),
            _buildSocialShareOption('Instagram', Icons.camera_alt, Colors.pink),
            _buildSocialShareOption('TikTok', Icons.music_note, Colors.black),
            
            const SizedBox(height: 16),
            
            // General share
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _shareToExternalWithText('I want a dragon couch');
                },
                icon: const Icon(Icons.share),
                label: const Text('Share via App'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF98D8C8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Copy share code
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _copyShareCode();
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy Share Code'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF98D8C8),
                  side: const BorderSide(color: Color(0xFF98D8C8)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialShareOption(String platform, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text('Share on $platform'),
      onTap: () {
        Navigator.pop(context);
        _shareToSocialMedia(platform);
      },
    );
  }

  void _shareToSocialMedia(String platform) {
    final tempShareCode = 'TEMP${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final shareText = CreatureSharingService.getSocialShareText(
      widget.creatureName ?? 'My Creature',
      tempShareCode,
      platform,
    );
    
    Share.share(shareText);
  }

  void _copyShareCode() {
    final tempShareCode = 'TEMP${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    Clipboard.setData(ClipboardData(text: tempShareCode));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share code copied: $tempShareCode'),
        backgroundColor: const Color(0xFF98D8C8),
      ),
    );
  }

  void _shareToExternalWithText(String text) {
    final shareText = CreatureSharingService.getDetailedShareText(
      widget.creatureName ?? 'My Creature',
      'TEMP${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      text,
    );
    
    Share.share(shareText);
  }
}
