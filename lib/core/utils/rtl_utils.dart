import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A utility class for handling RTL (Right-to-Left) text direction and other RTL-specific utilities.
class RtlUtils {
  /// Returns the appropriate [TextDirection] based on the current locale.
  /// Defaults to [TextDirection.rtl] for Hebrew and Arabic.
  static TextDirection getTextDirection(String languageCode) {
    final rtlLanguages = {'he', 'ar', 'fa', 'ur', 'ps', 'sd', 'ug', 'yi'};
    return rtlLanguages.contains(languageCode.toLowerCase())
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  /// Returns the appropriate [TextAlign] based on the current locale.
  /// Defaults to [TextAlign.right] for RTL languages.
  static TextAlign getTextAlign(String languageCode) {
    return getTextDirection(languageCode) == TextDirection.rtl
        ? TextAlign.right
        : TextAlign.left;
  }

  /// Returns the appropriate [CrossAxisAlignment] for a row based on the current locale.
  static CrossAxisAlignment getCrossAxisAlignment(String languageCode) {
    return getTextDirection(languageCode) == TextDirection.rtl
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
  }

  /// Returns the appropriate [MainAxisAlignment] for a row based on the current locale.
  static MainAxisAlignment getMainAxisAlignment(String languageCode) {
    return getTextDirection(languageCode) == TextDirection.rtl
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;
  }

  /// Returns the appropriate [TextDirection] for the current context.
  static TextDirection getCurrentTextDirection(BuildContext context) {
    return Directionality.of(context);
  }

  /// Returns true if the current text direction is RTL.
  /// Returns true if the current text direction is RTL.
  static bool isRtl(BuildContext context) {
    return getCurrentTextDirection(context) == TextDirection.rtl;
  }

  /// Returns true if the given locale is an RTL language.
  static bool isRtlLocale(String languageCode) {
    final rtlLanguages = {'he', 'ar', 'fa', 'ur', 'ps', 'sd', 'ug', 'yi'};
    return rtlLanguages.contains(languageCode.toLowerCase());
  }

  /// Returns the appropriate [TextDirection] for the given language code.
  static TextDirection getTextDirectionForLanguageCode(String languageCode) {
    return isRtlLocale(languageCode) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Returns the appropriate [TextAlign] for the given language code.
  static TextAlign getTextAlignForLanguageCode(String languageCode) {
    return isRtlLocale(languageCode) ? TextAlign.right : TextAlign.left;
  }

  /// Returns the appropriate [Alignment] for the given language code.
  static Alignment getAlignmentForLanguageCode(String languageCode) {
    return isRtlLocale(languageCode) ? Alignment.centerRight : Alignment.centerLeft;
  }

  /// Returns the appropriate [CrossAxisAlignment] for a row based on the language code.
  static CrossAxisAlignment getCrossAxisAlignmentForLanguageCode(String languageCode) {
    return isRtlLocale(languageCode) 
        ? CrossAxisAlignment.end 
        : CrossAxisAlignment.start;
  }

  /// Returns the appropriate [MainAxisAlignment] for a row based on the language code.
  static MainAxisAlignment getMainAxisAlignmentForLanguageCode(String languageCode) {
    return isRtlLocale(languageCode)
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;
  }

  /// Sets the system UI overlay style based on the current locale.
  static void setSystemUIOverlayStyle(BuildContext context) {
    // In newer Flutter versions, we can only control top and bottom overlays
    // Left/right overlays are not directly controllable
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ],
    );
  }

  /// Returns the appropriate [EdgeInsets] for padding based on the current locale.
  static EdgeInsetsDirectional getDirectionalPadding({
    required BuildContext context,
    double start = 0.0,
    double top = 0.0,
    double end = 0.0,
    double bottom = 0.0,
  }) {
    return isRtl(context)
        ? EdgeInsetsDirectional.only(
            start: end,
            top: top,
            end: start,
            bottom: bottom,
          )
        : EdgeInsetsDirectional.only(
            start: start,
            top: top,
            end: end,
            bottom: bottom,
          );
  }

  /// Returns the appropriate [Alignment] for positioning based on the current locale.
  static Alignment getAlignment(String languageCode) {
    return getTextDirection(languageCode) == TextDirection.rtl
        ? Alignment.centerRight
        : Alignment.centerLeft;
  }

  /// Returns the appropriate [TextDirection] for a given string.
  /// This is a simple heuristic and may not be 100% accurate.
  static TextDirection estimateDirectionOfText(String text) {
    if (text.isEmpty) return TextDirection.ltr;
    
    // Check for RTL characters (Hebrew, Arabic, etc.)
    final rtlRegex = RegExp(r'[\u0591-\u07FF\uFB1D-\uFEFE]');
    return rtlRegex.hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Wraps a widget with a [Directionality] widget if needed.
  static Widget withDirectionality({
    required Widget child,
    TextDirection textDirection = TextDirection.rtl,
  }) {
    return Directionality(
      textDirection: textDirection,
      child: child,
    );
  }

  /// Returns the appropriate [TextDirection] for a given locale.
  static TextDirection getTextDirectionForLocale(Locale locale) {
    return getTextDirection(locale.languageCode);
  }

  /// Returns the appropriate [TextAlign] for a given locale.
  static TextAlign getTextAlignForLocale(Locale locale) {
    return getTextAlign(locale.languageCode);
  }

  /// Returns the appropriate [CrossAxisAlignment] for a row based on the given locale.
  static CrossAxisAlignment getCrossAxisAlignmentForLocale(Locale locale) {
    return getCrossAxisAlignment(locale.languageCode);
  }

  /// Returns the appropriate [MainAxisAlignment] for a row based on the given locale.
  static MainAxisAlignment getMainAxisAlignmentForLocale(Locale locale) {
    return getMainAxisAlignment(locale.languageCode);
  }

  /// Returns the appropriate [Alignment] for positioning based on the given locale.
  static Alignment getAlignmentForLocale(Locale locale) {
    return getAlignment(locale.languageCode);
  }
}
