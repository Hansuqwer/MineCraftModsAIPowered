import 'package:flutter/material.dart';
import 'lib/widgets/simple_3d_preview.dart';
import 'lib/models/enhanced_creature_attributes.dart';

/// Test script to verify table model with legs works correctly
void main() {
  runApp(TableModelTestApp());
}

class TableModelTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Table Model Test',
      theme: ThemeData.dark(),
      home: TableModelTestScreen(),
    );
  }
}

class TableModelTestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Create table attributes
    final tableAttributes = EnhancedCreatureAttributes(
      baseType: 'table',
      customName: 'Test Table',
      primaryColor: Colors.brown,
      secondaryColor: Colors.amber,
      accentColor: Colors.orange,
      size: CreatureSize.medium,
      personality: PersonalityType.friendly,
      abilities: [],
      accessories: [],
      patterns: [],
      texture: TextureType.smooth,
      glowEffect: GlowEffect.none,
      animationStyle: CreatureAnimationStyle.natural,
      description: 'A wooden table with legs',
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Table Model Test'),
        backgroundColor: Colors.brown,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Testing Table Model with Legs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Base Type: ${tableAttributes.baseType}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Primary Color: ${tableAttributes.primaryColor}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Secondary Color: ${tableAttributes.secondaryColor}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 30),
            // 3D Preview
            Simple3DPreview(
              creatureAttributes: tableAttributes,
              creatureName: 'Test Table',
              size: 300,
              enableRotation: true,
              enableZoom: true,
              enableEffects: true,
            ),
            SizedBox(height: 20),
            Text(
              '✅ Table model should show:',
              style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '• Brown table top (80x8)',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            Text(
              '• 4 amber legs (6x30)',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            Text(
              '• Proper positioning',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
