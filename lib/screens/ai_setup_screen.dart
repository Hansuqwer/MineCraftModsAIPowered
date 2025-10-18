import 'package:flutter/material.dart';
import '../services/api_key_manager.dart';

class AISetupScreen extends StatefulWidget {
  const AISetupScreen({super.key});

  @override
  State<AISetupScreen> createState() => _AISetupScreenState();
}

class _AISetupScreenState extends State<AISetupScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _setupStatus = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadSetupStatus();
  }

  void _initializeControllers() {
    _controllers['groq'] = TextEditingController();
    _controllers['huggingface'] = TextEditingController();
    _controllers['openai'] = TextEditingController();
  }

  Future<void> _loadSetupStatus() async {
    final status = await APIKeyManager.getSetupStatus();
    setState(() {
      _setupStatus.addAll(status);
    });
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0), // Crafta cream
      appBar: AppBar(
        backgroundColor: const Color(0xFF98D8C8), // Crafta mint
        title: const Text(
          'AI Setup',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.psychology,
                    size: 48,
                    color: Color(0xFF98D8C8),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Set Up AI Services',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose which AI services you want to use. You can start with just one!',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Groq Setup
            _buildServiceCard(
              'groq',
              'Groq (Recommended)',
              'Fast and free! 14,400 requests per day',
              Icons.flash_on,
              const Color(0xFF4CAF50),
            ),
            
            const SizedBox(height: 16),
            
            // Hugging Face Setup
            _buildServiceCard(
              'huggingface',
              'Hugging Face',
              'Free tier with 1,000 requests per month',
              Icons.favorite,
              const Color(0xFFFF6B6B),
            ),
            
            const SizedBox(height: 16),
            
            // Ollama Setup
            _buildServiceCard(
              'ollama',
              'Ollama (Local AI)',
              'Runs on your device - completely free',
              Icons.computer,
              const Color(0xFF9C27B0),
            ),
            
            const SizedBox(height: 16),
            
            // OpenAI Setup
            _buildServiceCard(
              'openai',
              'OpenAI (Paid)',
              'Most reliable but costs money',
              Icons.star,
              const Color(0xFFFF9800),
            ),
            
            const SizedBox(height: 32),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _continue,
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
                      'Continue to Crafta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(String service, String title, String description, IconData icon, Color color) {
    final isSetup = _setupStatus[service] ?? false;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSetup ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
          width: isSetup ? 2 : 1,
        ),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSetup)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 24,
                ),
            ],
          ),
          
          if (!isSetup && service != 'ollama') ...[
            const SizedBox(height: 16),
            TextField(
              controller: _controllers[service],
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'Paste your API key here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.key),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSetupInstructions(service),
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Setup Instructions'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _saveAPIKey(service),
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (service == 'ollama') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSetupInstructions(service),
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Install Instructions'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _checkOllamaStatus(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Check Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showSetupInstructions(String service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${service.toUpperCase()} Setup'),
        content: SingleChildScrollView(
          child: Text(APIKeyManager.getSetupInstructions(service)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAPIKey(String service) async {
    final key = _controllers[service]?.text.trim();
    if (key == null || key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an API key')),
      );
      return;
    }

    await APIKeyManager.setAPIKey(service, key);
    setState(() {
      _setupStatus[service] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$service API key saved!'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _checkOllamaStatus() {
    // This would check if Ollama is running
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ollama status check not implemented yet'),
      ),
    );
  }

  void _continue() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }
}
