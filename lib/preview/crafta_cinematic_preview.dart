import 'package:flutter/material.dart';

class CraftaCinematicPreview extends StatelessWidget {
  final String title;
  final ImageProvider image; // supports AssetImage or FileImage or NetworkImage

  const CraftaCinematicPreview({
    super.key,
    required this.title,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6F1FF),
      body: Stack(
        children: [
          Center(
            child: AnimatedScale(
              scale: 1.03,
              duration: const Duration(seconds: 3),
              curve: Curves.easeInOut,
              child: Image(
                image: image,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

