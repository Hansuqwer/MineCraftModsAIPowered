import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/secure_api_key_manager.dart';
import '../theme/minecraft_theme.dart';

/// API Key Setup Screen
/// Allows users to securely configure their API keys
class APIKeySetupScreen extends StatefulWidget {
  const APIKeySetupScreen({super.key});

  @override
  State<APIKeySetupScreen> createState() => _APIKeySetupScreenState();
}

class _APIKeySetupScreenState extends State<APIKeySetupScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _obscureText = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadExistingKeys();
  }

  void _initializeControllers() {
    final keyNames = ['OPENAI_API_KEY', 'GROQ_API_KEY', 'HUGGINGFACE_API_KEY'];
    for (final keyName in keyNames) {
      _controllers[keyName] = TextEditingController();
      _obscureText[keyName] = true;
    }
  }

  Future<void> _loadExistingKeys() async {
    setState(() => _isLoading = true);
    
    try {
      final keys = await SecureAPIKeyManager.getAllAPIKeys();
      for (final entry in keys.entries) {
        if (entry.value != null && entry.value!.isNotEmpty) {
          _controllers[entry.key]?.text = entry.value!;
        }
      }
    } catch (e) {
      print('Error loading existing keys: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinecraftTheme.darkBlue,
      appBar: AppBar(
        title: const Text(
          'API Key Setup',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: MinecraftTheme.darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildAPIKeySection('OPENAI_API_KEY', 'OpenAI API Key', 'sk-...'),
                  const SizedBox(height: 16),
                  _buildAPIKeySection('GROQ_API_KEY', 'Groq API Key', 'gsk_...'),
                  const SizedBox(height: 16),
                  _buildAPIKeySection('HUGGINGFACE_API_KEY', 'Hugging Face API Key', 'hf_...'),
                  const SizedBox(height: 32),
                  _buildStatusSection(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinecraftTheme.stoneGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MinecraftTheme.diamond, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: MinecraftTheme.diamond, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Secure API Configuration',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure your AI service API keys securely. Keys are stored encrypted on your device.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAPIKeySection(String keyName, String displayName, String example) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MinecraftTheme.stoneGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MinecraftTheme.diamond, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _obscureText[keyName]! ? Icons.visibility : Icons.visibility_off,
                  color: MinecraftTheme.diamond,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText[keyName] = !_obscureText[keyName]!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controllers[keyName],
            obscureText: _obscureText[keyName]!,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter your $displayName ($example)',
              hintStyle: const TextStyle(color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: MinecraftTheme.diamond),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: MinecraftTheme.diamond),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: MinecraftTheme.diamond, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Example: $example',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return FutureBuilder<Map<String, APIKeyStatus>>(
      future: SecureAPIKeyManager.getAPIKeyStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final status = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MinecraftTheme.stoneGray,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: MinecraftTheme.diamond, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'API Key Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...status.entries.map((entry) => _buildStatusItem(entry.key, entry.value)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusItem(String keyName, APIKeyStatus status) {
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case APIKeyStatus.valid:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case APIKeyStatus.invalid:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case APIKeyStatus.placeholder:
        statusColor = Colors.blue;
        statusIcon = Icons.info;
        break;
      case APIKeyStatus.notSet:
        statusColor = Colors.grey;
        statusIcon = Icons.circle_outlined;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 16),
          const SizedBox(width: 8),
          Text(
            keyName,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const Spacer(),
          Text(
            status.displayName,
            style: TextStyle(color: statusColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: MinecraftButton(
            text: 'Save Keys',
            onPressed: _saveKeys,
            color: MinecraftTheme.diamond,
            icon: Icons.save,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: MinecraftButton(
            text: 'Clear All',
            onPressed: _clearKeys,
            color: Colors.red,
            icon: Icons.clear,
          ),
        ),
      ],
    );
  }

  Future<void> _saveKeys() async {
    setState(() => _isLoading = true);

    try {
      for (final entry in _controllers.entries) {
        final keyName = entry.key;
        final controller = entry.value;
        
        if (controller.text.isNotEmpty && !controller.text.contains('your_')) {
          await SecureAPIKeyManager.storeAPIKey(keyName, controller.text);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API keys saved securely!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving keys: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearKeys() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Keys'),
        content: const Text('Are you sure you want to clear all API keys?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        await SecureAPIKeyManager.clearAllKeys();
        for (final controller in _controllers.values) {
          controller.clear();
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All API keys cleared!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing keys: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Minecraft-style button widget
class MinecraftButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final IconData? icon;
  final double? height;

  const MinecraftButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
