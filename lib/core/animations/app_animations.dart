import 'package:flutter/material.dart';

/// Centralized animation configurations for the RIVO app
class AppAnimations {
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Animation curves
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.easeOutBack;
  static const Curve elasticCurve = Curves.elasticOut;

  // Pre-configured animations
  static Widget fadeIn({
    Key? key,
    required Widget child,
    Duration? duration,
    Curve? curve,
    double? delay,
    Offset? offset,
    bool transformHitTests = true,
  }) {
    // Using a simple fade transition as a fallback
    return TweenAnimationBuilder<double>(
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInOut,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
    );
  }

  static Widget slideIn({
    Key? key,
    required Widget child,
    Duration? duration,
    Curve? curve,
    double? delay,
    AxisDirection direction = AxisDirection.down,
    Offset? offset,
    bool transformHitTests = true,
  }) {
    // Using a simple slide transition as a fallback
    final offsetValue = offset ?? _getOffsetForDirection(direction);
    return TweenAnimationBuilder<Offset>(
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInOut,
      tween: Tween<Offset>(
        begin: offsetValue,
        end: Offset.zero,
      ),
      child: child,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
    );
  }

  static Offset _getOffsetForDirection(AxisDirection direction) {
    switch (direction) {
      case AxisDirection.up:
        return const Offset(0, 1);
      case AxisDirection.down:
        return const Offset(0, -1);
      case AxisDirection.left:
        return const Offset(1, 0);
      case AxisDirection.right:
        return const Offset(-1, 0);
    }
  }

  static Widget scaleIn({
    Key? key,
    required Widget child,
    Duration? duration,
    Curve? curve,
    double? delay,
    double? beginScale,
    double? endScale,
    bool transformHitTests = true,
  }) {
    // Using a simple scale transition as a fallback
    return TweenAnimationBuilder<double>(
      duration: duration ?? const Duration(milliseconds: 300),
      curve: curve ?? Curves.easeInOut,
      tween: Tween<double>(
        begin: beginScale ?? 0.8,
        end: endScale ?? 1.0,
      ),
      child: child,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
    );
  }

  static Widget button({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    bool enabled = true,
    double scale = 0.96,
    bool enableHapticFeedback = true,
  }) {
    return GestureDetector(
      key: key,
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 150),
        tween: Tween<double>(begin: 1.0, end: enabled ? 1.0 : 0.5),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: child,
          );
        },
        child: child,
      ),
    );
  }

  static Widget card({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 150),
        tween: Tween<double>(begin: 1.0, end: enabled ? 1.0 : 0.5),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: child,
          );
        },
        child: child,
      ),
    );
  }

  static Widget staggeredList({
    required List<Widget> children,
    Duration? duration,
    Curve? curve,
    double? startPosition,
    double? endPosition,
    bool fade = true,
    bool slide = true,
    bool scale = false,
    bool rotate = false,
    Offset? offset,
    double? beginScale,
    double? endScale,
    double? beginRotation,
    double? endRotation,
    AxisDirection direction = AxisDirection.down,
    bool animateOnce = true,
  }) {
    // Simple fallback implementation without staggered animation
    return Column(
      children: children.map((child) {
        Widget result = child;
        
        if (fade) {
          result = TweenAnimationBuilder<double>(
            duration: duration ?? const Duration(milliseconds: 300),
            curve: curve ?? Curves.easeInOut,
            tween: Tween<double>(begin: 0.0, end: 1.0),
            child: result,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: child,
              );
            },
          );
        }
        
        if (slide) {
          final offsetValue = offset ?? _getOffsetForDirection(direction);
          result = TweenAnimationBuilder<Offset>(
            duration: duration ?? const Duration(milliseconds: 300),
            curve: curve ?? Curves.easeInOut,
            tween: Tween<Offset>(
              begin: offsetValue,
              end: Offset.zero,
            ),
            child: result,
            builder: (context, value, child) {
              return Transform.translate(
                offset: value,
                child: child,
              );
            },
          );
        }
        
        return result;
      }).toList(),
    );
  }

  static PageRoute<T> fadeRoute<T>({
    required Widget page,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    Curve? curve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      transitionDuration: transitionDuration ?? mediumAnimation,
      reverseTransitionDuration: reverseTransitionDuration ?? mediumAnimation,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  static PageRoute<T> slideRoute<T>({
    required Widget page,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    Curve? curve,
    AxisDirection direction = AxisDirection.right,
  }) {
    final offset = direction == AxisDirection.right
        ? const Offset(1.0, 0.0)
        : direction == AxisDirection.left
            ? const Offset(-1.0, 0.0)
            : direction == AxisDirection.down
                ? const Offset(0.0, 1.0)
                : const Offset(0.0, -1.0);
                
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      transitionDuration: transitionDuration ?? mediumAnimation,
      reverseTransitionDuration: reverseTransitionDuration ?? mediumAnimation,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: offset,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: curve ?? Curves.easeInOut,
          )),
          child: child,
        );
      },
    );
  }

  static PageRoute<T> scaleRoute<T>({
    required Widget page,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    Curve? curve,
    double beginScale = 0.8,
    double endScale = 1.0,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      transitionDuration: transitionDuration ?? mediumAnimation,
      reverseTransitionDuration: reverseTransitionDuration ?? mediumAnimation,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: beginScale,
            end: endScale,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: curve ?? Curves.easeInOut,
          )),
          child: child,
        );
      },
    );
  }

  static Widget heroTransition({
    required String tag,
    required Widget child,
    bool enabled = true,
    HeroFlightShuttleBuilder? flightShuttleBuilder,
    HeroPlaceholderBuilder? placeholderBuilder,
    bool transitionOnUserGestures = false,
    bool fade = true,
    bool slide = true,
    bool scale = false,
    bool rotate = false,
    Offset? offset,
    double? beginScale,
    double? endScale,
    double? beginRotation,
    double? endRotation,
  }) {
    if (!enabled) return child;

    return Hero(
      tag: tag,
      flightShuttleBuilder: flightShuttleBuilder,
      placeholderBuilder: placeholderBuilder,
      transitionOnUserGestures: transitionOnUserGestures,
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}
