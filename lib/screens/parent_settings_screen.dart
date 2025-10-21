import 'package:flutter/material.dart';
import '../widgets/language_selector.dart';
import '../services/ai_service.dart';
import '../services/api_key_service.dart';
import '../services/app_localizations.dart';

class ParentSettingsScreen extends StatefulWidget {
  const ParentSettingsScreen({super.key});

  @override
  State<ParentSettingsScreen> createState() => _ParentSettingsScreenState();
}

class _ParentSettingsScreenState extends State<ParentSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _securityController;
  late AnimationController _historyController;
  late Animation<double> _securityAnimation;
  late Animation<double> _historyAnimation;

  bool _speechEnabled = true;
  bool _ttsEnabled = true;
  bool _aiEnabled = true;
  bool _exportEnabled = true;
  bool _historyEnabled = true;
  String _selectedAgeGroup = '4-6';
  String _selectedSafetyLevel = 'High';

  final ApiKeyService _apiKeyService = ApiKeyService();
  final TextEditingController _apiKeyController = TextEditingController();
  bool _apiKeyConfigured = false;
  bool _showApiKey = false;

  @override
  void initState() {
    super.initState();

    _loadApiKey();

    // Security animation
    _securityController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _securityAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _securityController,
      curve: Curves.easeInOut,
    ));

    // History animation
    _historyController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _historyAnimation = Tween<double>(
      begin: 0.9,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _historyController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadApiKey() async {
    final key = await _apiKeyService.getApiKey();
    if (key != null && mounted) {
      setState(() {
        _apiKeyConfigured = true;
        _apiKeyController.text = key;
      });
    }
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) return;

    try {
      await _apiKeyService.saveApiKey(key);
      if (mounted) {
        setState(() => _apiKeyConfigured = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ API Key saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeApiKey() async {
    await _apiKeyService.removeApiKey();
    if (mounted) {
      setState(() {
        _apiKeyConfigured = false;
        _apiKeyController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Key removed'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _securityController.dispose();
    _historyController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0), // Crafta cream background
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B9D), // Crafta pink
        title: Text(
          l10n.parentSettings,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Security Header
              AnimatedBuilder(
                animation: _securityAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _securityAnimation.value,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF98D8C8), // Crafta mint
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF98D8C8).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.security,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.safetyFirst,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.craftaIsSafe,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // API Key Configuration Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.key, color: Colors.blue.shade700, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '🔑 OpenAI API Key',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                        if (_apiKeyConfigured)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Configured ✓',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Required for AI to create items. Get your free key at platform.openai.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _apiKeyController,
                      obscureText: !_showApiKey,
                      decoration: InputDecoration(
                        labelText: 'Enter API Key',
                        hintText: 'sk-proj-...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                _showApiKey ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() => _showApiKey = !_showApiKey);
                              },
                            ),
                            if (_apiKeyConfigured)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: _removeApiKey,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveApiKey,
                        icon: const Icon(Icons.save),
                        label: const Text('Save API Key'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Safety Controls
              Text(
                l10n.featureToggles,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),

              _buildSafetyCard(
                l10n.speechRecognition,
                l10n.speechRecognition,
                _speechEnabled,
                (value) => setState(() => _speechEnabled = value),
                Icons.mic,
              ),
              const SizedBox(height: 12),

              _buildSafetyCard(
                l10n.textToSpeech,
                l10n.textToSpeech,
                _ttsEnabled,
                (value) => setState(() => _ttsEnabled = value),
                Icons.volume_up,
              ),
              const SizedBox(height: 12),

              _buildSafetyCard(
                l10n.aiCreation,
                l10n.aiCreation,
                _aiEnabled,
                (value) => setState(() => _aiEnabled = value),
                Icons.psychology,
              ),
              const SizedBox(height: 12),

              _buildSafetyCard(
                l10n.minecraftExportFeature,
                l10n.minecraftExportFeature,
                _exportEnabled,
                (value) => setState(() => _exportEnabled = value),
                Icons.download,
              ),
              const SizedBox(height: 32),

              // Voice Settings
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B59B6).withOpacity(0.1), // Purple tint
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF9B59B6)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.settings_voice,
                      size: 48,
                      color: const Color(0xFF9B59B6),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Voice Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9B59B6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Adjust voice speed, calibrate microphone, and customize speech settings',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/voice-settings');
                        },
                        icon: const Icon(Icons.mic),
                        label: const Text(
                          'Configure Voice',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9B59B6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Age Group Selection
              Text(
                l10n.ageGroup,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: DropdownButton<String>(
                  value: _selectedAgeGroup,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: '4-6', child: Text('Ages 4-6')),
                    DropdownMenuItem(value: '7-8', child: Text('Ages 7-8')),
                    DropdownMenuItem(value: '9-10', child: Text('Ages 9-10')),
                  ],
                  onChanged: (value) => setState(() => _selectedAgeGroup = value ?? '4-6'),
                ),
              ),
              const SizedBox(height: 32),

              // Safety Level
              Text(
                l10n.safetyLevel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: DropdownButton<String>(
                  value: _selectedSafetyLevel,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: [
                    DropdownMenuItem(value: 'High', child: Text(l10n.high)),
                    DropdownMenuItem(value: 'Medium', child: Text(l10n.medium)),
                    DropdownMenuItem(value: 'Low', child: Text(l10n.low)),
                  ],
                  onChanged: (value) => setState(() => _selectedSafetyLevel = value ?? 'High'),
                ),
              ),
              const SizedBox(height: 32),

              // Creation History
              AnimatedBuilder(
                animation: _historyAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _historyAnimation.value,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7DC6F), // Crafta yellow
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF7DC6F).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.history,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.creationHistory,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.creationHistory,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _showHistoryDialog(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFF7DC6F),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Text(
                                l10n.viewHistory,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Export Management
              const Text(
                'Export Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.file_download,
                      size: 48,
                      color: Color(0xFF98D8C8),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Download Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage your child\'s mod downloads',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showManageExportsDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF98D8C8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Manage Exports',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Language Settings
              const LanguageSelector(),
              
              const SizedBox(height: 32),

              // Legal Settings Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/legal-settings');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 8,
                    shadowColor: Colors.orange.withOpacity(0.3),
                  ),
                  child: const Text(
                    'Legal & Privacy Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),

              // Save Settings Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings saved successfully!'),
                        backgroundColor: Color(0xFF98D8C8),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF98D8C8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFF98D8C8).withOpacity(0.3),
                  ),
                  child: const Text(
                    'Save Settings',
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
      ),
    );
  }

  Widget _buildSafetyCard(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: const Color(0xFF98D8C8),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF98D8C8),
          ),
        ],
      ),
    );
  }

  /// Show creation history dialog
  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.history,
                color: Color(0xFF98D8C8),
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Creation History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: _buildHistoryList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF98D8C8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build history list widget
  Widget _buildHistoryList() {
    // Mock history data - in real app, this would come from storage
    final historyData = [
      {
        'creature': 'Rainbow Dragon',
        'timestamp': '2024-01-15 14:30',
        'type': 'creature',
        'status': 'exported',
      },
      {
        'creature': 'Blue Couch',
        'timestamp': '2024-01-15 13:45',
        'type': 'furniture',
        'status': 'exported',
      },
      {
        'creature': 'Sparkly Unicorn',
        'timestamp': '2024-01-15 12:20',
        'type': 'creature',
        'status': 'created',
      },
      {
        'creature': 'Green Chair',
        'timestamp': '2024-01-15 11:15',
        'type': 'furniture',
        'status': 'created',
      },
      {
        'creature': 'Purple Cat with Wings',
        'timestamp': '2024-01-15 10:30',
        'type': 'creature',
        'status': 'exported',
      },
    ];

    return ListView.builder(
      itemCount: historyData.length,
      itemBuilder: (context, index) {
        final item = historyData[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            children: [
              // Icon based on type
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item['type'] == 'creature' 
                    ? const Color(0xFF98D8C8).withOpacity(0.2)
                    : const Color(0xFFF7DC6F).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  item['type'] == 'creature' ? Icons.pets : Icons.chair,
                  color: item['type'] == 'creature' 
                    ? const Color(0xFF98D8C8)
                    : const Color(0xFFF7DC6F),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['creature'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['timestamp'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item['status'] == 'exported' 
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : const Color(0xFFF7DC6F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item['status'] == 'exported' ? 'Exported' : 'Created',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: item['status'] == 'exported' 
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFF7DC6F),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show manage exports dialog
  void _showManageExportsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.file_download,
                color: Color(0xFF98D8C8),
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Manage Exports',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: _buildExportsList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF98D8C8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build exports list widget
  Widget _buildExportsList() {
    // Mock exports data - in real app, this would come from storage
    final exportsData = [
      {
        'name': 'Rainbow_Dragon.mcpack',
        'size': '2.3 MB',
        'date': '2024-01-15 14:30',
        'creature': 'Rainbow Dragon',
        'status': 'ready',
      },
      {
        'name': 'Blue_Couch.mcpack',
        'size': '1.8 MB',
        'date': '2024-01-15 13:45',
        'creature': 'Blue Couch',
        'status': 'ready',
      },
      {
        'name': 'Purple_Cat_with_Wings.mcpack',
        'size': '2.1 MB',
        'date': '2024-01-15 10:30',
        'creature': 'Purple Cat with Wings',
        'status': 'ready',
      },
      {
        'name': 'Green_Chair.mcpack',
        'size': '1.5 MB',
        'date': '2024-01-15 11:15',
        'creature': 'Green Chair',
        'status': 'ready',
      },
    ];

    return ListView.builder(
      itemCount: exportsData.length,
      itemBuilder: (context, index) {
        final item = exportsData[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            children: [
              // File icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF98D8C8).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.file_download,
                  color: Color(0xFF98D8C8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['creature'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item['name']} • ${item['size']} • ${item['date']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Re-export button
                  IconButton(
                    onPressed: () => _reExportFile(item['name'] as String),
                    icon: const Icon(
                      Icons.refresh,
                      color: Color(0xFF98D8C8),
                      size: 20,
                    ),
                    tooltip: 'Re-export',
                  ),
                  
                  // Delete button
                  IconButton(
                    onPressed: () => _deleteExportFile(item['name'] as String),
                    icon: const Icon(
                      Icons.delete,
                      color: Color(0xFFFF6B6B),
                      size: 20,
                    ),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Re-export a file
  void _reExportFile(String fileName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Re-exporting $fileName...'),
        backgroundColor: const Color(0xFF98D8C8),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Delete an export file
  void _deleteExportFile(String fileName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Export',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          content: Text(
            'Are you sure you want to delete $fileName?',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$fileName deleted'),
                    backgroundColor: const Color(0xFF4CAF50),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF6B6B),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

