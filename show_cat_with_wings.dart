import 'package:flutter/material.dart';
import 'lib/widgets/creature_preview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat with Wings Preview',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CatPreviewScreen(),
    );
  }
}

class CatPreviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Your cat with wings attributes
    final catAttributes = {
      'creatureType': 'cat',
      'color': 'orange',
      'effects': ['wings', 'flying', 'sparkles'],
      'size': 'normal',
      'behavior': 'friendly',
      'abilities': ['flying', 'purring', 'meowing'],
      'theme': null,
      'originalMessage': 'I want a cat with wings',
      'timestamp': DateTime.now().toIso8601String(),
      'complexity': 3,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF), // Light blue background
      appBar: AppBar(
        title: const Text('🐱 Your Cat with Wings'),
        backgroundColor: const Color(0xFF98D8C8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Text(
              'Your Flying Cat!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 20),
            
            // Cat Preview
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CreaturePreview(
                  creatureAttributes: catAttributes,
                  size: const Size(300, 300),
                  isAnimated: true,
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Description
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    '🐱 Cat with Wings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your orange cat with beautiful wings!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Features
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFeature('🪶 Wings', 'Flying'),
                      _buildFeature('🐱 Cat', 'Friendly'),
                      _buildFeature('✨ Sparkles', 'Magical'),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Export Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // This would normally export to Minecraft
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ready to export to Minecraft!'),
                            backgroundColor: Color(0xFF98D8C8),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Export to Minecraft'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF98D8C8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeature(String icon, String text) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }
}

