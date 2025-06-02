import 'package:flutter/material.dart';

class StaggeredAnimation extends StatelessWidget {
  final int position;
  final int itemCount;
  final Widget child;
  final Duration duration;
  final Duration startDelay;
  final Curve curve;
  final bool fade;
  final bool slide;
  final bool scale;
  final Offset offset;
  final double beginScale;
  final double endScale;
  final AxisDirection direction;
  final bool fadeFirst;
  final bool animateOnRebuild;
  final bool enabled;

  const StaggeredAnimation({
    super.key,
    required this.position,
    required this.itemCount,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.startDelay = Duration.zero,
    this.curve = Curves.easeInOut,
    this.fade = true,
    this.slide = true,
    this.scale = false,
    this.offset = const Offset(0.0, 0.1),
    this.beginScale = 0.95,
    this.endScale = 1.0,
    this.direction = AxisDirection.down,
    this.fadeFirst = true,
    this.animateOnRebuild = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration + (startDelay * (position + 1)),
      curve: Interval(
        position / itemCount,
        1.0,
        curve: curve,
      ),
      builder: (context, value, child) {
        Widget animatedChild = child!;

        // Apply fade animation
        if (fade && fadeFirst) {
          animatedChild = Opacity(
            opacity: value,
            child: animatedChild,
          );
        }

        // Apply slide animation
        if (slide) {
          Offset beginOffset;
          switch (direction) {
            case AxisDirection.up:
              beginOffset = Offset(0.0, offset.dy);
              break;
            case AxisDirection.down:
              beginOffset = Offset(0.0, -offset.dy);
              break;
            case AxisDirection.left:
              beginOffset = Offset(offset.dx, 0.0);
              break;
            case AxisDirection.right:
              beginOffset = Offset(-offset.dx, 0.0);
              break;
          }
          final offsetTween = Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          );
          animatedChild = Transform.translate(
            offset: offsetTween.transform(value),
            child: animatedChild,
          );
        }

        // Apply scale animation
        if (scale) {
          final scaleTween = Tween<double>(
            begin: beginScale,
            end: endScale,
          );
          animatedChild = Transform.scale(
            scale: scaleTween.transform(value),
            child: animatedChild,
          );
        }


        // Apply fade animation (after other transforms)
        if (fade && !fadeFirst) {
          animatedChild = Opacity(
            opacity: value,
            child: animatedChild,
          );
        }

        return animatedChild;
      },
      child: child,
    );
  }

  // Builder for ListView/GridView items
  static Widget buildList({
    required int index,
    required int itemCount,
    required Widget Function(int index) builder,
    Duration duration = const Duration(milliseconds: 300),
    Duration startDelay = const Duration(milliseconds: 50),
    Curve curve = Curves.easeInOut,
    bool fade = true,
    bool slide = true,
    bool scale = false,
    Offset offset = const Offset(0.0, 0.1),
    double beginScale = 0.95,
    double endScale = 1.0,
    AxisDirection direction = AxisDirection.down,
    bool fadeFirst = true,
    bool enabled = true,
  }) {
    return StaggeredAnimation(
      position: index,
      itemCount: itemCount,
      duration: duration,
      startDelay: startDelay,
      curve: curve,
      fade: fade,
      slide: slide,
      scale: scale,
      offset: offset,
      beginScale: beginScale,
      endScale: endScale,
      direction: direction,
      fadeFirst: fadeFirst,
      enabled: enabled,
      child: builder(index),
    );
  }

  // Staggered column
  static Widget column({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    Duration duration = const Duration(milliseconds: 300),
    Duration startDelay = const Duration(milliseconds: 50),
    Curve curve = Curves.easeInOut,
    bool fade = true,
    bool slide = true,
    bool scale = false,
    Offset offset = const Offset(0.0, 0.1),
    double beginScale = 0.95,
    double endScale = 1.0,
    AxisDirection direction = AxisDirection.down,
    bool fadeFirst = true,
    bool enabled = true,
  }) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: List.generate(
        children.length,
        (index) => StaggeredAnimation(
          position: index,
          itemCount: children.length,
          duration: duration,
          startDelay: startDelay,
          curve: curve,
          fade: fade,
          slide: slide,
          scale: scale,
          offset: offset,
          beginScale: beginScale,
          endScale: endScale,
          direction: direction,
          fadeFirst: fadeFirst,
          enabled: enabled,
          child: children[index],
        ),
      ),
    );
  }

  // Staggered row
  static Widget row({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    Duration duration = const Duration(milliseconds: 300),
    Duration startDelay = const Duration(milliseconds: 50),
    Curve curve = Curves.easeInOut,
    bool fade = true,
    bool slide = true,
    bool scale = false,
    Offset offset = const Offset(0.1, 0.0),
    double beginScale = 0.95,
    double endScale = 1.0,
    AxisDirection direction = AxisDirection.right,
    bool fadeFirst = true,
    bool enabled = true,
  }) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: List.generate(
        children.length,
        (index) => StaggeredAnimation(
          position: index,
          itemCount: children.length,
          duration: duration,
          startDelay: startDelay,
          curve: curve,
          fade: fade,
          slide: slide,
          scale: scale,
          offset: offset,
          beginScale: beginScale,
          endScale: endScale,
          direction: direction,
          fadeFirst: fadeFirst,
          enabled: enabled,
          child: children[index],
        ),
      ),
    );
  }

  // Staggered grid
  static Widget grid({
    required int itemCount,
    required Widget Function(int index) itemBuilder,
    required SliverGridDelegate gridDelegate,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double? cacheExtent,
    int? semanticChildCount,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    String? restorationId,
    Clip clipBehavior = Clip.hardEdge,
    Duration duration = const Duration(milliseconds: 300),
    Duration startDelay = const Duration(milliseconds: 50),
    Curve curve = Curves.easeInOut,
    bool fade = true,
    bool slide = true,
    bool scale = false,
    Offset offset = const Offset(0.0, 0.1),
    double beginScale = 0.95,
    double endScale = 1.0,
    AxisDirection direction = AxisDirection.down,
    bool fadeFirst = true,
    bool enabled = true,
  }) {
    return GridView.builder(
      itemCount: itemCount,
      gridDelegate: gridDelegate,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      cacheExtent: cacheExtent,
      semanticChildCount: semanticChildCount,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      itemBuilder: (context, index) {
        return StaggeredAnimation(
          position: index,
          itemCount: itemCount,
          duration: duration,
          startDelay: startDelay,
          curve: curve,
          fade: fade,
          slide: slide,
          scale: scale,
          offset: offset,
          beginScale: beginScale,
          endScale: endScale,
          direction: direction,
          fadeFirst: fadeFirst,
          enabled: enabled,
          child: itemBuilder(index),
        );
      },
    );
  }
}
