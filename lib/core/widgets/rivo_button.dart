import 'package:flutter/material.dart';

/// A customizable button with animation and multiple style variants
class RivoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final bool isExpanded;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final double scale;
  final bool enableHapticFeedback;
  final Duration animationDuration;
  final Curve animationCurve;
  final Color? backgroundColor;
  final Color? textColor;
  final double elevation;
  final RivoButtonVariant variant;

  /// Creates a Rivo button with the given properties
  const RivoButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.isExpanded = true,
    this.width,
    this.height = 48.0,
    this.borderRadius = 12.0,
    this.padding,
    this.icon,
    this.scale = 0.98,
    this.enableHapticFeedback = true,
    this.animationDuration = const Duration(milliseconds: 150),
    this.animationCurve = Curves.easeInOut,
    this.backgroundColor,
    this.textColor,
    this.elevation = 0,
    this.variant = RivoButtonVariant.primary,
  });

  /// Creates a primary button
  factory RivoButton.primary({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    bool isExpanded = true,
    double? width,
    double height = 48.0,
    double borderRadius = 12.0,
    EdgeInsetsGeometry? padding,
    Widget? icon,
    double elevation = 0,
  }) {
    return RivoButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isExpanded: isExpanded,
      width: width,
      height: height,
      borderRadius: borderRadius,
      padding: padding,
      icon: icon,
      elevation: elevation,
      variant: RivoButtonVariant.primary,
    );
  }

  /// Creates an outlined button
  factory RivoButton.outlined({
    Key? key,
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    bool isExpanded = true,
    double? width,
    double height = 48.0,
    double borderRadius = 12.0,
    EdgeInsetsGeometry? padding,
    Widget? icon,
    double elevation = 0,
  }) {
    return RivoButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isExpanded: isExpanded,
      width: width,
      height: height,
      borderRadius: borderRadius,
      padding: padding,
      icon: icon,
      elevation: elevation,
      variant: RivoButtonVariant.outline,
    );
  }


  @override
  State<RivoButton> createState() => _RivoButtonState();
}

class _RivoButtonState extends State<RivoButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTapDown(TapDownDetails details) async {
    if (widget.isLoading || widget.isDisabled) return;
    
    await _controller.forward();
    
    if (widget.enableHapticFeedback) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> _handleTapUp(TapUpDetails details) async {
    if (widget.isLoading || widget.isDisabled) return;
    
    await _controller.reverse();
    
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  Future<void> _handleTapCancel() async {
    if (widget.isLoading || widget.isDisabled) return;
    
    await _controller.reverse();
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (widget.isDisabled) {
      return theme.disabledColor.withAlpha(128);
    }
    
    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }
    
    switch (widget.variant) {
      case RivoButtonVariant.primary:
        return theme.colorScheme.primary;
      case RivoButtonVariant.secondary:
        return theme.colorScheme.secondary;
      case RivoButtonVariant.outline:
      case RivoButtonVariant.text:
        return Colors.transparent;
      case RivoButtonVariant.danger:
        return theme.colorScheme.error;
    }
  }

  Color _getTextColor(ThemeData theme) {
    if (widget.isDisabled) {
      return theme.disabledColor;
    }

    if (widget.textColor != null) {
      return widget.textColor!;
    }

    switch (widget.variant) {
      case RivoButtonVariant.primary:
      case RivoButtonVariant.danger:
        return Colors.white;
      case RivoButtonVariant.secondary:
        return theme.colorScheme.onSecondary;
      case RivoButtonVariant.outline:
        return widget.isDisabled
            ? theme.disabledColor
            : (widget.textColor ?? theme.colorScheme.primary);
      case RivoButtonVariant.text:
        return widget.isDisabled
            ? theme.disabledColor
            : (widget.textColor ?? theme.colorScheme.primary);
    }
  }

  BorderSide _getBorderSide(ThemeData theme) {
    switch (widget.variant) {
      case RivoButtonVariant.primary:
      case RivoButtonVariant.secondary:
      case RivoButtonVariant.danger:
        return BorderSide.none;
      case RivoButtonVariant.outline:
        return BorderSide(
          color: widget.isDisabled
              ? theme.disabledColor
              : (widget.textColor ?? theme.colorScheme.primary),
          width: 1.0,
        );
      case RivoButtonVariant.text:
        return BorderSide.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: widget.isExpanded ? double.infinity : widget.width,
              height: widget.height,
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24.0),
              decoration: BoxDecoration(
                color: _getBackgroundColor(theme),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.fromBorderSide(_getBorderSide(theme)),
                boxShadow: [
                  if (widget.elevation > 0)
                    BoxShadow(
                      color: Colors.black.withValues(
                        red: 0.1,
                        green: 0.1,
                        blue: 0.1,
                        alpha: 0.1,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Center(
                child: _buildButtonContent(theme),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (widget.isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getTextColor(theme),
          ),
        ),
      );
    }

    final textWidget = Text(
      widget.text,
      style: theme.textTheme.labelLarge?.copyWith(
        color: _getTextColor(theme),
        fontWeight: FontWeight.w600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTheme(
            data: IconThemeData(
              color: _getTextColor(theme),
              size: 20,
            ),
            child: widget.icon!,
          ),
          const SizedBox(width: 8),
          textWidget,
        ],
      );
    }

    return textWidget;
  }
}

/// The visual style of the button
enum RivoButtonVariant {
  /// A filled button with primary color background
  primary,
  
  /// A filled button with secondary color background
  secondary,
  
  /// An outlined button with transparent background
  outline,
  
  /// A text button with no background or border
  text,
  
  /// A filled button with error color background
  danger,
}
