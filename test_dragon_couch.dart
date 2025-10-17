import 'package:flutter/material.dart';
import 'lib/widgets/furniture_renderer.dart';

/// Test script to visualize the dragon couch
void main() {
  runApp(const DragonCouchTestApp());
}

class DragonCouchTestApp extends StatelessWidget {
  const DragonCouchTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dragon Couch Test',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DragonCouchTestScreen(),
    );
  }
}

class DragonCouchTestScreen extends StatefulWidget {
  const DragonCouchTestScreen({super.key});

  @override
  State<DragonCouchTestScreen> createState() => _DragonCouchTestScreenState();
}

class _DragonCouchTestScreenState extends State<DragonCouchTestScreen> {
  // Dragon couch attributes
  final Map<String, dynamic> dragonCouchAttributes = {
    'creatureType': 'couch',
    'theme': 'dragon',
    'description': 'A majestic dragon-covered couch with scales and magical effects',
    'color': 'purple',
    'size': 'large',
    'effects': ['sparkle', 'magic', 'dragon', 'glow'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('🐉 Dragon Couch Visualization'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Dragon-Covered Couch',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              'A majestic couch covered in dragon scales with magical effects and dragon-themed details.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Large Preview
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Large Preview (300x300)',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FurnitureRenderer(
                      furnitureAttributes: dragonCouchAttributes,
                      size: 300,
                      isAnimated: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Medium Preview
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Medium Preview (200x200)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FurnitureRenderer(
                      furnitureAttributes: dragonCouchAttributes,
                      size: 200,
                      isAnimated: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Small Preview
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Small Preview (150x150)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FurnitureRenderer(
                      furnitureAttributes: dragonCouchAttributes,
                      size: 150,
                      isAnimated: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Features
            const Text(
              '✨ Dragon Couch Features',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            
            _buildFeature('🐉 Dragon Scale Pattern', 'Intricate scale texture covering the entire couch'),
            _buildFeature('🔥 Dragon Fire Effects', 'Animated fire effects that appear periodically'),
            _buildFeature('✨ Magical Sparkles', 'Floating sparkles around the couch for enchantment'),
            _buildFeature('🦇 Dragon Wing Arms', 'Armrests shaped like dragon wings'),
            _buildFeature('👑 Dragon Head Backrest', 'Backrest featuring a dragon head silhouette'),
            _buildFeature('💎 Scale-Patterned Cushions', 'Cushions with matching dragon scale patterns'),
            
            const SizedBox(height: 40),
            
            // Technical Details
            const Text(
              '🔧 Technical Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTechDetail('Furniture Type', 'Couch/Sofa'),
                  _buildTechDetail('Theme', 'Dragon'),
                  _buildTechDetail('Color Scheme', 'Deep Purple with Scale Patterns'),
                  _buildTechDetail('Size', 'Large'),
                  _buildTechDetail('Effects', 'Sparkle, Magic, Dragon, Glow'),
                  _buildTechDetail('Animation', 'Floating, Fire Effects, Sparkles'),
                  _buildTechDetail('Rendering', 'Custom Flutter Canvas Painting'),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Show info dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Dragon Couch Info'),
                          content: const Text(
                            'This dragon couch features:\n\n'
                            '• Dragon scale patterns\n'
                            '• Animated fire effects\n'
                            '• Magical sparkles\n'
                            '• Dragon wing armrests\n'
                            '• Dragon head backrest\n'
                            '• Scale-patterned cushions\n\n'
                            'Perfect for a magical living room!',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cool!'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.info),
                    label: const Text('Learn More'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF98D8C8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Show export info
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Export to Minecraft'),
                          content: const Text(
                            'This dragon couch can be exported to Minecraft as:\n\n'
                            '• Custom furniture addon\n'
                            '• Dragon-themed textures\n'
                            '• Magical effects\n'
                            '• Custom geometry\n\n'
                            'Ready for your Minecraft world!',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Awesome!'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Export Info'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


