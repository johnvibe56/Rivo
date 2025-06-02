import 'package:flutter/material.dart';

class GestureAnimation extends StatefulWidget {
  final Widget child;
  final double scale;
  final double pressedOpacity;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onTapDown;
  final VoidCallback? onTapUp;
  final VoidCallback? onTapCancel;
  final bool enabled;
  final bool enableHapticFeedback;
  final bool enableFeedback;
  final HitTestBehavior? behavior;
  final bool excludeFromSemantics;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool excludeFromSemanticsForPointer;
  final bool forcePressEnabled;
  final bool isSelected;
  final bool isDisabled;
  final bool isFocusable;
  final bool enableScaleAnimation;
  final bool enableFadeAnimation;
  final bool enableRotationAnimation;
  final double rotationAngle;
  final Offset? tapPosition;
  final bool trackTapPosition;
  final AlignmentGeometry alignment;
  final bool transformHitTests;
  final FilterQuality? filterQuality;

  const GestureAnimation({
    super.key,
    required this.child,
    this.scale = 0.98,
    this.pressedOpacity = 0.7,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.easeInOut,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.enabled = true,
    this.enableHapticFeedback = true,
    this.enableFeedback = true,
    this.behavior,
    this.excludeFromSemantics = false,
    this.focusNode,
    this.autofocus = false,
    this.excludeFromSemanticsForPointer = false,
    this.forcePressEnabled = false,
    this.isSelected = false,
    this.isDisabled = false,
    this.isFocusable = true,
    this.enableScaleAnimation = true,
    this.enableFadeAnimation = true,
    this.enableRotationAnimation = false,
    this.rotationAngle = 0.02,
    this.tapPosition,
    this.trackTapPosition = false,
    this.alignment = Alignment.center,
    this.transformHitTests = true,
    this.filterQuality,
  });

  @override
  GestureAnimationState createState() => GestureAnimationState();

  // Common animation presets
  static GestureAnimation button({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    bool enabled = true,
    double scale = 0.96,
  }) {
    return GestureAnimation(
      key: key,
      onTap: onTap,
      enabled: enabled,
      scale: scale,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      enableHapticFeedback: true,
      enableFeedback: true,
      child: child,
    );
  }

  static GestureAnimation card({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return GestureAnimation(
      key: key,
      onTap: onTap,
      enabled: enabled,
      scale: 0.98,
      pressedOpacity: 0.9,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutQuart,
      child: child,
    );
  }

  // Renamed to avoid conflict with the instance property
  static GestureAnimation scaleAnimation({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    double scale = 0.95,
    bool enabled = true,
  }) {
    return GestureAnimation(
      key: key,
      onTap: onTap,
      enabled: enabled,
      scale: scale,
      enableFadeAnimation: false,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: child,
    );
  }

  static GestureAnimation fade({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    double pressedOpacity = 0.7,
    bool enabled = true,
  }) {
    return GestureAnimation(
      key: key,
      onTap: onTap,
      enabled: enabled,
      scale: 1.0,
      pressedOpacity: pressedOpacity,
      enableScaleAnimation: false,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: child,
    );
  }

  static GestureAnimation rotate({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    double rotationAngle = 0.03,
    bool enabled = true,
  }) {
    return GestureAnimation(
      key: key,
      onTap: onTap,
      enabled: enabled,
      enableRotationAnimation: true,
      rotationAngle: rotationAngle,
      enableScaleAnimation: false,
      enableFadeAnimation: false,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutBack,
      child: child,
    );
  }
}

class GestureAnimationState extends State<GestureAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _rotationAnimation;

  bool _isPressed = false;
  // Removed unused fields

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1.0, // Start at normal state
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: widget.rotationAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    setState(() {
      _isPressed = true;
    });
    _controller.reverse();
  }

  // Hover handling removed as it's not used

  void _handleTapUp([TapUpDetails? details]) {
    if (!widget.enabled || widget.isDisabled) return;
    
    setState(() {
      _isPressed = false;
    });
    
    _controller.reverse();
    widget.onTapUp?.call();
  }

  void _handleTapCancel() {
    if (!widget.enabled || widget.isDisabled) return;
    
    setState(() {
      _isPressed = false;
    });
    
    _controller.reverse();
    widget.onTapCancel?.call();
  }

  void _handleTap() {
    if (!widget.enabled || widget.isDisabled) return;
    
    if (widget.enableHapticFeedback) {
      // HapticFeedback.lightImpact();
    }
    
    widget.onTap?.call();
  }

  void _handleLongPress() {
    if (!widget.enabled || widget.isDisabled) return;
    
    if (widget.enableHapticFeedback) {
      // HapticFeedback.mediumImpact();
    }
    
    widget.onLongPress?.call();
  }

  void _handleDoubleTap() {
    if (!widget.enabled || widget.isDisabled) return;
    
    if (widget.enableHapticFeedback) {
      // HapticFeedback.heavyImpact();
    }
    
    widget.onDoubleTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || widget.isDisabled) {
      return IgnorePointer(
        ignoring: true,
        child: Opacity(
          opacity: 0.5,
          child: widget.child,
        ),
      );
    }

    final Widget animatedChild = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget result = widget.child;

        // Apply scale animation
        if (widget.enableScaleAnimation) {
          result = Transform.scale(
            scale: _scaleAnimation.value,
            child: result,
          );
        }


        // Apply rotation animation
        if (widget.enableRotationAnimation) {
          result = Transform.rotate(
            angle: _rotationAnimation.value * (_isPressed ? 1.0 : -1.0),
            alignment: widget.alignment,
            child: result,
          );
        }

        // Apply opacity animation
        if (widget.enableFadeAnimation) {
          result = Opacity(
            opacity: _opacityAnimation.value,
            child: result,
          );
        }

        return result;
      },
      child: widget.child,
    );

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      onLongPress: widget.onLongPress != null ? _handleLongPress : null,
      onDoubleTap: widget.onDoubleTap != null ? _handleDoubleTap : null,
      behavior: widget.behavior,
      excludeFromSemantics: widget.excludeFromSemantics,
      child: animatedChild,
    );
  }
}
