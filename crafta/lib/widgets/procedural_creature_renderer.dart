import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

/// Procedurally generates creature visuals based on AI-parsed attributes
/// Creates unique visual representations for each creature combination
class ProceduralCreatureRenderer extends StatefulWidget {
  final Map<String, dynamic> creatureAttributes;
  final double size;
  final bool isAnimated;

  const ProceduralCreatureRenderer({
    super.key,
    required this.creatureAttributes,
    this.size = 300.0,
    this.isAnimated = true,
  });

  @override
  State<ProceduralCreatureRenderer> createState() => _ProceduralCreatureRendererState();
}

class _ProceduralCreatureRendererState extends State<ProceduralCreatureRenderer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: CreaturePainter(
            creatureAttributes: widget.creatureAttributes,
            animationValue: widget.isAnimated ? _animation.value : 0.5,
          ),
        );
      },
    );
  }
}

/// Custom painter that draws creatures based on attributes
class CreaturePainter extends CustomPainter {
  final Map<String, dynamic> creatureAttributes;
  final double animationValue;

  CreaturePainter({
    required this.creatureAttributes,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Extract attributes
    final creatureType = (creatureAttributes['creatureType'] ?? 'creature').toString().toLowerCase();
    final colorName = (creatureAttributes['color'] ?? 'rainbow').toString().toLowerCase();
    final sizeAttr = (creatureAttributes['size'] ?? 'normal').toString().toLowerCase();
    final effects = (creatureAttributes['effects'] as List<dynamic>?) ?? [];
    final abilities = (creatureAttributes['abilities'] as List<dynamic>?) ?? [];

    // Calculate size multiplier
    final sizeMultiplier = _getSizeMultiplier(sizeAttr);

    // Get colors
    final primaryColor = _getColor(colorName);
    final secondaryColor = _getSecondaryColor(colorName);

    // Save canvas state
    canvas.save();
    canvas.translate(centerX, centerY);

    // Add floating animation
    final floatOffset = math.sin(animationValue * math.pi * 2) * 10;
    canvas.translate(0, floatOffset);

    // Draw based on creature type
    switch (creatureType) {
      case 'cow':
        _drawCow(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'pig':
        _drawPig(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'chicken':
        _drawChicken(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'sheep':
        _drawSheep(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'horse':
        _drawHorse(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'dragon':
        _drawDragon(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'unicorn':
        _drawUnicorn(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'phoenix':
        _drawPhoenix(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'griffin':
        _drawGriffin(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'cat':
        _drawCat(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'dog':
        _drawDog(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      default:
        _drawGenericCreature(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
    }

    // Draw effects on top
    _drawEffects(canvas, size, effects, animationValue);

    // Draw abilities indicators
    _drawAbilities(canvas, size, abilities, animationValue);

    canvas.restore();
  }

  // Cow: rectangular body, spots, legs
  void _drawCow(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Body
    paint.color = primary;
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 120 * scale, height: 80 * scale),
      paint,
    );

    // Spots
    paint.color = secondary;
    final spots = [
      Offset(-30 * scale, -10 * scale),
      Offset(20 * scale, -15 * scale),
      Offset(-10 * scale, 15 * scale),
      Offset(35 * scale, 10 * scale),
    ];
    for (final spot in spots) {
      canvas.drawCircle(spot, 12 * scale, paint);
    }

    // Head
    paint.color = primary;
    canvas.drawCircle(Offset(-55 * scale, -10 * scale), 25 * scale, paint);

    // Eyes
    paint.color = Colors.white;
    canvas.drawCircle(Offset(-60 * scale, -15 * scale), 8 * scale, paint);
    canvas.drawCircle(Offset(-50 * scale, -15 * scale), 8 * scale, paint);
    paint.color = Colors.black;
    canvas.drawCircle(Offset(-60 * scale, -15 * scale), 4 * scale, paint);
    canvas.drawCircle(Offset(-50 * scale, -15 * scale), 4 * scale, paint);

    // Legs
    paint.color = primary.withOpacity(0.8);
    final legWidth = 12 * scale;
    final legHeight = 30 * scale;
    canvas.drawRect(Rect.fromLTWH(-45 * scale, 40 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(-20 * scale, 40 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(10 * scale, 40 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(35 * scale, 40 * scale, legWidth, legHeight), paint);
  }

  // Pig: rounded body, snout, curly tail
  void _drawPig(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Body
    paint.color = primary;
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 100 * scale, height: 70 * scale),
      paint,
    );

    // Head
    canvas.drawCircle(Offset(-50 * scale, -5 * scale), 30 * scale, paint);

    // Snout
    paint.color = secondary;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-65 * scale, -5 * scale),
        width: 25 * scale,
        height: 20 * scale,
      ),
      paint,
    );

    // Nostrils
    paint.color = Colors.black;
    canvas.drawCircle(Offset(-70 * scale, -8 * scale), 3 * scale, paint);
    canvas.drawCircle(Offset(-60 * scale, -8 * scale), 3 * scale, paint);

    // Eyes
    paint.color = Colors.black;
    canvas.drawCircle(Offset(-55 * scale, -15 * scale), 5 * scale, paint);
    canvas.drawCircle(Offset(-45 * scale, -15 * scale), 5 * scale, paint);

    // Ears
    paint.color = primary;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-60 * scale, -30 * scale),
        width: 15 * scale,
        height: 20 * scale,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-40 * scale, -30 * scale),
        width: 15 * scale,
        height: 20 * scale,
      ),
      paint,
    );

    // Curly tail
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4 * scale;
    final tailPath = Path();
    tailPath.moveTo(50 * scale, 0);
    for (var i = 0; i < 3; i++) {
      tailPath.quadraticBezierTo(
        60 * scale + (i * 10 * scale), -10 * scale + (i % 2 * 20 * scale),
        70 * scale + (i * 10 * scale), 0,
      );
    }
    canvas.drawPath(tailPath, paint);

    // Legs
    paint.style = PaintingStyle.fill;
    final legWidth = 10 * scale;
    final legHeight = 25 * scale;
    canvas.drawRect(Rect.fromLTWH(-35 * scale, 35 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(-15 * scale, 35 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(5 * scale, 35 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(25 * scale, 35 * scale, legWidth, legHeight), paint);
  }

  // Dragon: large wings, long neck, fire-breathing
  void _drawDragon(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Wings (behind body)
    paint.color = secondary.withOpacity(0.7);
    _drawWing(canvas, Offset(-40 * scale, -20 * scale), 60 * scale, paint, true);
    _drawWing(canvas, Offset(40 * scale, -20 * scale), 60 * scale, paint, false);

    // Body
    paint.color = primary;
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 100 * scale, height: 70 * scale),
      paint,
    );

    // Scales texture
    paint.color = secondary.withOpacity(0.3);
    for (var y = -25; y < 30; y += 15) {
      for (var x = -40; x < 40; x += 15) {
        canvas.drawCircle(Offset(x * scale, y * scale), 6 * scale, paint);
      }
    }

    // Long neck
    paint.color = primary;
    final neckPath = Path();
    neckPath.moveTo(-50 * scale, 0);
    neckPath.quadraticBezierTo(
      -70 * scale, -40 * scale,
      -60 * scale, -60 * scale,
    );
    neckPath.lineTo(-50 * scale, -60 * scale);
    neckPath.quadraticBezierTo(
      -60 * scale, -40 * scale,
      -40 * scale, 0,
    );
    canvas.drawPath(neckPath, paint);

    // Head
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-55 * scale, -70 * scale),
        width: 40 * scale,
        height: 30 * scale,
      ),
      paint,
    );

    // Horns
    paint.color = secondary;
    final hornPath1 = Path();
    hornPath1.moveTo(-65 * scale, -80 * scale);
    hornPath1.lineTo(-70 * scale, -95 * scale);
    hornPath1.lineTo(-60 * scale, -82 * scale);
    canvas.drawPath(hornPath1, paint);

    final hornPath2 = Path();
    hornPath2.moveTo(-45 * scale, -80 * scale);
    hornPath2.lineTo(-40 * scale, -95 * scale);
    hornPath2.lineTo(-50 * scale, -82 * scale);
    canvas.drawPath(hornPath2, paint);

    // Eyes (glowing)
    paint.color = Colors.yellow;
    canvas.drawCircle(Offset(-60 * scale, -72 * scale), 6 * scale, paint);
    paint.color = Colors.red;
    canvas.drawCircle(Offset(-60 * scale, -72 * scale), 3 * scale, paint);

    // Fire breath effect
    if (animationValue > 0.5) {
      paint.color = Colors.orange.withOpacity(0.6);
      canvas.drawCircle(Offset(-75 * scale, -70 * scale), 15 * scale * animationValue, paint);
      paint.color = Colors.red.withOpacity(0.4);
      canvas.drawCircle(Offset(-75 * scale, -70 * scale), 10 * scale * animationValue, paint);
    }

    // Tail
    paint.color = primary;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 20 * scale;
    final tailPath = Path();
    tailPath.moveTo(50 * scale, 10 * scale);
    tailPath.quadraticBezierTo(
      80 * scale, 20 * scale,
      90 * scale, 40 * scale,
    );
    canvas.drawPath(tailPath, paint);

    // Tail spike
    paint.style = PaintingStyle.fill;
    paint.color = secondary;
    final spikePathCanvas = Path();
    spikePathCanvas.moveTo(85 * scale, 35 * scale);
    spikePathCanvas.lineTo(95 * scale, 50 * scale);
    spikePathCanvas.lineTo(90 * scale, 42 * scale);
    canvas.drawPath(spikePathCanvas, paint);
  }

  // Unicorn: horse with horn and magical aura
  void _drawUnicorn(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Start with horse base
    _drawHorse(canvas, size, primary, secondary, scale);

    // Add magical horn
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    final hornPath = Path();
    hornPath.moveTo(-50 * scale, -50 * scale);
    hornPath.lineTo(-45 * scale, -80 * scale);
    hornPath.lineTo(-40 * scale, -50 * scale);
    canvas.drawPath(hornPath, paint);

    // Horn spirals
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2 * scale;
    paint.color = Colors.yellow.withOpacity(0.7);
    for (var i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(-48 * scale, -55 * scale - (i * 5 * scale)),
        Offset(-42 * scale, -53 * scale - (i * 5 * scale)),
        paint,
      );
    }

    // Magical sparkles around unicorn
    paint.style = PaintingStyle.fill;
    final sparklePositions = [
      Offset(-80 * scale, -60 * scale),
      Offset(60 * scale, -40 * scale),
      Offset(-70 * scale, 20 * scale),
      Offset(70 * scale, 10 * scale),
    ];

    for (final pos in sparklePositions) {
      final sparkleOpacity = (math.sin(animationValue * math.pi * 4) + 1) / 2;
      paint.color = Colors.yellow.withOpacity(sparkleOpacity * 0.8);
      _drawStar(canvas, pos, 8 * scale, paint);
    }
  }

  // Horse: elegant body, mane, tail
  void _drawHorse(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Body
    paint.color = primary;
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 110 * scale, height: 75 * scale),
      paint,
    );

    // Neck
    final neckPath = Path();
    neckPath.moveTo(-40 * scale, -20 * scale);
    neckPath.quadraticBezierTo(
      -50 * scale, -35 * scale,
      -45 * scale, -45 * scale,
    );
    neckPath.lineTo(-35 * scale, -45 * scale);
    neckPath.quadraticBezierTo(
      -40 * scale, -35 * scale,
      -30 * scale, -20 * scale,
    );
    canvas.drawPath(neckPath, paint);

    // Head
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-40 * scale, -50 * scale),
        width: 30 * scale,
        height: 35 * scale,
      ),
      paint,
    );

    // Mane
    paint.color = secondary;
    for (var i = 0; i < 5; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(-35 * scale - (i * 3 * scale), -40 * scale + (i * 5 * scale)),
          width: 15 * scale,
          height: 20 * scale,
        ),
        paint,
      );
    }

    // Eyes
    paint.color = Colors.black;
    canvas.drawCircle(Offset(-45 * scale, -52 * scale), 4 * scale, paint);

    // Ears
    paint.color = primary;
    final earPath = Path();
    earPath.moveTo(-50 * scale, -65 * scale);
    earPath.lineTo(-48 * scale, -75 * scale);
    earPath.lineTo(-45 * scale, -67 * scale);
    canvas.drawPath(earPath, paint);

    // Legs
    paint.color = primary.withOpacity(0.9);
    final legWidth = 12 * scale;
    final legHeight = 40 * scale;
    canvas.drawRect(Rect.fromLTWH(-40 * scale, 37 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(-15 * scale, 37 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(10 * scale, 37 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(35 * scale, 37 * scale, legWidth, legHeight), paint);

    // Hooves
    paint.color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(-40 * scale, 72 * scale, legWidth, 5 * scale), paint);
    canvas.drawRect(Rect.fromLTWH(-15 * scale, 72 * scale, legWidth, 5 * scale), paint);
    canvas.drawRect(Rect.fromLTWH(10 * scale, 72 * scale, legWidth, 5 * scale), paint);
    canvas.drawRect(Rect.fromLTWH(35 * scale, 72 * scale, legWidth, 5 * scale), paint);

    // Tail
    paint.color = secondary;
    final tailPath = Path();
    tailPath.moveTo(55 * scale, 10 * scale);
    tailPath.quadraticBezierTo(
      75 * scale, 30 * scale,
      70 * scale, 60 * scale,
    );
    tailPath.lineTo(65 * scale, 60 * scale);
    tailPath.quadraticBezierTo(
      70 * scale, 30 * scale,
      50 * scale, 15 * scale,
    );
    canvas.drawPath(tailPath, paint);
  }

  // Chicken: small, feathered, beak
  void _drawChicken(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Body
    paint.color = primary;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, 5 * scale), width: 60 * scale, height: 50 * scale),
      paint,
    );

    // Head
    canvas.drawCircle(Offset(-25 * scale, -15 * scale), 20 * scale, paint);

    // Comb (red crest)
    paint.color = Colors.red;
    final combPath = Path();
    combPath.moveTo(-30 * scale, -30 * scale);
    combPath.lineTo(-28 * scale, -40 * scale);
    combPath.lineTo(-25 * scale, -32 * scale);
    combPath.lineTo(-22 * scale, -38 * scale);
    combPath.lineTo(-20 * scale, -30 * scale);
    canvas.drawPath(combPath, paint);

    // Beak
    paint.color = Colors.orange;
    final beakPath = Path();
    beakPath.moveTo(-35 * scale, -10 * scale);
    beakPath.lineTo(-45 * scale, -12 * scale);
    beakPath.lineTo(-35 * scale, -14 * scale);
    canvas.drawPath(beakPath, paint);

    // Eye
    paint.color = Colors.black;
    canvas.drawCircle(Offset(-28 * scale, -18 * scale), 3 * scale, paint);

    // Wing
    paint.color = secondary;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(5 * scale, 5 * scale),
        width: 35 * scale,
        height: 25 * scale,
      ),
      paint,
    );

    // Wing feathers
    paint.color = primary.withOpacity(0.7);
    for (var i = 0; i < 3; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(15 * scale + (i * 8 * scale), 10 * scale),
          width: 12 * scale,
          height: 18 * scale,
        ),
        paint,
      );
    }

    // Legs
    paint.color = Colors.orange;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3 * scale;
    canvas.drawLine(Offset(-10 * scale, 30 * scale), Offset(-10 * scale, 45 * scale), paint);
    canvas.drawLine(Offset(5 * scale, 30 * scale), Offset(5 * scale, 45 * scale), paint);

    // Feet
    canvas.drawLine(Offset(-10 * scale, 45 * scale), Offset(-18 * scale, 48 * scale), paint);
    canvas.drawLine(Offset(-10 * scale, 45 * scale), Offset(-2 * scale, 48 * scale), paint);
    canvas.drawLine(Offset(5 * scale, 45 * scale), Offset(-3 * scale, 48 * scale), paint);
    canvas.drawLine(Offset(5 * scale, 45 * scale), Offset(13 * scale, 48 * scale), paint);
  }

  // Sheep: fluffy, woolly texture
  void _drawSheep(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Fluffy wool body (multiple overlapping circles)
    paint.color = primary;
    final woolCircles = [
      Offset(0, 0),
      Offset(-20 * scale, -10 * scale),
      Offset(20 * scale, -10 * scale),
      Offset(-20 * scale, 10 * scale),
      Offset(20 * scale, 10 * scale),
      Offset(-30 * scale, 0),
      Offset(30 * scale, 0),
      Offset(0, -15 * scale),
      Offset(0, 15 * scale),
    ];

    for (final pos in woolCircles) {
      canvas.drawCircle(pos, 22 * scale, paint);
    }

    // Head (darker)
    paint.color = secondary;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-50 * scale, -5 * scale),
        width: 30 * scale,
        height: 25 * scale,
      ),
      paint,
    );

    // Ears
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-58 * scale, -18 * scale),
        width: 12 * scale,
        height: 18 * scale,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-42 * scale, -18 * scale),
        width: 12 * scale,
        height: 18 * scale,
      ),
      paint,
    );

    // Eyes
    paint.color = Colors.black;
    canvas.drawCircle(Offset(-55 * scale, -8 * scale), 4 * scale, paint);
    canvas.drawCircle(Offset(-45 * scale, -8 * scale), 4 * scale, paint);

    // Legs
    paint.color = secondary;
    final legWidth = 10 * scale;
    final legHeight = 30 * scale;
    canvas.drawRect(Rect.fromLTWH(-30 * scale, 22 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(-10 * scale, 22 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(5 * scale, 22 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(20 * scale, 22 * scale, legWidth, legHeight), paint);
  }

  // Phoenix: bird with flames
  void _drawPhoenix(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Wings with flame effect
    paint.color = Colors.orange.withOpacity(0.6);
    _drawFlameWing(canvas, Offset(-60 * scale, 0), 80 * scale, paint, true);
    _drawFlameWing(canvas, Offset(60 * scale, 0), 80 * scale, paint, false);

    // Body (bird-like)
    paint.color = primary;
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 70 * scale, height: 60 * scale),
      paint,
    );

    // Head
    canvas.drawCircle(Offset(0, -35 * scale), 25 * scale, paint);

    // Crown of flames
    paint.color = Colors.orange;
    final crownPositions = [-15, -5, 5, 15];
    for (final x in crownPositions) {
      _drawFlame(canvas, Offset(x * scale, -55 * scale), 15 * scale, paint);
    }

    // Beak
    paint.color = Colors.yellow;
    final beakPath = Path();
    beakPath.moveTo(0, -30 * scale);
    beakPath.lineTo(15 * scale, -32 * scale);
    beakPath.lineTo(0, -35 * scale);
    canvas.drawPath(beakPath, paint);

    // Eye
    paint.color = Colors.red;
    canvas.drawCircle(Offset(-8 * scale, -38 * scale), 5 * scale, paint);
    paint.color = Colors.yellow;
    canvas.drawCircle(Offset(-8 * scale, -38 * scale), 2 * scale, paint);

    // Tail feathers with flames
    final tailFeathers = [
      Offset(35 * scale, 20 * scale),
      Offset(40 * scale, 30 * scale),
      Offset(35 * scale, 40 * scale),
    ];

    for (final feather in tailFeathers) {
      paint.color = Colors.red.withOpacity(0.7);
      _drawFlame(canvas, feather, 25 * scale, paint);
      paint.color = Colors.orange.withOpacity(0.7);
      _drawFlame(canvas, Offset(feather.dx + 10 * scale, feather.dy), 20 * scale, paint);
    }
  }

  // Griffin: eagle head + lion body
  void _drawGriffin(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Lion body
    paint.color = primary;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(10 * scale, 10 * scale), width: 100 * scale, height: 70 * scale),
      paint,
    );

    // Eagle wings
    paint.color = secondary.withOpacity(0.8);
    _drawWing(canvas, Offset(-30 * scale, -10 * scale), 70 * scale, paint, true);
    _drawWing(canvas, Offset(50 * scale, -10 * scale), 70 * scale, paint, false);

    // Eagle head and neck
    paint.color = secondary;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-45 * scale, -20 * scale),
        width: 35 * scale,
        height: 40 * scale,
      ),
      paint,
    );

    // Beak (curved eagle beak)
    paint.color = Colors.yellow.shade700;
    final beakPath = Path();
    beakPath.moveTo(-55 * scale, -15 * scale);
    beakPath.quadraticBezierTo(
      -70 * scale, -15 * scale,
      -68 * scale, -25 * scale,
    );
    beakPath.lineTo(-60 * scale, -22 * scale);
    canvas.drawPath(beakPath, paint);

    // Eagle eye
    paint.color = Colors.yellow;
    canvas.drawCircle(Offset(-50 * scale, -25 * scale), 6 * scale, paint);
    paint.color = Colors.black;
    canvas.drawCircle(Offset(-50 * scale, -25 * scale), 3 * scale, paint);

    // Lion legs
    paint.color = primary.withOpacity(0.9);
    final legWidth = 15 * scale;
    final legHeight = 35 * scale;
    canvas.drawRect(Rect.fromLTWH(-20 * scale, 42 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(5 * scale, 42 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(30 * scale, 42 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(55 * scale, 42 * scale, legWidth, legHeight), paint);

    // Lion tail
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 12 * scale;
    final tailPath = Path();
    tailPath.moveTo(60 * scale, 20 * scale);
    tailPath.quadraticBezierTo(
      85 * scale, 35 * scale,
      80 * scale, 55 * scale,
    );
    canvas.drawPath(tailPath, paint);

    // Tail tuft
    paint.style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(80 * scale, 60 * scale),
        width: 20 * scale,
        height: 25 * scale,
      ),
      paint,
    );
  }

  // Cat: sleek, whiskers, pointed ears
  void _drawCat(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Body
    paint.color = primary;
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 80 * scale, height: 50 * scale),
      paint,
    );

    // Head
    canvas.drawCircle(Offset(-35 * scale, -15 * scale), 22 * scale, paint);

    // Pointed ears
    final leftEar = Path();
    leftEar.moveTo(-48 * scale, -30 * scale);
    leftEar.lineTo(-55 * scale, -45 * scale);
    leftEar.lineTo(-42 * scale, -35 * scale);
    canvas.drawPath(leftEar, paint);

    final rightEar = Path();
    rightEar.moveTo(-28 * scale, -30 * scale);
    rightEar.lineTo(-21 * scale, -45 * scale);
    rightEar.lineTo(-32 * scale, -35 * scale);
    canvas.drawPath(rightEar, paint);

    // Eyes (cat eyes)
    paint.color = Colors.yellow.shade700;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-40 * scale, -18 * scale),
        width: 8 * scale,
        height: 12 * scale,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-30 * scale, -18 * scale),
        width: 8 * scale,
        height: 12 * scale,
      ),
      paint,
    );

    // Pupils (vertical slits)
    paint.color = Colors.black;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-40 * scale, -18 * scale),
        width: 2 * scale,
        height: 8 * scale,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-30 * scale, -18 * scale),
        width: 2 * scale,
        height: 8 * scale,
      ),
      paint,
    );

    // Nose
    paint.color = Colors.pink;
    canvas.drawCircle(Offset(-35 * scale, -10 * scale), 3 * scale, paint);

    // Whiskers
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1 * scale;
    canvas.drawLine(Offset(-35 * scale, -12 * scale), Offset(-55 * scale, -15 * scale), paint);
    canvas.drawLine(Offset(-35 * scale, -10 * scale), Offset(-55 * scale, -10 * scale), paint);
    canvas.drawLine(Offset(-35 * scale, -8 * scale), Offset(-55 * scale, -5 * scale), paint);
    canvas.drawLine(Offset(-35 * scale, -12 * scale), Offset(-15 * scale, -15 * scale), paint);
    canvas.drawLine(Offset(-35 * scale, -10 * scale), Offset(-15 * scale, -10 * scale), paint);
    canvas.drawLine(Offset(-35 * scale, -8 * scale), Offset(-15 * scale, -5 * scale), paint);

    // Legs
    paint.style = PaintingStyle.fill;
    final legWidth = 10 * scale;
    final legHeight = 25 * scale;
    canvas.drawRect(Rect.fromLTWH(-30 * scale, 25 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(-10 * scale, 25 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(5 * scale, 25 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(20 * scale, 25 * scale, legWidth, legHeight), paint);

    // Tail (curved)
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 10 * scale;
    final tailPath = Path();
    tailPath.moveTo(40 * scale, 0);
    tailPath.quadraticBezierTo(
      60 * scale, -20 * scale,
      55 * scale, -40 * scale,
    );
    canvas.drawPath(tailPath, paint);
  }

  // Dog: friendly, wagging tail, floppy ears
  void _drawDog(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Body
    paint.color = primary;
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 90 * scale, height: 55 * scale),
      paint,
    );

    // Head
    canvas.drawCircle(Offset(-40 * scale, -15 * scale), 25 * scale, paint);

    // Snout
    paint.color = secondary;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-55 * scale, -8 * scale),
        width: 22 * scale,
        height: 18 * scale,
      ),
      paint,
    );

    // Nose
    paint.color = Colors.black;
    canvas.drawCircle(Offset(-60 * scale, -10 * scale), 5 * scale, paint);

    // Floppy ears
    paint.color = primary.withOpacity(0.9);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-52 * scale, -25 * scale),
        width: 18 * scale,
        height: 30 * scale,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-28 * scale, -25 * scale),
        width: 18 * scale,
        height: 30 * scale,
      ),
      paint,
    );

    // Eyes (friendly)
    paint.color = Colors.black;
    canvas.drawCircle(Offset(-48 * scale, -18 * scale), 5 * scale, paint);
    canvas.drawCircle(Offset(-38 * scale, -18 * scale), 5 * scale, paint);

    // Tongue (happy panting)
    paint.color = Colors.pink;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-55 * scale, 0),
        width: 10 * scale,
        height: 15 * scale,
      ),
      paint,
    );

    // Spot on body
    paint.color = secondary;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(10 * scale, -5 * scale),
        width: 30 * scale,
        height: 25 * scale,
      ),
      paint,
    );

    // Legs
    paint.color = primary;
    final legWidth = 12 * scale;
    final legHeight = 30 * scale;
    canvas.drawRect(Rect.fromLTWH(-35 * scale, 27 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(-12 * scale, 27 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(8 * scale, 27 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(28 * scale, 27 * scale, legWidth, legHeight), paint);

    // Wagging tail (animated)
    final tailWag = math.sin(animationValue * math.pi * 4) * 15 * scale;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 12 * scale;
    final tailPath = Path();
    tailPath.moveTo(45 * scale, 5 * scale);
    tailPath.quadraticBezierTo(
      65 * scale, tailWag,
      70 * scale, 20 * scale + tailWag,
    );
    canvas.drawPath(tailPath, paint);
  }

  // Generic creature fallback
  void _drawGenericCreature(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Simple friendly blob creature
    paint.color = primary;
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 100 * scale, height: 80 * scale),
      paint,
    );

    // Eyes
    paint.color = Colors.white;
    canvas.drawCircle(Offset(-20 * scale, -15 * scale), 12 * scale, paint);
    canvas.drawCircle(Offset(20 * scale, -15 * scale), 12 * scale, paint);

    paint.color = Colors.black;
    canvas.drawCircle(Offset(-18 * scale, -13 * scale), 6 * scale, paint);
    canvas.drawCircle(Offset(22 * scale, -13 * scale), 6 * scale, paint);

    // Smile
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4 * scale;
    paint.color = secondary;
    final smilePath = Path();
    smilePath.moveTo(-30 * scale, 5 * scale);
    smilePath.quadraticBezierTo(0, 20 * scale, 30 * scale, 5 * scale);
    canvas.drawPath(smilePath, paint);
  }

  // Helper: Draw wing
  void _drawWing(Canvas canvas, Offset position, double size, Paint paint, bool leftSide) {
    final wingPath = Path();
    wingPath.moveTo(position.dx, position.dy);

    if (leftSide) {
      wingPath.quadraticBezierTo(
        position.dx - size, position.dy - size * 0.3,
        position.dx - size * 0.8, position.dy + size * 0.5,
      );
      wingPath.quadraticBezierTo(
        position.dx - size * 0.5, position.dy + size * 0.7,
        position.dx, position.dy + size * 0.4,
      );
    } else {
      wingPath.quadraticBezierTo(
        position.dx + size, position.dy - size * 0.3,
        position.dx + size * 0.8, position.dy + size * 0.5,
      );
      wingPath.quadraticBezierTo(
        position.dx + size * 0.5, position.dy + size * 0.7,
        position.dx, position.dy + size * 0.4,
      );
    }

    wingPath.close();
    canvas.drawPath(wingPath, paint);

    // Wing feathers
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    for (var i = 0; i < 4; i++) {
      final featherOffset = size * 0.2 * (i + 1);
      if (leftSide) {
        canvas.drawLine(
          position,
          Offset(position.dx - featherOffset, position.dy + featherOffset * 0.5),
          paint,
        );
      } else {
        canvas.drawLine(
          position,
          Offset(position.dx + featherOffset, position.dy + featherOffset * 0.5),
          paint,
        );
      }
    }
    paint.style = PaintingStyle.fill;
  }

  // Helper: Draw flame wing
  void _drawFlameWing(Canvas canvas, Offset position, double size, Paint paint, bool leftSide) {
    final numFlames = 5;
    for (var i = 0; i < numFlames; i++) {
      final flameSize = size * (1 - i * 0.15);
      final flameY = position.dy + (i * size * 0.2);
      _drawFlame(
        canvas,
        leftSide
          ? Offset(position.dx - (i * size * 0.15), flameY)
          : Offset(position.dx + (i * size * 0.15), flameY),
        flameSize * 0.3,
        paint,
      );
    }
  }

  // Helper: Draw flame
  void _drawFlame(Canvas canvas, Offset position, double size, Paint paint) {
    final flamePath = Path();
    flamePath.moveTo(position.dx, position.dy + size);
    flamePath.quadraticBezierTo(
      position.dx - size * 0.5, position.dy + size * 0.5,
      position.dx - size * 0.2, position.dy,
    );
    flamePath.quadraticBezierTo(
      position.dx, position.dy - size * 0.3,
      position.dx + size * 0.2, position.dy,
    );
    flamePath.quadraticBezierTo(
      position.dx + size * 0.5, position.dy + size * 0.5,
      position.dx, position.dy + size,
    );
    canvas.drawPath(flamePath, paint);
  }

  // Helper: Draw star
  void _drawStar(Canvas canvas, Offset position, double size, Paint paint) {
    final starPath = Path();
    for (var i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - math.pi / 2;
      final x = position.dx + size * math.cos(angle);
      final y = position.dy + size * math.sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, paint);
  }

  // Draw effects (sparkles, fire, etc.)
  void _drawEffects(Canvas canvas, Size size, List<dynamic> effects, double anim) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final effect in effects) {
      final effectStr = effect.toString().toLowerCase();

      if (effectStr.contains('sparkle') || effectStr.contains('magic')) {
        // Sparkle particles
        paint.color = Colors.yellow.withOpacity(0.6 * math.sin(anim * math.pi));
        for (var i = 0; i < 8; i++) {
          final angle = (i / 8) * math.pi * 2 + anim * math.pi * 2;
          final radius = 60 + math.sin(anim * math.pi * 4) * 10;
          final x = math.cos(angle) * radius;
          final y = math.sin(angle) * radius;
          _drawStar(canvas, Offset(x, y), 6, paint);
        }
      }

      if (effectStr.contains('fire') || effectStr.contains('flame')) {
        // Fire particles
        paint.color = Colors.orange.withOpacity(0.5);
        for (var i = 0; i < 5; i++) {
          final x = (math.sin(anim * math.pi * 2 + i) * 40);
          final y = -50 - (anim * 30) + i * 10;
          _drawFlame(canvas, Offset(x, y), 15, paint);
        }
      }

      if (effectStr.contains('ice') || effectStr.contains('frost')) {
        // Ice crystals
        paint.color = Colors.cyan.withOpacity(0.4);
        for (var i = 0; i < 6; i++) {
          final angle = (i / 6) * math.pi * 2 + anim * math.pi;
          final radius = 70;
          final x = math.cos(angle) * radius;
          final y = math.sin(angle) * radius;

          final crystalPath = Path();
          crystalPath.moveTo(x, y - 10);
          crystalPath.lineTo(x - 5, y);
          crystalPath.lineTo(x, y + 10);
          crystalPath.lineTo(x + 5, y);
          crystalPath.close();
          canvas.drawPath(crystalPath, paint);
        }
      }
    }
  }

  // Draw ability indicators
  void _drawAbilities(Canvas canvas, Size size, List<dynamic> abilities, double anim) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final ability in abilities) {
      final abilityStr = ability.toString().toLowerCase();

      if (abilityStr.contains('fly') || abilityStr.contains('flies')) {
        // Wing indicators
        paint.color = Colors.white.withOpacity(0.5);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(-80, -20), width: 40, height: 60),
          paint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(80, -20), width: 40, height: 60),
          paint,
        );
      }
    }
  }

  // Get size multiplier
  double _getSizeMultiplier(String size) {
    switch (size) {
      case 'tiny':
      case 'small':
        return 0.7;
      case 'large':
      case 'huge':
      case 'giant':
        return 1.3;
      default:
        return 1.0;
    }
  }

  // Get primary color
  Color _getColor(String colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'black':
        return Colors.black87;
      case 'white':
        return Colors.white;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'rainbow':
        return Color.lerp(
          Colors.red,
          Colors.purple,
          math.sin(animationValue * math.pi * 2) * 0.5 + 0.5,
        )!;
      case 'gold':
      case 'golden':
        return Colors.amber.shade600;
      case 'silver':
        return Colors.grey.shade400;
      default:
        return Colors.blue;
    }
  }

  // Get secondary color (for accents)
  Color _getSecondaryColor(String colorName) {
    final primary = _getColor(colorName);
    return Color.lerp(primary, Colors.white, 0.3)!;
  }

  @override
  bool shouldRepaint(CreaturePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.creatureAttributes != creatureAttributes;
  }
}
