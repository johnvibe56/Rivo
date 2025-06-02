import 'package:flutter/material.dart';

class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;
  final bool withBackground;
  final double backgroundOpacity;
  final String? message;
  final TextStyle? messageStyle;
  final MainAxisSize mainAxisSize;
  final double spacing;

  const AppLoadingIndicator({
    super.key,
    this.size = 24.0,
    this.strokeWidth = 2.0,
    this.color,
    this.withBackground = false,
    this.backgroundOpacity = 0.2,
    this.message,
    this.messageStyle,
    this.mainAxisSize = MainAxisSize.min,
    this.spacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    
    Widget indicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );

    if (withBackground) {
      indicator = Container(
        width: size * 1.5,
        height: size * 1.5,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: effectiveColor.withOpacity(backgroundOpacity),
          shape: BoxShape.circle,
        ),
        child: indicator,
      );
    }

    if (message != null) {
      return Column(
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          indicator,
          SizedBox(height: spacing),
          Text(
            message!,
            style: messageStyle ?? theme.textTheme.bodyMedium?.copyWith(
              // ignore: deprecated_member_use
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return indicator;
  }

  // Full screen loading indicator with a semi-transparent background
  static Widget fullScreen({
    String? message,
    Color? backgroundColor,
    Color? indicatorColor,
  }) {
    return Stack(
      children: [
        ModalBarrier(
          // ignore: deprecated_member_use
          color: (backgroundColor ?? Colors.black).withOpacity(0.5),
          dismissible: false,
        ),
        Center(
          child: AppLoadingIndicator(
            size: 48.0,
            strokeWidth: 3.0,
            color: indicatorColor,
            withBackground: true,
            message: message,
            messageStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Small inline loading indicator
  static Widget small({Color? color}) {
    return AppLoadingIndicator(
      size: 16.0,
      strokeWidth: 1.5,
      color: color,
    );
  }

  // Medium sized loading indicator
  static Widget medium({Color? color}) {
    return AppLoadingIndicator(
      size: 24.0,
      strokeWidth: 2.0,
      color: color,
    );
  }

  // Large loading indicator
  static Widget large({Color? color}) {
    return AppLoadingIndicator(
      size: 36.0,
      strokeWidth: 3.0,
      color: color,
    );
  }

  // Button loading indicator
  static Widget button({Color? color}) {
    return AppLoadingIndicator(
      size: 20.0,
      strokeWidth: 2.0,
      color: color,
    );
  }
}
