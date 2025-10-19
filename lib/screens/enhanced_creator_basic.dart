import 'package:flutter/material.dart';
import '../services/enhanced_voice_ai_service.dart';
import '../services/voice_personality_service.dart';
import '../services/educational_voice_service.dart';
import '../theme/kid_friendly_theme.dart';

/// Basic Enhanced Creator Screen for Phase 5 testing
class EnhancedCreatorBasic extends StatefulWidget {
  const EnhancedCreatorBasic({Key? key}) : super(key: key);

  @override
  State<EnhancedCreatorBasic> createState() => _EnhancedCreatorBasicState();
}

class _EnhancedCreatorBasicState extends State<EnhancedCreatorBasic> {
  final EnhancedVoiceAIService _voiceAI = EnhancedVoiceAIService();
  final VoicePersonalityService _personalityService = VoicePersonalityService();
  final EducationalVoiceService _educationalService = EducationalVoiceService();

  bool _isInitialized = false;
  String _currentResponse = '';
  VoicePersonality _currentPersonality = VoicePersonality.friendlyTeacher;
  List<String> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _voiceAI.initialize();
      await _voiceAI.startConversation();
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing services: $e');
    }
  }

  Future<void> _testVoiceInteraction() async {
    try {
      final response = await _voiceAI.processVoiceInput('Hello Crafta!');
      setState(() {
        _currentResponse = response;
        _conversationHistory.add('You: Hello Crafta!');
        _conversationHistory.add('Crafta: $response');
      });
    } catch (e) {
      setState(() {
        _currentResponse = 'Error: $e';
      });
    }
  }

  Future<void> _changePersonality(VoicePersonality personality) async {
    try {
      await _voiceAI.changePersonality(personality);
      setState(() {
        _currentPersonality = personality;
      });
    } catch (e) {
      print('Error changing personality: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: KidFriendlyTheme.backgroundLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  KidFriendlyTheme.primaryPurple,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Setting up Enhanced Creator...',
                style: TextStyle(
                  fontSize: KidFriendlyTheme.headingFontSize,
                  fontWeight: FontWeight.bold,
                  color: KidFriendlyTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: KidFriendlyTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Enhanced Creator - Phase 5',
          style: TextStyle(
            fontSize: KidFriendlyTheme.headingFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: KidFriendlyTheme.primaryPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Personality Selection
            _buildPersonalitySelector(),
            
            const SizedBox(height: 24),
            
            // Voice Test Button
            _buildVoiceTestButton(),
            
            const SizedBox(height: 24),
            
            // Response Display
            _buildResponseDisplay(),
            
            const SizedBox(height: 24),
            
            // Conversation History
            if (_conversationHistory.isNotEmpty) _buildConversationHistory(),
            
            const SizedBox(height: 24),
            
            // Educational Content Test
            _buildEducationalTest(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalitySelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Crafta\'s Personality:',
              style: TextStyle(
                fontSize: KidFriendlyTheme.headingFontSize,
                fontWeight: FontWeight.bold,
                color: KidFriendlyTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: VoicePersonality.values.map((personality) {
                final isSelected = _currentPersonality == personality;
                return GestureDetector(
                  onTap: () => _changePersonality(personality),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? KidFriendlyTheme.primaryPurple
                          : KidFriendlyTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected 
                            ? KidFriendlyTheme.primaryPurple
                            : KidFriendlyTheme.primaryBlue,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      _getPersonalityName(personality),
                      style: TextStyle(
                        fontSize: KidFriendlyTheme.bodyFontSize,
                        color: isSelected ? Colors.white : KidFriendlyTheme.primaryBlue,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceTestButton() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Test Voice Interaction',
              style: TextStyle(
                fontSize: KidFriendlyTheme.headingFontSize,
                fontWeight: FontWeight.bold,
                color: KidFriendlyTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _testVoiceInteraction,
              icon: Icon(Icons.mic, size: 24),
              label: Text(
                'Say Hello to Crafta!',
                style: TextStyle(fontSize: KidFriendlyTheme.buttonFontSize),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: KidFriendlyTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseDisplay() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crafta\'s Response:',
              style: TextStyle(
                fontSize: KidFriendlyTheme.headingFontSize,
                fontWeight: FontWeight.bold,
                color: KidFriendlyTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KidFriendlyTheme.backgroundBlue,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: KidFriendlyTheme.primaryBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _currentResponse.isEmpty 
                    ? 'Tap the button above to test voice interaction!'
                    : _currentResponse,
                style: TextStyle(
                  fontSize: KidFriendlyTheme.bodyFontSize,
                  color: _currentResponse.isEmpty 
                      ? KidFriendlyTheme.textMedium
                      : KidFriendlyTheme.textDark,
                  fontStyle: _currentResponse.isEmpty 
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationHistory() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conversation History:',
              style: TextStyle(
                fontSize: KidFriendlyTheme.headingFontSize,
                fontWeight: FontWeight.bold,
                color: KidFriendlyTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              child: ListView.builder(
                itemCount: _conversationHistory.length,
                itemBuilder: (context, index) {
                  final message = _conversationHistory[index];
                  final isUser = message.startsWith('You:');
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUser ? '👤' : '🤖',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            message.substring(isUser ? 5 : 8),
                            style: TextStyle(
                              fontSize: KidFriendlyTheme.bodyFontSize,
                              color: isUser 
                                  ? KidFriendlyTheme.primaryBlue
                                  : KidFriendlyTheme.primaryPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationalTest() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Educational Content Test:',
              style: TextStyle(
                fontSize: KidFriendlyTheme.headingFontSize,
                fontWeight: FontWeight.bold,
                color: KidFriendlyTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Educational facts available for: animals, colors, creativity, friendship, nature',
              style: TextStyle(
                fontSize: KidFriendlyTheme.bodyFontSize,
                color: KidFriendlyTheme.textMedium,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                final fact = _educationalService.getEducationalFact('animals');
                setState(() {
                  _currentResponse = 'Educational Fact: $fact';
                });
              },
              icon: Icon(Icons.school, size: 20),
              label: Text('Test Educational Content'),
              style: ElevatedButton.styleFrom(
                backgroundColor: KidFriendlyTheme.primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPersonalityName(VoicePersonality personality) {
    switch (personality) {
      case VoicePersonality.friendlyTeacher:
        return 'Friendly Teacher';
      case VoicePersonality.playfulFriend:
        return 'Playful Friend';
      case VoicePersonality.wiseMentor:
        return 'Wise Mentor';
      case VoicePersonality.creativeArtist:
        return 'Creative Artist';
      case VoicePersonality.encouragingCoach:
        return 'Encouraging Coach';
    }
  }
}