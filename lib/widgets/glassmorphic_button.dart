import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glassmorphic_container.dart';

class GlassmorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final bool enableAnimation;
  final Duration animationDuration;
  final double elevation;

  const GlassmorphicButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.elevation = 8,
  }) : super(key: key);

  @override
  State<GlassmorphicButton> createState() => _GlassmorphicButtonState();
}

class _GlassmorphicButtonState extends State<GlassmorphicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: widget.elevation, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
              _controller.reverse();
              widget.onPressed();
            },
            onTapCancel: () => _controller.reverse(),
            child: GlassmorphicContainer(
              width: widget.width,
              height: widget.height,
              borderRadius: widget.borderRadius,
              gradient: LinearGradient(
                colors: [
                  widget.backgroundColor ?? AppTheme.primaryGreen,
                  widget.backgroundColor?.withOpacity(0.78) ?? AppTheme.accentBlue,
                ],
              ),
              borderColor: widget.borderColor,
              padding: widget.padding ?? const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shadows: [
                BoxShadow(
                  color: (widget.backgroundColor ?? AppTheme.primaryGreen)
                      .withOpacity(isDark ? 0.32 : 0.24),
                  blurRadius: _elevationAnimation.value + 12,
                  offset: Offset(0, (_elevationAnimation.value / 2) + 6),
                ),
              ],
              child: DefaultTextStyle(
                style: TextStyle(
                  color: widget.foregroundColor ?? 
                         (isDark ? Colors.white : Colors.white),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}
