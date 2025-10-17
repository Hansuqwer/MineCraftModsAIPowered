import 'package:flutter/material.dart';
import 'dart:math';

/// Screen utilities for responsive design
class ScreenUtils {
  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final diagonal = sqrt(screenWidth * screenWidth + screenHeight * screenHeight);
    
    // Scale based on screen diagonal
    if (diagonal < 400) return baseSize * 0.8;      // Small phones
    if (diagonal < 500) return baseSize * 0.9;      // Normal phones
    if (diagonal < 600) return baseSize * 1.0;      // Large phones
    if (diagonal < 700) return baseSize * 1.1;      // Phablets
    if (diagonal < 800) return baseSize * 1.2;      // Small tablets
    if (diagonal < 1000) return baseSize * 1.3;     // Tablets
    return baseSize * 1.4;                          // Large tablets
  }
  
  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context, double basePadding) {
    final scale = _getScaleFactor(context);
    return EdgeInsets.all(basePadding * scale);
  }
  
  /// Get responsive margin
  static EdgeInsets getResponsiveMargin(BuildContext context, double baseMargin) {
    final scale = _getScaleFactor(context);
    return EdgeInsets.all(baseMargin * scale);
  }
  
  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final scale = _getScaleFactor(context);
    return baseSize * scale;
  }
  
  /// Get responsive button height
  static double getResponsiveButtonHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 800) return 64;  // Tablets
    if (screenWidth > 600) return 56;  // Large phones
    return 48;                         // Normal phones
  }
  
  /// Get responsive input height
  static double getResponsiveInputHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 800) return 56;  // Tablets
    if (screenWidth > 600) return 48;  // Large phones
    return 40;                         // Normal phones
  }
  
  /// Get responsive card padding
  static EdgeInsets getResponsiveCardPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final basePadding = screenWidth > 800 ? 24.0 : 16.0;
    return EdgeInsets.all(basePadding * _getScaleFactor(context));
  }
  
  /// Get responsive grid columns
  static int getResponsiveGridColumns(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 4;   // Large tablets/desktop
    if (screenWidth > 800) return 3;   // Tablets
    if (screenWidth > 600) return 2;   // Large phones
    return 1;                          // Normal phones
  }
  
  /// Get scale factor based on screen size
  static double _getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final diagonal = sqrt(screenWidth * screenWidth + screenHeight * screenHeight);
    
    if (diagonal < 400) return 0.8;      // Small phones
    if (diagonal < 500) return 0.9;      // Normal phones
    if (diagonal < 600) return 1.0;      // Large phones
    if (diagonal < 700) return 1.1;      // Phablets
    if (diagonal < 800) return 1.2;      // Small tablets
    if (diagonal < 1000) return 1.3;    // Tablets
    return 1.4;                          // Large tablets
  }
  
  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 600;
  }
  
  /// Check if device is foldable
  static bool isFoldable(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 800;
  }
  
  /// Get responsive width percentage
  static double getResponsiveWidth(BuildContext context, double percent) {
    return MediaQuery.of(context).size.width * (percent / 100);
  }
  
  /// Get responsive height percentage
  static double getResponsiveHeight(BuildContext context, double percent) {
    return MediaQuery.of(context).size.height * (percent / 100);
  }
}
