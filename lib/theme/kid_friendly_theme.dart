import 'package:flutter/material.dart';

/// 🎨 Kid-Friendly Theme
/// Optimized for children ages 4-10 with bright colors, large buttons, and engaging animations
class KidFriendlyTheme {
  // Primary Colors - Bright and engaging
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color primaryPurple = Color(0xFF9B59B6);
  static const Color primaryPink = Color(0xFFE91E63);
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color primaryOrange = Color(0xFFFF9800);
  static const Color primaryYellow = Color(0xFFFFEB3B);
  static const Color primaryRed = Color(0xFFE74C3C);
  static const Color primaryCyan = Color(0xFF1ABC9C);
  
  // Secondary Colors - Softer tones
  static const Color secondaryBlue = Color(0xFF81C7E3);
  static const Color secondaryPurple = Color(0xFFBB8FCE);
  static const Color secondaryPink = Color(0xFFF8BBD9);
  static const Color secondaryGreen = Color(0xFF7DCEA0);
  static const Color secondaryOrange = Color(0xFFFFB74D);
  static const Color secondaryYellow = Color(0xFFFFF176);
  static const Color secondaryRed = Color(0xFFEF9A9A);
  static const Color secondaryCyan = Color(0xFF80CBC4);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundBlue = Color(0xFFE3F2FD);
  static const Color backgroundPurple = Color(0xFFF3E5F5);
  static const Color backgroundPink = Color(0xFFFCE4EC);
  static const Color backgroundGreen = Color(0xFFE8F5E8);
  static const Color backgroundOrange = Color(0xFFFFF3E0);
  static const Color backgroundYellow = Color(0xFFFFFDE7);
  static const Color backgroundRed = Color(0xFFFFEBEE);
  static const Color backgroundCyan = Color(0xFFE0F2F1);
  
  // Text Colors
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textMedium = Color(0xFF5D6D7E);
  static const Color textLight = Color(0xFF85929E);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Button Sizes - Large for small fingers
  static const double buttonHeight = 60.0;
  static const double buttonWidth = 200.0;
  static const double iconSize = 32.0;
  static const double largeIconSize = 48.0;
  static const double hugeIconSize = 64.0;
  
  // Font Sizes - Large and readable
  static const double titleFontSize = 28.0;
  static const double headingFontSize = 24.0;
  static const double bodyFontSize = 18.0;
  static const double buttonFontSize = 20.0;
  static const double captionFontSize = 16.0;
  
  // Spacing - Generous for easy interaction
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double hugeSpacing = 32.0;
  
  // Border Radius - Rounded for friendly feel
  static const double smallRadius = 8.0;
  static const double mediumRadius = 16.0;
  static const double largeRadius = 24.0;
  static const double hugeRadius = 32.0;
  
  /// Get gradient colors for buttons
  static List<Color> getButtonGradient(Color primaryColor) {
    return [
      primaryColor,
      primaryColor.withOpacity(0.8),
      primaryColor.withOpacity(0.6),
    ];
  }
  
  /// Get shadow colors for depth
  static List<BoxShadow> getButtonShadow(Color primaryColor) {
    return [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        blurRadius: 8,
        spreadRadius: 2,
        offset: Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        spreadRadius: 1,
        offset: Offset(0, 2),
      ),
    ];
  }
  
  /// Get encouragement colors
  static Color getEncouragementColor(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return primaryGreen;
      case 'warning':
        return primaryOrange;
      case 'error':
        return primaryRed;
      case 'info':
        return primaryBlue;
      default:
        return primaryPurple;
    }
  }
  
  /// Get random bright color
  static Color getRandomBrightColor() {
    final colors = [
      primaryBlue,
      primaryPurple,
      primaryPink,
      primaryGreen,
      primaryOrange,
      primaryYellow,
      primaryRed,
      primaryCyan,
    ];
    return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
  }
  
  /// Get rainbow gradient
  static LinearGradient getRainbowGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryRed,
        primaryOrange,
        primaryYellow,
        primaryGreen,
        primaryCyan,
        primaryBlue,
        primaryPurple,
        primaryPink,
      ],
    );
  }
  
  /// Get sparkle gradient
  static LinearGradient getSparkleGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryYellow,
        primaryOrange,
        primaryPink,
        primaryPurple,
      ],
    );
  }
  
  /// Get ocean gradient
  static LinearGradient getOceanGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryBlue,
        primaryCyan,
        primaryGreen,
      ],
    );
  }
  
  /// Get sunset gradient
  static LinearGradient getSunsetGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryOrange,
        primaryPink,
        primaryPurple,
      ],
    );
  }
}




