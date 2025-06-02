import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveUtils {
  // Screen size breakpoints based on Material Design guidelines
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Check device type based on screen width
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // Responsive padding/margin
  static EdgeInsetsGeometry responsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h);
    } else if (isTablet(context)) {
      return EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h);
    } else {
      return EdgeInsets.symmetric(horizontal: 64.w, vertical: 16.h);
    }
  }

  // Responsive text scale factor
  static double responsiveTextScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 1.0;
    } else if (width < tabletBreakpoint) {
      return 1.1;
    } else {
      return 1.2;
    }
  }

  // Responsive grid layout
  static int responsiveGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) {
      return 2; // 2 columns on mobile
    } else if (isTablet(context)) {
      return 3; // 3 columns on tablet
    } else {
      return 4; // 4 columns on desktop
    }
  }

  // Responsive item extent for grid view
  static double responsiveGridChildAspectRatio(BuildContext context) {
    if (isMobile(context)) {
      return 0.7; // Taller items on mobile
    } else if (isTablet(context)) {
      return 0.8; // Slightly shorter on tablet
    } else {
      return 0.9; // More square on desktop
    }
  }

  // Responsive icon size
  static double responsiveIconSize(BuildContext context) {
    if (isMobile(context)) {
      return 24.0;
    } else if (isTablet(context)) {
      return 28.0;
    } else {
      return 32.0;
    }
  }

  // Responsive button height
  static double responsiveButtonHeight(BuildContext context) {
    if (isMobile(context)) {
      return 44.0;
    } else if (isTablet(context)) {
      return 48.0;
    } else {
      return 52.0;
    }
  }

  // Responsive border radius
  static double responsiveBorderRadius(BuildContext context) {
    if (isMobile(context)) {
      return 12.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 20.0;
    }
  }

  // Responsive elevation
  static double responsiveElevation(BuildContext context) {
    if (isMobile(context)) {
      return 2.0;
    } else if (isTablet(context)) {
      return 3.0;
    } else {
      return 4.0;
    }
  }

  // Responsive spacing between widgets
  static double responsiveSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 8.0;
    } else if (isTablet(context)) {
      return 12.0;
    } else {
      return 16.0;
    }
  }

  // Responsive font size
  static double responsiveFontSize(
    BuildContext context, {
    double mobile = 14.0,
    double? tablet,
    double? desktop,
  }) {
    if (isTablet(context)) {
      return tablet ?? mobile * 1.2;
    } else if (isDesktop(context)) {
      return desktop ?? mobile * 1.4;
    }
    return mobile;
  }

  // Responsive width percentage
  static double responsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  // Responsive height percentage
  static double responsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  // Check if device is in landscape mode
  static bool isLandscapeMode(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  // Get keyboard height
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  // Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return getKeyboardHeight(context) > 0;
  }

  // Get screen size
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  // Get screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Get screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Get screen aspect ratio
  static double getScreenAspectRatio(BuildContext context) {
    return MediaQuery.of(context).size.aspectRatio;
  }

  // Get pixel ratio
  static double getPixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  // Get text scale factor
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }

  // Get view padding
  static EdgeInsets getViewPadding(BuildContext context) {
    return MediaQuery.of(context).viewPadding;
  }

  // Get view insets
  static EdgeInsets getViewInsets(BuildContext context) {
    return MediaQuery.of(context).viewInsets;
  }

  // Get system gesture insets
  static EdgeInsets getSystemGestureInsets(BuildContext context) {
    return MediaQuery.of(context).systemGestureInsets;
  }

  // Get padding for bottom navigation bar
  static EdgeInsets getBottomNavigationBarPadding(BuildContext context) {
    return EdgeInsets.only(
      bottom: MediaQuery.of(context).padding.bottom,
    );
  }

  // Get padding for floating action button
  static EdgeInsets getFloatingActionButtonPadding(BuildContext context) {
    return EdgeInsets.only(
      bottom: MediaQuery.of(context).padding.bottom + 16.0,
    );
  }

  // Get padding for bottom sheet
  static EdgeInsets getBottomSheetPadding(BuildContext context) {
    return EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
    );
  }

  // Get padding for keyboard
  static EdgeInsets getKeyboardPadding(BuildContext context) {
    return EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
    );
  }

  // Get padding for status bar
  static EdgeInsets getStatusBarPadding(BuildContext context) {
    return EdgeInsets.only(
      top: MediaQuery.of(context).padding.top,
    );
  }

  // Get padding for app bar
  static EdgeInsets getAppBarPadding(BuildContext context) {
    return EdgeInsets.only(
      top: MediaQuery.of(context).padding.top,
    );
  }

  // Get padding for safe area
  static EdgeInsets getSafeAreaPaddingForViewport({
    required BuildContext context,
    bool top = true,
    bool right = true,
    bool bottom = true,
    bool left = true,
  }) {
    final padding = MediaQuery.of(context).padding;
    return EdgeInsets.only(
      top: top ? padding.top : 0.0,
      right: right ? padding.right : 0.0,
      bottom: bottom ? padding.bottom : 0.0,
      left: left ? padding.left : 0.0,
    );
  }
}
