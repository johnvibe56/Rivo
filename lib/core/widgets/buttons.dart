library rivo_buttons;

/// A collection of customizable button widgets for the Rivo app.
/// 
/// This library provides a set of button widgets that follow the Rivo design system,
/// with support for different variants, states, and animations.

export 'rivo_button.dart';
export 'rivo_icon_button.dart';

/// The visual style of the button
enum ButtonVariant {
  /// A filled button with primary color background
  primary,
  
  /// A filled button with secondary color background
  secondary,
  
  /// An outlined button with transparent background
  outline,
  
  /// A text button with no background or border
  text,
  
  /// A filled button with error color background
  danger,
}
