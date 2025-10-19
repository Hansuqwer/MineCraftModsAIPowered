import 'package:flutter/material.dart';
import '../services/kid_voice_service.dart';

/// Kid-Friendly Voice Button
/// Large, colorful button optimized for children ages 4-10
class KidVoiceButton extends StatefulWidget {
  final KidVoiceService voiceService;
  final Function(String) onVoiceResult;
  final Function(String) onEncouragement;
  final bool isEnabled;

  const KidVoiceButton({
    super.key,
    required this.voiceService,
    required this.onVoiceResult,
    required this.onEncouragement,
    this.isEnabled = true,
  });

  @override
  State<KidVoiceButton> createState() => _KidVoiceButtonState();
}

class _KidVoiceButtonState extends State<KidVoiceButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;
  
  bool _isListening = false;
  String _currentPrompt = '';
  int _promptIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupPrompts();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
  }

  void _setupPrompts() {
    final prompts = widget.voiceService.getKidPrompts();
    _currentPrompt = prompts[0];
  }

  Future<void> _startListening() async {
    if (!widget.isEnabled || _isListening) return;

    setState(() {
      _isListening = true;
    });

    // Start pulse animation
    _pulseController.repeat(reverse: true);

    // Show encouragement
    widget.onEncouragement("I'm listening! Speak clearly!");

    try {
      final result = await widget.voiceService.listenForKids();
      
      if (result != null && result.isNotEmpty) {
        // Success - show celebration
        _bounceController.forward().then((_) {
          _bounceController.reverse();
        });
        
        widget.onEncouragement(widget.voiceService.getRandomEncouragement());
        widget.onVoiceResult(result);
      } else {
        // Failed - show encouragement
        widget.onEncouragement("Try again! You're doing great!");
        _nextPrompt();
      }
    } catch (e) {
      print('❌ Voice listening error: $e');
      widget.onEncouragement("Oops! Let's try again!");
    } finally {
      setState(() {
        _isListening = false;
      });
      
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  void _nextPrompt() {
    final prompts = widget.voiceService.getKidPrompts();
    _promptIndex = (_promptIndex + 1) % prompts.length;
    setState(() {
      _currentPrompt = prompts[_promptIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Main voice button with enhanced kid-friendly design
        GestureDetector(
          onTap: _startListening,
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulseAnimation, _bounceAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _isListening ? _pulseAnimation.value : _bounceAnimation.value,
                child: Container(
                  width: 140, // Larger for kids
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isListening
                          ? [Colors.purple, Colors.pink, Colors.blue, Colors.cyan]
                          : [Colors.blue, Colors.cyan, Colors.teal, Colors.green],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? Colors.purple : Colors.blue).withOpacity(0.4),
                        blurRadius: 25,
                        spreadRadius: 8,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Main icon
                      Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        size: 70,
                        color: Colors.white,
                      ),
                      // Listening indicator
                      if (_isListening)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.fiber_manual_record,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        SizedBox(height: 20),
        
        // Status text
        Text(
          _isListening ? "I'm listening..." : "Tap to speak!",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _isListening ? Colors.purple : Colors.blue,
          ),
        ),
        
        SizedBox(height: 10),
        
        // Current prompt
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Text(
            _currentPrompt,
            style: TextStyle(
              fontSize: 18,
              color: Colors.blue[800],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        SizedBox(height: 20),
        
        // Encouragement text
        if (_isListening)
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text(
                  "You're doing great!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
