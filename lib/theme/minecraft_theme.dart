import 'package:flutter/material.dart';

/// Minecraft-inspired theme for Crafta
/// Uses Minecraft's color palette and design language without infringing on trademarks
class MinecraftTheme {
  // Minecraft-inspired color palette
  static const Color grassGreen = Color(0xFF7CB342); // Minecraft grass
  static const Color dirtBrown = Color(0xFF8B6F47); // Minecraft dirt
  static const Color stoneGray = Color(0xFF7F7F7F); // Stone gray
  static const Color deepStone = Color(0xFF505050); // Dark stone
  static const Color oakWood = Color(0xFFA0826D); // Oak wood
  static const Color birchWood = Color(0xFFD7C185); // Birch wood
  static const Color diamond = Color(0xFF5DADE2); // Diamond blue
  static const Color emerald = Color(0xFF50C878); // Emerald green
  static const Color redstone = Color(0xFFFF0000); // Redstone red
  static const Color goldOre = Color(0xFFFCBE11); // Gold
  static const Color coalBlack = Color(0xFF1A1A1A); // Coal
  static const Color snowWhite = Color(0xFFFFFAFA); // Snow
  static const Color lavaOrange = Color(0xFFFF6B35); // Lava
  static const Color waterBlue = Color(0xFF3F76E4); // Water
  static const Color netherPortal = Color(0xFF8B00FF); // Portal purple

  // UI colors based on Minecraft GUI
  static const Color slotBackground = Color(0xFF8B8B8B); // Inventory slot
  static const Color slotBorder = Color(0xFF373737); // Slot border
  static const Color buttonBackground = Color(0xFF565656); // Button gray
  static const Color buttonHover = Color(0xFF7F7F7F); // Button hover
  static const Color textLight = Color(0xFFFCFCFC); // Light text
  static const Color textDark = Color(0xFF3F3F3F); // Dark text
  static const Color textShadow = Color(0xFF3F3F3F); // Text shadow
  static const Color hotbarBackground = Color(0xC8000000); // Hotbar semi-transparent

  // Crafta brand colors (adapted to Minecraft style)
  static const Color craftaMint = grassGreen; // Use grass green
  static const Color craftaPink = lavaOrange; // Use lava orange
  static const Color craftaCream = birchWood; // Use birch wood

  /// Create a box shadow that looks like Minecraft's 3D depth
  static List<BoxShadow> minecraftShadow({Color? color}) {
    return [
      BoxShadow(
        color: color ?? deepStone,
        offset: const Offset(3, 3),
        blurRadius: 0, // No blur for pixelated look
        spreadRadius: 0,
      ),
      BoxShadow(
        color: (color ?? deepStone).withOpacity(0.5),
        offset: const Offset(1, 1),
        blurRadius: 0,
        spreadRadius: 0,
      ),
    ];
  }

  /// Create a Minecraft-style button decoration
  static BoxDecoration minecraftButton({
    Color? color,
    bool isPressed = false,
  }) {
    final buttonColor = color ?? buttonBackground;

    return BoxDecoration(
      color: buttonColor,
      border: Border.all(
        color: isPressed ? deepStone : slotBorder,
        width: 2,
      ),
      boxShadow: isPressed ? [] : [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(2, 2),
          blurRadius: 0,
        ),
      ],
    );
  }

  /// Create a Minecraft-style panel decoration (like inventory)
  static BoxDecoration minecraftPanel({
    Color? backgroundColor,
    bool hasBorder = true,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? slotBackground.withOpacity(0.9),
      border: hasBorder ? Border.all(
        color: slotBorder,
        width: 3,
      ) : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.7),
          offset: const Offset(4, 4),
          blurRadius: 0,
        ),
      ],
    );
  }

  /// Create a Minecraft-style slot decoration (like inventory slots)
  static BoxDecoration minecraftSlot({
    bool isSelected = false,
  }) {
    return BoxDecoration(
      color: slotBackground,
      border: Border(
        top: BorderSide(color: isSelected ? goldOre : Colors.black, width: 2),
        left: BorderSide(color: isSelected ? goldOre : Colors.black, width: 2),
        right: BorderSide(color: isSelected ? goldOre : textLight, width: 2),
        bottom: BorderSide(color: isSelected ? goldOre : textLight, width: 2),
      ),
    );
  }

  /// Minecraft-style text with shadow (like in-game text)
  static TextStyle minecraftText({
    double fontSize = 16,
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
    bool hasShadow = true,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color ?? textLight,
      fontWeight: fontWeight,
      fontFamily: 'monospace', // Pixelated feel
      shadows: hasShadow ? [
        Shadow(
          color: textShadow,
          offset: const Offset(2, 2),
          blurRadius: 0,
        ),
      ] : null,
    );
  }

  /// Title text style (like Minecraft logo)
  static TextStyle titleText({
    double fontSize = 32,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: color ?? goldOre,
      fontWeight: FontWeight.bold,
      fontFamily: 'monospace',
      letterSpacing: 2,
      shadows: [
        Shadow(
          color: coalBlack,
          offset: const Offset(3, 3),
          blurRadius: 0,
        ),
      ],
    );
  }

  /// Create a pixelated border
  static Border pixelatedBorder({
    Color? color,
    double width = 2,
  }) {
    final borderColor = color ?? slotBorder;
    return Border.all(
      color: borderColor,
      width: width,
    );
  }

  /// Gradient background similar to Minecraft menu
  static LinearGradient minecraftGradient() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        dirtBrown.withOpacity(0.8),
        grassGreen.withOpacity(0.6),
        dirtBrown.withOpacity(0.8),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  /// Create a textured background (grass/dirt pattern)
  static BoxDecoration texturedBackground({
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor ?? grassGreen,
          secondaryColor ?? dirtBrown,
        ],
      ),
    );
  }
}

/// Widget for creating Minecraft-style buttons
class MinecraftButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final IconData? icon;
  final double width;
  final double height;

  const MinecraftButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.icon,
    this.width = double.infinity,
    this.height = 56,
  });

  @override
  State<MinecraftButton> createState() => _MinecraftButtonState();
}

class _MinecraftButtonState extends State<MinecraftButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: MinecraftTheme.minecraftButton(
          color: widget.color,
          isPressed: _isPressed,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: MinecraftTheme.textLight,
                  size: 24,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: MinecraftTheme.minecraftText(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget for creating Minecraft-style panels
class MinecraftPanel extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets padding;

  const MinecraftPanel({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: MinecraftTheme.minecraftPanel(
        backgroundColor: backgroundColor,
      ),
      child: child,
    );
  }
}

/// Widget for creating Minecraft-style text with shadow
class MinecraftText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final FontWeight fontWeight;
  final TextAlign textAlign;

  const MinecraftText(
    this.text, {
    super.key,
    this.fontSize = 16,
    this.color,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: MinecraftTheme.minecraftText(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
    );
  }
}
