import 'package:flutter/material.dart';
import '../theme/kid_friendly_theme.dart';

/// 🎨 Kid-Friendly UI Components
/// Large buttons, bright colors, and engaging animations for kids 4-10

/// Large Kid-Friendly Button
class KidFriendlyButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData? icon;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool isEnabled;
  final String? tooltip;

  const KidFriendlyButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.icon,
    this.width,
    this.height,
    this.isLoading = false,
    this.isEnabled = true,
    this.tooltip,
  });

  @override
  State<KidFriendlyButton> createState() => _KidFriendlyButtonState();
}

class _KidFriendlyButtonState extends State<KidFriendlyButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _colorController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    
    _colorController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: widget.color ?? KidFriendlyTheme.primaryBlue,
      end: (widget.color ?? KidFriendlyTheme.primaryBlue).withOpacity(0.8),
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _scaleController.forward();
      _colorController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      _scaleController.reverse();
      _colorController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.isEnabled && !widget.isLoading) {
      _scaleController.reverse();
      _colorController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? KidFriendlyTheme.primaryBlue;
    final isEnabled = widget.isEnabled && !widget.isLoading;
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _colorAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width ?? KidFriendlyTheme.buttonWidth,
              height: widget.height ?? KidFriendlyTheme.buttonHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: KidFriendlyTheme.getButtonGradient(
                    _colorAnimation.value ?? buttonColor,
                  ),
                ),
                borderRadius: BorderRadius.circular(KidFriendlyTheme.largeRadius),
                boxShadow: KidFriendlyTheme.getButtonShadow(buttonColor),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(KidFriendlyTheme.largeRadius),
                  onTap: isEnabled ? widget.onPressed : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: KidFriendlyTheme.largeSpacing,
                      vertical: KidFriendlyTheme.mediumSpacing,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: KidFriendlyTheme.largeIconSize,
                            color: KidFriendlyTheme.textWhite,
                          ),
                          SizedBox(width: KidFriendlyTheme.mediumSpacing),
                        ],
                        if (widget.isLoading)
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                KidFriendlyTheme.textWhite,
                              ),
                            ),
                          )
                        else
                          Flexible(
                            child: Text(
                              widget.text,
                              style: TextStyle(
                                fontSize: KidFriendlyTheme.buttonFontSize,
                                fontWeight: FontWeight.bold,
                                color: KidFriendlyTheme.textWhite,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Kid-Friendly Card
class KidFriendlyCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final bool isElevated;

  const KidFriendlyCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.margin,
    this.onTap,
    this.isElevated = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.all(KidFriendlyTheme.mediumSpacing),
      decoration: BoxDecoration(
        color: color ?? KidFriendlyTheme.backgroundLight,
        borderRadius: BorderRadius.circular(KidFriendlyTheme.largeRadius),
        boxShadow: isElevated ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(KidFriendlyTheme.largeRadius),
          onTap: onTap,
          child: Container(
            padding: padding ?? EdgeInsets.all(KidFriendlyTheme.largeSpacing),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Kid-Friendly Icon Button
class KidFriendlyIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final String? tooltip;
  final bool isEnabled;

  const KidFriendlyIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size,
    this.tooltip,
    this.isEnabled = true,
  });

  @override
  State<KidFriendlyIconButton> createState() => _KidFriendlyIconButtonState();
}

class _KidFriendlyIconButtonState extends State<KidFriendlyIconButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isEnabled) {
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isEnabled) {
      _scaleController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.isEnabled) {
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? KidFriendlyTheme.primaryBlue;
    final iconSize = widget.size ?? KidFriendlyTheme.hugeIconSize;
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: iconSize + 20,
              height: iconSize + 20,
              decoration: BoxDecoration(
                color: buttonColor,
                shape: BoxShape.circle,
                boxShadow: KidFriendlyTheme.getButtonShadow(buttonColor),
              ),
              child: Icon(
                widget.icon,
                size: iconSize,
                color: KidFriendlyTheme.textWhite,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Kid-Friendly Progress Indicator
class KidFriendlyProgressIndicator extends StatefulWidget {
  final double progress;
  final Color? color;
  final String? message;
  final bool showPercentage;

  const KidFriendlyProgressIndicator({
    super.key,
    required this.progress,
    this.color,
    this.message,
    this.showPercentage = true,
  });

  @override
  State<KidFriendlyProgressIndicator> createState() => _KidFriendlyProgressIndicatorState();
}

class _KidFriendlyProgressIndicatorState extends State<KidFriendlyProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _progressController.forward();
  }

  @override
  void didUpdateWidget(KidFriendlyProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ));
      _progressController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = widget.color ?? KidFriendlyTheme.primaryGreen;
    
    return Column(
      children: [
        if (widget.message != null) ...[
          Text(
            widget.message!,
            style: TextStyle(
              fontSize: KidFriendlyTheme.bodyFontSize,
              fontWeight: FontWeight.bold,
              color: KidFriendlyTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: KidFriendlyTheme.mediumSpacing),
        ],
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: 20,
              decoration: BoxDecoration(
                color: progressColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * _progressAnimation.value,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: KidFriendlyTheme.getButtonGradient(progressColor),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  if (widget.showPercentage)
                    Center(
                      child: Text(
                        '${(_progressAnimation.value * 100).round()}%',
                        style: TextStyle(
                          fontSize: KidFriendlyTheme.captionFontSize,
                          fontWeight: FontWeight.bold,
                          color: KidFriendlyTheme.textWhite,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Kid-Friendly Snackbar
class KidFriendlySnackBar extends StatelessWidget {
  final String message;
  final Color? backgroundColor;
  final IconData? icon;
  final Duration duration;

  const KidFriendlySnackBar({
    super.key,
    required this.message,
    this.backgroundColor,
    this.icon,
    this.duration = const Duration(seconds: 3),
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? KidFriendlyTheme.primaryGreen;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: KidFriendlyTheme.largeSpacing,
        vertical: KidFriendlyTheme.mediumSpacing,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(KidFriendlyTheme.mediumRadius),
        boxShadow: KidFriendlyTheme.getButtonShadow(bgColor),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: KidFriendlyTheme.textWhite,
              size: KidFriendlyTheme.largeIconSize,
            ),
            SizedBox(width: KidFriendlyTheme.mediumSpacing),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: KidFriendlyTheme.bodyFontSize,
                fontWeight: FontWeight.bold,
                color: KidFriendlyTheme.textWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




