import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/startup_service.dart';
import '../services/app_localizations.dart';
import '../services/tutorial_service.dart';
import '../services/enhanced_speech_service.dart';
import '../services/secure_api_key_manager.dart';
import '../models/item_type.dart';
import '../theme/minecraft_theme.dart';
import 'tutorial_screen.dart';
import 'first_run_setup_screen.dart';

/// Consolidated Welcome Screen with Sequential Setup Flow
/// Combines: Welcome → Voice Setup → API Key → Language → Tutorial
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _floatController;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatAnimation;

  // Setup flow state
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Step data
  bool _voiceSetupCompleted = false;
  bool _apiKeySetupCompleted = false;
  String _selectedLanguage = 'English';
  bool _tutorialAccepted = false;

  @override
  void initState() {
    super.initState();

    // Initialize startup services
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStartup();
    });

    // Glow animation for title
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Float animation for creature icon
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _initializeStartup() async {
    try {
      await StartupService.initialize(context);
      print('✅ [WELCOME] Startup services initialized');
    } catch (e) {
      print('❌ [WELCOME] Startup initialization error: $e');
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
        _errorMessage = null;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _errorMessage = null;
      });
    }
  }

  Future<void> _completeSetup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Save all settings
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenWelcome', true);
      await prefs.setBool('voiceSetupCompleted', _voiceSetupCompleted);
      await prefs.setBool('apiKeySetupCompleted', _apiKeySetupCompleted);
      await prefs.setString('selectedLanguage', _selectedLanguage);
      await prefs.setBool('tutorialAccepted', _tutorialAccepted);

      // Navigate to creator or tutorial
      if (mounted) {
        if (_tutorialAccepted) {
          Navigator.pushReplacementNamed(context, '/tutorial');
        } else {
          Navigator.pushReplacementNamed(context, '/creator');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Setup failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinecraftTheme.dirtBrown,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Progress indicator
              _buildProgressIndicator(),
              
              const SizedBox(height: 40),
              
              // Current step content
              _buildCurrentStep(),
              
              const SizedBox(height: 40),
              
              // Navigation buttons
              _buildNavigationButtons(),
              
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                _buildErrorMessage(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= _currentStep 
                ? MinecraftTheme.goldOre 
                : MinecraftTheme.stoneGray.withOpacity(0.3),
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildVoiceSetupStep();
      case 2:
        return _buildApiKeyStep();
      case 3:
        return _buildLanguageStep();
      case 4:
        return _buildTutorialStep();
      default:
        return _buildWelcomeStep();
    }
  }

  Widget _buildWelcomeStep() {
    return Column(
      children: [
        // Animated title
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _glowAnimation.value,
              child: Text(
                'Welcome to Crafta!',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: MinecraftTheme.goldOre,
                  shadows: [
                    Shadow(
                      color: MinecraftTheme.goldOre.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
        
        const SizedBox(height: 20),
        
        // Animated creature icon
        AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: MinecraftTheme.grassGreen,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: MinecraftTheme.goldOre,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 30),
        
        Text(
          'Let\'s set up your AI-powered Minecraft creation experience!',
          style: TextStyle(
            fontSize: 18,
            color: MinecraftTheme.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'We\'ll help you configure voice recognition, API keys, language, and show you how to use the app.',
          style: TextStyle(
            fontSize: 16,
            color: MinecraftTheme.textDark.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVoiceSetupStep() {
    return Column(
      children: [
        Icon(
          Icons.mic,
          size: 80,
          color: MinecraftTheme.goldOre,
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Voice Setup',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: MinecraftTheme.textDark,
          ),
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Let\'s set up your voice so Crafta can hear you perfectly! This only takes a minute.',
          style: TextStyle(
            fontSize: 16,
            color: MinecraftTheme.textDark.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 30),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _voiceSetupCompleted = false;
                });
                _nextStep();
              },
              icon: const Icon(Icons.skip_next),
              label: const Text('Skip for Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                
                try {
                  await Navigator.pushNamed(context, '/voice-calibration');
                  setState(() {
                    _voiceSetupCompleted = true;
                    _isLoading = false;
                  });
                  _nextStep();
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = 'Voice setup failed: $e';
                  });
                }
              },
              icon: const Icon(Icons.mic),
              label: const Text('Set Up Voice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApiKeyStep() {
    return Column(
      children: [
        Icon(
          Icons.key,
          size: 80,
          color: MinecraftTheme.goldOre,
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'API Key Setup',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: MinecraftTheme.textDark,
          ),
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'For the best AI quality, add your OpenAI API key. You can skip this and use limited offline mode.',
          style: TextStyle(
            fontSize: 16,
            color: MinecraftTheme.textDark.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 30),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _apiKeySetupCompleted = false;
                });
                _nextStep();
              },
              icon: const Icon(Icons.skip_next),
              label: const Text('Skip for Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                
                try {
                  await Navigator.pushNamed(context, '/ai-setup');
                  setState(() {
                    _apiKeySetupCompleted = true;
                    _isLoading = false;
                  });
                  _nextStep();
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = 'API key setup failed: $e';
                  });
                }
              },
              icon: const Icon(Icons.key),
              label: const Text('Add API Key'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageStep() {
    return Column(
      children: [
        Icon(
          Icons.language,
          size: 80,
          color: MinecraftTheme.goldOre,
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Choose Language',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: MinecraftTheme.textDark,
          ),
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Select your preferred language for the app interface.',
          style: TextStyle(
            fontSize: 16,
            color: MinecraftTheme.textDark.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 30),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLanguageOption('English', 'English'),
            _buildLanguageOption('Swedish', 'Svenska'),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageOption(String value, String display) {
    final isSelected = _selectedLanguage == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = value;
        });
        _nextStep();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? MinecraftTheme.goldOre : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? MinecraftTheme.goldOre : Colors.grey[400]!,
            width: 2,
          ),
        ),
        child: Text(
          display,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialStep() {
    return Column(
      children: [
        Icon(
          Icons.school,
          size: 80,
          color: MinecraftTheme.goldOre,
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Tutorial',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: MinecraftTheme.textDark,
          ),
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Would you like to see a quick tutorial on how to use Crafta?',
          style: TextStyle(
            fontSize: 16,
            color: MinecraftTheme.textDark.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 30),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _tutorialAccepted = false;
                });
                _completeSetup();
              },
              icon: const Icon(Icons.skip_next),
              label: const Text('Skip Tutorial'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _tutorialAccepted = true;
                });
                _completeSetup();
              },
              icon: const Icon(Icons.school),
              label: const Text('Show Tutorial'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _previousStep,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
            ),
          )
        else
          const SizedBox(width: 100),
        
        if (_currentStep < 4)
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _nextStep,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: MinecraftTheme.goldOre,
              foregroundColor: Colors.white,
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _completeSetup,
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.check),
            label: Text(_isLoading ? 'Setting up...' : 'Complete Setup'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red[600]),
            ),
          ),
        ],
      ),
    );
  }
}