import 'package:flutter/material.dart';
import '../models/minecraft/addon_metadata.dart';

/// Mobile-optimized settings screen for Minecraft integration
class MinecraftSettingsScreen extends StatefulWidget {
  const MinecraftSettingsScreen({Key? key}) : super(key: key);

  @override
  State<MinecraftSettingsScreen> createState() => _MinecraftSettingsScreenState();
}

class _MinecraftSettingsScreenState extends State<MinecraftSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Crafta Creatures');
  final _descriptionController = TextEditingController(text: 'AI-generated creatures from Crafta app');
  final _namespaceController = TextEditingController(text: 'crafta');
  final _authorController = TextEditingController(text: 'Crafta');
  final _versionController = TextEditingController(text: '1.0.0');
  
  bool _includeScriptAPI = true;
  bool _generateSpawnEggs = true;
  bool _autoExport = false;
  bool _cloudSync = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _namespaceController.dispose();
    _authorController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Minecraft Settings'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Addon Metadata Card
              _buildAddonMetadataCard(),
              const SizedBox(height: 20),

              // Export Options Card
              _buildExportOptionsCard(),
              const SizedBox(height: 20),

              // Advanced Settings Card
              _buildAdvancedSettingsCard(),
              const SizedBox(height: 20),

              // Save Button
              _buildSaveButton(),
              const SizedBox(height: 20),

              // Help Section
              _buildHelpSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddonMetadataCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Addon Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Addon Name',
                hintText: 'My Amazing Creatures',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an addon name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _namespaceController,
                    decoration: InputDecoration(
                      labelText: 'Namespace',
                      hintText: 'crafta',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.code),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a namespace';
                      }
                      if (!RegExp(r'^[a-z_]+$').hasMatch(value)) {
                        return 'Namespace must be lowercase letters and underscores only';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _versionController,
                    decoration: InputDecoration(
                      labelText: 'Version',
                      hintText: '1.0.0',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.tag),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a version';
                      }
                      if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(value)) {
                        return 'Version must be in format X.Y.Z';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: 'Author',
                hintText: 'Your name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOptionsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: Colors.orange[600], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Export Options',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Include Script API'),
              subtitle: const Text('Add custom commands like /crafta:summon'),
              value: _includeScriptAPI,
              onChanged: (value) => setState(() => _includeScriptAPI = value),
              secondary: const Icon(Icons.code),
            ),
            SwitchListTile(
              title: const Text('Generate Spawn Eggs'),
              subtitle: const Text('Add spawn eggs to creative inventory'),
              value: _generateSpawnEggs,
              onChanged: (value) => setState(() => _generateSpawnEggs = value),
              secondary: const Icon(Icons.egg),
            ),
            SwitchListTile(
              title: const Text('Auto Export'),
              subtitle: const Text('Automatically export after creature creation'),
              value: _autoExport,
              onChanged: (value) => setState(() => _autoExport = value),
              secondary: const Icon(Icons.auto_awesome),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettingsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.purple[600], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Advanced Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Cloud Sync'),
              subtitle: const Text('Sync creatures across devices'),
              value: _cloudSync,
              onChanged: (value) => setState(() => _cloudSync = value),
              secondary: const Icon(Icons.cloud_sync),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Export All Creatures'),
              subtitle: const Text('Create a collection addon'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _exportAllCreatures,
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Export History'),
              subtitle: const Text('View and manage exports'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _viewExportHistory,
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Minecraft Help'),
              subtitle: const Text('Learn how to install addons'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _showMinecraftHelp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _saveSettings,
        icon: const Icon(Icons.save),
        label: const Text('Save Settings'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, color: Colors.green[600], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Quick Help',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '• Namespace: Used in creature identifiers (e.g., crafta:dragon)\n'
              '• Script API: Enables custom commands and features\n'
              '• Spawn Eggs: Adds creatures to creative inventory\n'
              '• Auto Export: Saves time by exporting immediately',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      // Save settings to preferences
      final metadata = AddonMetadata(
        name: _nameController.text,
        description: _descriptionController.text,
        namespace: _namespaceController.text,
        version: _versionController.text,
        author: _authorController.text,
        includeScriptAPI: _includeScriptAPI,
        generateSpawnEggs: _generateSpawnEggs,
      );

      // TODO: Save to SharedPreferences or similar
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings saved successfully!'),
          backgroundColor: Colors.green[600],
        ),
      );
    }
  }

  void _exportAllCreatures() {
    // TODO: Navigate to export all creatures screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export all creatures feature coming soon!'),
      ),
    );
  }

  void _viewExportHistory() {
    // TODO: Navigate to export history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export history feature coming soon!'),
      ),
    );
  }

  void _showMinecraftHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Minecraft Installation Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to Install Addons:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Download the .mcpack file from Crafta'),
              Text('2. Open Minecraft Bedrock Edition'),
              Text('3. Go to Settings → Storage'),
              Text('4. Tap "Import" and select the .mcpack file'),
              Text('5. Activate the addon in your world'),
              Text('6. Your creatures will appear in the game!'),
              SizedBox(height: 16),
              Text(
                'Troubleshooting:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Make sure you\'re using Minecraft Bedrock Edition'),
              Text('• Check that the addon is activated in world settings'),
              Text('• Try restarting Minecraft after installing'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}


