import 'package:flutter/material.dart';

class AppDimens {
  // Spacing
  static const double spaceXXS = 2.0;
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 100.0;

  // Button
  static const double buttonHeight = 56.0;
  static const double buttonBorderRadius = 24.0;
  static const double buttonBorderWidth = 1.5;
  
  // App Bar
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0;
  
  // Bottom Navigation
  static const double bottomNavBarHeight = 72.0;
  static const double bottomNavBarElevation = 8.0;
  
  // Card
  static const double cardElevation = 0.0;
  static const double cardBorderRadius = 16.0;
  
  // Input Fields
  static const double inputBorderRadius = 12.0;
  static const double inputBorderWidth = 1.0;
  
  // Icons
  static const double iconSizeXS = 16.0;
  static const double iconSizeS = 20.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 40.0;
  
  // Product Card
  static const double productCardAspectRatio = 0.8;
  static const double productImageAspectRatio = 1.0;
  
  // Grid
  static const double gridSpacing = 16.0;
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 0.75;
  
  // Padding
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 16.0,
  );
  
  // Animation
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Curve animationCurve = Curves.easeInOut;
  
  // Divider
  static const double dividerThickness = 1.0;
  static const double dividerIndent = 16.0;
  static const double dividerEndIndent = 16.0;
  
  // Shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
  
  // Aspect Ratios
  static const double bannerAspectRatio = 16 / 9;
  static const double squareAspectRatio = 1.0;
  static const double wideAspectRatio = 16 / 9;
  
  // Loading Indicators
  static const double loadingIndicatorSize = 24.0;
  static const double loadingIndicatorStrokeWidth = 2.0;
}
