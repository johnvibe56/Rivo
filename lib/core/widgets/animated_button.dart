import 'package:flutter/material.dart';

enum ButtonVariant {
  primary,
  secondary,
  outline,
  text,
  danger,
}

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final ButtonVariant variant;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final double scale;
  final bool enableHapticFeedback;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.variant = ButtonVariant.primary,
    this.width,
    this.height = 48.0,
    this.borderRadius = 12.0,
    this.padding,
    this.icon,
    this.scale = 0.98,
    this.enableHapticFeedback = true,
    this.animationDuration = const Duration(milliseconds: 150),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isTapped = false;

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
    
    setState(() => _isTapped = true);
    await _controller.forward();
    
    // Add haptic feedback if enabled
    if (widget.enableHapticFeedback) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> _handleTapUp(TapUpDetails details) async {
    if (widget.isLoading || widget.isDisabled) return;
    
    await _controller.reverse();
    setState(() => _isTapped = false);
    
    // Trigger the onPressed callback after the animation completes
    if (mounted) {
      widget.onPressed();
    }
  }

  Future<void> _handleTapCancel() async {
    if (widget.isLoading || widget.isDisabled) return;
    
    await _controller.reverse();
    if (mounted) {
      setState(() => _isTapped = false);
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (widget.isDisabled) {
      // ignore: deprecated_member_use
      return theme.disabledColor.withOpacity(0.5);
    }
    
    switch (widget.variant) {
      case ButtonVariant.primary:
        return theme.primaryColor;
      case ButtonVariant.secondary:
        return theme.colorScheme.secondary;
      case ButtonVariant.outline:
        return Colors.transparent;
      case ButtonVariant.text:
        return Colors.transparent;
      case ButtonVariant.danger:
        return theme.colorScheme.error;
    }
  }

  Color _getTextColor(ThemeData theme) {
    if (widget.isDisabled) {
      return theme.disabledColor;
    }
    
    switch (widget.variant) {
      case ButtonVariant.primary:
        return theme.primaryTextTheme.labelLarge?.color ?? Colors.white;
      case ButtonVariant.secondary:
        return theme.colorScheme.onSecondary;
      case ButtonVariant.outline:
        return theme.primaryColor;
      case ButtonVariant.text:
        return theme.primaryColor;
      case ButtonVariant.danger:
        return theme.colorScheme.onError;
    }
  }

  BoxBorder? _getBorder(ThemeData theme) {
    if (widget.variant != ButtonVariant.outline) return null;
    
    return Border.all(
      color: widget.isDisabled 
          ? theme.disabledColor 
          : theme.primaryColor,
      width: 1.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: _getBackgroundColor(theme),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: _getBorder(theme),
                boxShadow: widget.variant == ButtonVariant.text || widget.variant == ButtonVariant.outline
                    ? null
                    : [
                        if (!_isTapped && !widget.isDisabled && !widget.isLoading)
                          BoxShadow(
                            color: (widget.variant == ButtonVariant.primary
                                        ? theme.primaryColor
                                        : theme.colorScheme.secondary)
                                    .withOpacity(0.4), // ignore: deprecated_member_use
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isLoading || widget.isDisabled ? null : widget.onPressed,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  // ignore: deprecated_member_use
                  splashColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Center(
                      child: _buildChild(theme),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChild(ThemeData theme) {
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          widget.icon!,
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: theme.textTheme.labelLarge?.copyWith(
            color: _getTextColor(theme),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
