import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

/// Splash screen that checks setup status and routes accordingly
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSetupAndNavigate();
  }

  /// Check if setup is complete and navigate to appropriate screen
  Future<void> _checkSetupAndNavigate() async {
    try {
      developer.log('[SPLASH] Checking setup status...');

      // Wait a minimum time for splash screen visibility
      await Future.delayed(const Duration(milliseconds: 500));

      // Check setup status
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedSetup = prefs.getBool('has_completed_setup') ?? false;

      developer.log('[SPLASH] Setup completed: $hasCompletedSetup');

      if (!mounted) return;

      // Navigate based on setup status
      if (hasCompletedSetup) {
        developer.log('[SPLASH] Navigating to welcome screen');
        Navigator.pushReplacementNamed(context, '/welcome');
      } else {
        developer.log('[SPLASH] Navigating to first-run setup');
        Navigator.pushReplacementNamed(context, '/first-run-setup');
      }
    } catch (e) {
      developer.log('[SPLASH] Error checking setup status: $e', level: 1000);

      // On error, default to welcome screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7CB342), // MinecraftTheme.grassGreen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.auto_awesome,
              size: 100,
              color: Color(0xFFFCBE11), // MinecraftTheme.goldOre
            ),
            SizedBox(height: 32),
            Text(
              'Crafta',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFCBE11),
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'AI-Powered Minecraft Creator',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 48),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Color(0xFFFCBE11),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
