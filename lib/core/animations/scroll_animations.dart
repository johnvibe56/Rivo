import 'package:flutter/material.dart';

class ScrollAnimation extends StatefulWidget {
  final Widget child;
  final double startPosition;
  final double endPosition;
  final Duration duration;
  final Curve curve;
  final bool fade;
  final bool slide;
  final bool scale;
  final bool rotate;
  final Offset offset;
  final double beginScale;
  final double endScale;
  final double beginRotation;
  final double endRotation;
  final AxisDirection direction;
  final bool animateOnce;
  final bool enabled;
  final ScrollController? scrollController;
  final bool reverse;

  const ScrollAnimation({
    super.key,
    required this.child,
    this.startPosition = 0.0,
    this.endPosition = 1.0,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutQuart,
    this.fade = true,
    this.slide = true,
    this.scale = false,
    this.rotate = false,
    this.offset = const Offset(0.0, 50.0),
    this.beginScale = 0.9,
    this.endScale = 1.0,
    this.beginRotation = 0.0,
    this.endRotation = 0.0,
    this.direction = AxisDirection.down,
    this.animateOnce = true,
    this.enabled = true,
    this.scrollController,
    this.reverse = false,
  })  : assert(startPosition >= 0.0 && startPosition <= 1.0),
        assert(endPosition >= 0.0 && endPosition <= 1.0),
        assert(startPosition < endPosition);

  @override
  State<ScrollAnimation> createState() => _ScrollAnimationState();

  // Common animation presets
  static ScrollAnimation fadeIn({
    Key? key,
    required Widget child,
    double startPosition = 0.2,
    double endPosition = 0.8,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutQuart,
    bool enabled = true,
    ScrollController? scrollController,
    bool reverse = false,
  }) {
    return ScrollAnimation(
      key: key,
      startPosition: startPosition,
      endPosition: endPosition,
      duration: duration,
      curve: curve,
      fade: true,
      slide: false,
      scale: false,
      rotate: false,
      enabled: enabled,
      scrollController: scrollController,
      reverse: reverse,
      child: child,
    );
  }

  static ScrollAnimation slideUp({
    Key? key,
    required Widget child,
    double startPosition = 0.2,
    double endPosition = 0.8,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutQuart,
    Offset offset = const Offset(0.0, 50.0),
    bool enabled = true,
    ScrollController? scrollController,
    bool reverse = false,
  }) {
    return ScrollAnimation(
      key: key,
      startPosition: startPosition,
      endPosition: endPosition,
      duration: duration,
      curve: curve,
      fade: false,
      slide: true,
      scale: false,
      rotate: false,
      offset: offset,
      enabled: enabled,
      scrollController: scrollController,
      reverse: reverse,
      child: child,
    );
  }

  static ScrollAnimation scaleIn({
    Key? key,
    required Widget child,
    double startPosition = 0.2,
    double endPosition = 0.8,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutBack,
    double beginScale = 0.8,
    double endScale = 1.0,
    bool enabled = true,
    ScrollController? scrollController,
    bool reverse = false,
  }) {
    return ScrollAnimation(
      key: key,
      startPosition: startPosition,
      endPosition: endPosition,
      duration: duration,
      curve: curve,
      fade: false,
      slide: false,
      scale: true,
      rotate: false,
      beginScale: beginScale,
      endScale: endScale,
      enabled: enabled,
      scrollController: scrollController,
      reverse: reverse,
      child: child,
    );
  }

  static ScrollAnimation rotateIn({
    Key? key,
    required Widget child,
    double startPosition = 0.2,
    double endPosition = 0.8,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeOutBack,
    double beginRotation = -0.1,
    double endRotation = 0.0,
    bool enabled = true,
    ScrollController? scrollController,
    bool reverse = false,
  }) {
    return ScrollAnimation(
      key: key,
      startPosition: startPosition,
      endPosition: endPosition,
      duration: duration,
      curve: curve,
      fade: false,
      slide: false,
      scale: false,
      rotate: true,
      beginRotation: beginRotation,
      endRotation: endRotation,
      enabled: enabled,
      scrollController: scrollController,
      reverse: reverse,
      child: child,
    );
  }

  // Builder for list of scroll animations
  static List<Widget> buildList({
    required List<Widget> children,
    double startPosition = 0.2,
    double endPosition = 0.8,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeOutQuart,
    bool fade = true,
    bool slide = true,
    bool scale = false,
    bool rotate = false,
    Offset offset = const Offset(0.0, 50.0),
    double beginScale = 0.9,
    double endScale = 1.0,
    double beginRotation = 0.0,
    double endRotation = 0.0,
    AxisDirection direction = AxisDirection.down,
    bool animateOnce = true,
    bool enabled = true,
    ScrollController? scrollController,
    bool reverse = false,
  }) {
    return children.map((child) {
      return ScrollAnimation(
        key: ValueKey(child.key),
        startPosition: startPosition,
        endPosition: endPosition,
        duration: duration,
        curve: curve,
        fade: fade,
        slide: slide,
        scale: scale,
        rotate: rotate,
        offset: offset,
        beginScale: beginScale,
        endScale: endScale,
        beginRotation: beginRotation,
        endRotation: endRotation,
        direction: direction,
        animateOnce: animateOnce,
        enabled: enabled,
        scrollController: scrollController,
        reverse: reverse,
        child: child,
      );
    }).toList();
  }
}

class _ScrollAnimationState extends State<ScrollAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late ScrollController _scrollController;
  bool _isDisposed = false;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 0.0,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _hasAnimated = true;
      }
    });

    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleScroll());
  }

  @override
  void didUpdateWidget(ScrollAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController != oldWidget.scrollController) {
      _scrollController.removeListener(_handleScroll);
      _scrollController = widget.scrollController ?? ScrollController();
      _scrollController.addListener(_handleScroll);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_handleScroll);
    }
    super.dispose();
  }

  void _handleScroll() {
    if (_isDisposed) return;

    final scrollPosition = _scrollController.position;
    // Calculate scroll position for animation
    final scrollProgress = (
      (scrollPosition.pixels - scrollPosition.minScrollExtent) / 
      (scrollPosition.maxScrollExtent - scrollPosition.minScrollExtent).clamp(0.0001, double.infinity)
    ).clamp(0.0, 1.0);
    
    // Calculate animation value based on scroll position
    final baseAnimationValue = _controller.value * scrollProgress;
    
    final widgetTop = (context.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero).dy ?? 0.0;
    final viewportHeight = MediaQuery.of(context).size.height;
    final scrollViewTop = _scrollController.position.pixels;
    
    // Calculate the final animation value based on widget position
    double calculatedValue;
    if (widgetTop + viewportHeight * widget.startPosition < viewportHeight + scrollViewTop) {
      calculatedValue = 1.0;
    } else if (widgetTop + viewportHeight * widget.endPosition < scrollViewTop) {
      calculatedValue = 0.0;
    } else {
      calculatedValue = (widgetTop + viewportHeight * widget.startPosition - scrollViewTop) /
          (viewportHeight * (widget.endPosition - widget.startPosition));
      calculatedValue = (1.0 - calculatedValue).clamp(0.0, 1.0);
    }
    
    // Apply the base animation value to the calculated value
    double animationValue = baseAnimationValue * calculatedValue;

    if (widget.reverse) {
      animationValue = 1.0 - animationValue;
    }

    if (!widget.animateOnce || (widget.animateOnce && !_hasAnimated)) {
      _controller.animateTo(
        animationValue,
        duration: widget.duration,
        curve: widget.curve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget result = widget.child;

        // Apply fade
        if (widget.fade) {
          result = Opacity(
            opacity: _controller.value,
            child: result,
          );
        }


        // Apply slide
        if (widget.slide) {
          Offset offset;
          switch (widget.direction) {
            case AxisDirection.up:
              offset = Offset(0.0, widget.offset.dy * (1.0 - _controller.value));
              break;
            case AxisDirection.down:
              offset = Offset(0.0, -widget.offset.dy * (1.0 - _controller.value));
              break;
            case AxisDirection.left:
              offset = Offset(widget.offset.dx * (1.0 - _controller.value), 0.0);
              break;
            case AxisDirection.right:
              offset = Offset(-widget.offset.dx * (1.0 - _controller.value), 0.0);
              break;
          }
          result = Transform.translate(
            offset: offset,
            child: result,
          );
        }

        // Apply scale
        if (widget.scale) {
          final scale = widget.beginScale + 
                      (_controller.value * (widget.endScale - widget.beginScale));
          result = Transform.scale(
            scale: scale,
            child: result,
          );
        }

        // Apply rotation
        if (widget.rotate) {
          final rotation = widget.beginRotation + 
                         (_controller.value * (widget.endRotation - widget.beginRotation));
          result = Transform.rotate(
            angle: rotation,
            child: result,
          );
        }

        return result;
      },
      child: widget.child,
    );
  }
}

// A widget that wraps a scroll view and provides scroll animations to its children
class AnimatedScrollView extends StatefulWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollPhysics? physics;
  final bool? primary;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final Duration duration;
  final Curve curve;
  final bool fade;
  final bool slide;
  final bool scale;
  final bool rotate;
  final Offset offset;
  final double beginScale;
  final double endScale;
  final double beginRotation;
  final double endRotation;
  final AxisDirection direction;
  final bool animateOnce;
  final double startPosition;
  final double endPosition;
  final bool enabled;

  const AnimatedScrollView({
    super.key,
    required this.children,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.physics,
    this.primary,
    this.shrinkWrap = false,
    this.padding,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutQuart,
    this.fade = true,
    this.slide = true,
    this.scale = false,
    this.rotate = false,
    this.offset = const Offset(0.0, 50.0),
    this.beginScale = 0.9,
    this.endScale = 1.0,
    this.beginRotation = 0.0,
    this.endRotation = 0.0,
    this.direction = AxisDirection.down,
    this.animateOnce = true,
    this.startPosition = 0.2,
    this.endPosition = 0.8,
    this.enabled = true,
  }) : assert(!(startPosition < 0.0 || startPosition > 1.0), 'startPosition must be between 0.0 and 1.0'),
       assert(!(endPosition < 0.0 || endPosition > 1.0), 'endPosition must be between 0.0 and 1.0'),
       assert(startPosition <= endPosition, 'startPosition must be less than or equal to endPosition');

  @override
  State<AnimatedScrollView> createState() => _AnimatedScrollViewState();
}

class _AnimatedScrollViewState extends State<AnimatedScrollView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animatedChildren = widget.children.map((child) {
      return ScrollAnimation(
        startPosition: widget.startPosition,
        endPosition: widget.endPosition,
        duration: widget.duration,
        curve: widget.curve,
        fade: widget.fade,
        slide: widget.slide,
        scale: widget.scale,
        rotate: widget.rotate,
        offset: widget.offset,
        beginScale: widget.beginScale,
        endScale: widget.endScale,
        beginRotation: widget.beginRotation,
        endRotation: widget.endRotation,
        direction: widget.direction,
        animateOnce: widget.animateOnce,
        enabled: widget.enabled,
        scrollController: _scrollController,
        reverse: widget.reverse,
        child: child,
      );
    }).toList();

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      physics: widget.physics,
      primary: widget.primary,
      padding: widget.padding,
      child: widget.scrollDirection == Axis.vertical
          ? Column(children: animatedChildren)
          : Row(children: animatedChildren),
    );
  }
}
