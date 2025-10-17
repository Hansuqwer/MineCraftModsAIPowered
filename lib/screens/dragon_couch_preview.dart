import 'package:flutter/material.dart';
import '../widgets/furniture_renderer.dart';

/// Preview screen for the dragon-covered couch
class DragonCouchPreviewScreen extends StatefulWidget {
  const DragonCouchPreviewScreen({super.key});

  @override
  State<DragonCouchPreviewScreen> createState() => _DragonCouchPreviewScreenState();
}

class _DragonCouchPreviewScreenState extends State<DragonCouchPreviewScreen> {
  @override
  Widget build(BuildContext context) {
    // Dragon couch attributes
    final dragonCouchAttributes = {
      'creatureType': 'couch',
      'theme': 'dragon',
      'description': 'A majestic dragon-covered couch with scales and magical effects',
      'color': 'purple',
      'size': 'large',
      'effects': ['sparkle', 'magic', 'dragon', 'glow'],
    };

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Dragon Couch Preview'),
        backgroundColor: const Color(0xFF98D8C8),
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
              '🐉 Dragon-Covered Couch',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              'A majestic couch covered in dragon scales with magical effects and dragon-themed details.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Visual Preview
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                    // Large preview
                    const Text(
                      'Large Preview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FurnitureRenderer(
                      furnitureAttributes: dragonCouchAttributes,
                      size: 300,
                      isAnimated: true,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Medium preview
                    const Text(
                      'Medium Preview',
                      style: TextStyle(
                        fontSize: 16,
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
                    
                    const SizedBox(height: 32),
                    
                    // Small preview
                    const Text(
                      'Small Preview',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FurnitureRenderer(
                      furnitureAttributes: dragonCouchAttributes,
                      size: 150,
                      isAnimated: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Features
            const Text(
              '✨ Dragon Couch Features',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildFeature('🐉 Dragon Scale Pattern', 'Intricate scale texture covering the entire couch'),
            _buildFeature('🔥 Dragon Fire Effects', 'Animated fire effects that appear periodically'),
            _buildFeature('✨ Magical Sparkles', 'Floating sparkles around the couch for enchantment'),
            _buildFeature('🦇 Dragon Wing Arms', 'Armrests shaped like dragon wings'),
            _buildFeature('👑 Dragon Head Backrest', 'Backrest featuring a dragon head silhouette'),
            _buildFeature('💎 Scale-Patterned Cushions', 'Cushions with matching dragon scale patterns'),
            
            const SizedBox(height: 32),
            
            // Technical Details
            const Text(
              '🔧 Technical Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
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
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to creator screen with dragon couch attributes
                      Navigator.pushNamed(
                        context,
                        '/creator',
                        arguments: dragonCouchAttributes,
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Dragon Couch'),
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
                      // Navigate to export screen
                      Navigator.pushNamed(
                        context,
                        '/export-minecraft',
                        arguments: dragonCouchAttributes,
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Export to Minecraft'),
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
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


