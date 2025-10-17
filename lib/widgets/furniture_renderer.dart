import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Renders furniture items based on AI-parsed attributes
/// Creates visual representations for furniture like couches, chairs, tables, etc.
class FurnitureRenderer extends StatefulWidget {
  final Map<String, dynamic> furnitureAttributes;
  final double size;
  final bool isAnimated;

  const FurnitureRenderer({
    super.key,
    required this.furnitureAttributes,
    this.size = 300.0,
    this.isAnimated = true,
  });

  @override
  State<FurnitureRenderer> createState() => _FurnitureRendererState();
}

class _FurnitureRendererState extends State<FurnitureRenderer>
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
      duration: const Duration(seconds: 4),
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
          painter: FurniturePainter(
            furnitureAttributes: widget.furnitureAttributes,
            animationValue: widget.isAnimated ? _animation.value : 0.5,
          ),
        );
      },
    );
  }
}

/// Custom painter that draws furniture based on attributes
class FurniturePainter extends CustomPainter {
  final Map<String, dynamic> furnitureAttributes;
  final double animationValue;

  FurniturePainter({
    required this.furnitureAttributes,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Extract attributes
    final furnitureType = (furnitureAttributes['creatureType'] ?? 'chair').toString().toLowerCase();
    final colorName = (furnitureAttributes['color'] ?? 'brown').toString().toLowerCase();
    final sizeAttr = (furnitureAttributes['size'] ?? 'normal').toString().toLowerCase();
    final effects = (furnitureAttributes['effects'] as List<dynamic>?) ?? [];

    // Calculate size multiplier
    final sizeMultiplier = _getSizeMultiplier(sizeAttr);

    // Get colors
    final primaryColor = _getColor(colorName);
    final secondaryColor = _getSecondaryColor(colorName);

    // Save canvas state
    canvas.save();
    canvas.translate(centerX, centerY);

    // Add subtle animation
    final floatOffset = math.sin(animationValue * math.pi * 2) * 2;
    canvas.translate(0, floatOffset);

    // Draw based on furniture type
    switch (furnitureType) {
      case 'couch':
      case 'sofa':
        _drawCouch(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'chair':
        _drawChair(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'table':
        _drawTable(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'bed':
        _drawBed(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'desk':
        _drawDesk(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'bookshelf':
        _drawBookshelf(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'lamp':
        _drawLamp(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'cabinet':
        _drawCabinet(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'dresser':
        _drawCabinet(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'stool':
        _drawStool(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'bench':
        _drawBench(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'ottoman':
        _drawOttoman(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'armchair':
        _drawArmchair(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'mirror':
        _drawMirror(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'rug':
      case 'carpet':
        _drawRug(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'plant':
        _drawPlant(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      case 'clock':
        _drawClock(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
        break;
      default:
        _drawGenericFurniture(canvas, size, primaryColor, secondaryColor, sizeMultiplier);
    }

    // Draw effects on top
    _drawEffects(canvas, size, effects, animationValue);

    canvas.restore();
  }

  // Couch: Large seating with back and arms
  void _drawCouch(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Check if this is a dragon-themed couch
    final isDragonCouch = furnitureAttributes['theme']?.toString().toLowerCase().contains('dragon') == true ||
                         furnitureAttributes['description']?.toString().toLowerCase().contains('dragon') == true ||
                         furnitureAttributes['effects']?.toString().toLowerCase().contains('dragon') == true;

    if (isDragonCouch) {
      _drawDragonCouch(canvas, size, primary, secondary, scale);
      return;
    }

    // Main body
    paint.color = primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 80 * scale, height: 40 * scale),
        Radius.circular(8 * scale),
      ),
      paint,
    );

    // Back rest
    paint.color = primary.withOpacity(0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -15 * scale), width: 80 * scale, height: 20 * scale),
        Radius.circular(8 * scale),
      ),
      paint,
    );

    // Arms
    paint.color = primary.withOpacity(0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(-30 * scale, 0), width: 15 * scale, height: 30 * scale),
        Radius.circular(6 * scale),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(30 * scale, 0), width: 15 * scale, height: 30 * scale),
        Radius.circular(6 * scale),
      ),
      paint,
    );

    // Cushions
    paint.color = secondary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(-20 * scale, 0), width: 25 * scale, height: 15 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(20 * scale, 0), width: 25 * scale, height: 15 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );
  }

  // Dragon Couch: Special dragon-themed couch with scales and effects
  void _drawDragonCouch(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Dragon scale pattern background
    paint.color = Colors.deepPurple.shade800;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 80 * scale, height: 40 * scale),
        Radius.circular(8 * scale),
      ),
      paint,
    );

    // Dragon scales pattern
    paint.color = Colors.deepPurple.shade600;
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 8; col++) {
        final x = -35 * scale + (col * 10 * scale);
        final y = -15 * scale + (row * 8 * scale);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 8 * scale, height: 6 * scale),
          paint,
        );
      }
    }

    // Back rest with dragon head silhouette
    paint.color = Colors.deepPurple.shade700;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -15 * scale), width: 80 * scale, height: 20 * scale),
        Radius.circular(8 * scale),
      ),
      paint,
    );

    // Dragon head silhouette on back rest
    paint.color = Colors.deepPurple.shade900;
    _drawDragonHeadSilhouette(canvas, Offset(0, -15 * scale), 60 * scale, 15 * scale, paint);

    // Dragon wing arms
    paint.color = Colors.deepPurple.shade600;
    _drawDragonWing(canvas, Offset(-30 * scale, 0), 15 * scale, 30 * scale, paint);
    _drawDragonWing(canvas, Offset(30 * scale, 0), 15 * scale, 30 * scale, paint);

    // Dragon scale cushions
    paint.color = Colors.deepPurple.shade400;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(-20 * scale, 0), width: 25 * scale, height: 15 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(20 * scale, 0), width: 25 * scale, height: 15 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );

    // Dragon scale pattern on cushions
    paint.color = Colors.deepPurple.shade300;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 2; j++) {
        final x = -20 * scale + (i * 10 * scale);
        final y = -5 * scale + (j * 8 * scale);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 6 * scale, height: 4 * scale),
          paint,
        );
      }
    }

    // Dragon fire effect
    if (animationValue > 0.5) {
      paint.color = Colors.orange.withOpacity(0.6);
      _drawDragonFire(canvas, Offset(0, -25 * scale), 20 * scale, paint);
    }

    // Magical sparkles around the couch
    paint.color = Colors.yellow.withOpacity(0.8 * math.sin(animationValue * math.pi));
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * math.pi * 2 + animationValue * math.pi * 2;
      final radius = 50 + math.sin(animationValue * math.pi * 4) * 10;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;
      _drawStar(canvas, Offset(x, y), 3, paint);
    }
  }

  // Draw dragon head silhouette
  void _drawDragonHeadSilhouette(Canvas canvas, Offset center, double width, double height, Paint paint) {
    final path = Path();
    
    // Dragon head shape
    path.moveTo(center.dx - width/2, center.dy);
    path.quadraticBezierTo(center.dx - width/2, center.dy - height/2, center.dx, center.dy - height/2);
    path.quadraticBezierTo(center.dx + width/2, center.dy - height/2, center.dx + width/2, center.dy);
    path.quadraticBezierTo(center.dx + width/3, center.dy + height/3, center.dx, center.dy + height/2);
    path.quadraticBezierTo(center.dx - width/3, center.dy + height/3, center.dx - width/2, center.dy);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  // Draw dragon wing
  void _drawDragonWing(Canvas canvas, Offset center, double width, double height, Paint paint) {
    final path = Path();
    
    // Wing shape
    path.moveTo(center.dx - width/2, center.dy - height/2);
    path.quadraticBezierTo(center.dx, center.dy - height/2, center.dx + width/2, center.dy);
    path.quadraticBezierTo(center.dx, center.dy + height/2, center.dx - width/2, center.dy + height/2);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  // Draw dragon fire effect
  void _drawDragonFire(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
    // Fire shape
    path.moveTo(center.dx, center.dy);
    path.quadraticBezierTo(center.dx - size/2, center.dy - size, center.dx, center.dy - size);
    path.quadraticBezierTo(center.dx + size/2, center.dy - size, center.dx, center.dy);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  // Chair: Simple chair with back and seat
  void _drawChair(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Seat
    paint.color = primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 10 * scale), width: 30 * scale, height: 8 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );

    // Back rest
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -5 * scale), width: 30 * scale, height: 20 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );

    // Legs
    paint.color = primary.withOpacity(0.8);
    final legWidth = 3 * scale;
    final legHeight = 15 * scale;
    canvas.drawRect(Rect.fromLTWH(-12 * scale, 15 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(9 * scale, 15 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(-12 * scale, 15 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(9 * scale, 15 * scale, legWidth, legHeight), paint);
  }

  // Table: Flat surface with legs
  void _drawTable(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Table top
    paint.color = primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -5 * scale), width: 60 * scale, height: 8 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );

    // Legs
    paint.color = primary.withOpacity(0.8);
    final legWidth = 4 * scale;
    final legHeight = 20 * scale;
    canvas.drawRect(Rect.fromLTWH(-25 * scale, 0, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(21 * scale, 0, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(-25 * scale, 0, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(21 * scale, 0, legWidth, legHeight), paint);
  }

  // Bed: Mattress with headboard
  void _drawBed(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Mattress
    paint.color = primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 5 * scale), width: 70 * scale, height: 20 * scale),
        Radius.circular(6 * scale),
      ),
      paint,
    );

    // Headboard
    paint.color = primary.withOpacity(0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -15 * scale), width: 70 * scale, height: 15 * scale),
        Radius.circular(6 * scale),
      ),
      paint,
    );

    // Pillows
    paint.color = secondary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(-15 * scale, -10 * scale), width: 20 * scale, height: 8 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(15 * scale, -10 * scale), width: 20 * scale, height: 8 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );
  }

  // Desk: Work surface with drawers
  void _drawDesk(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Desktop
    paint.color = primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -8 * scale), width: 80 * scale, height: 6 * scale),
        Radius.circular(3 * scale),
      ),
      paint,
    );

    // Drawers
    paint.color = primary.withOpacity(0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(-20 * scale, 0), width: 25 * scale, height: 15 * scale),
        Radius.circular(2 * scale),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(20 * scale, 0), width: 25 * scale, height: 15 * scale),
        Radius.circular(2 * scale),
      ),
      paint,
    );

    // Legs
    paint.color = primary.withOpacity(0.8);
    final legWidth = 3 * scale;
    final legHeight = 18 * scale;
    canvas.drawRect(Rect.fromLTWH(-35 * scale, 5, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(32 * scale, 5, legWidth, legHeight), paint);
  }

  // Bookshelf: Vertical storage with shelves
  void _drawBookshelf(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Main structure
    paint.color = primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 0), width: 30 * scale, height: 60 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );

    // Shelves
    paint.color = primary.withOpacity(0.9);
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(-12 * scale, -20 * scale + (i * 15 * scale), 24 * scale, 2 * scale),
        paint,
      );
    }

    // Books
    paint.color = secondary;
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 4; j++) {
        canvas.drawRect(
          Rect.fromLTWH(-10 * scale + (j * 5 * scale), -15 * scale + (i * 15 * scale), 3 * scale, 8 * scale),
          paint,
        );
      }
    }
  }

  // Lamp: Light source with base and shade
  void _drawLamp(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Base
    paint.color = primary;
    canvas.drawCircle(Offset(0, 15 * scale), 8 * scale, paint);

    // Pole
    paint.color = primary.withOpacity(0.8);
    canvas.drawRect(Rect.fromLTWH(-1 * scale, -10 * scale, 2 * scale, 25 * scale), paint);

    // Shade
    paint.color = secondary;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, -15 * scale), width: 20 * scale, height: 12 * scale),
      paint,
    );

    // Light effect
    if (animationValue > 0.5) {
      paint.color = Colors.yellow.withOpacity(0.3);
      canvas.drawCircle(Offset(0, -15 * scale), 15 * scale * animationValue, paint);
    }
  }

  // Cabinet: Storage with doors
  void _drawCabinet(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Main body
    paint.color = primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 0), width: 40 * scale, height: 50 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );

    // Doors
    paint.color = primary.withOpacity(0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(-10 * scale, 0), width: 18 * scale, height: 45 * scale),
        Radius.circular(2 * scale),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(10 * scale, 0), width: 18 * scale, height: 45 * scale),
        Radius.circular(2 * scale),
      ),
      paint,
    );

    // Handles
    paint.color = secondary;
    canvas.drawCircle(Offset(-5 * scale, 0), 2 * scale, paint);
    canvas.drawCircle(Offset(5 * scale, 0), 2 * scale, paint);
  }

  // Stool: Simple seating
  void _drawStool(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Seat
    paint.color = primary;
    canvas.drawCircle(Offset(0, -5 * scale), 15 * scale, paint);

    // Legs
    paint.color = primary.withOpacity(0.8);
    final legWidth = 2 * scale;
    final legHeight = 20 * scale;
    canvas.drawRect(Rect.fromLTWH(-8 * scale, 5, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(6 * scale, 5, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(-1 * scale, 5, legWidth, legHeight), paint);
  }

  // Bench: Long seating
  void _drawBench(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Seat
    paint.color = primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 0), width: 60 * scale, height: 8 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );

    // Back rest
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -8 * scale), width: 60 * scale, height: 15 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );

    // Legs
    paint.color = primary.withOpacity(0.8);
    final legWidth = 3 * scale;
    final legHeight = 15 * scale;
    canvas.drawRect(Rect.fromLTWH(-25 * scale, 5, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(22 * scale, 5, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(-25 * scale, 5, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(22 * scale, 5, legWidth, legHeight), paint);
  }

  // Ottoman: Footrest
  void _drawOttoman(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Main body
    paint.color = primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 0), width: 40 * scale, height: 15 * scale),
        Radius.circular(8 * scale),
      ),
      paint,
    );

    // Cushion
    paint.color = secondary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -2 * scale), width: 35 * scale, height: 8 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );
  }

  // Armchair: Comfortable chair with arms
  void _drawArmchair(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Seat
    paint.color = primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 5 * scale), width: 35 * scale, height: 8 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );

    // Back rest
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -8 * scale), width: 35 * scale, height: 20 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );

    // Arms
    paint.color = primary.withOpacity(0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(-15 * scale, 0), width: 8 * scale, height: 20 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(15 * scale, 0), width: 8 * scale, height: 20 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );

    // Legs
    paint.color = primary.withOpacity(0.8);
    final legWidth = 2 * scale;
    final legHeight = 12 * scale;
    canvas.drawRect(Rect.fromLTWH(-12 * scale, 10 * scale, legWidth, legHeight), paint);
    canvas.drawRect(Rect.fromLTWH(10 * scale, 10 * scale, legWidth, legHeight), paint);
  }

  // Mirror: Reflective surface
  void _drawMirror(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Frame
    paint.color = primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 0), width: 30 * scale, height: 40 * scale),
        Radius.circular(8 * scale),
      ),
      paint,
    );

    // Mirror surface
    paint.color = Colors.blue.withOpacity(0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 0), width: 25 * scale, height: 35 * scale),
        Radius.circular(6 * scale),
      ),
      paint,
    );

    // Reflection effect
    if (animationValue > 0.5) {
      paint.color = Colors.white.withOpacity(0.2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(0, 0), width: 25 * scale, height: 35 * scale),
          Radius.circular(6 * scale),
        ),
        paint,
      );
    }
  }

  // Rug: Floor covering
  void _drawRug(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Main rug
    paint.color = primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 0), width: 80 * scale, height: 50 * scale),
        Radius.circular(10 * scale),
      ),
      paint,
    );

    // Pattern
    paint.color = secondary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 0), width: 70 * scale, height: 40 * scale),
        Radius.circular(8 * scale),
      ),
      paint,
    );

    // Decorative elements
    paint.color = primary;
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 2; j++) {
        canvas.drawCircle(
          Offset(-20 * scale + (i * 20 * scale), -10 * scale + (j * 20 * scale)),
          3 * scale,
          paint,
        );
      }
    }
  }

  // Plant: Decorative greenery
  void _drawPlant(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Pot
    paint.color = primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 10 * scale), width: 20 * scale, height: 15 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );

    // Plant
    paint.color = Colors.green;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, -5 * scale), width: 25 * scale, height: 30 * scale),
      paint,
    );

    // Leaves
    paint.color = Colors.green.shade700;
    for (var i = 0; i < 5; i++) {
      final angle = (i / 5) * math.pi * 2;
      final x = math.cos(angle) * 8 * scale;
      final y = math.sin(angle) * 8 * scale;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y - 5 * scale), width: 8 * scale, height: 12 * scale),
        paint,
      );
    }
  }

  // Clock: Time display
  void _drawClock(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Clock face
    paint.color = primary;
    canvas.drawCircle(Offset(0, 0), 20 * scale, paint);

    // Numbers
    paint.color = Colors.white;
    for (var i = 1; i <= 12; i++) {
      final angle = (i / 12) * math.pi * 2 - math.pi / 2;
      final x = math.cos(angle) * 15 * scale;
      final y = math.sin(angle) * 15 * scale;
      canvas.drawCircle(Offset(x, y), 1 * scale, paint);
    }

    // Hands
    paint.color = Colors.black;
    paint.strokeWidth = 2 * scale;
    canvas.drawLine(Offset.zero, Offset(0, -10 * scale), paint);
    canvas.drawLine(Offset.zero, Offset(5 * scale, 0), paint);
  }

  // Generic furniture fallback
  void _drawGenericFurniture(Canvas canvas, Size size, Color primary, Color secondary, double scale) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Simple box
    paint.color = primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 40 * scale, height: 30 * scale),
        Radius.circular(6 * scale),
      ),
      paint,
    );

    // Decorative elements
    paint.color = secondary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 35 * scale, height: 25 * scale),
        Radius.circular(4 * scale),
      ),
      paint,
    );
  }

  // Draw effects (sparkles, glow, etc.)
  void _drawEffects(Canvas canvas, Size size, List<dynamic> effects, double anim) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final effect in effects) {
      final effectStr = effect.toString().toLowerCase();

      if (effectStr.contains('sparkle') || effectStr.contains('magic')) {
        // Sparkle particles
        paint.color = Colors.yellow.withOpacity(0.6 * math.sin(anim * math.pi));
        for (var i = 0; i < 6; i++) {
          final angle = (i / 6) * math.pi * 2 + anim * math.pi * 2;
          final radius = 40 + math.sin(anim * math.pi * 4) * 5;
          final x = math.cos(angle) * radius;
          final y = math.sin(angle) * radius;
          _drawStar(canvas, Offset(x, y), 4, paint);
        }
      }

      if (effectStr.contains('glow') || effectStr.contains('shine')) {
        // Glow effect
        paint.color = Colors.yellow.withOpacity(0.3);
        canvas.drawCircle(Offset.zero, 30 + math.sin(anim * math.pi * 2) * 5, paint);
      }
    }
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

  // Get size multiplier
  double _getSizeMultiplier(String size) {
    switch (size) {
      case 'tiny':
      case 'small':
        return 0.7;
      case 'large':
      case 'huge':
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
      default:
        return Colors.brown;
    }
  }

  // Get secondary color (for accents)
  Color _getSecondaryColor(String colorName) {
    final primary = _getColor(colorName);
    return Color.lerp(primary, Colors.white, 0.3)!;
  }

  @override
  bool shouldRepaint(FurniturePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.furnitureAttributes != furnitureAttributes;
  }
}
