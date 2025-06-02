import 'package:flutter/material.dart';

class RivoPageTransitionsBuilder extends PageTransitionsBuilder {
  final bool fade;
  final bool slide;
  final bool scale;
  final Curve curve;
  final Duration duration;
  final Offset beginOffset;
  final Offset endOffset;
  final double beginScale;
  final double endScale;
  final double beginRotation;
  final double endRotation;

  const RivoPageTransitionsBuilder({
    this.fade = true,
    this.slide = true,
    this.scale = false,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 300),
    this.beginOffset = const Offset(0.0, 0.02),
    this.endOffset = Offset.zero,
    this.beginScale = 0.98,
    this.endScale = 1.0,
    this.beginRotation = 0.0,
    this.endRotation = 0.0,
  });

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curveTween = CurveTween(curve: curve);
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curveTween.curve,
      reverseCurve: curveTween.curve.flipped,
    );

    // Fade animation
    Widget result = fade
        ? FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
            child: child,
          )
        : child;

    // Slide animation
    if (slide) {
      final offsetTween = Tween<Offset>(
        begin: beginOffset,
        end: endOffset,
      );
      result = SlideTransition(
        position: offsetTween.animate(curvedAnimation),
        child: result,
      );
    }

    // Scale animation
    if (scale) {
      final scaleTween = Tween<double>(
        begin: beginScale,
        end: endScale,
      );
      result = ScaleTransition(
        scale: scaleTween.animate(curvedAnimation),
        child: result,
      );
    }

    return result;
  }
}

// Pre-configured page transitions
class RivoPageTransitions {
  // Standard fade transition
  static const PageTransitionsTheme fade = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: RivoPageTransitionsBuilder(
        fade: true,
        slide: false,
        scale: false,
      ),
      TargetPlatform.iOS: RivoPageTransitionsBuilder(
        fade: true,
        slide: false,
        scale: false,
      ),
    },
  );

  // Slide up transition
  static const PageTransitionsTheme slideUp = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: RivoPageTransitionsBuilder(
        fade: true,
        slide: true,
        scale: false,
        beginOffset: Offset(0.0, 1.0),
      ),
      TargetPlatform.iOS: RivoPageTransitionsBuilder(
        fade: true,
        slide: true,
        scale: false,
        beginOffset: Offset(0.0, 1.0),
      ),
    },
  );

  // Slide right transition
  static const PageTransitionsTheme slideRight = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: RivoPageTransitionsBuilder(
        fade: true,
        slide: true,
        scale: false,
        beginOffset: Offset(1.0, 0.0),
      ),
      TargetPlatform.iOS: RivoPageTransitionsBuilder(
        fade: true,
        slide: true,
        scale: false,
        beginOffset: Offset(1.0, 0.0),
      ),
    },
  );

  // Scale transition
  static const PageTransitionsTheme scale = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: RivoPageTransitionsBuilder(
        fade: true,
        slide: false,
        scale: true,
        beginScale: 0.9,
        endScale: 1.0,
      ),
      TargetPlatform.iOS: RivoPageTransitionsBuilder(
        fade: true,
        slide: false,
        scale: true,
        beginScale: 0.9,
        endScale: 1.0,
      ),
    },
  );

  // Modal transition (slide up with slight scale)
  static const PageTransitionsTheme modal = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: RivoPageTransitionsBuilder(
        fade: true,
        slide: true,
        scale: true,
        beginOffset: Offset(0.0, 0.02),
        beginScale: 0.98,
        endScale: 1.0,
      ),
      TargetPlatform.iOS: RivoPageTransitionsBuilder(
        fade: true,
        slide: true,
        scale: true,
        beginOffset: Offset(0.0, 0.02),
        beginScale: 0.98,
        endScale: 1.0,
      ),
    },
  );

  // Custom transition
  static PageTransitionsTheme custom({
    bool fade = true,
    bool slide = false,
    bool scale = false,
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 300),
    Offset beginOffset = const Offset(0.0, 0.02),
    Offset endOffset = Offset.zero,
    double beginScale = 0.98,
    double endScale = 1.0,
  }) {
    return PageTransitionsTheme(
      builders: {
        TargetPlatform.android: RivoPageTransitionsBuilder(
          fade: fade,
          slide: slide,
          scale: scale,
          curve: curve,
          duration: duration,
          beginOffset: beginOffset,
          endOffset: endOffset,
          beginScale: beginScale,
          endScale: endScale,
        ),
        TargetPlatform.iOS: RivoPageTransitionsBuilder(
          fade: fade,
          slide: slide,
          scale: scale,
          curve: curve,
          duration: duration,
          beginOffset: beginOffset,
          endOffset: endOffset,
          beginScale: beginScale,
          endScale: endScale,
        ),
      },
    );
  }
}

// Helper extension for applying transitions to MaterialPageRoute
extension RivoPageRoute<T> on PageRouteBuilder<T> {
  static PageRouteBuilder<T> fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page is T ? page as T : page as dynamic,
      transitionsBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  static PageRouteBuilder<T> slide<T>(Widget page, {Offset begin = const Offset(1.0, 0.0)}) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page is T ? page as T : page as dynamic,
      transitionsBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: Curves.easeInOut),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static PageRouteBuilder<T> scale<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page is T ? page as T : page as dynamic,
      transitionsBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: child,
        );
      },
    );
  }

  static PageRouteBuilder<T> rotation<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page is T ? page as T : page as dynamic,
      transitionDuration: const Duration(milliseconds: 700),
      transitionsBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
          ),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.5,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              ),
            ),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
