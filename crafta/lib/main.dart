import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/creator_screen.dart';
import 'screens/complete_screen.dart';

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
      },
    );
  }
}