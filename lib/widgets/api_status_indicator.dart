import 'package:flutter/material.dart';
import '../services/api_key_service.dart';
import '../theme/minecraft_theme.dart';

/// Widget that displays the current API/AI status
///
/// Shows one of three states:
/// - 🟢 Online (API key configured and working)
/// - 🟡 Limited Mode (No API key, using offline cache)
/// - 🔴 Error (API key invalid or network issue)
class ApiStatusIndicator extends StatefulWidget {
  const ApiStatusIndicator({super.key});

  @override
  State<ApiStatusIndicator> createState() => _ApiStatusIndicatorState();
}

class _ApiStatusIndicatorState extends State<ApiStatusIndicator> {
  bool _hasApiKey = false;
  bool _isLoading = true;
  String _keyPrefix = '';

  @override
  void initState() {
    super.initState();
    _checkApiKeyStatus();
  }

  /// Check if API key exists
  Future<void> _checkApiKeyStatus() async {
    final apiKeyService = ApiKeyService();
    final status = await apiKeyService.getKeyStatus();

    if (mounted) {
      setState(() {
        _hasApiKey = status['hasKey'] ?? false;
        _keyPrefix = status['keyPrefix'] ?? '';
        _isLoading = false;
      });
    }
  }

  /// Show detailed status dialog
  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _hasApiKey ? Icons.check_circle : Icons.warning,
              color: _hasApiKey ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(_hasApiKey ? 'AI Online' : 'Limited Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hasApiKey) ...[
              const Text(
                'Your app is connected to OpenAI for the best AI quality.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'API Key: $_keyPrefix',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ] else ...[
              const Text(
                'You\'re using offline mode with limited creature variety.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'To enable full AI features, add your OpenAI API key in Settings.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          if (!_hasApiKey)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/parent-settings');
              },
              child: const Text('Add API Key'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return GestureDetector(
      onTap: _showStatusDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _hasApiKey
              ? Colors.green.withOpacity(0.2)
              : Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hasApiKey ? Colors.green : Colors.orange,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _hasApiKey ? Icons.cloud_done : Icons.cloud_off,
              color: _hasApiKey ? Colors.green : Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              _hasApiKey ? 'Online' : 'Offline',
              style: TextStyle(
                color: _hasApiKey ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact version for smaller spaces
class CompactApiStatusIndicator extends StatefulWidget {
  const CompactApiStatusIndicator({super.key});

  @override
  State<CompactApiStatusIndicator> createState() =>
      _CompactApiStatusIndicatorState();
}

class _CompactApiStatusIndicatorState extends State<CompactApiStatusIndicator> {
  bool _hasApiKey = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkApiKeyStatus();
  }

  Future<void> _checkApiKeyStatus() async {
    final apiKeyService = ApiKeyService();
    final hasKey = await apiKeyService.hasApiKey();

    if (mounted) {
      setState(() {
        _hasApiKey = hasKey;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _hasApiKey ? Colors.green : Colors.orange,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (_hasApiKey ? Colors.green : Colors.orange).withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
