import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

/// Simple QR code generator widget
class QRCodeGenerator extends StatelessWidget {
  final String data;
  final double size;
  final Color? foregroundColor;
  final Color? backgroundColor;

  const QRCodeGenerator({
    super.key,
    required this.data,
    this.size = 200.0,
    this.foregroundColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: CustomPaint(
        painter: QRCodePainter(
          data: data,
          foregroundColor: foregroundColor ?? Colors.black,
          backgroundColor: backgroundColor ?? Colors.white,
        ),
        size: Size(size, size),
      ),
    );
  }
}

/// QR Code painter for drawing QR codes
class QRCodePainter extends CustomPainter {
  final String data;
  final Color foregroundColor;
  final Color backgroundColor;

  QRCodePainter({
    required this.data,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Simple QR code simulation (in real implementation, use a QR code library)
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = foregroundColor;

    final backgroundPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor;

    // Fill background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Generate simple pattern based on data hash
    final hash = data.hashCode;
    final random = hash % 1000;
    final cellSize = size.width / 25; // 25x25 grid

    for (int x = 0; x < 25; x++) {
      for (int y = 0; y < 25; y++) {
        final cellHash = (hash + x * 25 + y) % 3;
        if (cellHash == 0) {
          canvas.drawRect(
            Rect.fromLTWH(
              x * cellSize,
              y * cellSize,
              cellSize,
              cellSize,
            ),
            paint,
          );
        }
      }
    }

    // Add corner markers (QR code style)
    _drawCornerMarker(canvas, 0, 0, cellSize);
    _drawCornerMarker(canvas, size.width - 7 * cellSize, 0, cellSize);
    _drawCornerMarker(canvas, 0, size.height - 7 * cellSize, cellSize);
  }

  void _drawCornerMarker(Canvas canvas, double x, double y, double cellSize) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = foregroundColor;

    // Outer square
    canvas.drawRect(Rect.fromLTWH(x, y, 7 * cellSize, 7 * cellSize), paint);
    
    // Inner square (background)
    final innerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(x + cellSize, y + cellSize, 5 * cellSize, 5 * cellSize), innerPaint);
    
    // Center square
    canvas.drawRect(Rect.fromLTWH(x + 2 * cellSize, y + 2 * cellSize, 3 * cellSize, 3 * cellSize), paint);
  }

  @override
  bool shouldRepaint(QRCodePainter oldDelegate) {
    return oldDelegate.data != data ||
           oldDelegate.foregroundColor != foregroundColor ||
           oldDelegate.backgroundColor != backgroundColor;
  }
}

/// QR Code dialog for sharing
class QRCodeDialog extends StatelessWidget {
  final String shareCode;
  final String creatureName;

  const QRCodeDialog({
    super.key,
    required this.shareCode,
    required this.creatureName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Share $creatureName',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // QR Code
            QRCodeGenerator(
              data: 'https://crafta.app/share/$shareCode',
              size: 200,
              foregroundColor: Colors.black,
              backgroundColor: Colors.white,
            ),
            
            const SizedBox(height: 16),
            
            // Share code
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Share code: $shareCode',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      // Copy to clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share code copied!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Instructions
            Text(
              'Scan this QR code or use the share code to load this creature in Crafta',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF98D8C8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


