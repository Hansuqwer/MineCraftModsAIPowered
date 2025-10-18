import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced Modern Theme for Crafta
/// Provides modern, polished UI components with smooth animations
class EnhancedModernTheme {
  // Modern Color Palette
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryBlueDark = Color(0xFF1976D2);
  static const Color primaryBlueLight = Color(0xFF64B5F6);
  
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color accentPurpleLight = Color(0xFFBA68C8);
  
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color successGreenLight = Color(0xFF81C784);
  
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color warningOrangeLight = Color(0xFFFFB74D);
  
  static const Color errorRed = Color(0xFFF44336);
  static const Color errorRedLight = Color(0xFFE57373);
  
  static const Color backgroundDark = Color(0xFF121212);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Modern Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, accentPurple],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successGreen, successGreenLight],
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warningOrange, warningOrangeLight],
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [errorRed, errorRedLight],
  );

  // Modern Shadows
  static const List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> heavyShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // Modern Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Modern Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Modern Typography
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.3,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.4,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.3,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // Modern Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Modern Curves
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveBounceOut = Curves.bounceOut;
  static const Curve curveElasticOut = Curves.elasticOut;

  /// Create modern card decoration
  static BoxDecoration modernCard({
    Color? backgroundColor,
    List<BoxShadow>? shadows,
    double? borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? surfaceLight,
      borderRadius: BorderRadius.circular(borderRadius ?? radiusMedium),
      boxShadow: shadows ?? lightShadow,
      border: border,
    );
  }

  /// Create modern button decoration
  static BoxDecoration modernButton({
    Color? backgroundColor,
    List<BoxShadow>? shadows,
    double? borderRadius,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? primaryBlue,
      borderRadius: BorderRadius.circular(borderRadius ?? radiusMedium),
      boxShadow: isPressed ? [] : (shadows ?? lightShadow),
    );
  }

  /// Create modern input decoration
  static InputDecoration modernInput({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? fillColor,
    Color? borderColor,
    double? borderRadius,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor ?? surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? radiusMedium),
        borderSide: BorderSide(color: borderColor ?? textHint),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? radiusMedium),
        borderSide: BorderSide(color: borderColor ?? textHint),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? radiusMedium),
        borderSide: BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? radiusMedium),
        borderSide: BorderSide(color: errorRed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingMedium,
        vertical: spacingMedium,
      ),
    );
  }

  /// Create modern app bar
  static AppBar modernAppBar({
    String? title,
    List<Widget>? actions,
    Widget? leading,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
  }) {
    return AppBar(
      title: title != null ? Text(title, style: heading3) : null,
      actions: actions,
      leading: leading,
      backgroundColor: backgroundColor ?? surfaceLight,
      foregroundColor: foregroundColor ?? textPrimary,
      elevation: elevation ?? 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: true,
    );
  }

  /// Create modern floating action button
  static FloatingActionButton modernFAB({
    required VoidCallback onPressed,
    Widget? child,
    Color? backgroundColor,
    Color? foregroundColor,
    String? tooltip,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: child,
      backgroundColor: backgroundColor ?? primaryBlue,
      foregroundColor: foregroundColor ?? Colors.white,
      tooltip: tooltip,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    );
  }

  /// Create modern bottom navigation bar
  static BottomNavigationBar modernBottomNav({
    required List<BottomNavigationBarItem> items,
    required int currentIndex,
    required ValueChanged<int> onTap,
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
  }) {
    return BottomNavigationBar(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: backgroundColor ?? surfaceLight,
      selectedItemColor: selectedItemColor ?? primaryBlue,
      unselectedItemColor: unselectedItemColor ?? textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: button,
      unselectedLabelStyle: bodySmall,
    );
  }

  /// Create modern dialog
  static Widget modernDialog({
    required String title,
    required String content,
    List<Widget>? actions,
    Color? backgroundColor,
    double? borderRadius,
  }) {
    return AlertDialog(
      title: Text(title, style: heading3),
      content: Text(content, style: bodyLarge),
      actions: actions,
      backgroundColor: backgroundColor ?? surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? radiusLarge),
      ),
      elevation: 24,
    );
  }

  /// Create modern snackbar
  static SnackBar modernSnackBar({
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Duration? duration,
    Widget? action,
  }) {
    return SnackBar(
      content: Text(message, style: bodyMedium.copyWith(color: textColor)),
      backgroundColor: backgroundColor ?? surfaceDark,
      duration: duration ?? animationMedium,
      action: action != null ? SnackBarAction(label: 'Action', onPressed: () {}) : null,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      margin: const EdgeInsets.all(spacingMedium),
    );
  }

  /// Create modern progress indicator
  static Widget modernProgressIndicator({
    Color? color,
    double? strokeWidth,
    double? size,
  }) {
    return SizedBox(
      width: size ?? 24,
      height: size ?? 24,
      child: CircularProgressIndicator(
        color: color ?? primaryBlue,
        strokeWidth: strokeWidth ?? 3,
      ),
    );
  }

  /// Create modern chip
  static Widget modernChip({
    required String label,
    VoidCallback? onDeleted,
    Color? backgroundColor,
    Color? textColor,
    double? borderRadius,
  }) {
    return Chip(
      label: Text(label, style: bodySmall.copyWith(color: textColor)),
      backgroundColor: backgroundColor ?? primaryBlueLight,
      deleteIcon: onDeleted != null ? const Icon(Icons.close, size: 16) : null,
      onDeleted: onDeleted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? radiusSmall),
      ),
    );
  }

  /// Create modern switch
  static Widget modernSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
    Color? inactiveColor,
  }) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor ?? primaryBlue,
      inactiveThumbColor: inactiveColor ?? textHint,
      activeTrackColor: (activeColor ?? primaryBlue).withOpacity(0.3),
      inactiveTrackColor: textHint.withOpacity(0.3),
    );
  }

  /// Create modern slider
  static Widget modernSlider({
    required double value,
    required ValueChanged<double> onChanged,
    double? min,
    double? max,
    Color? activeColor,
    Color? inactiveColor,
  }) {
    return Slider(
      value: value,
      onChanged: onChanged,
      min: min ?? 0,
      max: max ?? 100,
      activeColor: activeColor ?? primaryBlue,
      inactiveColor: inactiveColor ?? textHint,
    );
  }

  /// Create modern divider
  static Widget modernDivider({
    Color? color,
    double? thickness,
    double? indent,
    double? endIndent,
  }) {
    return Divider(
      color: color ?? textHint,
      thickness: thickness ?? 1,
      indent: indent ?? 0,
      endIndent: endIndent ?? 0,
    );
  }

  /// Create modern list tile
  static Widget modernListTile({
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    Color? backgroundColor,
    double? borderRadius,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: spacingXSmall),
      decoration: modernCard(
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: ListTile(
        title: Text(title, style: bodyLarge),
        subtitle: subtitle != null ? Text(subtitle, style: bodyMedium) : null,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall,
        ),
      ),
    );
  }

  /// Create modern grid tile
  static Widget modernGridTile({
    required String title,
    String? subtitle,
    Widget? child,
    VoidCallback? onTap,
    Color? backgroundColor,
    double? borderRadius,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: modernCard(
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (child != null) ...[
              child,
              const SizedBox(height: spacingSmall),
            ],
            Text(title, style: bodyLarge, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: spacingXSmall),
              Text(subtitle, style: bodySmall, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }

  /// Create modern tab bar
  static TabBar modernTabBar({
    required List<Tab> tabs,
    Color? indicatorColor,
    Color? labelColor,
    Color? unselectedLabelColor,
  }) {
    return TabBar(
      tabs: tabs,
      indicatorColor: indicatorColor ?? primaryBlue,
      labelColor: labelColor ?? textPrimary,
      unselectedLabelColor: unselectedLabelColor ?? textSecondary,
      labelStyle: button,
      unselectedLabelStyle: bodyMedium,
    );
  }

  /// Create modern expansion tile
  static Widget modernExpansionTile({
    required String title,
    required Widget children,
    Widget? leading,
    Widget? trailing,
    Color? backgroundColor,
    double? borderRadius,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: spacingXSmall),
      decoration: modernCard(
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: ExpansionTile(
        title: Text(title, style: bodyLarge),
        leading: leading,
        trailing: trailing,
        children: [children],
      ),
    );
  }

  /// Create modern stepper
  static Widget modernStepper({
    required List<Step> steps,
    required int currentStep,
    required ValueChanged<int> onStepTapped,
    Color? activeColor,
    Color? inactiveColor,
  }) {
    return Stepper(
      steps: steps,
      currentStep: currentStep,
      onStepTapped: onStepTapped,
      controlsBuilder: (context, details) {
        return Row(
          children: [
            if (details.stepIndex > 0)
              TextButton(
                onPressed: details.onStepCancel,
                child: Text('BACK', style: button),
              ),
            const SizedBox(width: spacingMedium),
            ElevatedButton(
              onPressed: details.onStepContinue,
              child: Text('NEXT', style: button),
            ),
          ],
        );
      },
    );
  }
}
