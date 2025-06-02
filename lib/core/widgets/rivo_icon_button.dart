import 'package:flutter/material.dart';

import 'rivo_button.dart';

/// A customizable icon button with animation and multiple style variants
class RivoIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? backgroundColor;
  final double elevation;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isDisabled;
  final bool enableHapticFeedback;
  final RivoButtonVariant variant;

  /// Creates a Rivo icon button with the given properties
  const RivoIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 40.0,
    this.iconSize = 24.0,
    this.color,
    this.backgroundColor,
    this.elevation = 0,
    this.borderRadius = 12.0,
    this.padding,
    this.isDisabled = false,
    this.enableHapticFeedback = true,
    this.variant = RivoButtonVariant.primary,
  });

  /// Creates a filled icon button
  factory RivoIconButton.filled({
    Key? key,
    required IconData icon,
    required VoidCallback? onPressed,
    double size = 40.0,
    double iconSize = 24.0,
    Color? color,
    Color? backgroundColor,
    double elevation = 0,
    double borderRadius = 12.0,
    EdgeInsetsGeometry? padding,
    bool isDisabled = false,
    bool enableHapticFeedback = true,
  }) {
    return RivoIconButton(
      key: key,
      icon: icon,
      onPressed: onPressed,
      size: size,
      iconSize: iconSize,
      color: color,
      backgroundColor: backgroundColor,
      elevation: elevation,
      borderRadius: borderRadius,
      padding: padding,
      isDisabled: isDisabled,
      enableHapticFeedback: enableHapticFeedback,
      variant: RivoButtonVariant.primary,
    );
  }

  /// Creates an outlined icon button
  factory RivoIconButton.outlined({
    Key? key,
    required IconData icon,
    required VoidCallback? onPressed,
    double size = 40.0,
    double iconSize = 24.0,
    Color? color,
    double elevation = 0,
    double borderRadius = 12.0,
    EdgeInsetsGeometry? padding,
    bool isDisabled = false,
    bool enableHapticFeedback = true,
  }) {
    return RivoIconButton(
      key: key,
      icon: icon,
      onPressed: onPressed,
      size: size,
      iconSize: iconSize,
      color: color,
      elevation: elevation,
      borderRadius: borderRadius,
      padding: padding,
      isDisabled: isDisabled,
      enableHapticFeedback: enableHapticFeedback,
      variant: RivoButtonVariant.outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? _getIconColor(theme);
    final effectiveBackgroundColor = _getBackgroundColor(theme);
    final border = _getBorderSide(theme);

    return Material(
      color: effectiveBackgroundColor,
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: size,
          height: size,
          padding: padding ?? const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: border == null ? null : Border.fromBorderSide(border),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: isDisabled ? theme.disabledColor : effectiveColor,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (isDisabled) {
      return theme.disabledColor.withValues(
        red: 0.5,
        green: 0.5,
        blue: 0.5,
        alpha: 0.1,
      );
    }
    
    if (backgroundColor != null) {
      return backgroundColor!;
    }
    
    switch (variant) {
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

  Color _getIconColor(ThemeData theme) {
    if (isDisabled) {
      return theme.disabledColor;
    }

    switch (variant) {
      case RivoButtonVariant.primary:
        return Colors.white;
      case RivoButtonVariant.secondary:
        return theme.colorScheme.onSecondary;
      case RivoButtonVariant.outline:
      case RivoButtonVariant.text:
        return theme.colorScheme.primary;
      case RivoButtonVariant.danger:
        return theme.colorScheme.onError;
    }
  }

  BorderSide? _getBorderSide(ThemeData theme) {
    if (variant == RivoButtonVariant.outline) {
      return BorderSide(
        color: isDisabled ? theme.disabledColor : (color ?? theme.colorScheme.primary),
        width: 1.5,
      );
    }
    return null;
  }
}
