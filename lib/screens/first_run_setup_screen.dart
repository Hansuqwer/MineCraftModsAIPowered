import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_key_service.dart';
import '../services/app_localizations.dart';
import '../theme/minecraft_theme.dart';

/// First-run setup wizard for configuring the app
///
/// Shown only on the first launch to help users:
/// - Configure API keys (optional)
/// - Select language
/// - Learn about the app
class FirstRunSetupScreen extends StatefulWidget {
  const FirstRunSetupScreen({super.key});

  @override
  State<FirstRunSetupScreen> createState() => _FirstRunSetupScreenState();
}

class _FirstRunSetupScreenState extends State<FirstRunSetupScreen> {
  int _currentStep = 0;
  final _apiKeyController = TextEditingController();
  bool _isValidatingKey = false;
  bool _keyIsValid = false;
  String? _validationError;
  String _selectedLanguage = 'en';

  final ApiKeyService _apiKeyService = ApiKeyService();

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  /// Complete the setup and navigate to main app
  Future<void> _completeSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_setup', true);

    if (!mounted) return;

    // Navigate to welcome screen
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  /// Validate the entered API key
  Future<void> _validateApiKey() async {
    setState(() {
      _isValidatingKey = true;
      _validationError = null;
      _keyIsValid = false;
    });

    final key = _apiKeyController.text.trim();

    if (key.isEmpty) {
      setState(() {
        _validationError = 'Please enter an API key';
        _isValidatingKey = false;
      });
      return;
    }

    final isValid = await _apiKeyService.validateApiKey(key);

    setState(() {
      _isValidatingKey = false;
      _keyIsValid = isValid;
      if (!isValid) {
        _validationError = 'Invalid API key. Please check and try again.';
      }
    });

    if (isValid) {
      // Save the key
      await _apiKeyService.saveApiKey(key);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ API key saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Skip API key setup
  void _skipApiKey() {
    setState(() => _currentStep++);
  }

  /// Go to next step
  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _completeSetup();
    }
  }

  /// Go to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: MinecraftTheme.grassGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),

            // Step content
            Expanded(
              child: _buildStepContent(l10n),
            ),

            // Navigation buttons
            _buildNavigationButtons(l10n),
          ],
        ),
      ),
    );
  }

  /// Build progress indicator at top
  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Container(
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isCompleted
                    ? MinecraftTheme.emerald
                    : isActive
                        ? MinecraftTheme.goldOre
                        : MinecraftTheme.stoneGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Build content for current step
  Widget _buildStepContent(AppLocalizations l10n) {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep(l10n);
      case 1:
        return _buildApiKeyStep(l10n);
      case 2:
        return _buildLanguageStep(l10n);
      case 3:
        return _buildTutorialStep(l10n);
      default:
        return const SizedBox();
    }
  }

  /// Step 1: Welcome
  Widget _buildWelcomeStep(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 120,
            color: MinecraftTheme.goldOre,
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome to Crafta!',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: MinecraftTheme.goldOre,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Let\'s get you set up to create amazing creatures and items for Minecraft!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MinecraftTheme.goldOre, width: 2),
            ),
            child: Column(
              children: [
                _buildFeatureItem(
                  Icons.mic,
                  'Voice Control',
                  'Just speak to create creatures',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  Icons.psychology,
                  'AI Powered',
                  'Smart AI understands what you want',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  Icons.extension,
                  'Minecraft Ready',
                  'Export directly to your game',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Icon(icon, color: MinecraftTheme.goldOre, size: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Step 2: API Key Configuration
  Widget _buildApiKeyStep(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.key,
            size: 80,
            color: MinecraftTheme.goldOre,
          ),
          const SizedBox(height: 24),
          Text(
            'OpenAI API Key',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: MinecraftTheme.goldOre,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'For the best AI quality, add your OpenAI API key.\n\nYou can skip this and use limited offline mode.',
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'API Key',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    hintText: 'sk-...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: _keyIsValid
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                  obscureText: true,
                  onChanged: (_) {
                    setState(() {
                      _keyIsValid = false;
                      _validationError = null;
                    });
                  },
                ),
                if (_validationError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _validationError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isValidatingKey ? null : _validateApiKey,
                    icon: _isValidatingKey
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                        _isValidatingKey ? 'Validating...' : 'Test & Save Key'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MinecraftTheme.emerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: _skipApiKey,
            child: const Text(
              'Skip for now (use offline mode)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'How to get an API key:',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Visit platform.openai.com\n'
                  '2. Sign up or log in\n'
                  '3. Go to API Keys section\n'
                  '4. Create new secret key\n'
                  '5. Copy and paste it here',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Step 3: Language Selection
  Widget _buildLanguageStep(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.language,
            size: 80,
            color: MinecraftTheme.goldOre,
          ),
          const SizedBox(height: 24),
          Text(
            'Choose Your Language',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: MinecraftTheme.goldOre,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 32),
          _buildLanguageOption('en', 'English', '🇬🇧'),
          const SizedBox(height: 16),
          _buildLanguageOption('sv', 'Svenska', '🇸🇪'),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, String flag) {
    final isSelected = _selectedLanguage == code;

    return GestureDetector(
      onTap: () async {
        setState(() => _selectedLanguage = code);

        // Save language preference
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('language_code', code);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? MinecraftTheme.goldOre : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? MinecraftTheme.goldOre : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: MinecraftTheme.goldOre.withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 32),
          ],
        ),
      ),
    );
  }

  /// Step 4: Tutorial/Completion
  Widget _buildTutorialStep(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.celebration,
            size: 100,
            color: MinecraftTheme.goldOre,
          ),
          const SizedBox(height: 24),
          Text(
            'All Set!',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: MinecraftTheme.goldOre,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          const Text(
            'You\'re ready to start creating!',
            style: TextStyle(color: Colors.white, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MinecraftTheme.goldOre, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Tips:',
                  style: TextStyle(
                    color: MinecraftTheme.goldOre,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTipItem('1. Tap the microphone button to speak'),
                _buildTipItem('2. Describe what you want to create'),
                _buildTipItem('3. Preview and modify your creation'),
                _buildTipItem('4. Export to Minecraft and have fun!'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: MinecraftTheme.emerald, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build navigation buttons at bottom
  Widget _buildNavigationButtons(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Back button
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back', style: TextStyle(fontSize: 16)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),

          // Next/Finish button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep == 1 && !_keyIsValid) {
                  // On API key step, allow skip
                  _skipApiKey();
                } else {
                  _nextStep();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MinecraftTheme.goldOre,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _currentStep == 3 ? 'Start Creating!' : 'Next',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
