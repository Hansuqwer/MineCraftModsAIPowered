import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'services/language_service.dart';
import 'services/debug_service.dart';
import 'services/responsive_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/creator_screen.dart';
import 'screens/complete_screen.dart';
import 'screens/creature_preview_screen.dart';
import 'screens/parent_settings_screen.dart';
import 'screens/creation_history_screen.dart';
import 'screens/export_management_screen.dart';
import 'screens/export_minecraft_screen.dart';
import 'screens/minecraft_settings_screen.dart';
import 'screens/legal_settings_screen.dart';
import 'screens/creature_sharing_screen.dart';
import 'screens/dragon_couch_preview.dart';
import 'screens/ai_setup_screen.dart';

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

  // Initialize debug service
  await DebugService.initialize();

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
      localizationsDelegates: LanguageService.getLocalizationDelegates(),
      supportedLocales: LanguageService.getSupportedLocales(),
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
        '/export-minecraft': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ExportMinecraftScreen(
            creatureAttributes: args['creatureAttributes'],
            creatureName: args['creatureName'],
          );
        },
        '/minecraft-settings': (context) => const MinecraftSettingsScreen(),
        '/legal-settings': (context) => const LegalSettingsScreen(),
        '/creature-sharing': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return CreatureSharingScreen(
            creatureAttributes: args?['creatureAttributes'],
            creatureName: args?['creatureName'],
          );
        },
        '/dragon-couch-preview': (context) => const DragonCouchPreviewScreen(),
        '/ai-setup': (context) => const AISetupScreen(),
            },
    );
  }
}