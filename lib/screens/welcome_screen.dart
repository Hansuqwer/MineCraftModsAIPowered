import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/startup_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late AnimationController _bounceController;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize startup services
    _initializeStartup();
    
    // Sparkle animation for the rainbow emoji
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _sparkleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));
    
    // Bounce animation for the start button
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _bounceAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticInOut,
    ));
  }

  /// Initialize startup services
  Future<void> _initializeStartup() async {
    try {
      await StartupService.initialize(context);
    } catch (e) {
      print('❌ Startup initialization failed: $e');
    }
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  /// Show language selection dialog
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.language, color: Color(0xFF98D8C8)),
              SizedBox(width: 8),
              Text('Choose Language'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 32)),
                title: const Text('English'),
                onTap: () async {
                  await _setLanguage(context, 'en');
                },
              ),
              ListTile(
                leading: const Text('🇸🇪', style: TextStyle(fontSize: 32)),
                title: const Text('Svenska (Swedish)'),
                onTap: () async {
                  await _setLanguage(context, 'sv');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Set the language and refresh the app
  Future<void> _setLanguage(BuildContext context, String languageCode) async {
    try {
      // Import the language service
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', languageCode);

      // Show confirmation
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageCode == 'en'
                ? 'Language set to English'
                : 'Språk inställt på Svenska',
            ),
            backgroundColor: const Color(0xFF98D8C8),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error setting language: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0), // Crafta cream background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Crafta Logo/Title
              AnimatedBuilder(
                animation: _sparkleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _sparkleAnimation.value,
                    child: const Text(
                      '🌈 Crafta',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B9D), // Crafta pink
                        shadows: [
                          Shadow(
                            color: Color(0xFFFF6B9D),
                            blurRadius: 10,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'AI-Powered Minecraft Mod Creator',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Welcome Message
              const Text(
                'Welcome to Crafta!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tell me what you want to create, and I\'ll help you make it!',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Animated Start Creating Button
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bounceAnimation.value,
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/creator');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF98D8C8), // Crafta mint
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 8,
                          shadowColor: const Color(0xFF98D8C8).withOpacity(0.3),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 24,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Start Creating!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Test Speech Button (for development)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/creator');
                },
                child: const Text(
                  'Test Speech Recognition',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                  ),
                ),
              ),
              
              // Quick Access Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Language Button
                  TextButton.icon(
                    onPressed: () {
                      _showLanguageDialog(context);
                    },
                    icon: const Icon(Icons.language, size: 16),
                    label: const Text(
                      'Language',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Parent Settings Button
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/parent-settings');
                    },
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text(
                      'Settings',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Quick Tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F8FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF98D8C8),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFF98D8C8),
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '💡 Quick Tips',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Say "I want a dragon" to create creatures\n• Try "make me a chair" for furniture\n• Use colors like "blue", "rainbow", "gold"\n• Add effects like "wings", "sparkles", "glow"',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
