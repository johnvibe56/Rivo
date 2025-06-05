import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Defines the visual style of the button
enum AppButtonVariant {
  /// A filled button with primary color background
  primary,
  
  /// A filled button with secondary color background
  secondary,
  
  /// A text button with no background or border
  text,
  
  /// A filled button with error color background
  danger,
  
  /// An outlined button with transparent background
  outlined,
}

/// A reusable button component that supports multiple variants, loading states, and RTL.
class AppButton extends StatelessWidget {
  /// Creates a primary button
  factory AppButton.primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool fullWidth = false,
    EdgeInsetsGeometry? padding,
    double height = 48.0,
    double borderRadius = 12.0,
    bool enableHapticFeedback = true,
  }) {
    return AppButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: AppButtonVariant.primary,
      icon: icon,
      fullWidth: fullWidth,
      padding: padding,
      height: height,
      borderRadius: borderRadius,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Creates a secondary button
  factory AppButton.secondary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool fullWidth = false,
    EdgeInsetsGeometry? padding,
    double height = 48.0,
    double borderRadius = 12.0,
    bool enableHapticFeedback = true,
  }) {
    return AppButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: AppButtonVariant.secondary,
      icon: icon,
      fullWidth: fullWidth,
      padding: padding,
      height: height,
      borderRadius: borderRadius,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Creates a danger button
  factory AppButton.danger({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool fullWidth = false,
    EdgeInsetsGeometry? padding,
    double height = 48.0,
    double borderRadius = 12.0,
    bool enableHapticFeedback = true,
  }) {
    return AppButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: AppButtonVariant.danger,
      icon: icon,
      fullWidth: fullWidth,
      padding: padding,
      height: height,
      borderRadius: borderRadius,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Creates a text button
  factory AppButton.text({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool fullWidth = false,
    EdgeInsetsGeometry? padding,
    double height = 48.0,
    double borderRadius = 12.0,
    bool enableHapticFeedback = true,
  }) {
    return AppButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: AppButtonVariant.text,
      icon: icon,
      fullWidth: fullWidth,
      padding: padding,
      height: height,
      borderRadius: borderRadius,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Creates an outlined button
  factory AppButton.outlined({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    bool fullWidth = false,
    EdgeInsetsGeometry? padding,
    double height = 48.0,
    double borderRadius = 12.0,
    bool enableHapticFeedback = true,
  }) {
    return AppButton._(
      key: key,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: AppButtonVariant.outlined,
      icon: icon,
      fullWidth: fullWidth,
      padding: padding,
      height: height,
      borderRadius: borderRadius,
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Creates an icon button
  factory AppButton.icon({
    Key? key,
    required IconData icon,
    required String tooltip,
    VoidCallback? onPressed,
    bool isLoading = false,
    double size = 40.0,
    double iconSize = 24.0,
    AppButtonVariant variant = AppButtonVariant.primary,
    bool enableHapticFeedback = true,
  }) {
    return AppButton._(
      key: key,
      label: '',
      onPressed: onPressed,
      isLoading: isLoading,
      variant: variant,
      icon: icon,
      height: size,
      padding: const EdgeInsets.all(8.0),
      enableHapticFeedback: enableHapticFeedback,
    );
  }

  /// Creates a new [AppButton].
  const AppButton._({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.fullWidth = false,
    this.padding,
    this.height = 48.0,
    this.borderRadius = 12.0,
    this.enableHapticFeedback = true,
  });

  /// The text label of the button
  final String label;

  /// Callback when the button is pressed
  final VoidCallback? onPressed;

  /// Whether to show a loading indicator
  final bool isLoading;

  /// The visual style of the button
  final AppButtonVariant variant;

  /// Optional icon to display
  final IconData? icon;

  /// Whether the button should expand to fill available width
  final bool fullWidth;
  
  /// Custom padding
  final EdgeInsetsGeometry? padding;
  
  /// Button height
  final double height;
  
  /// Border radius
  final double borderRadius;
  
  /// Whether to enable haptic feedback
  final bool enableHapticFeedback;

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);
    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 24);

    // Determine button style based on variant
    final buttonStyle = _getButtonStyle(context);

    // Build the button child
    Widget buttonChild = _buildButtonChild(theme, isRTL);

    // Apply full width if needed
    if (fullWidth) {
      buttonChild = SizedBox(
        width: double.infinity,
        height: height,
        child: buttonChild,
      );
    } else {
      buttonChild = SizedBox(
        height: height,
        child: buttonChild,
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? _buildLoadingButton(theme, buttonStyle, effectivePadding)
          : _buildInteractiveButton(buttonChild, buttonStyle, effectivePadding, context),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Calculate colors with proper opacity
    final onSurface = colorScheme.onSurface.withAlpha(30);
    final onSurfaceDisabled = colorScheme.onSurface.withAlpha(96);

    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: onSurface,
          disabledForegroundColor: onSurfaceDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      case AppButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          disabledBackgroundColor: onSurface,
          disabledForegroundColor: onSurfaceDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      case AppButtonVariant.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          disabledForegroundColor: onSurfaceDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      case AppButtonVariant.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.error,
          foregroundColor: colorScheme.onError,
          disabledBackgroundColor: onSurface,
          disabledForegroundColor: onSurfaceDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      case AppButtonVariant.text:
        return TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          disabledForegroundColor: onSurfaceDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
    }
  }

  Widget _buildButtonChild(ThemeData theme, bool isRTL) {
    final buttonChildren = <Widget>[];

    // Add icon if provided
    if (icon != null) {
      buttonChildren.add(
        Icon(icon, size: 20),
      );
      buttonChildren.add(const SizedBox(width: 8));
    }

    // Add label
    buttonChildren.add(Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ));

    // Handle RTL
    final effectiveChildren = isRTL ? buttonChildren.reversed.toList() : buttonChildren;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: effectiveChildren,
    );
  }

  Widget _buildLoadingButton(ThemeData theme, ButtonStyle buttonStyle, EdgeInsetsGeometry padding) {
    return ElevatedButton(
      onPressed: null,
      style: buttonStyle.copyWith(
        padding: WidgetStateProperty.all(padding),
      ),
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getLoadingIndicatorColor(theme),
          ),
        ),
      ),
    );
  }

  Color _getLoadingIndicatorColor(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    switch (variant) {
      case AppButtonVariant.primary:
        return colorScheme.onPrimary;
      case AppButtonVariant.secondary:
        return colorScheme.onSecondary;
      case AppButtonVariant.danger:
        return colorScheme.onError;
      case AppButtonVariant.outlined:
      case AppButtonVariant.text:
        return colorScheme.primary;
    }
  }

  Widget _buildInteractiveButton(Widget child, ButtonStyle buttonStyle, EdgeInsetsGeometry padding, BuildContext context) {
    final effectiveOnPressed = onPressed == null
        ? null
        : () {
            if (enableHapticFeedback) {
              HapticFeedback.lightImpact();
            }
            onPressed!();
          };

    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
      case AppButtonVariant.danger:
        return ElevatedButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle.copyWith(
            padding: WidgetStateProperty.all(padding),
          ),
          child: child,
        );
      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle.copyWith(
            padding: WidgetStateProperty.all(padding),
          ),
          child: child,
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: effectiveOnPressed,
          style: buttonStyle.copyWith(
            padding: WidgetStateProperty.all(padding),
          ),
          child: child,
        );
    }
  }
}
