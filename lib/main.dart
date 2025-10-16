import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/welcome_screen.dart';
import 'screens/creator_screen.dart';
import 'screens/complete_screen.dart';
import 'screens/creature_preview_screen.dart';
import 'screens/parent_settings_screen.dart';
import 'screens/creation_history_screen.dart';
import 'screens/export_management_screen.dart';

/// Main entry point for Crafta app
/// Loads environment variables and initializes the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables from .env file
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded successfully');
  } catch (e) {
    print('⚠️ Warning: Could not load .env file. Make sure to create one from .env.example');
    print('   Error: $e');
  }

  runApp(const CraftaApp());
}

class CraftaApp extends StatelessWidget {
  const CraftaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crafta - AI-Powered Minecraft Mod Creator',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      initialRoute: '/',
            routes: {
              '/': (context) => const WelcomeScreen(),
              '/creator': (context) => const CreatorScreen(),
              '/complete': (context) => const CompleteScreen(),
              '/creature-preview': (context) {
                final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
                print('DEBUG: Creature preview route called with args: $args');
                return CreaturePreviewScreen(
                  creatureAttributes: args['creatureAttributes'],
                  creatureName: args['creatureName'],
                );
              },
              '/parent-settings': (context) => const ParentSettingsScreen(),
              '/creation-history': (context) => const CreationHistoryScreen(),
              '/export-management': (context) => const ExportManagementScreen(),
            },
    );
  }
}