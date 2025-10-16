import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/creator_screen.dart';
import 'screens/complete_screen.dart';
import 'screens/creature_preview_screen.dart';
import 'screens/parent_settings_screen.dart';
import 'screens/creation_history_screen.dart';
import 'screens/export_management_screen.dart';

void main() {
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