import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/language_service.dart';
import 'services/debug_service.dart';
import 'services/secure_api_key_manager.dart';
import 'services/error_handling_service.dart';
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
import 'screens/enhanced_modern_screen.dart';
import 'screens/community_gallery_screen.dart';
import 'screens/kid_friendly_screen.dart';
import 'screens/voice_calibration_screen.dart';
import 'screens/voice_settings_screen.dart';
import 'screens/item_type_selection_screen.dart';
import 'screens/material_selection_screen.dart';
import 'screens/enhanced_creator_basic.dart';
import 'screens/voice_test_screen.dart';
import 'models/enhanced_creature_attributes.dart';
import 'models/item_type.dart';
import 'services/google_cloud_service.dart';
import 'services/enhanced_voice_ai_service.dart';
import 'services/community_service.dart';

/// Main entry point for Crafta app
/// Loads environment variables and initializes the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables from .env file
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded successfully');
    
    // Initialize secure API key manager
    await SecureAPIKeyManager.initialize();
    print('✅ Secure API key manager initialized');
    
    // Initialize error handling
    GlobalErrorHandler.initialize();
    print('✅ Error handling system initialized');
    
    // Initialize Google Cloud service
    await GoogleCloudService.initialize();
    print('✅ Google Cloud service initialized');
    
    // Initialize Enhanced Voice AI service
    await EnhancedVoiceAIService().initialize();
    print('✅ Enhanced Voice AI service initialized');
  } catch (e) {
    print('⚠️ Warning: Could not load .env file. Make sure to create one from .env.example');
    print('   Error: $e');
  }

  // Initialize debug service
  await DebugService.initialize();

  // Initialize responsive service
  // ResponsiveService.init(); // Will be initialized in WelcomeScreen

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
        '/minecraft-3d-viewer': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return Minecraft3DViewerScreen(
            creatureAttributes: args['creatureAttributes'] as EnhancedCreatureAttributes,
            creatureName: args['creatureName'] as String,
          );
        },
        '/enhanced-modern': (context) => const EnhancedModernScreen(),
        '/community-gallery': (context) => const CommunityGalleryScreen(),
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
            },
    );
  }
}