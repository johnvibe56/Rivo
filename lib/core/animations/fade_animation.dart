import 'package:flutter/material.dart';

class FadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double begin;
  final double end;
  final Offset? offset;
  final bool transform;
  final bool scale;
  final bool rotate;
  final double beginScale;
  final double endScale;
  final double beginAngle;
  final double endAngle;
  final bool animateOnMount;
  final bool animateOnRebuild;
  final VoidCallback? onComplete;
  final bool fade;

  const FadeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeInOut,
    this.begin = 0.0,
    this.end = 1.0,
    this.offset,
    this.transform = true,
    this.scale = false,
    this.rotate = false,
    this.beginScale = 0.9,
    this.endScale = 1.0,
    this.beginAngle = 0.0,
    this.endAngle = 0.0,
    this.animateOnMount = true,
    this.animateOnRebuild = false,
    this.onComplete,
    this.fade = true,
  });

  @override
  State<FadeAnimation> createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  late Animation<double> _rotate;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _configureAnimations();

    if (widget.animateOnMount) {
      _startAnimation();
    }
  }

  void _configureAnimations() {
    _opacity = Tween<double>(
      begin: widget.fade ? widget.begin : 1.0,
      end: widget.fade ? widget.end : 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _scale = Tween<double>(
      begin: widget.scale ? widget.beginScale : 1.0,
      end: widget.scale ? widget.endScale : 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _rotate = Tween<double>(
      begin: widget.rotate ? widget.beginAngle : 0.0,
      end: widget.rotate ? widget.endAngle : 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _offset = Tween<Offset>(
      begin: widget.offset ?? Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );
  }

  Future<void> _startAnimation() async {
    if (widget.delay > Duration.zero) {
      await Future<void>.delayed(widget.delay);
    }
    if (mounted) {
      _controller.forward().then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void didUpdateWidget(FadeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animateOnRebuild &&
        (widget.child != oldWidget.child ||
            widget.duration != oldWidget.duration ||
            widget.curve != oldWidget.curve)) {
      _controller.reset();
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget animatedChild = widget.child;

        if (widget.fade) {
          animatedChild = Opacity(
            opacity: _opacity.value,
            child: animatedChild,
          );
        }

        if (widget.transform) {
          animatedChild = Transform.translate(
            offset: _offset.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Transform.rotate(
                angle: _rotate.value,
                child: animatedChild,
              ),
            ),
          );
        }

        return animatedChild;
      },
    );
  }

  void restart() {
    _controller.reset();
    _startAnimation();
  }
}

// Pre-configured animations
class FadeInAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double begin;
  final double end;
  final Offset? offset;
  final bool transform;
  final bool scale;
  final bool rotate;
  final double beginScale;
  final double endScale;
  final double beginAngle;
  final double endAngle;
  final bool animateOnMount;
  final bool animateOnRebuild;
  final VoidCallback? onComplete;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeInOut,
    this.begin = 0.0,
    this.end = 1.0,
    this.offset,
    this.transform = true,
    this.scale = false,
    this.rotate = false,
    this.beginScale = 0.9,
    this.endScale = 1.0,
    this.beginAngle = 0.0,
    this.endAngle = 0.0,
    this.animateOnMount = true,
    this.animateOnRebuild = false,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      key: super.key,
      duration: duration,
      delay: delay,
      begin: begin,
      end: end,
      offset: offset,
      transform: transform,
      scale: scale,
      rotate: rotate,
      beginScale: beginScale,
      endScale: endScale,
      beginAngle: beginAngle,
      endAngle: endAngle,
      animateOnMount: animateOnMount,
      animateOnRebuild: animateOnRebuild,
      onComplete: onComplete,
      child: child,
    );
  }
}

class SlideInAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Offset begin;
  final bool fade;
  final bool scale;
  final double beginScale;
  final double endScale;
  final bool animateOnMount;
  final bool animateOnRebuild;
  final VoidCallback? onComplete;

  const SlideInAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutQuart,
    this.begin = const Offset(0.0, 0.2),
    this.fade = true,
    this.scale = false,
    this.beginScale = 1.0,
    this.endScale = 1.0,
    this.animateOnMount = true,
    this.animateOnRebuild = false,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      key: super.key,
      duration: duration,
      delay: delay,
      offset: begin,
      transform: true,
      scale: true,
      rotate: false,
      beginScale: beginScale,
      endScale: endScale,
      animateOnMount: animateOnMount,
      animateOnRebuild: animateOnRebuild,
      onComplete: onComplete,
      child: child,
    );
  }
}

class ScaleAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double beginScale;
  final double endScale;
  final bool animateOnMount;
  final bool animateOnRebuild;
  final VoidCallback? onComplete;

  const ScaleAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
    this.curve = Curves.easeInOutBack,
    this.beginScale = 0.8,
    this.endScale = 1.0,
    this.animateOnMount = true,
    this.animateOnRebuild = false,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      key: super.key,
      duration: duration,
      delay: delay,
      curve: curve,
      begin: 1.0, // Start fully transparent
      end: 1.0,   // End fully opaque
      transform: true,
      scale: true,
      beginScale: beginScale,
      endScale: endScale,
      animateOnMount: animateOnMount,
      animateOnRebuild: animateOnRebuild,
      onComplete: onComplete,
      child: child,
    );
  }
}
