import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

/// Service for responsive design and device detection
class ResponsiveService {
  static late MediaQueryData _mediaQuery;
  static late Size _screenSize;
  static late double _devicePixelRatio;
  static late Orientation _orientation;
  
  /// Initialize responsive service
  static void init(BuildContext context) {
    _mediaQuery = MediaQuery.of(context);
    _screenSize = _mediaQuery.size;
    _devicePixelRatio = _mediaQuery.devicePixelRatio;
    _orientation = _mediaQuery.orientation;
  }
  
  /// Get screen width
  static double get screenWidth => _screenSize.width;
  
  /// Get screen height
  static double get screenHeight => _screenSize.height;
  
  /// Get device pixel ratio
  static double get devicePixelRatio => _devicePixelRatio;
  
  /// Get orientation
  static Orientation get orientation => _orientation;
  
  /// Check if device is tablet
  static bool get isTablet {
    final diagonal = _getDiagonal();
    return diagonal >= 7.0; // 7 inches or larger
  }
  
  /// Check if device is phone
  static bool get isPhone => !isTablet;
  
  /// Check if device is foldable
  static bool get isFoldable {
    // Detect foldable devices by checking for multiple display modes
    return _mediaQuery.platformBrightness != null && 
           _screenSize.width > 1000; // Foldable devices typically have wide screens
  }
  
  /// Get device type
  static DeviceType get deviceType {
    if (isFoldable) return DeviceType.foldable;
    if (isTablet) return DeviceType.tablet;
    return DeviceType.phone;
  }
  
  /// Get screen diagonal in inches
  static double _getDiagonal() {
    final size = _screenSize;
    final diagonal = sqrt(size.width * size.width + size.height * size.height);
    return diagonal / _devicePixelRatio / 160; // Convert to inches
  }
  
  /// Get responsive font size
  static double getFontSize(double baseSize) {
    final scale = _getScaleFactor();
    return baseSize * scale;
  }
  
  /// Get responsive padding
  static double getPadding(double basePadding) {
    final scale = _getScaleFactor();
    return basePadding * scale;
  }
  
  /// Get responsive margin
  static double getMargin(double baseMargin) {
    final scale = _getScaleFactor();
    return baseMargin * scale;
  }
  
  /// Get responsive icon size
  static double getIconSize(double baseSize) {
    final scale = _getScaleFactor();
    return baseSize * scale;
  }
  
  /// Get scale factor based on screen size
  static double _getScaleFactor() {
    final diagonal = _getDiagonal();
    
    if (diagonal < 4.0) {
      return 0.8; // Small phones
    } else if (diagonal < 5.0) {
      return 1.0; // Normal phones
    } else if (diagonal < 6.0) {
      return 1.1; // Large phones
    } else if (diagonal < 7.0) {
      return 1.2; // Phablets
    } else if (diagonal < 10.0) {
      return 1.4; // Tablets
    } else {
      return 1.6; // Large tablets
    }
  }
  
  /// Get responsive width percentage
  static double getWidthPercent(double percent) {
    return screenWidth * (percent / 100);
  }
  
  /// Get responsive height percentage
  static double getHeightPercent(double percent) {
    return screenHeight * (percent / 100);
  }
  
  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding() {
    return _mediaQuery.padding;
  }
  
  /// Get responsive button height
  static double getButtonHeight() {
    if (isTablet) return 64;
    if (isFoldable) return 72;
    return 56;
  }
  
  /// Get responsive input height
  static double getInputHeight() {
    if (isTablet) return 56;
    if (isFoldable) return 64;
    return 48;
  }
  
  /// Get responsive card padding
  static EdgeInsets getCardPadding() {
    final basePadding = isTablet ? 24.0 : 16.0;
    return EdgeInsets.all(basePadding * _getScaleFactor());
  }
  
  /// Get responsive grid columns
  static int getGridColumns() {
    if (isFoldable) return 4;
    if (isTablet) return 3;
    return 2;
  }
  
  /// Get responsive breakpoint
  static ResponsiveBreakpoint getBreakpoint() {
    final width = screenWidth;
    
    if (width < 600) return ResponsiveBreakpoint.mobile;
    if (width < 900) return ResponsiveBreakpoint.tablet;
    if (width < 1200) return ResponsiveBreakpoint.desktop;
    return ResponsiveBreakpoint.largeDesktop;
  }
}

/// Device type enum
enum DeviceType {
  phone,
  tablet,
  foldable,
}

/// Responsive breakpoint enum
enum ResponsiveBreakpoint {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Responsive widget builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;
  
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });
  
  @override
  Widget build(BuildContext context) {
    ResponsiveService.init(context);
    return builder(context, ResponsiveService.deviceType);
  }
}

/// Responsive text widget
class ResponsiveText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  
  const ResponsiveText(
    this.text, {
    super.key,
    required this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
  });
  
  @override
  Widget build(BuildContext context) {
    ResponsiveService.init(context);
    
    return Text(
      text,
      style: TextStyle(
        fontSize: ResponsiveService.getFontSize(fontSize),
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}

/// Responsive container widget
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
  });
  
  @override
  Widget build(BuildContext context) {
    ResponsiveService.init(context);
    
    return Container(
      width: width != null ? ResponsiveService.getWidthPercent(width!) : null,
      height: height != null ? ResponsiveService.getHeightPercent(height!) : null,
      padding: padding != null 
          ? EdgeInsets.all(ResponsiveService.getPadding(padding!.left))
          : null,
      margin: margin != null 
          ? EdgeInsets.all(ResponsiveService.getMargin(margin!.left))
          : null,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}
