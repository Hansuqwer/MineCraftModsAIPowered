import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;
import 'services/language_service.dart';
import 'services/debug_service.dart';
import 'services/secure_api_key_manager.dart';
import 'services/error_handling_service.dart';
import 'screens/splash_screen.dart';
import 'screens/first_run_setup_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/creator_screen_simple.dart';
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
import 'screens/minecraft_3d_viewer_screen.dart';
import 'screens/ai_creation_screen.dart';
import 'ai/ai_processor.dart';
import 'screens/kid_friendly_screen.dart';
import 'screens/voice_calibration_screen.dart';
import 'screens/voice_settings_screen.dart';
import 'screens/item_type_selection_screen.dart';
import 'screens/material_selection_screen.dart';
import 'screens/enhanced_creator_basic.dart';
import 'screens/voice_test_screen.dart';
import 'screens/voice_first_creator.dart';
import 'screens/creature_preview_approval_screen.dart';
import 'screens/tutorial_screen.dart';
import 'models/enhanced_creature_attributes.dart';
import 'models/item_type.dart';

/// Main entry point for Crafta app
/// Loads environment variables and initializes the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables from .env file
    await dotenv.load(fileName: ".env");
    developer.log('Environment variables loaded successfully');
    
    // Initialize secure API key manager
    await SecureAPIKeyManager.initialize();
    developer.log('Secure API key manager initialized');
    
    // Initialize error handling
    GlobalErrorHandler.initialize();
    developer.log('Error handling system initialized');
    
    // Initialize OpenAI service (primary AI)
    developer.log('OpenAI service ready (with offline fallback)');
  } catch (e) {
    developer.log('Warning: Could not load .env file. Make sure to create one from .env.example', level: 1000);
    developer.log('Error: $e', level: 1000);
  }

  // Initialize debug service
  await DebugService.initialize();

  // Initialize responsive service
  // ResponsiveService.init(); // Will be initialized in WelcomeScreen

  runApp(const CraftaApp());
}

class CraftaApp extends StatefulWidget {
  const CraftaApp({super.key});

  @override
  State<CraftaApp> createState() => _CraftaAppState();
}

class _CraftaAppState extends State<CraftaApp> {
  Locale _currentLocale = const Locale('en', '');

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final locale = await LanguageService.getCurrentLanguage();
      if (mounted) {
        setState(() {
          _currentLocale = locale;
        });
      }
    } catch (e) {
      print('❌ Error loading language: $e');
      // Keep default English locale
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crafta - AI-Powered Minecraft Mod Creator',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      locale: _currentLocale,
      localizationsDelegates: LanguageService.getLocalizationDelegates(),
      supportedLocales: LanguageService.getSupportedLocales(),
      initialRoute: '/splash',
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/first-run-setup': (context) => const FirstRunSetupScreen(),
              '/welcome': (context) => const WelcomeScreen(),
              '/': (context) => const WelcomeScreen(),
              '/creator': (context) {
                final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                return CreatorScreenSimple(
                  itemType: args?['itemType'] as ItemType?,
                  material: args?['material'] as ItemMaterialType?,
                );
              },
              '/complete': (context) => const CompleteScreen(),
              '/creature-preview': (context) {
                final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
                developer.log('Creature preview route called with args: $args');
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
        '/minecraft-3d-viewer': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          
          // Convert Map to EnhancedCreatureAttributes
          final Map<String, dynamic> attributesMap = args['creatureAttributes'] as Map<String, dynamic>;
          final creatureAttributes = EnhancedCreatureAttributes.fromMap(attributesMap);
          
          return Minecraft3DViewerScreen(
            creatureAttributes: creatureAttributes,
            creatureName: args['creatureName'] as String,
          );
        },
        '/ai-creation': (context) => const AICreationScreen(),
        '/ai-processor': (context) => const AiProcessor(),
        '/kid-friendly': (context) => const KidFriendlyScreen(),
        '/voice-calibration': (context) => const VoiceCalibrationScreen(),
        '/voice-settings': (context) => const VoiceSettingsScreen(),
        '/item-type-selection': (context) => const ItemTypeSelectionScreen(),
        '/material-selection': (context) {
          final itemType = ModalRoute.of(context)!.settings.arguments;
          return MaterialSelectionScreen(itemType: itemType as ItemType);
        },
        '/enhanced-creator': (context) => const EnhancedCreatorBasic(),
        '/voice-test': (context) => const VoiceTestScreen(),
        '/voice-first': (context) => const VoiceFirstCreator(),
        '/creature-preview-approval': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return CreaturePreviewApprovalScreen(
            creatureAttributes: args['creatureAttributes'],
            creatureName: args['creatureName'],
          );
        },
        '/tutorial': (context) => const TutorialScreen(),
            },
    );
  }
}