import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Visual feedback widget that shows when Crafta is listening
/// Shows animated pulse/waveform to indicate active listening
class VoiceFeedbackWidget extends StatefulWidget {
  final bool isListening;
  final double soundLevel; // 0.0 to 1.0
  final VoiceFeedbackStyle style;
  final Color? primaryColor;
  final Color? accentColor;

  const VoiceFeedbackWidget({
    Key? key,
    required this.isListening,
    this.soundLevel = 0.5,
    this.style = VoiceFeedbackStyle.pulse,
    this.primaryColor,
    this.accentColor,
  }) : super(key: key);

  @override
  State<VoiceFeedbackWidget> createState() => _VoiceFeedbackWidgetState();
}

class _VoiceFeedbackWidgetState extends State<VoiceFeedbackWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for circular feedback
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Wave animation for waveform feedback
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isListening) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(VoiceFeedbackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _waveController.repeat(reverse: true);
  }

  void _stopAnimations() {
    _pulseController.stop();
    _waveController.stop();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ??
        Theme.of(context).primaryColor;
    final accentColor = widget.accentColor ??
        Theme.of(context).colorScheme.secondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: widget.isListening
          ? _buildActiveIndicator(primaryColor, accentColor)
          : _buildInactiveIndicator(primaryColor),
    );
  }

  Widget _buildActiveIndicator(Color primaryColor, Color accentColor) {
    switch (widget.style) {
      case VoiceFeedbackStyle.pulse:
        return _buildPulseIndicator(primaryColor, accentColor);
      case VoiceFeedbackStyle.waveform:
        return _buildWaveformIndicator(primaryColor, accentColor);
      case VoiceFeedbackStyle.ripple:
        return _buildRippleIndicator(primaryColor, accentColor);
      case VoiceFeedbackStyle.bars:
        return _buildBarsIndicator(primaryColor, accentColor);
    }
  }

  Widget _buildInactiveIndicator(Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.mic_off,
        size: 40,
        color: color.withOpacity(0.6),
      ),
    );
  }

  /// Pulse animation - expanding circle
  Widget _buildPulseIndicator(Color primaryColor, Color accentColor) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = _pulseAnimation.value;
        final soundScale = 1.0 + (widget.soundLevel * 0.3);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Container(
              width: 100 * scale * soundScale,
              height: 100 * scale * soundScale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentColor.withOpacity(0.3),
                    accentColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
            // Middle pulse
            Container(
              width: 85 * scale,
              height: 85 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.4),
              ),
            ),
            // Inner core
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor,
                    accentColor,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.mic,
                size: 35,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Waveform animation - sound waves
  Widget _buildWaveformIndicator(Color primaryColor, Color accentColor) {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return SizedBox(
          width: 200,
          height: 80,
          child: CustomPaint(
            painter: WaveformPainter(
              animation: _waveAnimation.value,
              soundLevel: widget.soundLevel,
              primaryColor: primaryColor,
              accentColor: accentColor,
            ),
          ),
        );
      },
    );
  }

  /// Ripple animation - expanding circles
  Widget _buildRippleIndicator(Color primaryColor, Color accentColor) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.33;
            final progress = (_pulseAnimation.value + delay) % 1.0;
            final scale = 1.0 + (progress * 2.0);
            final opacity = 1.0 - progress;

            return Container(
              width: 80 * scale,
              height: 80 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(opacity * 0.5),
                  width: 3,
                ),
              ),
            );
          })..add(
            // Center microphone
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Icon(
                Icons.mic,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Bars animation - equalizer style
  Widget _buildBarsIndicator(Color primaryColor, Color accentColor) {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return SizedBox(
          width: 150,
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(7, (index) {
              final phase = (index * 0.2 + _waveAnimation.value) % 1.0;
              final height = 20 + (math.sin(phase * math.pi * 2) * 30).abs() *
                  (1.0 + widget.soundLevel);

              return Container(
                width: 12,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      primaryColor,
                      accentColor,
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

/// Custom painter for waveform visualization
class WaveformPainter extends CustomPainter {
  final double animation;
  final double soundLevel;
  final Color primaryColor;
  final Color accentColor;

  WaveformPainter({
    required this.animation,
    required this.soundLevel,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerY = size.height / 2;

    // Draw multiple waves with different phases
    for (var waveIndex = 0; waveIndex < 2; waveIndex++) {
      final waveColor = waveIndex == 0 ? primaryColor : accentColor;
      paint.color = waveColor.withOpacity(0.7);

      path.reset();
      path.moveTo(0, centerY);

      for (var x = 0.0; x <= size.width; x += 2) {
        final progress = x / size.width;
        final phase = (progress * 4 * math.pi) + (animation * 2 * math.pi) +
            (waveIndex * math.pi / 2);
        final amplitude = 20 * soundLevel * (waveIndex == 0 ? 1.0 : 0.7);
        final y = centerY + (math.sin(phase) * amplitude);

        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.soundLevel != soundLevel;
  }
}

/// Different visual styles for voice feedback
enum VoiceFeedbackStyle {
  /// Pulsing circle (default, kid-friendly)
  pulse,

  /// Animated waveform (technical, cool)
  waveform,

  /// Ripple effect (calm, meditative)
  ripple,

  /// Equalizer bars (energetic, fun)
  bars,
}

/// Compact voice indicator badge for corner display
class VoiceFeedbackBadge extends StatelessWidget {
  final bool isListening;
  final Color? color;

  const VoiceFeedbackBadge({
    Key? key,
    required this.isListening,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? Theme.of(context).primaryColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isListening
            ? badgeColor.withOpacity(0.9)
            : badgeColor.withOpacity(0.3),
        boxShadow: isListening ? [
          BoxShadow(
            color: badgeColor.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Icon(
        isListening ? Icons.mic : Icons.mic_off,
        size: 20,
        color: Colors.white,
      ),
    );
  }
}
