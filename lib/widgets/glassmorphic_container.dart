import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Alignment? alignment;
  final BoxShadow? boxShadow;
  final Gradient? gradient;
  final List<BoxShadow>? shadows;

  const GlassmorphicContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.blur = 10,
    this.color,
    this.borderColor,
    this.padding,
    this.margin,
    this.alignment,
    this.boxShadow,
    this.gradient,
    this.shadows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      alignment: alignment,
      decoration: BoxDecoration(
        gradient:
            gradient ??
            LinearGradient(
              colors: [
                color ??
                    (isDark
                        ? const Color(0xFF102D38).withOpacity(0.86)
                        : Colors.white.withOpacity(0.88)),
                color?.withOpacity(0.78) ??
                    (isDark
                        ? const Color(0xFF0B2029).withOpacity(0.82)
                        : const Color(0xFFF9FFFC).withOpacity(0.8)),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color:
              borderColor ??
              (isDark
                  ? Colors.white.withOpacity(0.12)
                  : AppTheme.premiumLine),
          width: 1.1,
        ),
        boxShadow:
            shadows ??
            [
              BoxShadow(
                color: AppTheme.ink.withOpacity(isDark ? 0.28 : 0.08),
                blurRadius: blur + 12,
                offset: const Offset(0, 12),
              ),
              if (boxShadow != null) boxShadow!,
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(padding: padding, child: child),
        ),
      ),
    );
  }
}

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final bool enableAnimation;
  final Duration animationDuration;

  const GlassmorphicCard({
    Key? key,
    required this.child,
    this.onTap,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget card = GlassmorphicContainer(
      width: width,
      height: height,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      color: color,
      borderColor: borderColor,
      child: child,
    );

    if (onTap != null) {
      card = GestureDetector(onTap: onTap, child: card);
    }

    if (enableAnimation) {
      card = AnimatedContainer(
        duration: animationDuration,
        curve: Curves.easeInOut,
        child: card,
      );
    }

    return card;
  }
}

class GlassmorphicTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final int maxLines;
  final int? maxLength;

  const GlassmorphicTextField({
    Key? key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
  }) : super(key: key);

  @override
  State<GlassmorphicTextField> createState() => _GlassmorphicTextFieldState();
}

class _GlassmorphicTextFieldState extends State<GlassmorphicTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassmorphicContainer(
      borderRadius: 16,
      color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
      borderColor: _isFocused
          ? AppTheme.primaryGreen
          : (isDark ? Colors.white : Colors.black).withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: _isFocused
                      ? AppTheme.primaryGreen
                      : (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                )
              : null,
          suffixIcon: widget.suffixIcon != null
              ? GestureDetector(
                  onTap: widget.onSuffixIconTap,
                  child: Icon(
                    widget.suffixIcon,
                    color: _isFocused
                        ? AppTheme.primaryGreen
                        : (isDark ? Colors.white : Colors.black).withOpacity(
                            0.6,
                          ),
                  ),
                )
              : null,
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
          ),
          labelStyle: TextStyle(
            color: _isFocused
                ? AppTheme.primaryGreen
                : (isDark ? Colors.white : Colors.black).withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
