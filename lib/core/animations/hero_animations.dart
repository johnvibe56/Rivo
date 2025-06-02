import 'package:flutter/material.dart';

class RivoHero extends StatelessWidget {
  final String tag;
  final Widget child;
  final bool enabled;
  final Duration flightShuttleBuilderDuration;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;
  final HeroPlaceholderBuilder? placeholderBuilder;
  final bool transitionOnUserGestures;
  // Using dynamic type to avoid type mismatch with CreateRectTween
  final dynamic createRectTween;
  final bool maintainState;
  final bool createRectTweenFromRect;
  final bool createRectTweenFromScene;
  final bool createRectTweenFromPage;
  final bool createRectTweenFromOffset;
  final Offset? offset;
  final Size? size;
  final bool fadeIn;
  final bool fadeOut;
  final Curve curve;
  final Duration duration;

  const RivoHero({
    super.key,
    required this.tag,
    required this.child,
    this.enabled = true,
    this.flightShuttleBuilder,
    this.placeholderBuilder,
    this.transitionOnUserGestures = false,
    this.createRectTween,
    this.maintainState = false,
    this.createRectTweenFromRect = false,
    this.createRectTweenFromScene = false,
    this.createRectTweenFromPage = false,
    this.createRectTweenFromOffset = false,
    this.offset,
    this.size,
    this.fadeIn = true,
    this.fadeOut = true,
    this.curve = Curves.fastOutSlowIn,
    this.duration = const Duration(milliseconds: 300),
    this.flightShuttleBuilderDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Hero(
      tag: tag,
      createRectTween: createRectTween ?? _createRectTween,
      flightShuttleBuilder: flightShuttleBuilder ?? _flightShuttleBuilder,
      placeholderBuilder: placeholderBuilder,
      transitionOnUserGestures: transitionOnUserGestures,
      child: child,
    );
  }

  Widget _flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final Hero hero = flightDirection == HeroFlightDirection.pop
        ? fromHeroContext.widget as Hero
        : toHeroContext.widget as Hero;

    final bool shouldFadeIn = fadeIn && flightDirection == HeroFlightDirection.push;
    final bool shouldFadeOut = fadeOut && flightDirection == HeroFlightDirection.pop;

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double value = animation.value;
        final double opacity = shouldFadeIn
            ? value
            : shouldFadeOut
                ? 1.0 - value
                : 1.0;

        return Opacity(
          opacity: opacity,
          child: hero.child,
        );
      },
    );
  }

  RectTween? _createRectTween(Rect? begin, Rect? end) {
    if (createRectTween != null) {
      // Call the function and cast the result to RectTween?
      final result = createRectTween(begin, end);
      if (result is RectTween) {
        return result;
      }
      return null;
    }

    if (createRectTweenFromRect && begin != null && end != null) {
      return _RivoRectTween(begin: begin, end: end, curve: curve);
    }
    
    return RectTween(begin: begin, end: end);
  }

  // Pre-configured hero animations
  static Widget fade({
    required String tag,
    required Widget child,
    bool enabled = true,
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return RivoHero(
      tag: tag,
      enabled: enabled,
      curve: curve,
      duration: duration,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        final double opacity = animation.drive(Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve))).value;

        return Opacity(
          opacity: opacity,
          child: toHeroContext.widget is Hero
              ? (toHeroContext.widget as Hero).child
              : const SizedBox(),
        );
      },
      child: child,
    );
  }

  static Widget scale({
    required String tag,
    required Widget child,
    bool enabled = true,
    double beginScale = 0.8,
    double endScale = 1.0,
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return RivoHero(
      tag: tag,
      enabled: enabled,
      curve: curve,
      duration: duration,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        final double scale = Tween<double>(
          begin: beginScale,
          end: endScale,
        ).evaluate(animation);

        return Transform.scale(
          scale: scale,
          child: toHeroContext.widget is Hero
              ? (toHeroContext.widget as Hero).child
              : const SizedBox(),
        );
      },
      child: child,
    );
  }

  static Widget slide({
    required String tag,
    required Widget child,
    required Offset beginOffset,
    bool enabled = true,
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return RivoHero(
      tag: tag,
      enabled: enabled,
      curve: curve,
      duration: duration,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        final Offset offset = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).evaluate(animation);

        return Transform.translate(
          offset: offset,
          child: toHeroContext.widget is Hero
              ? (toHeroContext.widget as Hero).child
              : const SizedBox(),
        );
      },
      child: child,
    );
  }

  static Widget rotation({
    required String tag,
    required Widget child,
    bool enabled = true,
    double beginAngle = -0.1,
    double endAngle = 0.0,
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return RivoHero(
      tag: tag,
      enabled: enabled,
      curve: curve,
      duration: duration,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        final double angle = Tween<double>(
          begin: beginAngle,
          end: endAngle,
        ).evaluate(animation);

        return Transform.rotate(
          angle: angle,
          child: toHeroContext.widget is Hero
              ? (toHeroContext.widget as Hero).child
              : const SizedBox(),
        );
      },
      child: child,
    );
  }

  // Combined animations
  static Widget fadeScale({
    required String tag,
    required Widget child,
    bool enabled = true,
    double beginScale = 0.8,
    double endScale = 1.0,
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return RivoHero(
      tag: tag,
      enabled: enabled,
      curve: curve,
      duration: duration,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        final double opacity = animation.drive(Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve))).value;

        final double scale = Tween<double>(
          begin: beginScale,
          end: endScale,
        ).evaluate(animation);

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: toHeroContext.widget is Hero
                ? (toHeroContext.widget as Hero).child
                : const SizedBox(),
          ),
        );
      },
      child: child,
    );
  }

  static Widget fadeSlide({
    required String tag,
    required Widget child,
    required Offset beginOffset,
    bool enabled = true,
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return RivoHero(
      tag: tag,
      enabled: enabled,
      curve: curve,
      duration: duration,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        final double opacity = animation.drive(Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve))).value;

        final Offset offset = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).evaluate(animation);

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: offset,
            child: toHeroContext.widget is Hero
                ? (toHeroContext.widget as Hero).child
                : const SizedBox(),
          ),
        );
      },
      child: child,
    );
  }
}

class _RivoRectTween extends RectTween {
  _RivoRectTween({
    required super.begin,
    required super.end,
    this.curve = Curves.linear,
  });

  final Curve curve;

  @override
  Rect? lerp(double t) {
    final curvedT = curve.transform(t);
    return Rect.lerp(begin, end, curvedT);
  }
}
