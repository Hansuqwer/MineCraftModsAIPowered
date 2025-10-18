import 'package:flutter/material.dart';
import 'lib/services/ai_service.dart';
import 'lib/widgets/furniture_renderer.dart';

/// Test the dragon couch functionality
void main() async {
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
  final AIService _aiService = AIService();
  String _testResult = '';
  bool _isTesting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('🐉 Dragon Couch Functionality Test'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Input
            const Text(
              'Test Dragon Couch Creation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            
            // Test Input Field
            TextField(
              onSubmitted: (text) => _testDragonCouch(text),
              decoration: const InputDecoration(
                hintText: 'Type: "I want a dragon couch"',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTesting ? null : () => _testDragonCouch('I want a dragon couch'),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Test Dragon Couch'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Test Results
            if (_testResult.isNotEmpty) ...[
              const Text(
                'Test Results:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple.shade200),
                ),
                child: Text(
                  _testResult,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Visual Preview
            const Text(
              'Visual Preview:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: FurnitureRenderer(
                  furnitureAttributes: {
                    'creatureType': 'couch',
                    'theme': 'dragon',
                    'description': 'A majestic dragon-covered couch with scales and magical effects',
                    'color': 'purple',
                    'size': 'large',
                    'effects': ['sparkle', 'magic', 'dragon', 'glow'],
                  },
                  size: 250,
                  isAnimated: true,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to Test:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('1. Type "I want a dragon couch" in the input field'),
                  Text('2. Press Enter or click "Test Dragon Couch"'),
                  Text('3. Check if the AI parses it correctly'),
                  Text('4. See the visual preview below'),
                  SizedBox(height: 8),
                  Text(
                    'Expected Result:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('• creatureType: "couch"'),
                  Text('• theme: "dragon"'),
                  Text('• color: "purple" (or detected color)'),
                  Text('• effects: ["sparkle", "magic", "dragon", "glow"]'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testDragonCouch(String input) async {
    setState(() {
      _isTesting = true;
      _testResult = 'Testing: $input\n\n';
    });

    try {
      // Test AI parsing
      final attributes = await _aiService.parseCreatureRequest(input);
      
      setState(() {
        _testResult += '✅ AI Parsing Results:\n';
        _testResult += '• creatureType: ${attributes['creatureType']}\n';
        _testResult += '• color: ${attributes['color']}\n';
        _testResult += '• size: ${attributes['size']}\n';
        _testResult += '• effects: ${attributes['effects']}\n';
        _testResult += '• theme: ${attributes['theme']}\n\n';
        
        // Check if dragon couch was detected
        final isDragonCouch = attributes['creatureType'] == 'couch' && 
                             (attributes['theme']?.toString().toLowerCase().contains('dragon') == true ||
                              attributes['effects']?.toString().toLowerCase().contains('dragon') == true);
        
        if (isDragonCouch) {
          _testResult += '🎉 SUCCESS: Dragon couch detected!\n';
          _testResult += 'The app will render the special dragon couch with:\n';
          _testResult += '• Dragon scale patterns\n';
          _testResult += '• Dragon head backrest\n';
          _testResult += '• Dragon wing armrests\n';
          _testResult += '• Fire effects\n';
          _testResult += '• Magical sparkles\n';
        } else {
          _testResult += '❌ FAILED: Dragon couch not detected\n';
          _testResult += 'Expected: creatureType=couch + dragon theme/effects\n';
        }
      });
    } catch (e) {
      setState(() {
        _testResult += '❌ ERROR: $e\n';
      });
    }
    
    setState(() {
      _isTesting = false;
    });
  }
}


